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
        initDefaultUser();
    }

    private void initDefaultUser() {
        try {
            // Đảm bảo user_id = 1 tồn tại để không vi phạm ràng buộc Foreign Key
            jdbcTemplate.update("""
                INSERT IGNORE INTO users (id, email, full_name, role)
                VALUES (1, 'default@nihongo.app', 'Nihongo User', 'user')
            """);
        } catch (Exception e) {
            log.warn("Không thể tạo user mặc định: {}", e.getMessage());
        }
    }

    public void addKeyword(String rawQuery) {
        if (rawQuery == null || rawQuery.trim().isEmpty()) return;
        String query = rawQuery.trim();

        try {
            // Xóa từ khóa cũ nếu đã tồn tại để khi thêm mới sẽ được xếp lên đầu
            jdbcTemplate.update("DELETE FROM search_histories WHERE query_text = ?", query);

            // Thêm từ khóa mới
            jdbcTemplate.update("""
                INSERT INTO search_histories (user_id, query_text, searched_at)
                VALUES (1, ?, CURRENT_TIMESTAMP)
            """, query);
        } catch (Exception e) {
            log.error("Lỗi khi thêm từ khóa vào search_histories: {}", e.getMessage());
        }
    }

    public List<String> getRecentKeywords(int limit) {
        try {
            return jdbcTemplate.queryForList("""
                SELECT query_text
                FROM search_histories
                ORDER BY searched_at DESC, id DESC
                LIMIT ?
            """, String.class, limit);
        } catch (Exception e) {
            log.error("Lỗi khi đọc danh sách search_histories: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    public void deleteKeyword(String rawQuery) {
        if (rawQuery == null || rawQuery.trim().isEmpty()) return;
        String query = rawQuery.trim();

        try {
            jdbcTemplate.update("DELETE FROM search_histories WHERE query_text = ?", query);
        } catch (Exception e) {
            log.error("Lỗi khi xóa từ khóa trong search_histories: {}", e.getMessage());
        }
    }

    public void clearAll() {
        try {
            jdbcTemplate.update("DELETE FROM search_histories");
        } catch (Exception e) {
            log.error("Lỗi khi xóa toàn bộ search_histories: {}", e.getMessage());
        }
    }
}

