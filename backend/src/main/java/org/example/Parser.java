package org.example;

import java.util.*;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Parser {
    public Parser() {}

    private static Pattern triggerPattern = Pattern.compile(
            "(?i)\\b(?:at|beside|near|nearby|location|outside)\\b:?\\s*(?:\\w+\\s+)*?" +
                    "((?:[a-z]+[0-9]+|utown|(?:\\w+\\s+)*?auditorium)[^,.\\n]*)");
    private static Pattern lineStart = Pattern.compile(
            "(?i)^\\s*((?:[a-z]+[0-9]+|utown)[^,.\n]*)", Pattern.MULTILINE);
    private static Function<String, Optional<String>> schools = (text) -> {
        Pattern keyword = Pattern.compile("((?i)\\b(?:AS|MD|BIZ|COM|E|EW|S|SDE)[\\s-]?\\d{1,2}A?\\b)");
        Matcher m = keyword.matcher(text);
        Optional<String> parsed = Optional.ofNullable(m.find() ? m.group(1) : null);
        return parsed.map(x -> x.replace(" ", "").replace("-", ""));
    };
    private static Function<String, Optional<String>> lts = (text) -> {
        Pattern keyword = Pattern.compile("((?i)\\bLT[\\s-]?\\d{1,2}\\b)");
        Matcher m = keyword.matcher(text);
        Optional<String> parsed = Optional.ofNullable(m.find() ? m.group(1) : null);
        return parsed.map(x -> x.replace(" ", "").replace("-", ""));
    };
    private static Function<String, Optional<String>> misc = (text) -> {
        List<Map.Entry<Pattern, String>> rules = Arrays.asList(
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bFrontier\\b", Pattern.CASE_INSENSITIVE), "Frontier"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bYusof Ishak House\\b", Pattern.CASE_INSENSITIVE), "YIH"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bYIH\\b", Pattern.CASE_INSENSITIVE), "YIH"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bPGPR?\\b", Pattern.CASE_INSENSITIVE), "PGPR"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bPrince George Park\\b", Pattern.CASE_INSENSITIVE), "PGPR"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bTechno\\b", Pattern.CASE_INSENSITIVE), "Techno Edge"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bDeck\\b", Pattern.CASE_INSENSITIVE), "Deck"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bTerrace\\b", Pattern.CASE_INSENSITIVE), "Terrace"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bFine[ -]?Foods?\\b", Pattern.CASE_INSENSITIVE), "Fine Food"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bFlavou?rs\\b", Pattern.CASE_INSENSITIVE), "Flavours Utown"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bEusoff\\b", Pattern.CASE_INSENSITIVE), "Eusoff Hall"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bKent Ridge Hall\\b", Pattern.CASE_INSENSITIVE), "Kent Ridge Hall"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bEdward\\b", Pattern.CASE_INSENSITIVE), "King Edward VII Hall"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bRaffles\\b", Pattern.CASE_INSENSITIVE), "Raffles Hall"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bSheares\\b", Pattern.CASE_INSENSITIVE), "Sheares Hall"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bTemasek\\b", Pattern.CASE_INSENSITIVE), "Temasek Hall"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bLightHouse\\b", Pattern.CASE_INSENSITIVE), "Light House"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bHelix\\b", Pattern.CASE_INSENSITIVE), "Helix House"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bPioneer\\b", Pattern.CASE_INSENSITIVE), "Pioneer House"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bVH\\b", Pattern.CASE_INSENSITIVE), "Valour House"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bValou?r\\b", Pattern.CASE_INSENSITIVE), "Valour House"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bCAPT\\b", Pattern.CASE_INSENSITIVE), "CAPT"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bRC4\\b", Pattern.CASE_INSENSITIVE), "RC4"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bResidential College\\b", Pattern.CASE_INSENSITIVE), "RC4"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bTembusu\\b", Pattern.CASE_INSENSITIVE), "Tembusu College"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bRVRC\\b", Pattern.CASE_INSENSITIVE), "RVRC"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bAcacia\\b", Pattern.CASE_INSENSITIVE), "Acacia College"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bYale NUS\\b", Pattern.CASE_INSENSITIVE), "Yale NUS College"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bUTR\\b", Pattern.CASE_INSENSITIVE), "Utown Residence"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bUtown Residences?\\b", Pattern.CASE_INSENSITIVE), "Utown Residence"),
                new AbstractMap.SimpleEntry<>(Pattern.compile("\\bCinnamon\\b", Pattern.CASE_INSENSITIVE), "Cinnamon College")
        );
        for (Map.Entry<Pattern, String> rule : rules) {
            if (rule.getKey().matcher(text).find()) {
                return Optional.of(rule.getValue());
            }
        }
        return Optional.empty();
    };
    private static List<Function<String, Optional<String>>> processors = Arrays.asList(
            schools,
            lts,
            misc
    );
//little adjustments to venues
    public static String parseFromInfo(String text) {
        Matcher m1 = triggerPattern.matcher(text);
        if (m1.find()) {
            System.out.println("Found name!");
            return m1.group(1);
        }
        Matcher m2 = lineStart.matcher(text);
        if (m2.find()) {
            System.out.println("Found name!");
            return m2.group(1);
        }
        System.out.println("Defaulting to keyword reader");
        return Parser.keywordDetect(text);
    }

    public static String keywordDetect(String text) {
        for (Function<String, Optional<String>> f : processors) {
            if (f.apply(text).isPresent()) {
                System.out.println("Found location!");
                return f.apply(text).get();
            }
        }
        System.out.print("Cannot extract valuable info");
        return "";
    }

    /*public static void main(String[] args) {
        String[] inputs = {
                "S17 level 4, clearing at 2pm",
                "Food at UTown SRC Level 2, self service",
                "Buffet beside Engineering Auditorium, organiser approved", // fixed "Auditorium" capture overreach
                "Nearby MD 6 01-01B halal snack", // defaulting test success
                "Location: S14 level 5, clearing soon", // "Location: " trigger sequence fixed
                "Outside AS2 Level 2, leftover catering",
                "Shepherds pie at Engineering Auditorium.", // fixed
                "Just some food left here.", // this is intended for no output testing
                "Food at S17 level 4. Leftover potato salad, shakshuka, curry chicken, dory fish, and ice lemon tea."
        };
        for (String txt : inputs) {System.out.println(Parser.parseFromInfo(txt));}
        String[] inputs2 = {
                "Kris where the f*ck are we", // no return as expected
                "Like, uh, maybe things took a weird route at the utown auditorium, huh?",
                "That's... not, the ThornRing (that you found in LT 22), is it?",
                "Man... it's like he's in some king of Techno Edge right now...",
                "Berdly,\n I only play mobile games. On my alt 13. (please don't return anything please don't return anything" // It didn't return anything
        };
        for (String txt : inputs2) {System.out.println(Parser.keywordDetect(txt));}
    }*/
}
