package org.example;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Parser {
    public Parser() {}
    static Pattern p = Pattern.compile(
            "(?:^|\\b(?:at|beside|near|nearby|location:?|outside)\\b)\\s*(?:\\w+\\s+)*?" +
                    "((?:[a-z]+[0-9]+|utown|(?:\\w+\\s+)*?auditorium)[^,.\n]*)",
            Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);
    static String parseFromInfo(String text) {
        Matcher m = p.matcher(text);
        if (m.find()) {
            System.out.println("Sent!");
            return m.group(1);
        }
        System.out.print("No message");
        return "";
    }

    public static void main(String[] args) {
        String[] inputs = {
                "S17 level 4, clearing at 2pm",
                "Food at UTown SRC Level 2, self service",
                "Buffet beside Engineering Auditorium, organiser approved",
                "Nearby MD6 01-01B halal snack",
                "Location: S14 level 5, clearing soon",
                "Outside AS2 Level 2, leftover catering",
                "Shepherds pie at Engineering Auditorium.",
                "Just some food left here.",
                "Food at S17 level 4. Leftover potato salad, shakshuka, curry chicken, dory fish, and ice lemon tea."
        };
        for (String txt : inputs) {System.out.println(Parser.parseFromInfo(txt));}
    }
}
