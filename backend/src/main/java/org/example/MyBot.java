package org.example;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.sun.net.httpserver.HttpServer;
import org.telegram.telegrambots.client.okhttp.OkHttpTelegramClient;
import org.telegram.telegrambots.longpolling.util.LongPollingSingleThreadUpdateConsumer;
import org.telegram.telegrambots.meta.api.methods.GetFile;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.PhotoSize;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.api.objects.message.Message;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class MyBot implements LongPollingSingleThreadUpdateConsumer, AutoCloseable {
    private final String botToken;
    private final long ownerId;
    private final OkHttpTelegramClient telegramClient; // The client to execute API calls
    private final List<Event> eventsList;
    private final Map<String, Integer> latestEventIndex = new HashMap<>();
    private final Map<String, List<BufferedMessage>> messageBuffer = new HashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();

    public MyBot(String botToken) {
        this.botToken = botToken;
        this.telegramClient = new OkHttpTelegramClient(botToken);
        this.eventsList = loadEventsFromJson();
        rebuildIndexMap();
        long tempOwnerId = 0;
        String ownerIdStr = System.getenv("BOT_OWNER_ID");
        if (ownerIdStr == null || ownerIdStr.isEmpty()) {
            System.err.println("ERROR: BOT_OWNER_ID environment variable not set. 'Clear all' command will be disabled.");
        } else {
            try {
                tempOwnerId = Long.parseLong(ownerIdStr);
            } catch (NumberFormatException e) {
                System.err.println("ERROR: BOT_OWNER_ID must be a numeric Telegram user ID.");
            }
        }
        ownerId = tempOwnerId;
        scheduler.scheduleAtFixedRate(this::cleanExpiredEvents, 24, 24, TimeUnit.HOURS);
    }

    @Override
    public void close() {
        scheduler.shutdownNow();
        try {
            if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                System.err.println("Scheduler did not shut down gracefully.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private record MessageContext(long chatId, String userName, long time, String text, List<MediaReference> mediaRefs,
                                  String keyword, String parsedLocation) {}

    private static class MediaReference {
        public final String fileId;
        public final String type;
        public final long chatId;
        public final long timestamp;

        MediaReference(String fileId, String type, long chatId, long timestamp) {
            this.fileId = fileId;
            this.type = type;
            this.chatId = chatId;
            this.timestamp = timestamp;
        }
    }

    private static class BufferedMessage {
        public final String text;
        public final List<MediaReference> mediaRefs;
        public final long timestamp;

        BufferedMessage(String text, List<MediaReference> mediaRefs, long timestamp) {
            this.text = text;
            this.mediaRefs = new ArrayList<>(mediaRefs);
            this.timestamp = timestamp;
        }
    }

    // loads events.json file to https server
    public void startHttpServer() throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/events", exchange -> {
            try {
                File jsonFile = new File("events.json");
                if (!jsonFile.exists()) {
                    String empty = "[]";
                    exchange.getResponseHeaders().set("Content-Type", "application/json");
                    exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
                    exchange.sendResponseHeaders(200, empty.getBytes().length);
                    exchange.getResponseBody().write(empty.getBytes());
                    exchange.getResponseBody().close();
                    return;
                }
                byte[] jsonBytes = Files.readAllBytes(jsonFile.toPath());
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
                exchange.sendResponseHeaders(200, jsonBytes.length);
                exchange.getResponseBody().write(jsonBytes);
                exchange.getResponseBody().close();
            } catch (Exception e) {
                e.printStackTrace();
                exchange.sendResponseHeaders(500, -1);
            }
        });

        // servers images and other media from the 'images/' folder
        server.createContext("/images/", exchange -> {
            String path = exchange.getRequestURI().getPath();
            try {
                File imageFile = new File("." + path);
                if (imageFile.exists() && !imageFile.isDirectory()) {
                    byte[] imageBytes = Files.readAllBytes(imageFile.toPath());
                    String contentType = getMimeType(path);
                    exchange.getResponseHeaders().set("Content-Type", contentType);
                    exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
                    exchange.sendResponseHeaders(200, imageBytes.length);
                    exchange.getResponseBody().write(imageBytes);
                } else {
                    exchange.sendResponseHeaders(404, -1);
                }
                exchange.getResponseBody().close();
            } catch (Exception e) {
                e.printStackTrace();
                exchange.sendResponseHeaders(500, -1);
            }
        });

        server.setExecutor(null);
        server.start();
        System.out.println("HTTP Server started on port 8080");
    }

    private String getMimeType(String path) {
        if (path.endsWith(".jpg")) return "image/jpeg";
        if (path.endsWith(".gif")) return "image/gif";
        if (path.endsWith(".mp4")) return "video/mp4";
        return "application/octet-stream";
    }

    private static List<Event> loadEventsFromJson() {
        File file = new File("events.json");
        if (!file.exists()) return new ArrayList<>();
        ObjectMapper mapper = JsonMapper.builder().addModule(new JavaTimeModule()).build();
        try {
            return mapper.readValue(file, new TypeReference<List<Event>>() {});
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private void saveEventsToJson(List<Event> events) {
        ObjectMapper mapper = JsonMapper.builder().addModule(new JavaTimeModule()).build();
        try {
            mapper.writerWithDefaultPrettyPrinter().writeValue(new File("events.json"), events); // Pretty print for more readable output
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private synchronized void rebuildIndexMap() {
        latestEventIndex.clear();
        for (int i = 0; i< eventsList.size(); i++) {
            latestEventIndex.put(eventsList.get(i).uploader, i);
        }
    }

    private synchronized void addEvent(Event event) {
        eventsList.add(event);
        latestEventIndex.put(event.uploader, event.id);
        saveEventsToJson(eventsList);
    }

    private synchronized Event getLatestEvent(String userName) {
        Integer idx = latestEventIndex.get(userName);
        return idx == null ? null : eventsList.get(idx);
    }

    private synchronized void updateEvent(Event newEvent) {
        eventsList.set(newEvent.id, newEvent);
        saveEventsToJson(eventsList);
    }

    private static String hashString(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    private List<String> downloadMediaRefs(List<MediaReference> refs) {
        List<String> urls = new ArrayList<>();
        for (MediaReference ref : refs) {
            try {
                String ext;
                switch (ref.type) {
                    case "photo": ext = "jpg"; break;
                    case "video": ext = "mp4"; break;
                    case "animation": ext = "gif"; break;
                    default: continue;
                }
                String url = downloadMedia(ref.fileId, ext, ref.chatId, ref.timestamp);
                urls.add(url);
            } catch (TelegramApiException | IOException e) {
                e.printStackTrace();
            }
        }
        return urls;
    }

    private String downloadMedia(String fileId, String extension, long chatId, long timestamp) throws TelegramApiException, IOException {
        String fileHash = hashString(fileId);
        String fileName = chatId + "_" + timestamp + "_" + fileHash + "." + extension; // formatted in chatId_timestamp_FileId. mp4/jpg/gif
        Path targetPath = Paths.get("images/", fileName);
        if (Files.exists(targetPath)) {
            System.out.println("Reusing exisiting file: "+fileName);
            return "/images/"+fileName;
        }
        GetFile getFile = GetFile.builder().fileId(fileId).build();
        org.telegram.telegrambots.meta.api.objects.File telegramFile = telegramClient.execute(getFile);

        try (InputStream inputStream = telegramClient.downloadFileAsStream(telegramFile)) {
            Files.createDirectories(targetPath.getParent());
            Files.copy(inputStream, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }
        return "/images/" + fileName;
    }

    private void deleteMediaFiles(List<String> mediaUrls) {
        for (String url : mediaUrls) {
            String fileName=url.startsWith("/")?url.substring(1):url;
            Path filePath=Paths.get(fileName);
            try {
                Files.deleteIfExists(filePath);
            } catch (IOException e) {
                System.err.println("Failed to delete file: "+fileName);
                e.printStackTrace();
            }
        }
    }

    private void deleteAllMedia() {
        Path imagesDir=Paths.get("images/");
        if (Files.exists(imagesDir)) {
            try (var stream=Files.walk(imagesDir)) {
                stream.filter(Files::isRegularFile).forEach(path->{
                            try {Files.deleteIfExists(path);}
                            catch (IOException e) {e.printStackTrace();}
                        });
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void sendMessage(long chatId, String text) {
        SendMessage message = SendMessage.builder()
                .chatId(chatId)
                .text(text)
                .build();
        try {
            telegramClient.execute(message);
        } catch (TelegramApiException e) {
            e.printStackTrace();
        }
    }

    private synchronized void handleClearAll(long chatId) {
        deleteAllMedia();
        eventsList.clear();
        latestEventIndex.clear();
        messageBuffer.clear();
        saveEventsToJson(eventsList);
        sendMessage(chatId, "All events and media have been cleared.");
        System.out.println("Cleared all events and media.");
    }

    private void handleCleanExpired(long chatId) {
        int removed = cleanExpiredEvents();
        if (removed==0) {
            sendMessage(chatId, "No expired events found.");
        }
        else {
            sendMessage(chatId, "Cleaned " + removed + " expired events and their media.");
        }
    }

    private synchronized int cleanExpiredEvents() {
        long now = System.currentTimeMillis()/1000+28800;
        long expiryThreshold = 86400;
        List<Event> expired = new ArrayList<>();
        for (Event e : eventsList) {
            if (now - e.time > expiryThreshold) {
                expired.add(e);
            }
        }
        if (expired.isEmpty()) return 0;
        for (Event e : expired) {
            deleteMediaFiles(e.mediaUrls);
        }
        eventsList.removeAll(expired);
        List<Event> reindexed = new ArrayList<>();
        for (int i = 0; i < eventsList.size(); i++) {
            Event old = eventsList.get(i);
            Event updated = new Event(i, old.hash, old.uploader, old.time, old.txt, old.location, old.lat, old.lon, old.mediaUrls);
            reindexed.add(updated);
        }
        eventsList.clear();
        eventsList.addAll(reindexed);
        rebuildIndexMap();
        saveEventsToJson(eventsList);
        System.out.println("Performed regular cleanup: removed " + expired.size() + " expired events.");
        return expired.size();
    }

    private MessageContext extractMessageContext(Message msg) {
        long chatId = msg.getChatId();
        String userName = msg.getFrom().getUserName();
        Long time = msg.getDate().longValue() + 28800L;

        String messageText = msg.hasText() ? msg.getText() : msg.getCaption();
        boolean hasWord = messageText != null;
        String keyword = hasWord ? Parser.keywordDetect(messageText) : "";
        String parsed = hasWord ? Parser.parseFromInfo(messageText) : "";

        List<MediaReference> mediaRefs = new ArrayList<>();
        if (msg.getPhoto() != null && !msg.getPhoto().isEmpty()) {
            PhotoSize photo = msg.getPhoto().get(msg.getPhoto().size() - 1);
            mediaRefs.add(new MediaReference(photo.getFileId(), "photo", chatId, time));
        }
        if (msg.getVideo() != null) {
            mediaRefs.add(new MediaReference(msg.getVideo().getFileId(), "video", chatId, time));
        }
        if (msg.getAnimation() != null) {
            mediaRefs.add(new MediaReference(msg.getAnimation().getFileId(), "animation", chatId, time));
        }

        return new MessageContext(chatId, userName, time, messageText, mediaRefs, keyword, parsed);
    }

    private void processBufferedMessages(String username, Event targetEvent, long currentTime) {
        List<BufferedMessage> buffers = messageBuffer.getOrDefault(username, new ArrayList<>());
        Event temp = targetEvent;
        for (BufferedMessage bm : buffers) {
            long diff = currentTime - bm.timestamp;
            if (diff >= 0 && diff <= 900) {
                List<String> urls = downloadMediaRefs(bm.mediaRefs);
                temp = temp.merge(bm.text, urls);
            }
        }
        updateEvent(temp);
        buffers.clear();
        messageBuffer.remove(username);
    }

    private void handleLocationMessage(MessageContext ctx) {
        Coordinates coords = LocationMapper.getCoordinates(ctx.keyword);
        Event newEvent = new Event(eventsList.size(),
                ctx.text.hashCode(),
                ctx.userName,
                ctx.time,
                ctx.text,
                ctx.parsedLocation,
                coords.getLat(),
                coords.getLon(),
                new ArrayList<>());

        Event existing = getLatestEvent(ctx.userName);
        Event target;
        boolean merged;

        if (existing != null && newEvent.isSameEvent(existing)) {
            List<String> urls = downloadMediaRefs(ctx.mediaRefs);
            target = existing.merge(ctx.text, urls);
            updateEvent(target);
            merged = true;
        } else {
            List<String> urls = downloadMediaRefs(ctx.mediaRefs);
            newEvent = newEvent.merge(null, urls);//downloads the media for newEvent
            addEvent(newEvent);
            target = newEvent;
            merged = false;
        }
        processBufferedMessages(ctx.userName, target, ctx.time);
        saveEventsToJson(eventsList);
        System.out.println("Processed event for " + ctx.userName + (merged ? " (merged)" : " (new)"));
    }

    private void handleNonLocationMessage(MessageContext ctx) {
        Event recent = getLatestEvent(ctx.userName);
        if (recent != null && (ctx.time - recent.time <= 900)) {//merge into recent event
            List<String> urls = downloadMediaRefs(ctx.mediaRefs);
            Event merged = recent.merge(ctx.text, urls);
            updateEvent(merged);
            System.out.println("Merged non‑event message into recent event of " + ctx.userName);
        } else {//buffer the message
            BufferedMessage bm = new BufferedMessage(ctx.text, ctx.mediaRefs, ctx.time);
            messageBuffer.computeIfAbsent(ctx.userName, k -> new ArrayList<>()).add(bm);
            System.out.println("Buffered message from " + ctx.userName);
        }
    }

    private void handleEditedMessage(Message msg) {
        String userName = msg.getFrom().getUserName();
        long time = msg.getDate().longValue() + 28800L;
        long chatId = msg.getChatId();
        Event recent = getLatestEvent(userName);
        if (recent==null||time-recent.time>86400) {
            System.out.println("Too late! Discarded message because no recent event");
            return;
        }
        String messageText = msg.hasText() ? msg.getText() : msg.getCaption();
        if (messageText==null||messageText.isEmpty()) return;
        List<MediaReference> mediaRefs = new ArrayList<>();
        if (msg.getPhoto() != null && !msg.getPhoto().isEmpty()) {
            PhotoSize photo = msg.getPhoto().get(msg.getPhoto().size() - 1);
            mediaRefs.add(new MediaReference(photo.getFileId(), "photo", chatId, time));
        }
        if (msg.getVideo() != null) {
            mediaRefs.add(new MediaReference(msg.getVideo().getFileId(), "video", chatId, time));
        }
        if (msg.getAnimation() != null) {
            mediaRefs.add(new MediaReference(msg.getAnimation().getFileId(), "animation", chatId, time));
        }
        List<String> urls = downloadMediaRefs(mediaRefs);
        String mergeText = "Edited: " + messageText;
        Event merged = recent.merge(mergeText, urls);
        updateEvent(merged);
        System.out.println("Merged edited message into event by " + userName);
    }

    @Override
    public void consume(Update update) {
        if (update.hasEditedMessage()) {
            handleEditedMessage(update.getEditedMessage());
            return;
        }
        if (!update.hasMessage()) return;
        Message msg = update.getMessage();
        if (!msg.hasText() && !msg.hasCaption() && !msg.hasPhoto() && !msg.hasAnimation() && !msg.hasVideo()) return; // blocking out empty updates; temporary fix
        if (msg.hasText()) {
            String text = msg.getText().trim();
            long chatId = msg.getChatId();
            long senderId = msg.getFrom().getId();
            if (text.equalsIgnoreCase("clear all")) {
                if (ownerId == 0 || senderId != ownerId) {
                    sendMessage(chatId, "LMAO Get rekt you can't use this command\nL Bozo");
                    return;
                }
                handleClearAll(chatId);
                return;
            }
            if (text.equalsIgnoreCase("clean expired")) {
                handleCleanExpired(chatId);
                return;
            }
        }
        MessageContext ctx = extractMessageContext(msg);
        if (!ctx.keyword.isEmpty()) {
            handleLocationMessage(ctx);
        } else {
            handleNonLocationMessage(ctx);
        }
    }
}