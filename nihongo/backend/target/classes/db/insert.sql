
USE PRM;

-- =============================================================================
-- PHẦN 1: HÁN TỰ (KANJI) CƠ BẢN
-- =============================================================================

INSERT IGNORE INTO kanjis (
    kanji_char,
    han_viet,
    radical,
    stroke_count,
    onyomi,
    kunyomi,
    jlpt_level,
    meaning
)
VALUES
    ('学', 'HỌC', '子', 8, 'ガク', 'まなぶ', 'N5', 'học; học tập'),
    ('生', 'SINH', '生', 5, 'セイ・ショウ', 'いきる・うまれる', 'N5', 'sinh; sống; học sinh'),
    ('校', 'HIỆU', '木', 10, 'コウ', NULL, 'N5', 'trường học'),
    ('日', 'NHẬT', '日', 4, 'ニチ・ジツ', 'ひ・か', 'N5', 'mặt trời; ngày; Nhật Bản'),
    ('本', 'BẢN', '木', 5, 'ホン', 'もと', 'N5', 'gốc; sách; Nhật Bản'),
    ('先', 'TIÊN', '儿', 6, 'セン', 'さき', 'N5', 'trước; phía trước'),
    ('勉', 'MIỄN', '力', 10, 'ベン', NULL, 'N5', 'cố gắng; chăm chỉ'),
    ('強', 'CƯỜNG', '弓', 11, 'キョウ・ゴウ', 'つよい・つよまる', 'N5', 'mạnh; cố gắng');

-- =============================================================================
-- PHẦN 2: 100 TỪ VỰNG TỪ ĐIỂN MẪU (N5 ĐẾN N1)
-- =============================================================================

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_dictionary_vocab_expansion (
    word VARCHAR(100) NOT NULL,
    reading VARCHAR(100) NOT NULL,
    romaji VARCHAR(100) NOT NULL,
    jlpt_level VARCHAR(2) NOT NULL,
    part_of_speech VARCHAR(80) NOT NULL,
    meaning VARCHAR(500) NOT NULL
);

INSERT INTO tmp_dictionary_vocab_expansion
    (word, reading, romaji, jlpt_level, part_of_speech, meaning)
