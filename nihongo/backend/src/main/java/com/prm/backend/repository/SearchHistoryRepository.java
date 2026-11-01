package com.prm.backend.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;

@Repository
public class SearchHistoryRepository {

    private static final Logger log = LoggerFactory.getLogger(SearchHistoryRepository.class);
    private final JdbcTemplate jdbcTemplate;

    public SearchHistoryRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void addKeyword(String rawQuery) {
        addKeyword(1, rawQuery);
    }

    public List<String> getRecentKeywords(int limit) {
        return getRecentKeywords(1, limit);
    }

    public void deleteKeyword(String rawQuery) {
        deleteKeyword(1, rawQuery);
    }

    public void clearAll() {
        clearAll(1);
    }

    public void addKeyword(int userId, String rawQuery) {
        if (rawQuery == null || rawQuery.trim().isEmpty()) return;
        String query = rawQuery.trim();

        try {
            // Xóa từ khóa cũ của user nếu đã tồn tại để khi thêm mới sẽ được xếp lên đầu
            jdbcTemplate.update("DELETE FROM search_histories WHERE user_id = ? AND query_text = ?", userId, query);

            // Thêm từ khóa mới
            jdbcTemplate.update("""
                INSERT INTO search_histories (user_id, query_text, searched_at)
                VALUES (?, ?, CURRENT_TIMESTAMP)
            """, userId, query);
        } catch (Exception e) {
            log.error("Lỗi khi thêm từ khóa vào search_histories: {}", e.getMessage());
        }
    }

    public List<String> getRecentKeywords(int userId, int limit) {
        try {
            return jdbcTemplate.queryForList("""
                SELECT query_text
                FROM search_histories
                WHERE user_id = ?
                ORDER BY searched_at DESC, id DESC
                LIMIT ?
            """, String.class, userId, limit);
        } catch (Exception e) {
            log.error("Lỗi khi đọc danh sách search_histories: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    public void deleteKeyword(int userId, String rawQuery) {
        if (rawQuery == null || rawQuery.trim().isEmpty()) return;
        String query = rawQuery.trim();

        try {
            jdbcTemplate.update("DELETE FROM search_histories WHERE user_id = ? AND query_text = ?", userId, query);
        } catch (Exception e) {
            log.error("Lỗi khi xóa từ khóa trong search_histories: {}", e.getMessage());
        }
    }

    public void clearAll(int userId) {
        try {
            jdbcTemplate.update("DELETE FROM search_histories WHERE user_id = ?", userId);
        } catch (Exception e) {
            log.error("Lỗi khi xóa toàn bộ search_histories: {}", e.getMessage());
        }
    }
}
