package com.prm.backend.repository;

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

    // Cache bộ nhớ trong phòng trường hợp database mất kết nối
    private final Map<String, NotebookWordItem> inMemoryCache = new ConcurrentHashMap<>();
    private final Map<Integer, NotebookItemDto> inMemoryNotebooks = new ConcurrentHashMap<>();

    public NotebookRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        try {
            // Đảm bảo user id = 1 tồn tại để không vi phạm khoá ngoại
            jdbcTemplate.update("""
                        INSERT IGNORE INTO users (id, email, full_name, role)
                        VALUES (1, 'default@nihongo.app', 'Nihongo User', 'user')
                    """);

            // Đảm bảo cột notebook_id tồn tại trong user_notebook_words
            try {
                jdbcTemplate.update("ALTER TABLE user_notebook_words ADD COLUMN notebook_id INT NULL");
            } catch (Exception ignored) {
                // Đã tồn tại
            }

            // Đảm bảo nếu chưa có sổ tay nào thì tạo mẫu "Tesr" và "Huy" như giao diện ảnh
            // mẫu
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
                // Gán các từ hiện tại vào sổ tay 2 (Huy)
                jdbcTemplate.update(
                        "UPDATE user_notebook_words SET notebook_id = 2 WHERE user_id = 1 AND notebook_id IS NULL");
            }
        } catch (Exception e) {
            log.warn("Lỗi khi khởi tạo schema/dữ liệu mẫu sổ tay trong MySQL: {}", e.getMessage());
            // Khởi tạo cache in-memory mặc định
            String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            inMemoryNotebooks.put(1, new NotebookItemDto(1, 1, "Tesr", "Sổ tay mẫu", 0, today));
            inMemoryNotebooks.put(2, new NotebookItemDto(2, 1, "Huy", "Sổ tay từ vựng", 12, today));
        }
    }

    public List<NotebookItemDto> findAllNotebooks(int userId) {
        String sql = """
                    SELECT n.id, n.user_id, n.title, n.description,
                           COUNT(w.id) as word_count,
                           COALESCE(DATE_FORMAT(n.created_at, '%d/%m/%Y'), '29/10/2026') as created_date
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

            if (list.isEmpty() && !inMemoryNotebooks.isEmpty()) {
                return new ArrayList<>(inMemoryNotebooks.values());
            }
            return list;
        } catch (Exception e) {
            log.warn("Lỗi khi đọc danh sách sổ tay từ MySQL: {}", e.getMessage());
            if (inMemoryNotebooks.isEmpty()) {
                String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                inMemoryNotebooks.put(1, new NotebookItemDto(1, userId, "Tesr", "Sổ tay mẫu", 0, today));
                inMemoryNotebooks.put(2, new NotebookItemDto(2, userId, "Huy", "Sổ tay từ vựng", 12, today));
            }
            return new ArrayList<>(inMemoryNotebooks.values());
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
            inMemoryNotebooks.put(newId, created);
            return created;
        } catch (Exception e) {
            log.warn("Lỗi khi tạo sổ tay mới vào MySQL, lưu tạm bộ nhớ: {}", e.getMessage());
            int newId = inMemoryNotebooks.size() + 10;
            NotebookItemDto created = new NotebookItemDto(newId, userId, title, description, 0, today);
            inMemoryNotebooks.put(newId, created);
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

        NotebookItemDto existing = inMemoryNotebooks.get(id);
        int wordCount = existing != null ? existing.wordCount() : 0;
        String date = existing != null ? existing.createdAt()
                : LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        NotebookItemDto updated = new NotebookItemDto(id, 1, title, description, wordCount, date);
        inMemoryNotebooks.put(id, updated);
        return updated;
    }

    public boolean deleteNotebook(int id) {
        try {
            jdbcTemplate.update("UPDATE user_notebook_words SET notebook_id = NULL WHERE notebook_id = ?", id);
            int rows = jdbcTemplate.update("DELETE FROM notebooks WHERE id = ?", id);
            inMemoryNotebooks.remove(id);
            return rows > 0;
        } catch (Exception e) {
            log.warn("Lỗi khi xóa sổ tay khỏi MySQL: {}", e.getMessage());
            inMemoryNotebooks.remove(id);
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
            return inMemoryCache.values().stream()
                    .filter(w -> w.notebookId() != null && w.notebookId() == notebookId)
                    .toList();
        }
    }

    public void upsertWordProgress(NotebookProgressItem item) {
        String sql = """
                    INSERT INTO user_notebook_words (user_id, word, reading, romaji, meaning, status, review_count, notebook_id)
                    VALUES (1, ?, ?, ?, ?, ?, 1, ?)
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
                    item.word(),
                    item.reading(),
                    item.romaji(),
                    item.meaning(),
                    item.status(),
                    item.notebookId());
        } catch (Exception e) {
            log.warn("Lỗi khi ghi bảng user_notebook_words (lưu vào cache tạm thời): {}", e.getMessage());
        }

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
                currentCount,
                item.notebookId()));
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
                    SELECT id, word, reading, romaji, meaning, status, review_count, notebook_id
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
                    rs.getInt("review_count"),
                    rs.getObject("notebook_id") != null ? rs.getInt("notebook_id") : null), status);

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
                    SELECT id, word, reading, romaji, meaning, status, review_count, notebook_id
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
                    rs.getInt("review_count"),
                    rs.getObject("notebook_id") != null ? rs.getInt("notebook_id") : null));

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