VALUES
    -- N5 (20 từ)
    ('あなた', 'あなた', 'anata', 'N5', 'đại từ', 'bạn; anh/chị'),
    ('家', 'いえ', 'ie', 'N5', 'danh từ', 'nhà'),
    ('駅', 'えき', 'eki', 'N5', 'danh từ', 'nhà ga'),
    ('お金', 'おかね', 'okane', 'N5', 'danh từ', 'tiền'),
    ('車', 'くるま', 'kuruma', 'N5', 'danh từ', 'xe ô tô'),
    ('電車', 'でんしゃ', 'densha', 'N5', 'danh từ', 'tàu điện'),
    ('時間', 'じかん', 'jikan', 'N5', 'danh từ', 'thời gian; giờ'),
    ('名前', 'なまえ', 'namae', 'N5', 'danh từ', 'tên'),
    ('友達', 'ともだち', 'tomodachi', 'N5', 'danh từ', 'bạn bè'),
    ('食べる', 'たべる', 'taberu', 'N5', 'động từ', 'ăn'),
    ('飲む', 'のむ', 'nomu', 'N5', 'động từ', 'uống'),
    ('行く', 'いく', 'iku', 'N5', 'động từ', 'đi'),
    ('来る', 'くる', 'kuru', 'N5', 'động từ', 'đến'),
    ('見る', 'みる', 'miru', 'N5', 'động từ', 'xem; nhìn'),
    ('聞く', 'きく', 'kiku', 'N5', 'động từ', 'nghe; hỏi'),
    ('買う', 'かう', 'kau', 'N5', 'động từ', 'mua'),
    ('大きい', 'おおきい', 'ookii', 'N5', 'tính từ', 'to; lớn'),
    ('小さい', 'chiisai', 'chiisai', 'N5', 'tính từ', 'nhỏ'),
    ('今日', 'きょう', 'kyou', 'N5', 'danh từ', 'hôm nay'),
    ('明日', 'あした', 'ashita', 'N5', 'danh từ', 'ngày mai'),
    -- Thêm các từ N5 cơ bản
    ('学生', 'がくせい', 'gakusei', 'N5', 'danh từ', 'học sinh; sinh viên'),
    ('学校', 'がっこう', 'gakkou', 'N5', 'danh từ', 'trường học'),
    ('日本', 'にほん', 'nihon', 'N5', 'danh từ', 'Nhật Bản'),
    ('先生', 'せんせい', 'sensei', 'N5', 'danh từ', 'giáo viên; thầy/cô'),
    ('勉強', 'べんきょう', 'benkyou', 'N5', 'danh từ; động từする', 'học tập; học bài'),

    -- N4 (20 từ)
    ('旅行', 'りょこう', 'ryokou', 'N4', 'danh từ; động từする', 'du lịch; chuyến đi'),
    ('会社', 'かいしゃ', 'kaisha', 'N4', 'danh từ', 'công ty'),
    ('仕事', 'しごと', 'shigoto', 'N4', 'danh từ', 'công việc'),
    ('病院', 'びょういん', 'byouin', 'N4', 'danh từ', 'bệnh viện'),
    ('薬', 'くすり', 'kusuri', 'N4', 'danh từ', 'thuốc'),
    ('料理', 'りょうり', 'ryouri', 'N4', 'danh từ; động từする', 'món ăn; nấu ăn'),
    ('練習', 'れんしゅう', 'renshuu', 'N4', 'danh từ; động từする', 'luyện tập'),
    ('質問', 'しつもん', 'shitsumon', 'N4', 'danh từ; động từする', 'câu hỏi; hỏi'),
    ('答える', 'こたえる', 'kotaeru', 'N4', 'động từ', 'trả lời'),
    ('始める', 'はじめる', 'hajimeru', 'N4', 'động từ', 'bắt đầu'),
    ('終わる', 'おわる', 'owaru', 'N4', 'động từ', 'kết thúc'),
    ('忘れる', 'わすれる', 'wasureru', 'N4', 'động từ', 'quên'),
    ('約束', 'やくそく', 'yakusoku', 'N4', 'danh từ; động từする', 'lời hứa; cuộc hẹn'),
    ('必要', 'ひつよう', 'hitsuyou', 'N4', 'tính từ な', 'cần thiết'),
    ('便利', 'べんり', 'benri', 'N4', 'tính từ な', 'tiện lợi'),
    ('不便', 'ふべん', 'fuben', 'N4', 'tính từ な', 'bất tiện'),
    ('安心', 'あんしん', 'anshin', 'N4', 'danh từ; tính từ な', 'yên tâm; an tâm'),
    ('有名', 'ゆうめい', 'yuumei', 'N4', 'tính từ な', 'nổi tiếng'),
    ('特別', 'とくべつ', 'tokubetsu', 'N4', 'tính từ な', 'đặc biệt'),
    ('連絡', 'れんらく', 'renraku', 'N4', 'danh từ; động từする', 'liên lạc; thông báo'),

    -- N3 (20 từ)
    ('経験', 'けいけん', 'keiken', 'N3', 'danh từ; động từする', 'kinh nghiệm; trải nghiệm'),
    ('文化', 'ぶんか', 'bunka', 'N3', 'danh từ', 'văn hóa'),
    ('社会', 'しゃかい', 'shakai', 'N3', 'danh từ', 'xã hội'),
    ('経済', 'けいざい', 'keizai', 'N3', 'danh từ', 'kinh tế'),
    ('技術', 'ぎじゅつ', 'gijutsu', 'N3', 'danh từ', 'kỹ thuật; công nghệ'),
    ('環境', 'かんきょう', 'kankyou', 'N3', 'danh từ', 'môi trường'),
    ('原因', 'げんいん', 'genin', 'N3', 'danh từ', 'nguyên nhân'),
    ('結果', 'けっか', 'kekka', 'N3', 'danh từ', 'kết quả'),
    ('関係', 'かんけい', 'kankei', 'N3', 'danh từ; động từする', 'quan hệ; liên quan'),
    ('連続', 'れんぞく', 'renzoku', 'N3', 'danh từ; động từする', 'liên tục; tiếp diễn'),
    ('参加', 'さんか', 'sanka', 'N3', 'danh từ; động từする', 'tham gia'),
    ('説明', 'せつめい', 'setsumei', 'N3', 'danh từ; động từする', 'giải thích; lời giải thích'),
    ('比較', 'ひかく', 'hikaku', 'N3', 'danh từ; động từする', 'so sánh'),
    ('確認', 'かくにん', 'kakunin', 'N3', 'danh từ; động từする', 'xác nhận; kiểm tra'),
    ('相談', 'そうだん', 'soudan', 'N3', 'danh từ; động từする', 'trao đổi; bàn bạc'),
    ('利用', 'りよう', 'riyou', 'N3', 'danh từ; động từする', 'sử dụng'),
    ('発見', 'はっけん', 'hakken', 'N3', 'danh từ; động từする', 'phát hiện'),
    ('増える', 'ふえる', 'fueru', 'N3', 'động từ', 'tăng lên'),
    ('減る', 'へる', 'heru', 'N3', 'động từ', 'giảm đi'),
    ('進む', 'すすむ', 'susumu', 'N3', 'động từ', 'tiến lên; tiến triển'),

    -- N2 (20 từ)
    ('制度', 'せいど', 'seido', 'N2', 'danh từ', 'chế độ; hệ thống'),
    ('状況', 'じょうきょう', 'joukyou', 'N2', 'danh từ', 'tình hình; tình trạng'),
    ('影響', 'えいきょう', 'eikyou', 'N2', 'danh từ; động từする', 'ảnh hưởng; tác động'),
    ('責任', 'せきにん', 'sekinin', 'N2', 'danh từ', 'trách nhiệm'),
    ('判断', 'はんだん', 'handan', 'N2', 'danh từ; động từする', 'phán đoán; quyết định'),
    ('適当', 'てきとう', 'tekitou', 'N2', 'tính từ な', 'thích hợp; phù hợp'),
    ('具体', 'ぐたい', 'gutai', 'N2', 'danh từ; tính từ な', 'cụ thể'),
    ('基本', 'きほん', 'kihon', 'N2', 'danh từ', 'cơ bản; nền tảng'),
    ('対象', 'たいしょう', 'taishou', 'N2', 'danh từ', 'đối tượng'),
    ('目的', 'もくてき', 'mokuteki', 'N2', 'danh từ', 'mục đích'),
    ('効果', 'こうか', 'kouka', 'N2', 'danh từ', 'hiệu quả; tác dụng'),
    ('解決', 'かいけつ', 'kaiketsu', 'N2', 'danh từ; động từする', 'giải quyết'),
    ('提案', 'ていあん', 'teian', 'N2', 'danh từ; động từする', 'đề xuất; kiến nghị'),
    ('実施', 'じっし', 'jisshi', 'N2', 'danh từ; động từする', 'thực hiện; triển khai'),
    ('維持', 'いじ', 'iji', 'N2', 'danh từ; động từする', 'duy trì'),
    ('管理', 'かんり', 'kanri', 'N2', 'danh từ; động từする', 'quản lý'),
    ('評価', 'ひょうか', 'hyouka', 'N2', 'danh từ; động từする', 'đánh giá'),
    ('供給', 'きょうきゅう', 'kyoukyuu', 'N2', 'danh từ; động từする', 'cung cấp; cung ứng'),
    ('消費', 'しょうひ', 'shouhi', 'N2', 'danh từ; động từする', 'tiêu thụ'),
    ('傾向', 'けいこう', 'keikou', 'N2', 'danh từ', 'xu hướng; khuynh hướng'),

    -- N1 (20 từ)
    ('概念', 'がいねん', 'gainen', 'N1', 'danh từ', 'khái niệm'),
    ('哲学', 'てつがく', 'tetsugaku', 'N1', 'danh từ', 'triết học'),
    ('矛盾', 'むじゅん', 'mujun', 'N1', 'danh từ; động từする', 'mâu thuẫn'),
    ('促進', 'そくしん', 'sokushin', 'N1', 'danh từ; động từする', 'thúc đẩy'),
    ('懸念', 'けねん', 'kenen', 'N1', 'danh từ; động từする', 'lo ngại; quan ngại'),
    ('把握', 'はあく', 'haaku', 'N1', 'danh từ; động từする', 'nắm bắt; hiểu rõ'),
    ('踏まえる', 'ふまえる', 'fumaeru', 'N1', 'động từ', 'dựa trên; căn cứ vào'),
    ('携わる', 'たずさわる', 'tazusawaru', 'N1', 'động từ', 'tham gia; đảm nhiệm'),
    ('著しい', 'いちじるしい', 'ichijirushii', 'N1', 'tính từ い', 'đáng kể; rõ rệt'),
    ('乏しい', 'とぼしい', 'toboshii', 'N1', 'tính từ い', 'thiếu; khan hiếm'),
    ('余儀ない', 'よぎない', 'yoginai', 'N1', 'tính từ い', 'không còn cách nào khác; bất đắc dĩ'),
    ('ひとえに', 'ひとえに', 'hitoeni', 'N1', 'phó từ', 'hoàn toàn; chỉ nhờ vào'),
    ('もっぱら', 'もっぱら', 'moppara', 'N1', 'phó từ', 'chủ yếu; chuyên'),
    ('いかん', 'いかん', 'ikan', 'N1', 'danh từ', 'tùy thuộc vào; tùy theo'),
    ('趣旨', 'しゅし', 'shushi', 'N1', 'danh từ', 'mục đích; ý chính'),
    ('謙虚', 'けんきょ', 'kenkyo', 'N1', 'tính từ な', 'khiêm tốn'),
    ('妥協', 'だきょう', 'dakyou', 'N1', 'danh từ; động từする', 'thỏa hiệp; nhượng bộ'),
    ('是正', 'ぜせい', 'zesei', 'N1', 'danh từ; động từする', 'chỉnh sửa; khắc phục'),
    ('遂行', 'すいこう', 'suikou', 'N1', 'danh từ; động từする', 'hoàn thành; thực thi'),
    ('模索', 'もさく', 'mosaku', 'N1', 'danh từ; động từする', 'tìm tòi; tìm hướng giải quyết');

