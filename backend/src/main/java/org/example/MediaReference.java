package org.example;

public class MediaReference {
    public final String fileId;
    public final String type; // "photo", "video", "animation"
    public final long chatId;
    public final long timestamp;

    MediaReference(String fileId, String type, long chatId, long timestamp) {
        this.fileId = fileId;
        this.type = type;
        this.chatId = chatId;
        this.timestamp = timestamp;
    }
}
