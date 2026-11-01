-- Bổ sung cột grammar_id và cho phép word_meaning_id NULL để bảng examples lưu ví dụ cho cả từ vựng và ngữ pháp
ALTER TABLE examples MODIFY word_meaning_id INT NULL;

-- Thêm grammar_id nếu chưa có
SET @exist := (SELECT COUNT(*) FROM information_schema.columns 
               WHERE table_schema = DATABASE() 
                 AND table_name = 'examples' 
                 AND column_name = 'grammar_id');
SET @sqlstmt := IF(@exist = 0, 'ALTER TABLE examples ADD COLUMN grammar_id INT NULL, ADD CONSTRAINT fk_examples_grammar FOREIGN KEY (grammar_id) REFERENCES grammars(id) ON DELETE CASCADE', 'SELECT 1');
PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================================================
-- 1. BẢNG GRAMMARS (NGỮ PHÁP)
-- =============================================================================
INSERT INTO grammars (structure, meaning, usage_note, jlpt_level) VALUES
('〜てしまう', 'Lỡ làm gì (hối tiếc) / Đã hoàn thành xong', 'Diễn tả hành động đã hoàn thành trọn vẹn hoặc sự hối tiếc khi lỡ làm điều gì.', 'N4'),
('〜やすい', 'Dễ làm một hành động nào đó', 'Đi kèm động từ thể V-masu bỏ masu: V(bỏ ます) + やすい.', 'N4'),
('〜にくい', 'Khó làm một hành động nào đó', 'Đi kèm động từ thể V-masu bỏ masu: V(bỏ ます) + にくい.', 'N4'),
('〜すぎる', 'Quá mức, vượt quá giới hạn', 'Dùng cho tính từ và động từ: V(bỏ ます) / A(bỏ い) + すぎる.', 'N4'),
('〜なければならない', 'Phải làm gì đó (bắt buộc)', 'Diễn tả nghĩa vụ hoặc điều bắt buộc: V(bỏ ない) + なければならない.', 'N4'),
('〜たことがある', 'Đã từng làm gì (trải nghiệm quá khứ)', 'Dùng với động từ thể quá khứ: V(thể た) + ことがある.', 'N4'),
('〜ほうがいい', 'Nên / Không nên làm gì (lời khuyên)', 'Khuyên nên làm: V(thể た) + ほうがいい; khuyên không nên: V(thể ない) + ほうがいい.', 'N4'),
('〜かもしれない', 'Có lẽ, có thể xảy ra (phỏng đoán 50%)', 'Đi sau thể thông thường (Futsuukei): Thể thường + かもしれない.', 'N4'),
('〜つもり', 'Dự định làm / không làm gì đó', 'Ý định của người nói: V(thể từ điển / thể ない) + つもり.', 'N4'),
('〜てはいけない', 'Không được phép làm gì (cấm đoán)', 'Cấm đoán trong quy định hoặc giao tiếp: V(thể て) + はいけない.', 'N4'),
('〜てもいい', 'Được phép làm gì đó (cho phép)', 'Xin phép hoặc cho phép: V(thể て) + もいい.', 'N4'),
('〜ながら', 'Vừa làm việc này vừa làm việc kia', 'Hai hành động diễn ra song song: V(bỏ ます) + ながら.', 'N4'),
('〜まえに', 'Trước khi làm hành động nào đó', 'Trình tự trước sau: V(thể từ điển) / N + の + まえに.', 'N4'),
('〜あとで', 'Sau khi làm xong hành động nào đó', 'Trình tự sau khi: V(thể た) / N + の + あとで.', 'N4'),
('〜ために', 'Để làm gì / Vì lợi ích của ai', 'Chỉ mục đích hoặc nguyên nhân vì ai đó: V(thể từ điển) / N + の + ために.', 'N4'),
('〜ことができる', 'Có thể làm được việc gì đó', 'Chỉ năng lực hoặc khả năng thực hiện: V(thể từ điển) + ことができる.', 'N4')
ON DUPLICATE KEY UPDATE 
    meaning = VALUES(meaning),
    usage_note = VALUES(usage_note),
    jlpt_level = VALUES(jlpt_level);