START TRANSACTION;

-- Chèn vào bảng words nếu chưa tồn tại
INSERT INTO words (word, reading, romaji, jlpt_level)
SELECT sample.word, sample.reading, sample.romaji, sample.jlpt_level
FROM tmp_dictionary_vocab_expansion AS sample
WHERE NOT EXISTS (
    SELECT 1
    FROM words AS existing
    WHERE existing.word = sample.word
      AND existing.reading = sample.reading
);

-- Chèn nghĩa vào bảng word_meanings
INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT word_row.id, 'vi', sample.part_of_speech, sample.meaning
FROM tmp_dictionary_vocab_expansion AS sample
JOIN words AS word_row
    ON word_row.word = sample.word
   AND word_row.reading = sample.reading
WHERE NOT EXISTS (
    SELECT 1
    FROM word_meanings AS existing
    WHERE existing.word_id = word_row.id
      AND existing.lang_code = 'vi'
      AND existing.meaning = sample.meaning
);

COMMIT;
DROP TEMPORARY TABLE IF EXISTS tmp_dictionary_vocab_expansion;

-- =============================================================================
-- PHẦN 3: LIÊN KẾT KANJI & TỪ VỰNG (KANJI_WORDS)
-- =============================================================================

START TRANSACTION;

INSERT INTO kanji_words (kanji_id, word_id)
SELECT kanji_row.id, word_row.id
FROM (
    SELECT '学' AS kanji_char, '学生' AS word, 'がくせい' AS reading
    UNION ALL SELECT '生', '学生', 'がくせい'
    UNION ALL SELECT '学', '学校', 'がっこう'
    UNION ALL SELECT '校', '学校', 'がっこう'
    UNION ALL SELECT '日', '日本', 'にほん'
    UNION ALL SELECT '本', '日本', 'にほん'
    UNION ALL SELECT '先', '先生', 'せんせい'
    UNION ALL SELECT '生', '先生', 'せんせい'
    UNION ALL SELECT '勉', '勉強', 'べんきょう'
    UNION ALL SELECT '強', '勉強', 'べんきょう'
) AS sample
JOIN kanjis kanji_row ON kanji_row.kanji_char = sample.kanji_char
JOIN words word_row
    ON word_row.word = sample.word
   AND word_row.reading = sample.reading
