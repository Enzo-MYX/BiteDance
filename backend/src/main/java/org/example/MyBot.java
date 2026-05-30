package org.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.telegram.telegrambots.client.okhttp.OkHttpTelegramClient;
import org.telegram.telegrambots.longpolling.util.LongPollingSingleThreadUpdateConsumer;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.PhotoSize;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.api.objects.Video;
import org.telegram.telegrambots.meta.api.objects.games.Animation;
import org.telegram.telegrambots.meta.api.objects.message.Message;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import java.io.File;
import java.io.IOException;
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

    @Override
    public void consume(Update update) {
        /*if (!update.hasMessage()) return;
        Message msg = update.getMessage();
        long chatId = msg.getChatId();
        String userName = msg.getFrom().getUserName();
        Long time = msg.getDate().longValue() + 28800L;

        String messageText = msg.hasText() ? msg.getText() : msg.getCaption();
        Video vid = msg.getVideo();
        Animation anm = msg.getAnimation();
        List<PhotoSize> photo = msg.getPhoto();
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
        String parsed = Parser.parseFromInfo(messageText);
        if (parsed != "") {
            eventsList.add(new Event(chatId, userName, time, messageText, vid, anm, photo, parsed));
//            saveEventsToJson(eventsList);
            System.out.println(parsed);
        }*/
        if (update.hasMessage()) System.out.println(update.getMessage().getText());
    }
}