-- =============================================================================
-- 2. BẢNG KANJIS (HÁN TỰ)
-- =============================================================================
INSERT INTO kanjis (kanji_char, han_viet, radical, stroke_count, onyomi, kunyomi, jlpt_level, meaning) VALUES
('学', 'HỌC', '子', 8, 'ガク', 'まなぶ', 'N5', 'học; học tập'),
('生', 'SINH', '生', 5, 'セイ・ショウ', 'いきる・うまれる', 'N5', 'sinh; sống; học sinh'),
('校', 'HIỆU', '木', 10, 'コウ', NULL, 'N5', 'trường học'),
('日', 'NHẬT', '日', 4, 'ニチ・ジツ', 'ひ・か', 'N5', 'mặt trời; ngày; Nhật Bản'),
('月', 'NGUYỆT', '月', 4, 'ゲツ・ガツ', 'つき', 'N5', 'mặt trăng; tháng'),
('火', 'HỎA', '火', 4, 'カ', 'ひ・ほ', 'N5', 'lửa'),
('水', 'THỦY', '水', 4, 'スイ', 'みず', 'N5', 'nước'),
('木', 'MỘC', '木', 4, 'モク・ボク', 'き・こ', 'N5', 'cây; gỗ'),
('金', 'KIM', '金', 8, 'キン・コン', 'かね・かな', 'N5', 'vàng; tiền'),
('土', 'THỔ', '土', 3, 'ド・ト', 'つち', 'N5', 'đất; thổ nhưỡng'),
('山', 'SƠN', '山', 3, 'サン', 'やま', 'N5', 'núi'),
('川', 'XUYÊN', '川', 3, 'セン', 'かわ', 'N5', 'sông'),
('田', 'ĐIỀN', '田', 5, 'デン', 'た', 'N5', 'ruộng'),
('人', 'NHÂN', '人', 2, 'ジン・ニン', 'ひと', 'N5', 'người'),
('本', 'BẢN', '木', 5, 'ホン', 'もと', 'N5', 'gốc; sách; Nhật Bản'),
('先', 'TIÊN', '儿', 6, 'セン', 'さき', 'N5', 'trước; phía trước'),
('勉', 'MIỄN', '力', 10, 'ベン', NULL, 'N5', 'cố gắng; chăm chỉ'),
('強', 'CƯỜNG', '弓', 11, 'キョウ・ゴウ', 'つよい・つよまる', 'N5', 'mạnh; cố gắng')
ON DUPLICATE KEY UPDATE
    han_viet = VALUES(han_viet),
    radical = VALUES(radical),
    stroke_count = VALUES(stroke_count),
    onyomi = VALUES(onyomi),
    kunyomi = VALUES(kunyomi),
    jlpt_level = VALUES(jlpt_level),
    meaning = VALUES(meaning);

-- =============================================================================
-- 3. BẢNG WORDS & WORD_MEANINGS (TỪ VỰNG & NGHĨA)
-- =============================================================================
-- Chèn thêm các từ vựng N4, N5, chuyên ngành, đời sống nếu chưa có
INSERT IGNORE INTO words (word, reading, romaji, jlpt_level) VALUES
('あっ', 'あっ', 'a', 'N4'),
('案内', 'あんない', 'annai', 'N4'),
('意見', 'いけん', 'iken', 'N4'),
('急ぐ', 'いそぐ', 'isogu', 'N4'),
('受付', 'うけつけ', 'uketsuke', 'N4'),
('運動', 'うんどう', 'undou', 'N4'),
('選ぶ', 'えらぶ', 'erabu', 'N4'),
('遅れる', 'おくれる', 'okureru', 'N4'),
('送る', 'おくる', 'okuru', 'N4'),
('驚く', 'おどろく', 'odoroku', 'N4'),
('会議', 'かいぎ', 'kaigi', 'N4'),
('簡単', 'かんたん', 'kantan', 'N4'),
('故障', 'こしょう', 'koshou', 'N4'),
('複雑', 'ふくざつ', 'fukuzatsu', 'N4'),
('予約', 'よやく', 'yoyaku', 'N4'),
('習慣', 'しゅうかん', 'shuukan', 'N4'),
('私', 'わたし', 'watashi', 'N5'),
('自転車', 'じてんしゃ', 'jitensha', 'N5'),
('バイク', 'ばいく', 'baiku', 'N5'),
('エンジン', 'えんじん', 'enjin', 'N4'),
('電線', 'でんせん', 'densen', 'N4'),
('水道管', 'すいどうかん', 'suidoukan', 'N4'),
('スイッチ', 'すいっち', 'suicchi', 'N5'),
('コンセント', 'こんせんと', 'konsento', 'N5'),
('蛇口', 'じゃぐち', 'jaguchi', 'N4'),
('メーター', 'めーたー', 'meetaa', 'N4'),
('レンチ', 'れんち', 'renchi', 'N4'),
('ドライバー', 'どらいばー', 'doraibaa', 'N4'),
('ボルト', 'ぼると', 'boruto', 'N4'),
('ナット', 'なっと', 'natto', 'N4'),
('溶接', 'ようせつ', 'yousetsu', 'N3'),
('部屋', 'へや', 'heya', 'N5'),
('掃除', 'そうじ', 'souji', 'N5'),
('洗濯', 'せんたく', 'sentaku', 'N5'),
('おはよう', 'おはようございます', 'ohayou gozaimasu', 'N5'),
('こんにちは', 'こんにちは', 'konnichiwa', 'N5'),
('ありがとう', 'ありがとうございます', 'arigatou gozaimasu', 'N5'),
('すみません', 'すみません', 'sumimasen', 'N5'),
('お疲れ様', 'おつかれさまでした', 'otsukaresama deshita', 'N5'),
('寿司', 'すし', 'sushi', 'N5'),
('ラーメン', 'らーめん', 'raamen', 'N5'),
('空港', 'くうこう', 'kuukou', 'N4');