WHERE NOT EXISTS (
    SELECT 1
    FROM kanji_words existing
    WHERE existing.kanji_id = kanji_row.id
      AND existing.word_id = word_row.id
);

COMMIT;

-- =============================================================================
-- PHẦN 4: DANH MỤC CHỦ ĐỀ HỌC TẬP (STUDY_TOPICS)
-- =============================================================================

INSERT INTO study_topics (topic_code, title, category, item_count_text) VALUES
('tu_vung_n4', 'Từ vựng N4', 'JLPT', '523 từ'),
('ngu_phap_n4', 'Ngữ pháp N4', 'JLPT', '436 từ'),
('han_tu_n4', 'Hán tự N4', 'JLPT', '167 từ'),
('tu_vung_n5', 'Từ vựng N5', 'JLPT', '571 từ'),
('xe_co', 'Xe cộ', 'CHUYEN_NGANH', '4 mục'),
('vat_lieu_dien_nuoc', 'Vật liệu điện và nước', 'CHUYEN_NGANH', '6 mục'),
('tho_co_khi', 'Thợ cơ khí', 'CHUYEN_NGANH', '7 mục'),
('loi_song', 'Lối sống', 'CHUYEN_NGANH', '12 mục'),
('it_cntt', 'Công nghệ thông tin', 'CHUYEN_NGANH', '6 mục'),
('xay_dung', 'Xây dựng', 'CHUYEN_NGANH', '4 mục'),
('dieu_duong', 'Điều dưỡng & Y tế', 'CHUYEN_NGANH', '4 mục'),
('khach_san_nha_hang', 'Khách sạn & Nhà hàng', 'CHUYEN_NGANH', '4 mục'),
('nong_nghiep', 'Nông nghiệp', 'CHUYEN_NGANH', '3 mục'),
('che_bien_thuc_pham', 'Chế biến thực phẩm', 'CHUYEN_NGANH', '3 mục'),
('may_mac', 'May mặc', 'CHUYEN_NGANH', '3 mục'),
('kinh_doanh', 'Kinh doanh & Thương mại', 'CHUYEN_NGANH', '3 mục'),
('giao_tiep_hang_ngay', 'Giao tiếp hàng ngày', 'KHAC', '15 mục'),
('du_lich_am_thuc', 'Du lịch & Ẩm thực', 'KHAC', '8 mục')
ON DUPLICATE KEY UPDATE 
    title=VALUES(title),
    category=VALUES(category),
    item_count_text=VALUES(item_count_text);

