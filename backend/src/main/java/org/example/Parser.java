package org.example;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Parser {
    public Parser() {}

    private static Pattern triggerPattern = Pattern.compile(
        "(?i)\\b(?:at|beside|near|nearby|location:?|outside)\\b\\s*(?:\\w+\\s+)*?" +
                "((?:[a-z]+[0-9]+|utown|(?:\\w+\\s+)*?auditorium)[^,.\n]*)");
    private static Pattern lineStart = Pattern.compile(
            "(?i)^\\s*((?:[a-z]+[0-9]+|utown)[^,.\n]*)", Pattern.MULTILINE);
    private static Pattern keyword = Pattern.compile("((?i)\\b(?:LT|AS|MD)\\s?\\d{1,2}\\b|\\butown auditorium\\b)");

    public static String parseFromInfo(String text) {
        Matcher m1 = triggerPattern.matcher(text);
        if (m1.find()) {
            System.out.println("Sent!");
            return m1.group(1);
        }
        Matcher m2 = lineStart.matcher(text);
        if (m2.find()) {
            System.out.println("Sent!");
            return m2.group(1);
        }
        System.out.println("Defaulting to keyword reader");
        return Parser.keywordDetect(text);
    }

    public static String keywordDetect(String text) {
        Matcher m = keyword.matcher(text);
        if (m.find()) {
            System.out.println("Sent!");
            return m.group(1); // due to the leniency on spaces such as "LT 13", later versions must process these into names on the map, e.g. "LT13"
        }
        System.out.print("Cannot extract valuable info");
        return "";
    }

    public static void main(String[] args) {
        String[] inputs = {
                "S17 level 4, clearing at 2pm",
                "Food at UTown SRC Level 2, self service",
                "Buffet beside Engineering Auditorium, organiser approved", // fixed "Auditorium" capture overreach
                "Nearby MD 6 01-01B halal snack", // defaulting test success
                "Location: S14 level 5, clearing soon", // needs adjustments
                "Outside AS2 Level 2, leftover catering",
                "Shepherds pie at Engineering Auditorium.", // fixed
                "Just some food left here.", // this is intended for no output testing
                "Food at S17 level 4. Leftover potato salad, shakshuka, curry chicken, dory fish, and ice lemon tea."
        };
        for (String txt : inputs) {System.out.println(Parser.parseFromInfo(txt));}
        String[] inputs2 = {
                "Kris where the f*ck are we", // no return as expected
                "Like, uh, maybe things took a weird route at the utown auditorium, huh?",
                "That's... not, the ThornRing (that you found in LT22), is it?",
                "Man... it's like he's in some king of MD 8 right now...",
                "Berdly,\n I only play mobile games. On my alt 13. (please don't return anything please don't return anything" // It didn't return anything
        };
        for (String txt : inputs2) {System.out.println(Parser.keywordDetect(txt));}
    }
}