-- Chèn nghĩa vào word_meanings
INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'thán từ', 'A! Á! Ôi! (thán từ bất ngờ)'
FROM words w WHERE w.word = 'あっ' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Hướng dẫn, dẫn đường, thông báo'
FROM words w WHERE w.word = '案内' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Ý kiến, quan điểm'
FROM words w WHERE w.word = '意見' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'động từ', 'Vội vã, gấp rút'
FROM words w WHERE w.word = '急ぐ' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Quầy tiếp tân, bàn lễ tân'
FROM words w WHERE w.word = '受付' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Vận động, tập thể thao'
FROM words w WHERE w.word = '運動' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'động từ', 'Chọn, lựa chọn'
FROM words w WHERE w.word = '選ぶ' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'động từ', 'Đến muộn, trễ hẹn'
FROM words w WHERE w.word = '遅れる' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'động từ', 'Gửi hàng, tiễn người'
FROM words w WHERE w.word = '送る' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'động từ', 'Kinh ngạc, giật mình'
FROM words w WHERE w.word = '驚く' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Cuộc họp, hội nghị'
FROM words w WHERE w.word = '会議' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ な', 'Đơn giản, dễ dàng'
FROM words w WHERE w.word = '簡単' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Hỏng hóc, sự cố máy móc'
FROM words w WHERE w.word = '故障' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ な', 'Phức tạp, rắc rối'
FROM words w WHERE w.word = '複雑' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Đặt trước, đặt chỗ'
FROM words w WHERE w.word = '予約' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Tập quán, thói quen'
FROM words w WHERE w.word = '習慣' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'đại từ', 'Tôi (ngôi thứ nhất)'
FROM words w WHERE w.word = '私' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

-- =============================================================================
-- 4. BẢNG EXAMPLES (CÂU VÍ DỤ SONG NGỮ)
-- =============================================================================
-- Ví dụ cho Từ vựng (liên kết qua word_meaning_id)
INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '日曜日には友達と映画を見に行きます。', 'Nichiyoubi ni wa tomodachi to eiga o mi ni ikimasu.', 'Chủ nhật tôi sẽ đi xem phim cùng bạn bè.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '日' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, 'あっ、財布を家に忘れてしまいました！', 'A, saifu o ie ni wasurete shimaimashita!', 'Á, tôi để quên ví ở nhà mất rồi!', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = 'あっ' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '東京の街を案内してあげましょう。', 'Toukyou no machi o annai shite agemashou.', 'Để tôi dẫn bạn đi tham quan Tokyo nhé.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '案内' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, 'あなたの率直な意見を聞かせてください。', 'Anata no socchoku na iken o kikasete kudasai.', 'Xin hãy cho tôi biết ý kiến thẳng thắn của bạn.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '意見' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '無事だと分かって安心しました。', 'Buji da to wakatte anshin shimashita.', 'Biết bạn bình an tôi thấy thật yên lòng.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '安心' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '電車に遅れないよう急ぎましょう。', 'Densha ni okurenai you isogimashou.', 'Chúng ta hãy nhanh lên để không bị trễ tàu.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '急ぐ' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '健康のために毎朝運動しています。', 'Kenkou no tame ni maiasa undou shiteimasu.', 'Tôi tập thể dục mỗi sáng vì sức khỏe.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '運動' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, 'メニューから好きな料理を選んでください。', 'Menyuu kara sukina ryouri o erande kudasai.', 'Hãy chọn món ăn yêu thích từ thực đơn nhé.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '選ぶ' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '渋滞のせいで約束の時間に遅れました。', 'Juutai no sei de yakusoku no jikan ni okremashita.', 'Vì kẹt xe nên tôi đã đến trễ giờ hẹn.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '遅れる' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '突然の知らせに大変驚きました。', 'Totsuzen no shirase ni taihen odorokimashita.', 'Tôi đã rất kinh ngạc trước tin báo đột ngột.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '驚く' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '午後二時から大事な会議があります。', 'Gogo niji kara daiji na kaigi ga arimasu.', 'Từ 2 giờ chiều có cuộc họp quan trọng.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '会議' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, 'この問題はとても簡単です。', 'Kono mondai wa totemo kantan desu.', 'Câu hỏi này rất dễ.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '簡単' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '日本料理を食べるのが好きです。', 'Nihon ryouri o taberu no ga suki desu.', 'Tôi thích ăn các món ăn Nhật Bản.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '食べる' LIMIT 1;

