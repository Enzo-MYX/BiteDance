package org.example;

public class Dist_Calc {
    private static double toRadians(double deg) {
        return deg * Math.PI / 180;
    }
    private static double distance(double lat1, double lon1, double lat2, double lon2) {
        double dLat = toRadians(lat2 - lat1);
        double dLon = toRadians(lon2 - lon1);
        double a = Math.pow(Math.sin(dLat / 2), 2) + Math.pow(Math.sin(dLon / 2), 2) * Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2));
        double theta = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return 6378000 * theta; // using this because the app is for Singapore, which is near the equator. Doesn't really matter though
    }

    public static void main(String[] args) {
        System.out.println(distance(0, -90, 0, 90));
        System.out.println(distance(1.352083, 103.819836, 31.22222, 121.45806)); // SPore <-> SH distance: 3792km
    }
}