package org.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
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
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;

public class MyBot implements LongPollingSingleThreadUpdateConsumer {
    private final String botToken;
    private final OkHttpTelegramClient telegramClient; // The client to execute API calls
    private final List<Event> eventsList = new ArrayList<>();

    public MyBot(String botToken) {
        this.botToken = botToken;
        this.telegramClient = new OkHttpTelegramClient(botToken);
    }

    private void saveEventsToJson(List<Event> events) {
        ObjectMapper mapper = JsonMapper.builder().addModule(new JavaTimeModule()).build();
        try {
            mapper.writeValue(new File("events.json"), events);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String downloadMedia(String fileId, String extension, long chatId, long timestamp) throws TelegramApiException, IOException {
        GetFile getFile = GetFile.builder().fileId(fileId).build();
        org.telegram.telegrambots.meta.api.objects.File telegramFile = telegramClient.execute(getFile);
        String uniqueId = fileId.length() > 8 ? fileId.substring(0, 8) : fileId;
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
        String keyword = Parser.keywordDetect(messageText);
        String parsed = Parser.keywordDetect(messageText);
        if (keyword != "") {
            Event event = new Event(chatId, userName, time, messageText, parsed, LocationMapper.getCoordinates(keyword));
            try {
                if (msg.getPhoto() != null && !msg.getPhoto().isEmpty()) {
                    PhotoSize photo = msg.getPhoto().get(msg.getPhoto().size() - 1); // for largest resolution
                    String url = downloadMedia(photo.getFileId(), "jpg", chatId, time);
                    event.mediaUrls.add(url);
                }
                if (msg.getVideo() != null) {
                    String url = downloadMedia(msg.getVideo().getFileId(), "mp4", chatId, time);
                    event.mediaUrls.add(url);
                }
                if (msg.getAnimation() != null) {
                    String url = downloadMedia(msg.getAnimation().getFileId(), "gif", chatId, time);
                    event.mediaUrls.add(url);
                }
            } catch (TelegramApiException | IOException e) {
                e.printStackTrace();
            }
            eventsList.add(event);
            saveEventsToJson(eventsList);
            System.out.println("Sent! Parsed location:" + parsed);
        }
    }
}