-- =============================================================================
-- PHẦN 5: TỪ VỰNG CHI TIẾT & FLASHCARD THEO CHỦ ĐỀ (TOPIC_WORDS)
-- =============================================================================

-- 5.1. Từ vựng N4 (Chuẩn xác theo hình ảnh tham khảo: từ '日', 'あっ'...)
INSERT INTO topic_words (topic_code, word, reading, romaji, meaning, example_jp, example_vi, display_order) VALUES
('tu_vung_n4', '日', '「 ひ 」「 にち 」「 か 」「 び 」「 ぴ 」', 'hi / nichi / ka', 'Ngày, mặt trời, chủ nhật', '日曜日には友達と映画を見に行きます。', 'Chủ nhật tôi sẽ đi xem phim cùng bạn bè.', 1),
('tu_vung_n4', 'あっ', '「 あっ 」', 'a', 'A! Á! Ôi! (thán từ thể hiện sự bất ngờ, nhớ ra điều gì)', 'あっ、財布を家に忘れてしまいました！', 'Á, tôi để quên ví ở nhà mất rồi!', 2),
('tu_vung_n4', '案内', '「 あんない 」', 'annai', 'Hướng dẫn, dẫn đường, thông báo', '東京の街を案内してあげましょう。', 'Để tôi dẫn bạn đi tham quan Tokyo nhé.', 3),
('tu_vung_n4', '意見', '「 いけん 」', 'iken', 'Ý kiến, quan điểm', 'あなたの率直な意見を聞かせてください。', 'Xin hãy cho tôi biết ý kiến thẳng thắn của bạn.', 4),
('tu_vung_n4', '安心', '「 あんしん 」', 'anshin', 'An tâm, yên lòng', '無事だと分かって安心しました。', 'Biết bạn bình an tôi thấy thật yên lòng.', 5),
('tu_vung_n4', '急ぐ', '「 いそぐ 」', 'isogu', 'Vội vã, gấp rút', '電車に遅れないよう急ぎましょう。', 'Chúng ta hãy nhanh lên để không bị trễ tàu.', 6),
('tu_vung_n4', '受付', '「 うけつけ 」', 'uketsuke', 'Quầy tiếp tân, bàn lễ tân', '受付で身分証を提示してください。', 'Vui lòng xuất trình giấy tờ tùy thân tại quầy lễ tân.', 7),
('tu_vung_n4', '運動', '「 うんどう 」', 'undou', 'Vận động, tập thể thao', '健康のために毎朝運動しています。', 'Tôi tập thể dục mỗi sáng vì sức khỏe.', 8),
('tu_vung_n4', '選ぶ', '「 えらぶ 」', 'erabu', 'Chọn, lựa chọn', 'メニューから好きな料理を選んでください。', 'Hãy chọn món ăn yêu thích từ thực đơn nhé.', 9),
('tu_vung_n4', '遅れる', '「 おくれる 」', 'okureru', 'Đến muộn, trễ hẹn, chậm trễ', '渋滞のせいで約束の時間に遅れました。', 'Vì kẹt xe nên tôi đã đến trễ giờ hẹn.', 10),
('tu_vung_n4', '送る', '「 おくる 」', 'okuru', 'Gửi hàng, tiễn người', '荷物を故郷の母に送りました。', 'Tôi đã gửi bưu kiện về cho mẹ ở quê.', 11),
('tu_vung_n4', '驚く', '「 おどろく 」', 'odoroku', 'Kinh ngạc, giật mình, ngạc nhiên', '突然の知らせに大変驚きました。', 'Tôi đã rất kinh ngạc trước tin báo đột ngột.', 12);

