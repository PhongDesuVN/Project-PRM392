package com.prm.backend.repository;

import com.prm.backend.dto.notebook.NotebookDtos.AddWordRequest;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookItemDto;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookProgressItem;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordItem;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class NotebookRepository {

    private static final Logger log = LoggerFactory.getLogger(NotebookRepository.class);
    private final JdbcTemplate jdbcTemplate;

    // Cache in-memory theo từng userId
    private final Map<Integer, Map<String, NotebookWordItem>> userWordCache = new ConcurrentHashMap<>();
    private final Map<Integer, Map<Integer, NotebookItemDto>> userNotebookCache = new ConcurrentHashMap<>();

    public NotebookRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        try {
            // Đảm bảo user id = 1 tồn tại để dùng làm fallback nếu cần
            jdbcTemplate.update("""
                        INSERT IGNORE INTO users (id, email, full_name, role)
                        VALUES (1, 'default@nihongo.app', 'Nihongo User', 'user')
                    """);

            // Đảm bảo cột notebook_id và word_type tồn tại trong user_notebook_words
            try {
                jdbcTemplate.update("ALTER TABLE user_notebook_words ADD COLUMN notebook_id INT NULL");
            } catch (Exception ignored) {
            }
            try {
                jdbcTemplate
                        .update("ALTER TABLE user_notebook_words ADD COLUMN word_type VARCHAR(50) DEFAULT 'Từ vựng'");
            } catch (Exception ignored) {
            }

            try {
                jdbcTemplate.update(
                        "UPDATE user_notebook_words SET status = 'thuoc_lau_lau' WHERE status = 'thuoc_kha_kha'");
                jdbcTemplate.update("DELETE FROM user_notebook_words WHERE notebook_id IS NULL");
            } catch (Exception ignored) {
            }

            // Đảm bảo nếu chưa có sổ tay nào cho user 1 (user mặc định/test) thì tạo mẫu
            try {
                Integer count = jdbcTemplate.queryForObject(
                        "SELECT COUNT(*) FROM notebooks WHERE user_id = 1", Integer.class);
                if (count == null || count == 0) {
                    jdbcTemplate.update("""
                                INSERT INTO notebooks (id, user_id, title, description, created_at)
                                VALUES
                                (1, 1, 'Tesr', 'Sổ tay mẫu', CURRENT_TIMESTAMP),
                                (2, 1, 'Huy', 'Sổ tay từ vựng', CURRENT_TIMESTAMP)
                                ON DUPLICATE KEY UPDATE title = VALUES(title)
                            """);
                }
            } catch (Exception ignored) {
                String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                userNotebookCache.computeIfAbsent(1, k -> new ConcurrentHashMap<>()).put(1,
                        new NotebookItemDto(1, 1, "Tesr", "Sổ tay mẫu", 0, today));
                userNotebookCache.computeIfAbsent(1, k -> new ConcurrentHashMap<>()).put(2,
                        new NotebookItemDto(2, 1, "Huy", "Sổ tay từ vựng", 12, today));
            }
        } catch (Exception e) {
            log.warn("Lỗi khi khởi tạo schema trong MySQL: {}", e.getMessage());
        }
    }

    public int getOrCreateUserId(String email, String fullName) {
        if (email == null || email.isBlank()) {
            return 1;
        }
        final String cleanEmail = email.trim().toLowerCase();
        try {
            List<Integer> list = jdbcTemplate.query(
                    "SELECT id FROM users WHERE LOWER(email) = ?",
                    (rs, rowNum) -> rs.getInt("id"),
                    cleanEmail);
            if (!list.isEmpty()) {
                return list.get(0);
            }

            KeyHolder keyHolder = new GeneratedKeyHolder();
            final String name = (fullName != null && !fullName.isBlank()) ? fullName.trim() : cleanEmail;
            jdbcTemplate.update(con -> {
                PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO users (email, full_name, role) VALUES (?, ?, 'user')",
                        Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, cleanEmail);
                ps.setString(2, name);
                return ps;
            }, keyHolder);

            Number key = keyHolder.getKey();
            return key != null ? key.intValue() : 1;
        } catch (Exception e) {
            log.warn("Lỗi getOrCreateUserId cho email {}: {}", cleanEmail, e.getMessage());
            return 1;
        }
    }

    public List<NotebookItemDto> findAllNotebooks(int userId) {
        String sql = """
                    SELECT n.id, n.user_id, n.title, n.description,
                           COUNT(w.id) as word_count,
                           COALESCE(DATE_FORMAT(n.created_at, '%d/%m/%Y'), '01/11/2026') as created_date
                    FROM notebooks n
                    LEFT JOIN user_notebook_words w ON w.notebook_id = n.id
                    WHERE n.user_id = ?
                    GROUP BY n.id, n.user_id, n.title, n.description, n.created_at
                    ORDER BY n.created_at DESC, n.id DESC
                """;
        try {
            List<NotebookItemDto> list = jdbcTemplate.query(sql, (rs, rowNum) -> new NotebookItemDto(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getInt("word_count"),
                    rs.getString("created_date")), userId);
            if (userId == 1 && list.isEmpty() && userNotebookCache.containsKey(1)) {
                return new ArrayList<>(userNotebookCache.get(1).values());
            }
            return list;
        } catch (Exception e) {
            log.warn("Lỗi khi đọc danh sách sổ tay của userId {}: {}", userId, e.getMessage());
            Map<Integer, NotebookItemDto> cache = userNotebookCache.get(userId);
            if (cache != null)
                return new ArrayList<>(cache.values());
            if (userId == 1) {
                String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                return List.of(
                        new NotebookItemDto(1, 1, "Tesr", "Sổ tay mẫu", 0, today),
                        new NotebookItemDto(2, 1, "Huy", "Sổ tay từ vựng", 12, today));
            }
            return List.of();
        }
    }

    public NotebookItemDto createNotebook(int userId, String title, String description) {
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        try {
            String sql = "INSERT INTO notebooks (user_id, title, description, created_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
            KeyHolder keyHolder = new GeneratedKeyHolder();
            jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, userId);
                ps.setString(2, title);
                ps.setString(3, description != null ? description : "");
                return ps;
            }, keyHolder);

            int newId = keyHolder.getKey() != null ? keyHolder.getKey().intValue()
                    : (int) (System.currentTimeMillis() % 100000);
            NotebookItemDto created = new NotebookItemDto(newId, userId, title, description, 0, today);
            userNotebookCache.computeIfAbsent(userId, k -> new ConcurrentHashMap<>()).put(newId, created);
            return created;
        } catch (Exception e) {
            log.warn("Lỗi khi tạo sổ tay mới vào MySQL, lưu tạm bộ nhớ: {}", e.getMessage());
            int newId = (int) (System.currentTimeMillis() % 100000);
            NotebookItemDto created = new NotebookItemDto(newId, userId, title, description, 0, today);
            userNotebookCache.computeIfAbsent(userId, k -> new ConcurrentHashMap<>()).put(newId, created);
            return created;
        }
    }

    public NotebookItemDto updateNotebook(int id, String title, String description) {
        try {
            String sql = "UPDATE notebooks SET title = ?, description = ? WHERE id = ?";
            jdbcTemplate.update(sql, title, description, id);
        } catch (Exception e) {
            log.warn("Lỗi khi cập nhật sổ tay trong MySQL: {}", e.getMessage());
        }

        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        return new NotebookItemDto(id, 1, title, description, 0, date);
    }

    public boolean deleteNotebook(int id) {
        try {
            jdbcTemplate.update("UPDATE user_notebook_words SET notebook_id = NULL WHERE notebook_id = ?", id);
            int rows = jdbcTemplate.update("DELETE FROM notebooks WHERE id = ?", id);
            for (Map<Integer, NotebookItemDto> map : userNotebookCache.values()) {
                map.remove(id);
            }
            return rows > 0;
        } catch (Exception e) {
            log.warn("Lỗi khi xóa sổ tay khỏi MySQL: {}", e.getMessage());
            for (Map<Integer, NotebookItemDto> map : userNotebookCache.values()) {
                map.remove(id);
            }
            return true;
        }
    }

    public List<NotebookWordItem> findWordsByNotebookId(int notebookId) {
        String sql = """
                    SELECT id, word, reading, romaji, meaning, status, review_count, notebook_id
                    FROM user_notebook_words
                    WHERE notebook_id = ?
                    ORDER BY last_studied_at DESC
                """;
        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> new NotebookWordItem(
                    rs.getInt("id"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("status"),
                    rs.getInt("review_count"),
                    rs.getInt("notebook_id")), notebookId);
        } catch (Exception e) {
            log.warn("Lỗi đọc từ của sổ tay {}: {}", notebookId, e.getMessage());
            return List.of();
        }
    }

    public NotebookWordItem addWordToNotebook(int userId, int notebookId, AddWordRequest request) {
        String word = request.word().trim();
        String reading = request.reading() != null ? request.reading().trim() : "";
        String romaji = request.romaji() != null ? request.romaji().trim() : "";
        String meaning = request.meaning() != null ? request.meaning().trim() : "";
        String wordType = request.wordType() != null && !request.wordType().isBlank() ? request.wordType().trim()
                : "Từ vựng";
        String status = "chua_thuoc";

        String sql = """
                    INSERT INTO user_notebook_words (user_id, notebook_id, word, reading, romaji, meaning, word_type, status, review_count)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)
                    ON DUPLICATE KEY UPDATE
                        notebook_id = VALUES(notebook_id),
                        reading = VALUES(reading),
                        romaji = VALUES(romaji),
                        meaning = VALUES(meaning),
                        word_type = VALUES(word_type),
                        last_studied_at = CURRENT_TIMESTAMP
                """;
        try {
            jdbcTemplate.update(sql, userId, notebookId, word, reading, romaji, meaning, wordType, status);
        } catch (Exception e) {
            log.warn("Lỗi khi thêm từ vào sổ tay {}: {}", notebookId, e.getMessage());
        }

        NotebookWordItem wordItem = new NotebookWordItem(
                (int) (System.currentTimeMillis() % 100000),
                word,
                reading,
                romaji,
                meaning,
                status,
                1,
                notebookId);
        userWordCache.computeIfAbsent(userId, k -> new ConcurrentHashMap<>()).put(word, wordItem);
        return wordItem;
    }

    public void upsertWordProgress(int userId, NotebookProgressItem item) {
        String sql = """
                    INSERT INTO user_notebook_words (user_id, word, reading, romaji, meaning, status, review_count, notebook_id)
                    VALUES (?, ?, ?, ?, ?, ?, 1, ?)
                    ON DUPLICATE KEY UPDATE
                        status = VALUES(status),
                        reading = VALUES(reading),
                        meaning = VALUES(meaning),
                        review_count = review_count + 1,
                        last_studied_at = CURRENT_TIMESTAMP,
                        notebook_id = COALESCE(VALUES(notebook_id), notebook_id)
                """;
        try {
            jdbcTemplate.update(sql,
                    userId,
                    item.word(),
                    item.reading(),
                    item.romaji(),
                    item.meaning(),
                    item.status(),
                    item.notebookId());
        } catch (Exception e) {
            log.warn("Lỗi khi ghi bảng user_notebook_words: {}", e.getMessage());
        }

        Map<String, NotebookWordItem> cache = userWordCache.computeIfAbsent(userId, k -> new ConcurrentHashMap<>());
        int currentCount = cache.containsKey(item.word()) ? cache.get(item.word()).reviewCount() + 1 : 1;
        cache.put(item.word(), new NotebookWordItem(
                cache.size() + 1,
                item.word(),
                item.reading(),
                item.romaji(),
                item.meaning(),
                item.status(),
                currentCount,
                item.notebookId()));
    }

    public NotebookStatsResponse getStats() {
        return getStats(1);
    }

    public NotebookStatsResponse getStats(int userId) {
        String sql = """
                    SELECT status, COUNT(*) as cnt
                    FROM user_notebook_words
                    WHERE user_id = ?
                    GROUP BY status
                """;
        try {
            Map<String, Integer> counts = new HashMap<>();
            jdbcTemplate.query(sql, rs -> {
                counts.put(rs.getString("status"), rs.getInt("cnt"));
            }, userId);

            int chuaThuoc = counts.getOrDefault("chua_thuoc", 0);
            int thuocLoMo = counts.getOrDefault("thuoc_lo_mo", 0);
            int thuocKhaKha = counts.getOrDefault("thuoc_kha_kha", 0);
            int thuocLauLau = counts.getOrDefault("thuoc_lau_lau", 0) + thuocKhaKha;
            int total = chuaThuoc + thuocLoMo + thuocLauLau;

            return new NotebookStatsResponse(chuaThuoc, thuocLoMo, thuocLauLau, total);
        } catch (Exception e) {
            log.warn("Lỗi khi đọc thống kê user_notebook_words: {}", e.getMessage());
            return new NotebookStatsResponse(0, 0, 0, 0);
        }
    }

    public List<NotebookWordItem> findWordsByStatus(int userId, String status) {
        String sql = """
                    SELECT id, word, reading, romaji, meaning, status, review_count, notebook_id
                    FROM user_notebook_words
                    WHERE user_id = ? AND (status = ? OR (? = 'thuoc_lau_lau' AND status = 'thuoc_kha_kha'))
                    ORDER BY last_studied_at DESC
                """;
        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> new NotebookWordItem(
                    rs.getInt("id"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("status"),
                    rs.getInt("review_count"),
                    rs.getObject("notebook_id") != null ? rs.getInt("notebook_id") : null), userId, status, status);
        } catch (Exception e) {
            log.warn("Lỗi đọc danh sách từ theo trạng thái: {}", e.getMessage());
            Map<String, NotebookWordItem> cache = userWordCache.get(userId);
            if (cache != null && status != null) {
                return cache.values().stream()
                        .filter(w -> w != null && w.status() != null && (w.status().equalsIgnoreCase(status)
                                || ("thuoc_lau_lau".equalsIgnoreCase(status) && "thuoc_kha_kha".equalsIgnoreCase(w.status()))))
                        .toList();
            }
            return List.of();
        }
    }

    public List<NotebookWordItem> findAllWords(int userId) {
        String sql = """
                    SELECT id, word, reading, romaji, meaning, status, review_count, notebook_id
                    FROM user_notebook_words
                    WHERE user_id = ?
                    ORDER BY last_studied_at DESC
                """;
        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> new NotebookWordItem(
                    rs.getInt("id"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("status"),
                    rs.getInt("review_count"),
                    rs.getObject("notebook_id") != null ? rs.getInt("notebook_id") : null), userId);
        } catch (Exception e) {
            log.warn("Lỗi đọc toàn bộ từ: {}", e.getMessage());
            Map<String, NotebookWordItem> cache = userWordCache.get(userId);
            return cache != null ? new ArrayList<>(cache.values()) : List.of();
        }
    }

    public List<NotebookWordItem> findAllReviewWords(int userId) {
        String sql = """
                    SELECT id, word, reading, romaji, meaning, status, review_count, notebook_id
                    FROM user_notebook_words
                    WHERE user_id = ? AND notebook_id IS NOT NULL
                    ORDER BY CASE status
                        WHEN 'chua_thuoc' THEN 1
                        WHEN 'thuoc_lo_mo' THEN 2
                        WHEN 'thuoc_kha_kha' THEN 3
                        ELSE 4
                    END, last_studied_at DESC
                """;
        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> new NotebookWordItem(
                    rs.getInt("id"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("status"),
                    rs.getInt("review_count"),
                    rs.getObject("notebook_id") != null ? rs.getInt("notebook_id") : null), userId);
        } catch (Exception e) {
            log.warn("Lỗi đọc danh sách ôn tập: {}", e.getMessage());
            Map<String, NotebookWordItem> cache = userWordCache.get(userId);
            return cache != null ? new ArrayList<>(cache.values()) : List.of();
        }
    }
}
