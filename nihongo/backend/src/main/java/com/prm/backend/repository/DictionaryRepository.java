package com.prm.backend.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class DictionaryRepository {

    private static final String SEARCH_SQL = """
            WITH matched_words AS (
                SELECT w.id, w.word, w.reading, w.romaji, w.jlpt_level
                FROM words w
                WHERE w.word LIKE ?
                   OR w.reading LIKE ?
                   OR w.romaji LIKE ?
                   OR EXISTS (
                       SELECT 1
                       FROM word_meanings search_meaning
                       WHERE search_meaning.word_id = w.id
                         AND (search_meaning.lang_code = ? OR search_meaning.lang_code IS NULL)
                         AND search_meaning.meaning LIKE ?
                   )
                ORDER BY CASE
                    WHEN w.word = ? THEN 0
                    WHEN w.word LIKE ? THEN 1
                    ELSE 2
                END, w.word
                LIMIT ?
            )
            SELECT mw.id AS word_id,
                   mw.word,
                   mw.reading,
                   mw.romaji,
                   mw.jlpt_level,
                   wm.id AS meaning_id,
                   wm.lang_code,
                   wm.part_of_speech,
                   wm.meaning AS meaning_text,
                   k.id AS kanji_id,
                   k.kanji_char,
                   k.han_viet,
                   k.radical,
                   k.stroke_count,
                   k.onyomi,
                   k.kunyomi,
                   k.jlpt_level AS kanji_jlpt_level,
                   k.meaning AS kanji_meaning
            FROM matched_words mw
            LEFT JOIN word_meanings wm
                ON wm.word_id = mw.id
               AND (wm.lang_code = ? OR wm.lang_code IS NULL)
            LEFT JOIN kanji_words kw ON kw.word_id = mw.id
            LEFT JOIN kanjis k ON k.id = kw.kanji_id
            ORDER BY mw.word, wm.id, k.kanji_char
            """;

    private final JdbcTemplate jdbcTemplate;

    public DictionaryRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<SearchRow> search(String query, String languageCode, int limit) {
        String prefix = query + "%";
        return jdbcTemplate.query(
                SEARCH_SQL,
                (resultSet, rowNumber) -> mapRow(resultSet),
                prefix,
                prefix,
                prefix,
                languageCode,
                prefix,
                query,
                prefix,
                limit,
                languageCode
        );
    }

    private SearchRow mapRow(ResultSet resultSet) throws SQLException {
        return new SearchRow(
                resultSet.getInt("word_id"),
                resultSet.getString("word"),
                resultSet.getString("reading"),
                resultSet.getString("romaji"),
                resultSet.getString("jlpt_level"),
                nullableInteger(resultSet, "meaning_id"),
                resultSet.getString("lang_code"),
                resultSet.getString("part_of_speech"),
                resultSet.getString("meaning_text"),
                nullableInteger(resultSet, "kanji_id"),
                resultSet.getString("kanji_char"),
                resultSet.getString("han_viet"),
                resultSet.getString("radical"),
                nullableInteger(resultSet, "stroke_count"),
                resultSet.getString("onyomi"),
                resultSet.getString("kunyomi"),
                resultSet.getString("kanji_jlpt_level"),
                resultSet.getString("kanji_meaning")
        );
    }

    private Integer nullableInteger(ResultSet resultSet, String column) throws SQLException {
        int value = resultSet.getInt(column);
        return resultSet.wasNull() ? null : value;
    }

    public record SearchRow(
            Integer wordId,
            String word,
            String reading,
            String romaji,
            String jlptLevel,
            Integer meaningId,
            String languageCode,
            String partOfSpeech,
            String meaningText,
            Integer kanjiId,
            String kanjiCharacter,
            String hanViet,
            String radical,
            Integer strokeCount,
            String onyomi,
            String kunyomi,
            String kanjiJlptLevel,
            String kanjiMeaning
    ) {
    }
}