-- 5.2. Hán tự N4
INSERT INTO topic_words (topic_code, word, reading, romaji, meaning, example_jp, example_vi, display_order) VALUES
('han_tu_n4', '日', '「 ニチ / ジツ / ひ / か 」', 'nichi / hi', 'NHẬT: Mặt trời, ngày', '日本（にほん）: Nước Nhật', 'Hôm nay là ngày đẹp trời.', 1),
('han_tu_n4', '月', '「 ゲツ / ガツ / つき 」', 'getsu / tsuki', 'NGUYỆT: Mặt trăng, tháng', '月曜日（げつようび）: Thứ Hai', 'Mặt trăng đêm nay thật tròn.', 2),
('han_tu_n4', '火', '「 カ / ひ 」', 'ka / hi', 'HỎA: Lửa', '火曜日（かようび）: Thứ Ba', 'Cẩn thận với lửa khi nấu ăn.', 3),
('han_tu_n4', '水', '「 スイ / みず 」', 'sui / mizu', 'THỦY: Nước', '水曜日（すいようび）: Thứ Tư', 'Xin cho tôi một cốc nước.', 4),
('han_tu_n4', '木', '「 モク / ボク / き 」', 'moku / ki', 'MỘC: Cây, gỗ', '木曜日（もくようび）: Thứ Năm', 'Dưới bóng mát của cây to.', 5);

