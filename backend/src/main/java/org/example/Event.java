package org.example;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

public class Event {
    private static final double radius = 6371000;
    public final int id;
    public final long hash;
    public final String uploader;
    public final Long time;
    public final String txt;
    public final List<String> mediaUrls;
    public final String location;
    public final double lat;
    public final double lon;
    public Event(@JsonProperty("id") int id,
                 @JsonProperty("hash") long hash,
                 @JsonProperty("uploader") String uploader,
                 @JsonProperty("time") Long time,
                 @JsonProperty("txt") String txt,
                 @JsonProperty("loc") String location,
                 @JsonProperty("lat") double lat,
                 @JsonProperty("lon") double lon,
                 @JsonProperty("mediaUrls") List<String> mediaUrls) {
        this.id = id;
        this.hash = hash;
        this.uploader = uploader;
        this.time = time;
        this.txt = txt != null ? txt : "";
        this.location = location;
        this.lat = lat;
        this.lon = lon;
        this.mediaUrls = mediaUrls != null ? new ArrayList<>(mediaUrls) : new ArrayList<>();
    }

    public double distanceTo(Event other) {
        double dLat = Math.toRadians(this.lat - other.lat);
        double dLon = Math.toRadians(this.lon - other.lon);
        double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(Math.toRadians(this.lat)) * Math.cos(Math.toRadians(other.lat)) *
                        Math.sin(dLon/2) * Math.sin(dLon/2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return radius * c;
    }

    public boolean isSameEvent(Event other) {
        if (other == null) return false;
        return Math.abs(other.time - this.time) <= 300 && distanceTo(other) <= 100;
    }

    public Event merge(String text, List<String> newMediaUrls) {
        String combinedTxt=this.txt;
        if (text!=null&&!text.isEmpty()) {
            if (combinedTxt.isEmpty()) {
                combinedTxt=text;
            } else {
                combinedTxt+="\n----------\n"+text;
            }
        }
        List<String> combinedUrls= Stream.of(this.mediaUrls, newMediaUrls).filter(x->x!=null)
                .flatMap(x->x.stream()).distinct().toList();
        return new Event(id, hash, uploader, time, combinedTxt, location, lat, lon, combinedUrls);
    }
}