package org.example;

import org.telegram.telegrambots.longpolling.TelegramBotsLongPollingApplication;

public class Main {
    public static void main(String[] args) {
        String botToken = "8884126057:AAEMbsQ7hVujzUl954nu7z7QMNDExwrCbIs";
        try (TelegramBotsLongPollingApplication botsApplication = new TelegramBotsLongPollingApplication()) {
            MyBot bot = new MyBot(botToken);
            bot.startHttpServer();  // start HTTP server to serve events.json and media
            botsApplication.registerBot(botToken, bot);
            System.out.println("Running...");
            Thread.currentThread().join(); // Keep the application running
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}