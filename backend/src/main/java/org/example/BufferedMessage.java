package org.example;

import java.util.ArrayList;
import java.util.List;

public class BufferedMessage {
    public final String text;
    public final List<MediaReference> mediaRefs;
    public final long timestamp;

    BufferedMessage(String text, List<MediaReference> mediaRefs, long timestamp) {
        this.text = text;
        this.mediaRefs = new ArrayList<>(mediaRefs);
        this.timestamp = timestamp;
    }
}
