package com.prm.backend.repository;

import com.prm.backend.dto.topic.TopicDtos.TopicInfo;
import com.prm.backend.dto.topic.TopicDtos.TopicWordItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;

@Repository
public class TopicRepository {

    private static final Logger log = LoggerFactory.getLogger(TopicRepository.class);
    private final JdbcTemplate jdbcTemplate;

    public TopicRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
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
            log.warn("Lỗi khi đọc bảng study_topics từ DB, sử dụng dữ liệu mặc định: {}", e.getMessage());
            return getDefaultTopics();
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
            List<TopicWordItem> words = jdbcTemplate.query(sql, (rs, rowNum) -> new TopicWordItem(
                    rs.getInt("id"),
                    rs.getString("topic_code"),
                    rs.getString("word"),
                    rs.getString("reading"),
                    rs.getString("romaji"),
                    rs.getString("meaning"),
                    rs.getString("example_jp"),
                    rs.getString("example_vi"),
                    rs.getInt("display_order")), topicCode);

            if (words.isEmpty()) {
                return getDefaultWords(topicCode);
            }
            return words;
        } catch (Exception e) {
            log.warn("Lỗi khi đọc bảng topic_words từ DB, sử dụng dữ liệu mặc định: {}", e.getMessage());
            return getDefaultWords(topicCode);
        }
    }

    private List<TopicInfo> getDefaultTopics() {
        return List.of(
                new TopicInfo("tu_vung_n4", "Từ vựng N4", "JLPT", "523 từ"),
                new TopicInfo("ngu_phap_n4", "Ngữ pháp N4", "JLPT", "436 từ"),
                new TopicInfo("han_tu_n4", "Hán tự N4", "JLPT", "167 từ"),
                new TopicInfo("tu_vung_n5", "Từ vựng N5", "JLPT", "571 từ"),
                new TopicInfo("xe_co", "Xe cộ", "CHUYEN_NGANH", "4 mục"),
                new TopicInfo("vat_lieu_dien_nuoc", "Vật liệu điện và nước", "CHUYEN_NGANH", "6 mục"),
                new TopicInfo("tho_co_khi", "Thợ cơ khí", "CHUYEN_NGANH", "7 mục"),
                new TopicInfo("loi_song", "Lối sống", "CHUYEN_NGANH", "12 mục"),
                new TopicInfo("it_cntt", "Công nghệ thông tin", "CHUYEN_NGANH", "6 mục"),
                new TopicInfo("xay_dung", "Xây dựng", "CHUYEN_NGANH", "4 mục"),
                new TopicInfo("dieu_duong", "Điều dưỡng & Y tế", "CHUYEN_NGANH", "4 mục"),
                new TopicInfo("khach_san_nha_hang", "Khách sạn & Nhà hàng", "CHUYEN_NGANH", "4 mục"),
                new TopicInfo("nong_nghiep", "Nông nghiệp", "CHUYEN_NGANH", "3 mục"),
                new TopicInfo("che_bien_thuc_pham", "Chế biến thực phẩm", "CHUYEN_NGANH", "3 mục"),
                new TopicInfo("may_mac", "May mặc", "CHUYEN_NGANH", "3 mục"),
                new TopicInfo("kinh_doanh", "Kinh doanh & Thương mại", "CHUYEN_NGANH", "3 mục"),
                new TopicInfo("giao_tiep_hang_ngay", "Giao tiếp hàng ngày", "KHAC", "15 mục"),
                new TopicInfo("du_lich_am_thuc", "Du lịch & Ẩm thực", "KHAC", "8 mục"));
    }

    private List<TopicWordItem> getDefaultWords(String topicCode) {
        List<TopicWordItem> list = new ArrayList<>();
        if ("tu_vung_n4".equals(topicCode) || topicCode == null) {
            list.add(new TopicWordItem(1, "tu_vung_n4", "日", "ひ / にち / か / び / ぴ", "hi / nichi",
                    "Ngày, mặt trời, chủ nhật", "日曜日に行きます。", "Tôi sẽ đi vào Chủ nhật.", 1));
            list.add(new TopicWordItem(2, "tu_vung_n4", "あっ", "あっ", "a", "A! Á! Ôi! (thán từ)", "あっ、忘れてた！",
                    "Á, tôi quên mất rồi!", 2));
            list.add(new TopicWordItem(3, "tu_vung_n4", "案内", "あんない", "annai", "Hướng dẫn, dẫn đường", "町を案内します。",
                    "Tôi sẽ hướng dẫn bạn tham quan thị trấn.", 3));
            list.add(new TopicWordItem(4, "tu_vung_n4", "意見", "いけん", "iken", "Ý kiến, quan điểm", "あなたの意見を聞かせて。",
                    "Hãy cho tôi nghe ý kiến của bạn.", 4));
            list.add(new TopicWordItem(5, "tu_vung_n4", "安心", "あんしん", "anshin", "An tâm, yên lòng", "それを聞いて安心しました。",
                    "Nghe điều đó tôi đã an tâm hơn.", 5));
            list.add(new TopicWordItem(6, "tu_vung_n4", "急ぐ", "いそぐ", "isogu", "Vội vã, gấp rút", "急いでください。",
                    "Xin hãy khẩn trương lên.", 6));
            list.add(new TopicWordItem(7, "tu_vung_n4", "受付", "うけつけ", "uketsuke", "Quầy tiếp tân, lễ tân",
                    "受付で名前を書いてください。", "Hãy ghi tên ở quầy lễ tân.", 7));
            list.add(new TopicWordItem(8, "tu_vung_n4", "運動", "うんどう", "undou", "Vận động, tập thể thao", "毎朝運動しています。",
                    "Tôi tập thể dục mỗi sáng.", 8));
            list.add(new TopicWordItem(9, "tu_vung_n4", "選ぶ", "えらぶ", "erabu", "Chọn, lựa chọn", "好きなものを選んでね。",
                    "Hãy chọn món bạn thích nhé.", 9));
            list.add(new TopicWordItem(10, "tu_vung_n4", "遅れる", "おくれる", "okureru", "Đến muộn, trễ giờ", "電車に遅れました。",
                    "Tôi bị trễ chuyến tàu điện.", 10));
        } else if ("xe_co".equals(topicCode)) {
            list.add(new TopicWordItem(1, "xe_co", "車", "くるま", "kuruma", "Xe ô tô, xe hơi", "車を運転します。",
                    "Tôi lái xe ô tô.", 1));
            list.add(new TopicWordItem(2, "xe_co", "自転車", "じてんしゃ", "jitensha", "Xe đạp", "自転車で行きます。",
                    "Tôi đi bằng xe đạp.", 2));
            list.add(new TopicWordItem(3, "xe_co", "バイク", "ばいく", "baiku", "Xe máy", "バイクに乗ります。", "Tôi đi xe máy.", 3));
            list.add(new TopicWordItem(4, "xe_co", "エンジン", "えんじん", "enjin", "Động cơ xe", "エンジンが故障した。",
                    "Động cơ bị hỏng.", 4));
        } else {
            list.add(new TopicWordItem(1, topicCode, "日", "ひ / にち", "hi", "Ngày, mặt trời", "今日は晴れです。",
                    "Hôm nay trời nắng đẹp.", 1));
            list.add(new TopicWordItem(2, topicCode, "あっ", "あっ", "a", "A! (thán từ)", "あっ、危ない！", "A! Nguy hiểm quá!",
                    2));
            list.add(new TopicWordItem(3, topicCode, "勉強", "べんきょう", "benkyou", "Học tập", "日本語を勉強する。",
                    "Học tiếng Nhật.", 3));
        }
        return list;
    }
}
