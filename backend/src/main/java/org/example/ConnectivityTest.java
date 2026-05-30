package org.example;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class ConnectivityTest {
    public static void main(String[] args) {
        try {
            URL url = new URL("https://api.telegram.org");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);
            connection.connect();

            int responseCode = connection.getResponseCode();
            System.out.println("Connection successful! Response Code: " + responseCode);
        } catch (IOException e) {
            System.err.println("Connection FAILED: " + e.getMessage());
            e.printStackTrace();
        }
    }
}