package com.prm.backend.repository;

import com.prm.backend.dto.notebook.NotebookDtos.NotebookProgressItem;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class NotebookRepository {

    private static final Logger log = LoggerFactory.getLogger(NotebookRepository.class);
    private final JdbcTemplate jdbcTemplate;

    // Cache bộ nhớ trong phòng trường hợp database chưa chạy script migration
    private final Map<String, NotebookWordItem> inMemoryCache = new ConcurrentHashMap<>();

    public NotebookRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void upsertWordProgress(NotebookProgressItem item) {
        String sql = """
                INSERT INTO user_notebook_words (user_id, word, reading, romaji, meaning, status, review_count)
                VALUES (1, ?, ?, ?, ?, ?, 1)
                ON DUPLICATE KEY UPDATE
                    status = VALUES(status),
                    reading = VALUES(reading),
                    meaning = VALUES(meaning),
                    review_count = review_count + 1,
                    last_studied_at = CURRENT_TIMESTAMP
                """;
        try {
            jdbcTemplate.update(sql,
                    item.word(),
                    item.reading(),
                    item.romaji(),
                    item.meaning(),
                    item.status()
            );
        } catch (Exception e) {
            log.warn("Lỗi khi ghi bảng user_notebook_words (lưu vào cache tạm thời): {}", e.getMessage());
        }

        // Cập nhật luôn cache in-memory
        int currentCount = inMemoryCache.containsKey(item.word())
                ? inMemoryCache.get(item.word()).reviewCount() + 1
                : 1;
        inMemoryCache.put(item.word(), new NotebookWordItem(
                inMemoryCache.size() + 1,
                item.word(),
                item.reading(),
                item.romaji(),
                item.meaning(),
                item.status(),
                currentCount
        ));
    }

    public NotebookStatsResponse getStats() {
        String sql = """
                SELECT status, COUNT(*) as cnt
                FROM user_notebook_words
                WHERE user_id = 1
                GROUP BY status
                """;
        try {
            Map<String, Integer> counts = new HashMap<>();
            jdbcTemplate.query(sql, rs -> {
                counts.put(rs.getString("status"), rs.getInt("cnt"));
            });

            int chuaThuoc = counts.getOrDefault("chua_thuoc", 0);
            int thuocLoMo = counts.getOrDefault("thuoc_lo_mo", 0);
            int thuocKhaKha = counts.getOrDefault("thuoc_kha_kha", 0);
            int thuocLauLau = counts.getOrDefault("thuoc_lau_lau", 0);
            int total = chuaThuoc + thuocLoMo + thuocKhaKha + thuocLauLau;

            // Nếu DB trả về 0 nhưng cache có dữ liệu thì lấy từ cache
            if (total == 0 && !inMemoryCache.isEmpty()) {
                return getStatsFromCache();
            }

            return new NotebookStatsResponse(chuaThuoc, thuocLoMo, thuocKhaKha, thuocLauLau, total);
        } catch (Exception e) {
            log.warn("Lỗi khi đọc thống kê user_notebook_words, lấy từ cache: {}", e.getMessage());
            return getStatsFromCache();
        }
    }

    public List<NotebookWordItem> findWordsByStatus(String status) {
        String sql = """
                SELECT id, word, reading, romaji, meaning, status, review_count
                FROM user_notebook_words
                WHERE user_id = 1 AND status = ?
                ORDER BY last_studied_at DESC
                """;
        try {
            List<NotebookWordItem> list = jdbcTemplate.query(sql, (rs, rowNum) -> new NotebookWordItem(
                    rs.getInt("id"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("status"),
                    rs.getInt("review_count")
            ), status);

            if (list.isEmpty() && !inMemoryCache.isEmpty()) {
                return inMemoryCache.values().stream()
                        .filter(w -> w.status().equalsIgnoreCase(status))
                        .toList();
            }
            return list;
        } catch (Exception e) {
            log.warn("Lỗi đọc danh sách từ theo trạng thái: {}", e.getMessage());
            return inMemoryCache.values().stream()
                    .filter(w -> w.status().equalsIgnoreCase(status))
                    .toList();
        }
    }

    public List<NotebookWordItem> findAllReviewWords() {
        String sql = """
                SELECT id, word, reading, romaji, meaning, status, review_count
                FROM user_notebook_words
                WHERE user_id = 1
                ORDER BY CASE status
                    WHEN 'chua_thuoc' THEN 1
                    WHEN 'thuoc_lo_mo' THEN 2
                    WHEN 'thuoc_kha_kha' THEN 3
                    ELSE 4
                END, last_studied_at DESC
                """;
        try {
            List<NotebookWordItem> list = jdbcTemplate.query(sql, (rs, rowNum) -> new NotebookWordItem(
                    rs.getInt("id"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("status"),
                    rs.getInt("review_count")
            ));

            if (list.isEmpty() && !inMemoryCache.isEmpty()) {
                return new ArrayList<>(inMemoryCache.values());
            }
            return list;
        } catch (Exception e) {
            log.warn("Lỗi đọc danh sách ôn tập: {}", e.getMessage());
            return new ArrayList<>(inMemoryCache.values());
        }
    }

    private NotebookStatsResponse getStatsFromCache() {
        int chuaThuoc = (int) inMemoryCache.values().stream().filter(w -> "chua_thuoc".equals(w.status())).count();
        int thuocLoMo = (int) inMemoryCache.values().stream().filter(w -> "thuoc_lo_mo".equals(w.status())).count();
        int thuocKhaKha = (int) inMemoryCache.values().stream().filter(w -> "thuoc_kha_kha".equals(w.status())).count();
        int thuocLauLau = (int) inMemoryCache.values().stream().filter(w -> "thuoc_lau_lau".equals(w.status())).count();
        return new NotebookStatsResponse(chuaThuoc, thuocLoMo, thuocKhaKha, thuocLauLau, inMemoryCache.size());
    }
}
