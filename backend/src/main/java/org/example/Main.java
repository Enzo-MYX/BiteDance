package org.example;

import org.telegram.telegrambots.longpolling.TelegramBotsLongPollingApplication;

public class Main {
    public static void main(String[] args) {
        String botToken = "8884126057:AAEMbsQ7hVujzUl954nu7z7QMNDExwrCbIs";
        try (TelegramBotsLongPollingApplication botsApplication = new TelegramBotsLongPollingApplication()) {
            botsApplication.registerBot(botToken, new MyBot(botToken));
            System.out.println("Running...");
            Thread.currentThread().join(); // Keep the application running
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}