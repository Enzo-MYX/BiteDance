package org.example;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;
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
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MyBot implements LongPollingSingleThreadUpdateConsumer {
    private final String botToken;
    private final OkHttpTelegramClient telegramClient; // The client to execute API calls
    private final List<Event> eventsList;
    private final Map<String, Integer> latestEventIndex = new HashMap<>();
    private final Map<String, List<BufferedMessage>> messageBuffer = new HashMap<>();

    private static class MediaReference {
        final String fileId;
        final String type; // "photo", "video", "animation"
        final long chatId;
        final long timestamp;

        MediaReference(String fileId, String type, long chatId, long timestamp) {
            this.fileId = fileId;
            this.type = type;
            this.chatId = chatId;
            this.timestamp = timestamp;
        }
    }

    private static class BufferedMessage {
        final String text;
        final List<MediaReference> mediaRefs;
        final long timestamp;

        BufferedMessage(String text, List<MediaReference> mediaRefs, long timestamp) {
            this.text = text;
            this.mediaRefs = new ArrayList<>(mediaRefs);
            this.timestamp = timestamp;
        }
    }

    public MyBot(String botToken) {
        this.botToken = botToken;
        this.telegramClient = new OkHttpTelegramClient(botToken);
        this.eventsList = loadEventsFromJson();
        rebuildIndexMap();
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

    private void rebuildIndexMap() {
        latestEventIndex.clear();
        for (int i = 0; i< eventsList.size(); i++) {
            latestEventIndex.put(eventsList.get(i).uploader, i);
        }
    }

    private void addEvent(Event event, String msg) {
        eventsList.add(event);
        latestEventIndex.put(event.uploader, event.id);
        saveEventsToJson(eventsList);
        System.out.println("Sent! Parsed location:" + msg);
    }

    private Event getLatestEvent(String userName) {
        Integer idx = latestEventIndex.get(userName);
        return idx == null ? null : eventsList.get(idx);
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

    private static final String ALPHANUMERIC="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    private static final SecureRandom RANDOM=new SecureRandom();
    public static String randomAlphanumeric(int length) {
        StringBuilder sb = new StringBuilder(length);
        for (int i=0; i<length; i++) {
            sb.append(ALPHANUMERIC.charAt(RANDOM.nextInt(ALPHANUMERIC.length())));
        }
        return sb.toString();
    }

    private String downloadMedia(String fileId, String extension, long chatId, long timestamp) throws TelegramApiException, IOException {
        GetFile getFile = GetFile.builder().fileId(fileId).build();
        org.telegram.telegrambots.meta.api.objects.File telegramFile = telegramClient.execute(getFile);
        String uniqueId = randomAlphanumeric(8);
        String fileName = chatId + "_" + timestamp + "_" + uniqueId + "." + extension; // formatted in chatId_timestamp_FileId. mp4/jpg/gif
        Path targetPath = Paths.get("images/", fileName);
        try (InputStream inputStream = telegramClient.downloadFileAsStream(telegramFile)) {
            Files.createDirectories(targetPath.getParent());
            Files.copy(inputStream, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }
        return "/images/" + fileName;
    }

    @Override
    public void consume(Update update) {
        if (!update.hasMessage()) return;
        Message msg = update.getMessage();
        if (!msg.hasText() && !msg.hasCaption() && !msg.hasPhoto() && !msg.hasAnimation() && !msg.hasVideo()) return; // blocking out empty updates; temporary fix
        long chatId = msg.getChatId();
        String userName = msg.getFrom().getUserName();
        Long time = msg.getDate().longValue() + 28800L;

        String messageText = msg.hasText() ? msg.getText() : msg.getCaption();
//        if ("/start".equals(messageText)) {
//            String welcomeText = String.format("Hello @%s! Enter /help to see the list of commands for this bot.", userName);
//            SendMessage message = SendMessage.builder()
//                    .chatId(chatId)
//                    .text(welcomeText)
//                    .build();
//            try {
//                telegramClient.execute(message);
//            } catch (TelegramApiException e) {
//                e.printStackTrace();
//            }
//        }
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
        java.util.function.BiConsumer<Event, List<MediaReference>> mergeContent = (event, refs) -> {
            if (messageText != null && !messageText.isEmpty()) {
                event.txt += "\n----------\n" + messageText;
            }
            List<String> urls = downloadMediaRefs(refs);
            event.mediaUrls.addAll(urls);
        };

        if (keyword != "") { // The case for messages w/ location indicators
            Coordinates coords = LocationMapper.getCoordinates(keyword);
            Event newEvent = new Event(eventsList.size(), messageText.hashCode(), userName, time, messageText, parsed, coords.getLat(), coords.getLon(), new ArrayList<>());
            // Check for recent event from same user (5 min, 100m)
            Event existing = getLatestEvent(userName);
            boolean merged = false;
            if (newEvent.isSameEvent(existing)) {
                existing.txt += "\n----------\n" + messageText;
                List<String> urls = downloadMediaRefs(mediaRefs);
                existing.mediaUrls.addAll(urls);
                merged = true;
            } else {
                List<String> urls = downloadMediaRefs(mediaRefs);
                newEvent.mediaUrls.addAll(urls);
                addEvent(newEvent, keyword);
            }
            Event targetEvent = merged ? existing : newEvent;

            // Compiling possible bufferMessages to the new event
            List<BufferedMessage> buffers = messageBuffer.getOrDefault(userName, new ArrayList<>());
            List<BufferedMessage> toRemove = new ArrayList<>();
            for (BufferedMessage bm : buffers) {
                if (time - bm.timestamp <= 900 && time - bm.timestamp >= 0) {
                    if (bm.text != null && !bm.text.isEmpty()) {
                        targetEvent.txt += "\n----------\n" + bm.text;
                    }
                    List<String> urls = downloadMediaRefs(bm.mediaRefs);
                    targetEvent.mediaUrls.addAll(urls);
                    toRemove.add(bm);
                }
            }
            buffers.removeAll(toRemove);
            if (buffers.isEmpty()) {
                messageBuffer.remove(userName);
            } else {
                messageBuffer.put(userName, buffers);
            }
            // Save after all merges
            saveEventsToJson(eventsList);
            System.out.println("Processed event for " + userName + (merged ? " (merged)" : " (new)"));
        } else {
            // The case for messages w/o locations or media only
            Event recent = getLatestEvent(userName);
            if (recent != null && (time - recent.time <= 900)) {
                mergeContent.accept(recent, mediaRefs);
                saveEventsToJson(eventsList);
                System.out.println("Merged non‑event message into recent event of " + userName);
            } else {
                BufferedMessage bm = new BufferedMessage(messageText, mediaRefs, time);
                messageBuffer.computeIfAbsent(userName, k -> new ArrayList<>()).add(bm);
                System.out.println("Buffered message from " + userName);
            }
        }
    }
}