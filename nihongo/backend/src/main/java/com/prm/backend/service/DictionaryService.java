package com.prm.backend.service;

import com.prm.backend.dto.dictionary.DictionaryDtos.KanjiSummary;
import com.prm.backend.dto.dictionary.DictionaryDtos.Meaning;
import com.prm.backend.dto.dictionary.DictionaryDtos.SearchResponse;
import com.prm.backend.dto.dictionary.DictionaryDtos.SearchResult;
import com.prm.backend.repository.DictionaryRepository;
import com.prm.backend.repository.DictionaryRepository.SearchRow;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class DictionaryService {

    private static final int MAX_LIMIT = 50;

    private final DictionaryRepository dictionaryRepository;

    public DictionaryService(DictionaryRepository dictionaryRepository) {
        this.dictionaryRepository = dictionaryRepository;
    }

    public SearchResponse search(String rawQuery, String rawLanguageCode, int limit) {
        String query = rawQuery == null ? "" : rawQuery.trim();
        String languageCode = rawLanguageCode == null ? "vi" : rawLanguageCode.trim();

        if (query.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Từ khóa không được để trống");
        }
        if (query.length() > 100) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Từ khóa tối đa 100 ký tự");
        }
        if (languageCode.isEmpty() || languageCode.length() > 10) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mã ngôn ngữ không hợp lệ");
        }
        if (limit < 1 || limit > MAX_LIMIT) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Số kết quả phải nằm trong khoảng 1 đến " + MAX_LIMIT
            );
        }

        Map<Integer, SearchResultBuilder> results = new LinkedHashMap<>();
        for (SearchRow row : dictionaryRepository.search(query, languageCode, limit)) {
            SearchResultBuilder result = results.computeIfAbsent(
                    row.wordId(),
                    ignored -> new SearchResultBuilder(row)
            );
            result.addMeaning(row);
            result.addKanji(row);
        }

        List<SearchResult> searchResults = results.values().stream()
                .map(SearchResultBuilder::build)
                .toList();
        return new SearchResponse(query, searchResults);
    }

    private static final class SearchResultBuilder {
        private final SearchRow wordRow;
        private final Map<Integer, Meaning> meanings = new LinkedHashMap<>();
        private final Map<Integer, KanjiSummary> kanjis = new LinkedHashMap<>();

        private SearchResultBuilder(SearchRow wordRow) {
            this.wordRow = wordRow;
        }

        private void addMeaning(SearchRow row) {
            if (row.meaningId() != null) {
                meanings.putIfAbsent(
                        row.meaningId(),
                        new Meaning(
                                row.meaningId(),
                                row.languageCode(),
                                row.partOfSpeech(),
                                row.meaningText()
                        )
                );
            }
        }

        private void addKanji(SearchRow row) {
            if (row.kanjiId() != null) {
                kanjis.putIfAbsent(
                        row.kanjiId(),
                        new KanjiSummary(
                                row.kanjiId(),
                                row.kanjiCharacter(),
                                row.hanViet(),
                                row.radical(),
                                row.strokeCount(),
                                row.onyomi(),
                                row.kunyomi(),
                                row.kanjiJlptLevel(),
                                row.kanjiMeaning()
                        )
                );
            }
        }

        private SearchResult build() {
            return new SearchResult(
                    wordRow.wordId(),
                    wordRow.word(),
                    wordRow.reading(),
                    wordRow.romaji(),
                    wordRow.jlptLevel(),
                    new ArrayList<>(meanings.values()),
                    new ArrayList<>(kanjis.values())
            );
        }
    }
}