package com.prm.backend.dto.dictionary;

import java.util.List;

public final class DictionaryDtos {

    private DictionaryDtos() {
    }

    public record SearchResponse(String query, List<SearchResult> results) {
    }

    public record SearchResult(
            Integer id,
            String word,
            String reading,
            String romaji,
            String jlptLevel,
            List<Meaning> meanings,
            List<KanjiSummary> kanjis
    ) {
    }

    public record Meaning(
            Integer id,
            String languageCode,
            String partOfSpeech,
            String text
    ) {
    }

    public record KanjiSummary(
            Integer id,
            String character,
            String hanViet,
            String radical,
            Integer strokeCount,
            String onyomi,
            String kunyomi,
            String jlptLevel,
            String meaning
    ) {
    }
}