INSERT INTO examples (word_meaning_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT wm.id, '毎朝新鮮な水を飲みます。', 'Maiasa shinsen na mizu o nomimasu.', 'Mỗi sáng tôi đều uống nước tươi mát.', 'vi'
FROM words w JOIN word_meanings wm ON wm.word_id = w.id
WHERE w.word = '飲む' LIMIT 1;

-- Ví dụ cho Ngữ pháp (liên kết qua grammar_id)
INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '宿題を忘れてしまいました。', 'Shukudai o wasurete shimaimashita.', 'Tôi lỡ quên mất bài tập về nhà.', 'vi'
FROM grammars g WHERE g.structure LIKE '%てしまう%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, 'このペンは書きやすいです。', 'Kono pen wa kakiyasui desu.', 'Cây bút này rất dễ viết.', 'vi'
FROM grammars g WHERE g.structure LIKE '%やすい%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, 'この薬は苦くて飲みにくい。', 'Kono kusuri wa nigakute nominikui.', 'Thuốc này đắng nên khó uống.', 'vi'
FROM grammars g WHERE g.structure LIKE '%にくい%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '昨日お酒を飲みすぎました。', 'Kinou osake o nomisugimashita.', 'Hôm qua tôi đã uống quá nhiều rượu.', 'vi'
FROM grammars g WHERE g.structure LIKE '%すぎる%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '明日早く起きなければなりません。', 'Ashita hayaku okinakereba narimasen.', 'Ngày mai tôi phải dậy sớm.', 'vi'
FROM grammars g WHERE g.structure LIKE '%なければならない%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '日本へ行ったことがありますか。', 'Nihon e itta koto ga arimasuka.', 'Bạn đã từng đến Nhật Bản chưa?', 'vi'
FROM grammars g WHERE g.structure LIKE '%たことがある%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '病院に行ったほうがいいですよ。', 'Byouin ni itta hou ga ii desu yo.', 'Bạn nên đi bệnh viện khám đi.', 'vi'
FROM grammars g WHERE g.structure LIKE '%ほうがいい%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '明日は雨が降るかもしれません。', 'Ashita wa ame ga furu kamoshiremasen.', 'Ngày mai có thể trời sẽ mưa.', 'vi'
FROM grammars g WHERE g.structure LIKE '%かもしれない%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '来年日本に留学するつもりです。', 'Rainen Nihon ni ryuugaku suru tsumori desu.', 'Năm sau tôi dự định sẽ đi du học Nhật Bản.', 'vi'
FROM grammars g WHERE g.structure LIKE '%つもり%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, 'ここでタバコを吸ってはいけません。', 'Koko de tabako o sutte wa ikemasen.', 'Không được phép hút thuốc ở đây.', 'vi'
FROM grammars g WHERE g.structure LIKE '%てはいけない%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '写真を撮ってもいいですか。', 'Shashin o totte mo ii desu ka.', 'Tôi có thể chụp ảnh được không?', 'vi'
FROM grammars g WHERE g.structure LIKE '%てもいい%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '音楽を聞きながら勉強します。', 'Ongaku o kikinagara benkyou shimasu.', 'Tôi vừa nghe nhạc vừa học bài.', 'vi'
FROM grammars g WHERE g.structure LIKE '%ながら%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '寝る前に本を読みます。', 'Neru mae ni hon o yomimasu.', 'Trước khi đi ngủ tôi đọc sách.', 'vi'
FROM grammars g WHERE g.structure LIKE '%まえに%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, 'ご飯を食べたあとで、薬を飲みます。', 'Gohan o tabeta ato de, kusuri o nomimasu.', 'Sau khi ăn cơm xong, tôi sẽ uống thuốc.', 'vi'
FROM grammars g WHERE g.structure LIKE '%あとで%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '健康のために毎日運動しています。', 'Kenkou no tame ni mainichi undou shiteimasu.', 'Tôi tập thể dục mỗi ngày vì sức khỏe.', 'vi'
FROM grammars g WHERE g.structure LIKE '%ために%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '日本語を話すことができます。', 'Nihongo o hanasu koto ga dekimasu.', 'Tôi có thể nói được tiếng Nhật.', 'vi'
FROM grammars g WHERE g.structure LIKE '%ことができる%' LIMIT 1;

