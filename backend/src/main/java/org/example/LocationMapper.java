package org.example;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

public class LocationMapper {
    private static final Map<String, Coordinates> LOCATION_MAP = new HashMap<>();

    static {
        try (InputStream is = LocationMapper.class.getResourceAsStream("/locations.json")) {
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Coordinates> rawMap = mapper.readValue(is, new TypeReference<>() {});
            rawMap.forEach((key, coords) -> LOCATION_MAP.put(key.toLowerCase().trim(), coords));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Coordinates getCoordinates(String locationName) {
        if (locationName == null) return new Coordinates();
        return LOCATION_MAP.get(locationName.toLowerCase().trim());
    }
}