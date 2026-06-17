package org.example;

import org.telegram.telegrambots.meta.api.objects.PhotoSize;
import org.telegram.telegrambots.meta.api.objects.Video;
import org.telegram.telegrambots.meta.api.objects.games.Animation;

import java.util.List;

public class Event {
    private static int incr = 0;
    public final int id;
    public final long chatId;
    public final String uploader;
    public final Long time;
    public final String txt;
    public final Video vid;
    public final Animation anm;
    public final List<PhotoSize> photo;
    public final String location;
    public final double lat;
    public final double lon;
    public Event(long chatId, String uploader, Long time, String txt, Video vid, Animation anm, List<PhotoSize> photo, String loc, Coordinates coords) {
        this.id = incr;
        incr++;
        this.chatId = chatId;
        this.uploader = uploader;
        this.time = time;
        this.txt = txt;
        this.vid = vid;
        this.anm = anm;
        this.photo = photo;
        this.location = loc;
        this.lat = coords.getLat();
        this.lon = coords.getLon();
    }
}