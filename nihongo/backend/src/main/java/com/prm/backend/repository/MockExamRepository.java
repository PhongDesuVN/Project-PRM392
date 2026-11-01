package com.prm.backend.repository;

import com.prm.backend.dto.mockexam.MockExamDtos.ExamOption;
import com.prm.backend.dto.mockexam.MockExamDtos.ExamQuestion;
import com.prm.backend.dto.mockexam.MockExamDtos.ExamSummary;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public class MockExamRepository {

    private static final Logger log = LoggerFactory.getLogger(MockExamRepository.class);

    /** App chua gui token cho cac API hoc tap nen dung user mac dinh, giong search-history. */
    private static final int DEFAULT_USER_ID = 1;

    private final JdbcTemplate jdbcTemplate;

    public MockExamRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        initDefaultUser();
    }

    private void initDefaultUser() {
        try {
            jdbcTemplate.update("""
                INSERT IGNORE INTO users (id, email, full_name, role)
                VALUES (1, 'default@nihongo.app', 'Nihongo User', 'user')
            """);
        } catch (Exception e) {
            log.warn("Không thể tạo user mặc định: {}", e.getMessage());
        }
    }

    public List<ExamSummary> findTests(String level, String type) {
        StringBuilder sql = new StringBuilder("""
                SELECT t.id, t.title, t.level, t.test_type, t.duration_minutes, t.total_questions,
                       COUNT(a.id) AS attempts, COALESCE(MAX(a.score), 0) AS best_score
                FROM jlpt_tests t
                LEFT JOIN jlpt_user_attempts a ON a.test_id = t.id AND a.user_id = ?
                WHERE 1 = 1
                """);
        List<Object> args = new ArrayList<>(List.of(DEFAULT_USER_ID));
        if (level != null && !level.isBlank()) {
            sql.append(" AND t.level = ?");
            args.add(level.trim().toUpperCase());
        }
        if (type != null && !type.isBlank()) {
            sql.append(" AND t.test_type = ?");
            args.add(type.trim().toLowerCase());
        }
        sql.append(" GROUP BY t.id ORDER BY t.level DESC, t.id ASC");

        return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
            int total = rs.getInt("total_questions");
            int best = total == 0 ? 0 : Math.round(rs.getInt("best_score") * 100f / total);
            return new ExamSummary(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("level"),
                    rs.getString("test_type"),
                    rs.getInt("duration_minutes"),
                    total,
                    rs.getInt("attempts"),
                    best);
        }, args.toArray());
    }

    public Optional<ExamSummary> findTest(int testId) {
        List<ExamSummary> rows = jdbcTemplate.query("""
                SELECT id, title, level, test_type, duration_minutes, total_questions
                FROM jlpt_tests WHERE id = ?
                """, (rs, rowNum) -> new ExamSummary(
                rs.getInt("id"),
                rs.getString("title"),
                rs.getString("level"),
                rs.getString("test_type"),
                rs.getInt("duration_minutes"),
                rs.getInt("total_questions"),
                0,
                0), testId);
        return rows.stream().findFirst();
    }

    /** Cau hoi kem lua chon (khong lo is_correct), da sap theo thu tu de. */
    public List<ExamQuestion> findQuestions(int testId) {
        Map<Integer, List<ExamOption>> optionsByQuestion = new HashMap<>();
        jdbcTemplate.query("""
                SELECT o.id, o.question_id, o.option_text
                FROM jlpt_options o
                JOIN jlpt_questions q ON q.id = o.question_id
                WHERE q.test_id = ?
                ORDER BY o.id ASC
                """, rs -> {
            optionsByQuestion
                    .computeIfAbsent(rs.getInt("question_id"), k -> new ArrayList<>())
                    .add(new ExamOption(rs.getInt("id"), rs.getString("option_text")));
        }, testId);

        return jdbcTemplate.query("""
                SELECT id, section, question_text, passage_text
                FROM jlpt_questions
                WHERE test_id = ?
                ORDER BY question_order ASC, id ASC
                """, (rs, rowNum) -> new ExamQuestion(
                rs.getInt("id"),
                rs.getString("section"),
                rs.getString("question_text"),
                rs.getString("passage_text"),
                optionsByQuestion.getOrDefault(rs.getInt("id"), List.of())), testId);
    }

    /** Dap an dung + giai thich + section cua tung cau trong de, de cham diem. */
    public Map<Integer, AnswerKey> findAnswerKeys(int testId) {
        Map<Integer, AnswerKey> keys = new LinkedHashMap<>();
        jdbcTemplate.query("""
                SELECT q.id, q.section, q.explanation, o.id AS option_id, o.is_correct
                FROM jlpt_questions q
                JOIN jlpt_options o ON o.question_id = q.id
                WHERE q.test_id = ?
                ORDER BY q.question_order ASC, q.id ASC, o.id ASC
                """, rs -> {
            int questionId = rs.getInt("id");
            String section = rs.getString("section");
            String explanation = rs.getString("explanation");
            AnswerKey key = keys.computeIfAbsent(questionId,
                    id -> new AnswerKey(id, section, explanation));
            key.optionIds.add(rs.getInt("option_id"));
            if (rs.getBoolean("is_correct")) {
                key.correctOptionId = rs.getInt("option_id");
            }
        }, testId);
        return keys;
    }

    public int saveAttempt(int testId, int score, Map<Integer, Integer> selectedByQuestion) {
        jdbcTemplate.update("""
                INSERT INTO jlpt_user_attempts (user_id, test_id, score) VALUES (?, ?, ?)
                """, DEFAULT_USER_ID, testId, score);
        Integer attemptId = jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);

        for (Map.Entry<Integer, Integer> e : selectedByQuestion.entrySet()) {
            jdbcTemplate.update("""
                    INSERT INTO jlpt_user_answers (attempt_id, question_id, selected_option_id)
                    VALUES (?, ?, ?)
                    """, attemptId, e.getKey(), e.getValue());
        }
        return attemptId == null ? 0 : attemptId;
    }

    public static class AnswerKey {
        public final int questionId;
        public final String section;
        public final String explanation;
        public final Set<Integer> optionIds = new HashSet<>();
        public Integer correctOptionId;

        AnswerKey(int questionId, String section, String explanation) {
            this.questionId = questionId;
            this.section = section;
            this.explanation = explanation;
        }
    }
}
