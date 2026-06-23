package org.example;

import com.fasterxml.jackson.annotation.JsonProperty;
// this class is functionally as useful as a double array but y'all wanted good principles so screw you
public class Coordinates {
    private final double lat;
    private final double lon;
// oh wow aren't you just loving the immutability and the information hiding and the encapsulation and
// gosh such professionally superficial lines of code eating away at the program's actual efficiency, ya love to see it
    public Coordinates() {
        lat = 0.0;
        lon = 0.0;
        System.out.println("Hey bozo there's an empty string somewhere in here!");
    }

    public Coordinates(@JsonProperty("lat") double lat, @JsonProperty("lon") double lon) {
        this.lat = lat;
        this.lon = lon;
    }

    public double getLat() {
        return lat;
    }

    public double getLon() {
        return lon;
    }
}