-- 5.3. Chuyên ngành: Xe cộ
INSERT INTO topic_words (topic_code, word, reading, romaji, meaning, example_jp, example_vi, display_order) VALUES
('xe_co', '車', '「 くるま 」', 'kuruma', 'Xe hơi, ô tô', '新しい車を買いました。', 'Tôi đã mua một chiếc xe ô tô mới.', 1),
('xe_co', '自転車', '「 じてんしゃ 」', 'jitensha', 'Xe đạp', '自転車で通学します。', 'Tôi đi học bằng xe đạp.', 2),
('xe_co', 'バイク', '「 ばいく 」', 'baiku', 'Xe máy', 'ベトナムはバイクが多いです。', 'Ở Việt Nam có rất nhiều xe máy.', 3),
('xe_co', 'エンジン', '「 えんじん 」', 'enjin', 'Động cơ máy', 'エンジンがかからない。', 'Động cơ xe không nổ máy được.', 4);

-- 5.4. Chuyên ngành: Vật liệu điện và nước
INSERT INTO topic_words (topic_code, word, reading, romaji, meaning, example_jp, example_vi, display_order) VALUES
('vat_lieu_dien_nuoc', '電線', '「 でんせん 」', 'densen', 'Dây điện', '電線に触れないでください。', 'Xin đừng chạm vào dây điện.', 1),
('vat_lieu_dien_nuoc', '水道管', '「 すいどうかん 」', 'suidoukan', 'Đường ống dẫn nước', '水道管の工事を行っています。', 'Đang sửa chữa đường ống nước.', 2),
('vat_lieu_dien_nuoc', 'スイッチ', '「 すいっち 」', 'suicchi', 'Công tắc điện', '部屋のスイッチを押す。', 'Bật công tắc đèn trong phòng.', 3),
('vat_lieu_dien_nuoc', 'コンセント', '「 こんせんと 」', 'konsento', 'Ổ cắm điện', '充電器をコンセントに差す。', 'Cắm sạc vào ổ cắm điện.', 4);

-- 5.5. Khác: Giao tiếp hàng ngày
INSERT INTO topic_words (topic_code, word, reading, romaji, meaning, example_jp, example_vi, display_order) VALUES
('giao_tiep_hang_ngay', 'おはよう', '「 おはようございます 」', 'ohayou gozaimasu', 'Chào buổi sáng', '先生、おはようございます。', 'Chào buổi sáng thầy ạ.', 1),
('giao_tiep_hang_ngay', 'こんにちは', '「 こんにちは 」', 'konnichiwa', 'Xin chào (ban ngày)', '皆さん、こんにちは！', 'Xin chào mọi người!', 2),
('giao_tiep_hang_ngay', 'ありがとう', '「 ありがとうございます 」', 'arigatou gozaimasu', 'Cảm ơn rất nhiều', '手伝ってくれてありがとう。', 'Cảm ơn bạn đã giúp đỡ tôi.', 3),
('giao_tiep_hang_ngay', 'すみません', '「 すみません 」', 'sumimasen', 'Xin lỗi / Làm phiền', 'すみません、駅はどこですか。', 'Xin lỗi, nhà ga ở đâu vậy ạ?', 4);

-- 5.6. Khác: Du lịch & Ẩm thực
INSERT INTO topic_words (topic_code, word, reading, romaji, meaning, example_jp, example_vi, display_order) VALUES
('du_lich_am_thuc', '寿司', '「 すし 」', 'sushi', 'Sushi', '新鮮なサーモンの寿司を食べる。', 'Ăn sushi cá hồi tươi ngon.', 1),
('du_lich_am_thuc', 'ラーメン', '「 らーめん 」', 'raamen', 'Mì Ramen Nhật Bản', '熱いとんこつラーメンが好きです。', 'Tôi thích mì ramen nước hầm xương.', 2),
('du_lich_am_thuc', '空港', '「 くうこう 」', 'kuukou', 'Sân bay, phi trường', '成田空港に到着しました。', 'Tôi đã đến sân bay Narita.', 3),
('du_lich_am_thuc', 'ホテル', '「 ほてる 」', 'hoteru', 'Khách sạn', '駅の近くのホテルに泊まります。', 'Tôi nghỉ tại khách sạn gần ga.', 4);
