package org.example;

import org.telegram.telegrambots.longpolling.TelegramBotsLongPollingApplication;

public class Main {
    public static void main(String[] args) {
        String botToken = System.getenv("TELEGRAM_BOT_TOKEN");
        System.out.println("Token length: " + (botToken == null ? "null" : botToken.length()));
        if (botToken == null || botToken.isEmpty()) {
            System.err.println("Critical error: TELEGRAM_BOT_TOKEN missing!");
            System.exit(1);
        }
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