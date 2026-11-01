package com.prm.backend.repository;

import com.prm.backend.dto.topic.TopicDtos.TopicInfo;
import com.prm.backend.dto.topic.TopicDtos.TopicWordItem;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Repository;

import java.util.Collections;
import java.util.List;

@Repository
public class TopicRepository {

    private static final Logger log = LoggerFactory.getLogger(TopicRepository.class);
    private final JdbcTemplate jdbcTemplate;

    public TopicRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        try {
            Integer count = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM topic_words", Integer.class);
            if (count == null || count < 50) {
                ResourceDatabasePopulator populator = new ResourceDatabasePopulator(
                        new ClassPathResource("db/seed_topics.sql")
                );
                populator.setContinueOnError(true);
                if (jdbcTemplate.getDataSource() != null) {
                    populator.execute(jdbcTemplate.getDataSource());
                    log.info("Đã nạp toàn bộ danh mục và từ vựng từ seed_topics.sql vào MySQL!");
                }
            }
        } catch (Exception e) {
            log.warn("Lỗi khi tự động nạp topic_words vào MySQL: {}", e.getMessage());
        }

        try {
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '20 từ' WHERE topic_code = 'tu_vung_n4'");
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '16 mục' WHERE topic_code = 'ngu_phap_n4'");
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '5 chữ' WHERE topic_code = 'han_tu_n4'");
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '3 từ' WHERE topic_code = 'tu_vung_n5'");
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '5 mục' WHERE topic_code = 'tho_co_khi'");
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '4 mục' WHERE topic_code = 'loi_song'");
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '5 mục' WHERE topic_code = 'giao_tiep_hang_ngay'");
            jdbcTemplate.update("UPDATE study_topics SET item_count_text = '4 mục' WHERE topic_code = 'du_lich_am_thuc'");
        } catch (Exception ignored) {
        }

        try {
            Integer grammarCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM grammars", Integer.class);
            Integer exampleCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM examples", Integer.class);
            if (grammarCount == null || grammarCount == 0 || exampleCount == null || exampleCount == 0) {
                ResourceDatabasePopulator relationalPopulator = new ResourceDatabasePopulator(
                        new ClassPathResource("db/seed_relational_data.sql")
                );
                relationalPopulator.setContinueOnError(true);
                if (jdbcTemplate.getDataSource() != null) {
                    relationalPopulator.execute(jdbcTemplate.getDataSource());
                    log.info("Đã nạp thành công toàn bộ dữ liệu vào các bảng riêng grammars, kanjis, words, word_meanings, examples trong MySQL!");
                }
            }
        } catch (Exception e) {
            log.warn("Lỗi khi tự động nạp dữ liệu các bảng quan hệ grammars/kanjis/examples: {}", e.getMessage());
        }
    }

    public List<TopicInfo> findAllTopics() {
        String sql = "SELECT topic_code, title, category, item_count_text FROM study_topics ORDER BY id ASC";
        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> new TopicInfo(
                    rs.getString("topic_code"),
                    rs.getString("title"),
                    rs.getString("category"),
                    rs.getString("item_count_text")));
        } catch (Exception e) {
            log.warn("Lỗi khi đọc bảng study_topics từ DB: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    public List<TopicWordItem> findWordsByTopicCode(String topicCode) {
        String sql = """
                SELECT id, topic_code, word, reading, romaji, meaning, example_jp, example_vi, display_order
                FROM topic_words
                WHERE topic_code = ?
                ORDER BY display_order ASC, id ASC
                """;
        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> new TopicWordItem(
                    rs.getInt("id"),
                    rs.getString("topic_code"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("example_jp"),
                    rs.getString("example_vi"),
                    rs.getInt("display_order")), topicCode);
        } catch (Exception e) {
            log.warn("Lỗi khi đọc bảng topic_words từ DB cho chủ đề {}: {}", topicCode, e.getMessage());
            return Collections.emptyList();
        }
    }
}
