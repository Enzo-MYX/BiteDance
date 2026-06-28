package org.example;

import org.telegram.telegrambots.longpolling.TelegramBotsLongPollingApplication;

public class Main {
    public static void main(String[] args) {
        String botToken = "8884126057:AAEMbsQ7hVujzUl954nu7z7QMNDExwrCbIs";
        try (TelegramBotsLongPollingApplication botsApplication = new TelegramBotsLongPollingApplication()) {
            botsApplication.registerBot(botToken, new MyBot(botToken));
            System.out.println("Running...");
            System.out.println("Greetings! You are now testing the backend capabilities.");
            System.out.println("After sending a message in Telegram, please wait and check if a confirm message has popped up on this screen before proceeding.");
            System.out.println("Please avoid using name schemes like 'AS-8' or 'LT 13', and opt for 'AS8', 'LT13' for now.");
            System.out.println("If you encounter any problems, proceed to Parser.java and uncomment the lines to see where the pipeline failed to parse your message.");
            Thread.currentThread().join(); // Keep the application running
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}