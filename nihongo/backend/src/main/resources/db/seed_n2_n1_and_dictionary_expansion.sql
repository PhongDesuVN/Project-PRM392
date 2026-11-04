-- =============================================================================
-- FILE SQL BỔ SUNG:
-- 1. ĐỀ THI THỬ JLPT N2 & N1 (TỪ VỰNG, NGỮ PHÁP, JLPT TỔNG HỢP)
-- 2. DỮ LIỆU TỪ ĐIỂN MỞ RỘNG (N5, N4, N3, N2, N1) GỒM WORDS, KANJIS, GRAMMARS, EXAMPLES
-- Toàn bộ câu lệnh viết dưới dạng INSERT IGNORE / ON DUPLICATE KEY UPDATE an toàn.
-- =============================================================================

USE PRM;

-- =============================================================================
-- PHẦN I: BÀI THI THỬ JLPT N2 & N1 (ĐỀ 28 ĐẾN 33)
-- Bao gồm cả 3 loại: 'vocabulary', 'grammar', 'jlpt' cho mỗi trình độ N2 và N1.
-- =============================================================================

-- Xóa trước các đề 28..33 nếu đã tồn tại để tránh xung đột
DELETE FROM jlpt_tests WHERE id BETWEEN 28 AND 33;

-- -----------------------------------------------------------------------------
-- ĐỀ 28: Test từ vựng N2 - Đề 1 (10 câu hỏi)
-- -----------------------------------------------------------------------------
INSERT INTO jlpt_tests (id, title, level, test_type, duration_minutes, total_questions)
VALUES (28, 'Test từ vựng N2 - Đề 1', 'N2', 'vocabulary', 15, 10);

INSERT INTO jlpt_questions (id, test_id, section, question_text, passage_text, explanation, question_order)
VALUES
    (289, 28, 'vocabulary', '【読み方】現在の状況を正確に【把握】する。', NULL, '把握 đọc là はあく (nắm bắt, thấu suốt).', 1),
    (290, 28, 'vocabulary', '【読み方】良好な健康状態を【維持】する。', NULL, '維持 đọc là いじ (duy trì).', 2),
    (291, 28, 'vocabulary', '【読み方】若者の消費【傾向】を調査する。', NULL, '傾向 đọc là けいこう (xu hướng, khuynh hướng).', 3),
    (292, 28, 'vocabulary', '【読み方】大きな決断には【慎重】な態度が求められる。', NULL, '慎重 đọc là しんちょう (thận trọng).', 4),
    (293, 28, 'vocabulary', '【表記】新しい計画を「じっし」する。', NULL, '「じっし」viết bằng Kanji là 実施 (thực hiện, triển khai).', 5),
    (294, 28, 'vocabulary', '【表記】問題の解決策を「ていあん」した。', NULL, '「ていあん」viết là 提案 (đề xuất, kiến nghị).', 6),
    (295, 28, 'vocabulary', '【表記】予算が「てきとう」か見直す。', NULL, '「てきとう」viết là 適当 (thích hợp, thỏa đáng).', 7),
    (296, 28, 'vocabulary', '【文脈】SNSの発達が社会に大きな（　）を与えている。', NULL, '「影響を与える」là cụm từ cố định: gây ảnh hưởng.', 8),
    (297, 28, 'vocabulary', '【文脈】プロジェクトのリーダーとして最後まで（　）を果たす。', NULL, '「責任を果たす」: hoàn thành trách nhiệm.', 9),
    (298, 28, 'vocabulary', '【意味】「おおむね」と意味が最も近いものはどれですか。', NULL, 'おおむね có nghĩa là đại khái, phần lớn ≈ だいたい.', 10);

INSERT INTO jlpt_options (id, question_id, option_text, is_correct)
VALUES
    (1153, 289, 'はあく', 1),
    (1154, 289, 'はそく', 0),
    (1155, 289, 'ほあく', 0),
    (1156, 289, 'ほそく', 0),
    (1157, 290, 'いじ', 1),
    (1158, 290, 'いち', 0),
    (1159, 290, 'いし', 0),
    (1160, 290, 'いり', 0),
    (1161, 291, 'けいこう', 1),
    (1162, 291, 'けいごう', 0),
    (1163, 291, 'けんこう', 0),
    (1164, 291, 'げいこう', 0),
    (1165, 292, 'しんちょう', 1),
    (1166, 292, 'じんちょう', 0),
    (1167, 292, 'しんじゅう', 0),
    (1168, 292, 'せんちょう', 0),
    (1169, 293, '実地', 0),
    (1170, 293, '実施', 1),
    (1171, 293, '実試', 0),
    (1172, 293, '実使', 0),
    (1173, 294, '提案', 1),
    (1174, 294, '定案', 0),
    (1175, 294, '提按', 0),
    (1176, 294, '提計', 0),
    (1177, 295, '適当', 1),
    (1178, 295, '適答', 0),
    (1179, 295, '滴当', 0),
    (1180, 295, '的当', 0),
    (1181, 296, '影響', 1),
    (1182, 296, '効果', 0),
    (1183, 296, '感触', 0),
    (1184, 296, '結果', 0),
    (1185, 297, '役割', 0),
    (1186, 297, '責任', 1),
    (1187, 297, '任務', 0),
    (1188, 297, '立場', 0),
    (1189, 298, 'まったく', 0),
    (1190, 298, 'だいたい', 1),
    (1191, 298, 'めったに', 0),
    (1192, 298, 'かならず', 0);

-- -----------------------------------------------------------------------------
-- ĐỀ 29: Test ngữ pháp N2 - Đề 1 (10 câu hỏi)
-- -----------------------------------------------------------------------------
INSERT INTO jlpt_tests (id, title, level, test_type, duration_minutes, total_questions)
VALUES (29, 'Test ngữ pháp N2 - Đề 1', 'N2', 'grammar', 15, 10);

INSERT INTO jlpt_questions (id, test_id, section, question_text, passage_text, explanation, question_order)
VALUES
    (299, 29, 'grammar', '山田先生（　）、多くの先生方にご指導をいただきました。', NULL, '「～をはじめ」: trước hết là / tiêu biểu là…', 1),
    (300, 29, 'grammar', '新しい事業を開始するに（　）、十分な市場調査を行った。', NULL, '「～に際して」: nhân dịp / vào thời điểm bắt đầu một việc trọng đại.', 2),
    (301, 29, 'grammar', 'アンケートのデータに（　）、報告書を作成した。', NULL, '「～に基づいて」: dựa trên / căn cứ vào…', 3),
    (302, 29, 'grammar', '大事な約束があるから、今日ばかりは遅刻する（　）。', NULL, '「～わけにはいかない」: không thể làm gì vì rào cản đạo đức/xã hội.', 4),
    (303, 29, 'grammar', 'こんなミスを放置したら、大事故につながり（　）。', NULL, '「～かねない」: có nguy cơ dẫn đến kết quả xấu.', 5),
    (304, 29, 'grammar', '景気は回復するどころか、悪化する（　）。', NULL, '「～一方だ」: diễn tả xu hướng ngày càng tiếp diễn (xấu đi/tốt lên).', 6),
    (305, 29, 'grammar', '彼が成功したのは、本人のたゆまぬ努力の賜物に（　）。', NULL, '「～にほかならない」: chính là / không gì khác ngoài…', 7),
    (306, 29, 'grammar', 'あんなに強敵には、初心者の私が勝ち（　）。', NULL, '「～っこない」: tuyệt đối không thể nào…', 8),
    (307, 29, 'grammar', '彼女はどこか寂し（　）な表情で窓の外を見つめていた。', NULL, '「～げ」: có vẻ / đượm nét (tâm trạng).', 9),
    (308, 29, 'grammar', '地球温暖化の影響で、各地の気候が変化し（　）。', NULL, '「～つつある」: đang dần dần biến đổi theo thời gian.', 10);

INSERT INTO jlpt_options (id, question_id, option_text, is_correct)
VALUES
    (1193, 299, 'をはじめ', 1),
    (1194, 299, 'をめぐって', 0),
    (1195, 299, 'をもとに', 0),
    (1196, 299, 'をこめて', 0),
    (1197, 300, 'こたえて', 0),
    (1198, 300, '際して', 1),
    (1199, 300, '関して', 0),
    (1200, 300, '比べて', 0),
    (1201, 301, 'したがって', 0),
    (1202, 301, '伴って', 0),
    (1203, 301, '基づいて', 1),
    (1204, 301, '対して', 0),
    (1205, 302, 'わけにはいかない', 1),
    (1206, 302, 'はずがない', 0),
    (1207, 302, 'にちがいない', 0),
    (1208, 302, 'っこない', 0),
    (1209, 303, '得ない', 0),
    (1210, 303, 'かねる', 0),
    (1211, 303, 'かねない', 1),
    (1212, 303, 'がちだ', 0),
    (1213, 304, '一方だ', 1),
    (1214, 304, 'ばかりだ', 0),
    (1215, 304, '気味だ', 0),
    (1216, 304, 'とおりだ', 0),
    (1217, 305, 'ほかならない', 1),
    (1218, 305, 'すぎない', 0),
    (1219, 305, '限らない', 0),
    (1220, 305, '相違ない', 0),
    (1221, 306, 'っこない', 1),
    (1222, 306, 'きれない', 0),
    (1223, 306, 'かねない', 0),
    (1224, 306, 'はずだ', 0),
    (1225, 307, 'げ', 1),
    (1226, 307, 'そう', 0),
    (1227, 307, 'ぽい', 0),
    (1228, 307, 'がち', 0),
    (1229, 308, 'つつある', 1),
    (1230, 308, 'つつあること', 0),
    (1231, 308, 'つつ', 0),
    (1232, 308, 'きっている', 0);

-- -----------------------------------------------------------------------------
-- ĐỀ 30: Thi thử JLPT N2 - Đề 1 (Tổng hợp 16 câu: Từ vựng, Ngữ pháp, Đọc hiểu)
-- -----------------------------------------------------------------------------
INSERT INTO jlpt_tests (id, title, level, test_type, duration_minutes, total_questions)
VALUES (30, 'Thi thử JLPT N2 - Đề 1', 'N2', 'jlpt', 50, 16);

INSERT INTO jlpt_questions (id, test_id, section, question_text, passage_text, explanation, question_order)
VALUES
    (309, 30, 'vocabulary', '【読み方】状況の変化に【柔軟】に対応する。', NULL, '柔軟 đọc là じゅうなん (mềm dẻo, linh hoạt).', 1),
    (310, 30, 'vocabulary', '【読み方】今回の失敗を【契機】として再出発する。', NULL, '契機 đọc là けいき (thời cơ, cơ hội, bước ngoặt).', 2),
    (311, 30, 'vocabulary', '【表記】スマートフォンが急速に「ふきゅう」した。', NULL, '「ふきゅう」viết là 普及 (phổ biến, phổ cập).', 3),
    (312, 30, 'vocabulary', '【表記】彼の発言には明らかな「むじゅん」がある。', NULL, '「むじゅん」viết là 矛盾 (mâu thuẫn).', 4),
    (313, 30, 'vocabulary', '【文脈】予算が不足したため、規模の縮小を（　）された。', NULL, '「余儀なくされた」: bị buộc phải / không còn lựa chọn nào khác.', 5),
    (314, 30, 'vocabulary', '【意味】「わずらわしい」と意味が近いものはどれですか。', NULL, 'わずらわしい có nghĩa là phiền toái, rắc rối ≈ めんどうな.', 6),
    (315, 30, 'grammar', '台風の接近に（　）、今夜は大雨になる恐れがあります。', NULL, '「～に伴って」: cùng với / đi kèm theo…', 7),
    (316, 30, 'grammar', '三日間に（　）開催された国際会議が無事に閉幕した。', NULL, '「～にわたって」: suốt / trải dài trong suốt khoảng thời gian/không gian.', 8),
    (317, 30, 'grammar', '事実を知った以上、警察に通報せ（　）。', NULL, '「～ざるを得ない」: đành phải / không thể không làm…', 9),
    (318, 30, 'grammar', '彼は勉強の時間が短かった（　）、高得点を取った。', NULL, '「～わりに（は）」: so với / tuy… nhưng (trái với kỳ vọng).', 10),
    (319, 30, 'grammar', 'この仕事は高収入である（　）、責任が非常に重い。', NULL, '「～反面」: mặt khác / trái lại (hai mặt của vấn đề).', 11),
    (320, 30, 'grammar', '油断すると、思わぬ事故につながる（　）。', NULL, '「～恐れがある」: có e ngại / nguy cơ xảy ra điều không tốt.', 12),
    (321, 30, 'reading', '問：筆者によると、AIの時代に人間に最も求められる力は何ですか。', 'AIの急速な発展により、単純な事務作業やデータ処理は機械に取って代わられつつある。しかし、他人の気持ちに共感し、感情を汲み取った上で柔軟に対話する能力は、依然として人間にしかできない領域である。これからの社会では、知識の量よりも、他者と良好な人間関係を築くコミュニケーション力が最も求められるだろう。', 'Bài viết khẳng định: kiến thức không bằng năng lực giao tiếp và thấu hiểu người khác: 他者と良好な人間関係を築くコミュニケーション力.', 13),
    (322, 30, 'reading', '問：本文の内容と一致しているものはどれですか。', 'AIの急速な発展により、単純な事務作業やデータ処理は機械に取って代わられつつある。しかし、他人の気持ちに共感し、感情を汲み取った上で柔軟に対話する能力は、依然として人間にしかできない領域である。これからの社会では、知識の量よりも、他者と良好な人間関係を築くコミュニケーション力が最も求められるだろう。', 'Bài viết chỉ ra việc xử lý dữ liệu và văn phòng đơn giản đang dần được máy móc thay thế.', 14),
    (323, 30, 'reading', '問：筆者は「失敗」についてどのように述べていますか。', '人は誰でも失敗を恐れる。しかし、失敗を経験しないことこそが、最大の失敗かもしれない。なぜなら、失敗からしか学べない教訓や改善の視点が存在するからである。挑戦した上での失敗は、成功への階段の一歩にほかならない。大切なのは、失敗を恐れて立ち止まるのではなく、次の行動へと活かす柔軟性である。', 'Tác giả xem thất bại là bước đệm cho thành công và cung cấp bài học không thể học được ở đâu khác.', 15),
    (324, 30, 'reading', '問：本文で筆者が一番言いたいことは何ですか。', '人は誰でも失敗を恐れる。しかし、失敗を経験しないことこそが、最大の失敗かもしれない。なぜなら、失敗からしか学べない教訓や改善の視点が存在するからである。挑戦した上での失敗は、成功への階段の一歩にほかならない。大切なのは、失敗を恐れて立ち止まるのではなく、次の行動へと活かす柔軟性である。', 'Thông điệp cốt lõi: Không nên vì sợ thất bại mà chùn bước, hãy học hỏi và linh hoạt hành động tiếp theo.', 16);

INSERT INTO jlpt_options (id, question_id, option_text, is_correct)
VALUES
    (1233, 309, 'じゅうなん', 1),
    (1234, 309, 'じゅんなん', 0),
    (1235, 309, 'じゅうだん', 0),
    (1236, 309, 'じゅんだん', 0),
    (1237, 310, 'けいき', 1),
    (1238, 310, 'けいぎ', 0),
    (1239, 310, 'かいき', 0),
    (1240, 310, 'けいきょう', 0),
    (1241, 311, '普及', 1),
    (1242, 311, '普通', 0),
    (1243, 311, '普給', 0),
    (1244, 311, '風及', 0),
    (1245, 312, '矛盾', 1),
    (1246, 312, '矛盾', 0),
    (1247, 312, '矛順', 0),
    (1248, 312, '無盾', 0),
    (1249, 313, '余儀なく', 1),
    (1250, 313, '心強く', 0),
    (1251, 313, '思いがけなく', 0),
    (1252, 313, '惜しく', 0),
    (1253, 314, 'めんどうな', 1),
    (1254, 314, 'おそろしい', 0),
    (1255, 314, 'くだらない', 0),
    (1256, 314, 'みっともない', 0),
    (1257, 315, '伴って', 1),
    (1258, 315, 'したがって', 0),
    (1259, 315, '沿って', 0),
    (1260, 315, '通して', 0),
    (1261, 316, 'わたって', 1),
    (1262, 316, '通じて', 0),
    (1263, 316, '通して', 0),
    (1264, 316, 'かけて', 0),
    (1265, 317, 'ざるを得ない', 1),
    (1266, 317, 'かねない', 0),
    (1267, 317, 'わけにはいかない', 0),
    (1268, 317, 'にちがいない', 0),
    (1269, 318, 'わりに', 1),
    (1270, 318, 'くせに', 0),
    (1271, 318, '反面', 0),
    (1272, 318, '一方', 0),
    (1273, 319, '反面', 1),
    (1274, 319, 'わりに', 0),
    (1275, 319, 'とおり', 0),
    (1276, 319, 'うえに', 0),
    (1277, 320, '恐れがある', 1),
    (1278, 320, 'わけがある', 0),
    (1279, 320, 'はずがある', 0),
    (1280, 320, 'きらいがある', 0),
    (1281, 321, '高度なプログラミング能力', 0),
    (1282, 321, '他者と良好な関係を築くコミュニケーション力', 1),
    (1283, 321, '膨大な知識を暗記する力', 0),
    (1284, 321, 'データを素早く計算する力', 0),
    (1285, 322, '単純なデータ処理は今後も人間が行うべきだ', 0),
    (1286, 322, '単純な事務作業は機械に取って代わられつつある', 1),
    (1287, 322, 'AIは他者の気持ちに完全に共感できる', 0),
    (1288, 322, 'これからはコミュニケーション力は不要になる', 0),
    (1289, 323, '失敗は成功への一歩であり、教訓を学べる機会である', 1),
    (1290, 323, '失敗を経験することは絶対に避けるべきである', 0),
    (1291, 323, '失敗すると二度と立ち上がれなくなる', 0),
    (1292, 323, '成功するためには最初から完璧でなければならない', 0),
    (1293, 324, '失敗を恐れて立ち止まらず、経験を次に活かすこと', 1),
    (1294, 324, '誰にも迷惑をかけないように生きること', 0),
    (1295, 324, 'リスクのある挑戦は最初から避けること', 0),
    (1296, 324, '成功者だけが失敗を語る資格があること', 0);

-- -----------------------------------------------------------------------------
-- ĐỀ 31: Test từ vựng N1 - Đề 1 (10 câu hỏi)
-- -----------------------------------------------------------------------------
INSERT INTO jlpt_tests (id, title, level, test_type, duration_minutes, total_questions)
VALUES (31, 'Test từ vựng N1 - Đề 1', 'N1', 'vocabulary', 15, 10);

INSERT INTO jlpt_questions (id, test_id, section, question_text, passage_text, explanation, question_order)
VALUES
    (325, 31, 'vocabulary', '【読み方】近年の技術革新には【著しい】進歩が見られる。', NULL, '著しい đọc là いちじるしい (đáng kể, nổi bật, rõ rệt).', 1),
    (326, 31, 'vocabulary', '【読み方】天然資源が【乏しい】国では、人材育成が鍵となる。', NULL, '乏しい đọc là とぼしい (nghèo nàn, thiếu thốn).', 2),
    (327, 31, 'vocabulary', '【読み方】事態の打開策を全力で【模索】している。', NULL, '模索 đọc là もさく (tìm kiếm, mò mẫm giải pháp).', 3),
    (328, 31, 'vocabulary', '【読み方】不公正な制度の【是正】を強く求める。', NULL, '是正 đọc là ぜせい (sửa đổi, điều chỉnh cho đúng đắn).', 4),
    (329, 31, 'vocabulary', '【表記】経済の先行きに「けねん」が広がっている。', NULL, '「けねん」viết bằng Kanji là 懸念 (lo ngại, quan ngại).', 5),
    (330, 31, 'vocabulary', '【表記】与えられた任務を最後まで「すいこう」する。', NULL, '「すいこう」viết là 遂行 (thực thi, hoàn thành trọn vẹn nhiệm vụ).', 6),
    (331, 31, 'vocabulary', '【表記】現実のデータを「ふまえて」議論を進める。', NULL, '「ふまえて」viết là 踏まえて (dựa trên, căn cứ vào).', 7),
    (332, 31, 'vocabulary', '【文脈】長年のたゆまぬ努力が、ついに（　）を結んだ。', NULL, '「実を結ぶ (みをむすぶ)」: đơm hoa kết trái, gặt hái thành quả.', 8),
    (333, 31, 'vocabulary', '【文脈】本日無事に開業できましたのは、（　）皆様方のおかげです。', NULL, '「ひとえに～のおかげ」: hoàn toàn nhờ vào / tất cả là nhờ…', 9),
    (334, 31, 'vocabulary', '【意味】「おのずから」と意味が最も近いものはどれですか。', NULL, 'おのずから có nghĩa là tự nhiên, tự khắc sẽ như thế ≈ 自然に.', 10);

INSERT INTO jlpt_options (id, question_id, option_text, is_correct)
VALUES
    (1297, 325, 'いちじるしい', 1),
    (1298, 325, 'めざましい', 0),
    (1299, 325, 'すさまじい', 0),
    (1300, 325, 'たくましい', 0),
    (1301, 326, 'とぼしい', 1),
    (1302, 326, 'くるしい', 0),
    (1303, 326, 'あやしい', 0),
    (1304, 326, 'いやしい', 0),
    (1305, 327, 'もさく', 1),
    (1306, 327, 'ぼさく', 0),
    (1307, 327, 'もうさく', 0),
    (1308, 327, 'ぼうさく', 0),
    (1309, 328, 'ぜせい', 1),
    (1310, 328, 'これせい', 0),
    (1311, 328, 'ぜしょう', 0),
    (1312, 328, 'しょうせい', 0),
    (1313, 329, '懸念', 1),
    (1314, 329, '懸命', 0),
    (1315, 329, '嫌念', 0),
    (1316, 329, '険念', 0),
    (1317, 330, '遂行', 1),
    (1318, 330, '遂業', 0),
    (1319, 330, '随行', 0),
    (1320, 330, '追行', 0),
    (1321, 331, '踏まえて', 1),
    (1322, 331, '履まえて', 0),
    (1323, 331, '践まえて', 0),
    (1324, 331, '歩まえて', 0),
    (1325, 332, '実', 1),
    (1326, 332, '花', 0),
    (1327, 332, '根', 0),
    (1328, 332, '芽', 0),
    (1329, 333, 'ひとえに', 1),
    (1330, 333, 'もっぱら', 0),
    (1331, 333, 'かりに', 0),
    (1332, 333, 'ろくに', 0),
    (1333, 334, '自然に', 1),
    (1334, 334, '意図的に', 0),
    (1335, 334, '慎重に', 0),
    (1336, 334, '急速に', 0);

-- -----------------------------------------------------------------------------
-- ĐỀ 32: Test ngữ pháp N1 - Đề 1 (10 câu hỏi)
-- -----------------------------------------------------------------------------
INSERT INTO jlpt_tests (id, title, level, test_type, duration_minutes, total_questions)
VALUES (32, 'Test ngữ pháp N1 - Đề 1', 'N1', 'grammar', 15, 10);

INSERT INTO jlpt_questions (id, test_id, section, question_text, passage_text, explanation, question_order)
VALUES
    (335, 32, 'grammar', '理由の（　）に関わらず、無断欠勤は規則違反とみなされます。', NULL, '「～いかんに関わらず」: bất kể ra sao / dù lý do là gì chăng nữa.', 1),
    (336, 32, 'grammar', '悪天候のため、航空会社は全便の欠航を（　）。', NULL, '「～余儀なくされた」: buộc phải / không có cách nào khác.', 2),
    (337, 32, 'grammar', '現代の若者（　）、挨拶すらまともにできない者がいる。', NULL, '「～ときたら」: nói về... thì thật là (thường mang ý phê phán, phàn nàn).', 3),
    (338, 32, 'grammar', 'このような不誠実な対応は、遺憾（　）。', NULL, '「～極まりない」: vô cùng / cực kỳ (cảm xúc tiêu cực như thất vọng, đáng tiếc).', 4),
    (339, 32, 'grammar', '子どもたちは泥（　）になって公園を駆け回っていた。', NULL, '「～まみれ」: dính đầy / bao phủ bởi thứ dơ bẩn (bùn, nợ nần, máu...).', 5),
    (340, 32, 'grammar', '賛成（　）反対（　）、自分の意見をはっきり述べるべきだ。', NULL, '「～であれ～であれ」: dù là A hay dù là B thì…', 6),
    (341, 32, 'grammar', '彼女は今にも泣き出さ（　）の表情で立ち尽くしていた。', NULL, '「～んばかり」: như thể sắp sửa / tựa hồ như…', 7),
    (342, 32, 'grammar', '皆様の温かいご支援には、感謝に（　）。', NULL, '「～にたえない」: khôn xiết / không kìm nổi (lòng biết ơn, sự tiếc thương).', 8),
    (343, 32, 'grammar', '子どもの将来を思え（　）、厳しいことも言うのだ。', NULL, '「～ばこそ」: chính vì… nên mới (nhấn mạnh lý do thực sự).', 9),
    (344, 32, 'grammar', 'いくら親しい間柄（　）、礼儀を欠いてはならない。', NULL, '「～とはいえ」: dẫu rằng / mặc dù nói là… nhưng…', 10);

INSERT INTO jlpt_options (id, question_id, option_text, is_correct)
VALUES
    (1337, 335, 'いかん', 1),
    (1338, 335, '次第', 0),
    (1339, 335, '次第で', 0),
    (1340, 335, 'いかんせん', 0),
    (1341, 336, '余儀なくされた', 1),
    (1342, 336, '余儀なくなった', 0),
    (1343, 336, '余儀なくした', 0),
    (1344, 336, '余儀ない', 0),
    (1345, 337, 'ときたら', 1),
    (1346, 337, 'とあって', 0),
    (1347, 337, 'としたら', 0),
    (1348, 337, 'といえば', 0),
    (1349, 338, '極まりない', 1),
    (1350, 338, '限りだ', 0),
    (1351, 338, '極みだ', 0),
    (1352, 338, '至りだ', 0),
    (1353, 339, 'まみれ', 1),
    (1354, 339, 'だらけ', 0),
    (1355, 339, 'ずくめ', 0),
    (1356, 339, 'っぽく', 0),
    (1357, 340, 'であれ／であれ', 1),
    (1358, 340, 'につけ／につけ', 0),
    (1359, 340, 'なり／なり', 0),
    (1360, 340, 'とか／とか', 0),
    (1361, 341, 'んばかり', 1),
    (1362, 341, 'ばかりに', 0),
    (1363, 341, 'ともなく', 0),
    (1364, 341, 'がてら', 0),
    (1365, 342, 'たえない', 1),
    (1366, 342, 'やまない', 0),
    (1367, 342, 'おかない', 0),
    (1368, 342, 'すぎない', 0),
    (1369, 343, 'ばこそ', 1),
    (1370, 343, 'てこそ', 0),
    (1371, 343, 'からこそ', 0),
    (1372, 343, 'とあれば', 0),
    (1373, 344, 'とはいえ', 1),
    (1374, 344, 'といえども', 0),
    (1375, 344, 'となると', 0),
    (1376, 344, 'としたって', 0);

-- -----------------------------------------------------------------------------
-- ĐỀ 33: Thi thử JLPT N1 - Đề 1 (Tổng hợp 16 câu: Từ vựng, Ngữ pháp, Đọc hiểu)
-- -----------------------------------------------------------------------------
INSERT INTO jlpt_tests (id, title, level, test_type, duration_minutes, total_questions)
VALUES (33, 'Thi thử JLPT N1 - Đề 1', 'N1', 'jlpt', 55, 16);

INSERT INTO jlpt_questions (id, test_id, section, question_text, passage_text, explanation, question_order)
VALUES
    (345, 33, 'vocabulary', '【読み方】彼の説明は【巧み】で、説得力に富んでいた。', NULL, '巧み đọc là たくみ (khéo léo, tài tình).', 1),
    (346, 33, 'vocabulary', '【読み方】似たような言葉が多くて【紛らわしい】。', NULL, '紛らわしい đọc là まぎらわしい (dễ nhầm lẫn, mơ hồ).', 2),
    (347, 33, 'vocabulary', '【表記】どんな「べんかい」も通用しない。', NULL, '「べんかい」viết là 弁解 (biện minh, thanh minh).', 3),
    (348, 33, 'vocabulary', '【表記】自由を「こうそく」されるのは耐えがたい。', NULL, '「こうそく」viết là 拘束 (trói buộc, câu thúc, kiềm tỏa).', 4),
    (349, 33, 'vocabulary', '【文脈】彼は常に（　）な態度で、他者の意見に耳を傾ける。', NULL, '「謙虚な態度」: thái độ khiêm nhường, biết lắng nghe.', 5),
    (350, 33, 'vocabulary', '【意味】「しなやか」と意味が最も近いものはどれですか。', NULL, 'しなやか có nghĩa là dẻo dai, uyển chuyển, mềm mại ≈ 柔軟な.', 6),
    (351, 33, 'grammar', '今度の全国ツアーは、東京ドーム公演（　）各地で開催される。', NULL, '「～を皮切りに（して）」: khởi đầu với / mở màn bằng…', 7),
    (352, 33, 'grammar', 'このきめ細やかなおもてなしは、日本の老舗旅館（　）のものだ。', NULL, '「～ならではの」: chỉ có ở / độc đáo chỉ riêng… mới có.', 8),
    (353, 33, 'grammar', '一流のプロ（　）、些細なミスも決して見逃さない。', NULL, '「～ともなると / ～ともなれば」: một khi đã là / khi đạt đến tầm cỡ…', 9),
    (354, 33, 'grammar', '周囲の協力（　）、この難事業の成功はあり得なかった。', NULL, '「～なくしては」: nếu không có… thì không thể…', 10),
    (355, 33, 'grammar', '平社員ならまだしも、役員（　）その事実を知らなかった。', NULL, '「～に至っては」: đến mức như… / thậm chí như…', 11),
    (356, 33, 'grammar', '散歩（　）、駅前の本屋に立ち寄った。', NULL, '「～かたがた」: nhân tiện / tiện thể làm việc này kết hợp việc kia.', 12),
    (357, 33, 'reading', '問：筆者は「読書」の本質についてどのように考えていますか。', '読書とは、単に他人の考えを受動的に吸収する行為ではない。本に書かれた著者の思索と、自分自身の経験や知性が対峙し、新たな問いや洞察が生まれるダイナミックな対話である。したがって、著者の意見にただ盲従するのではなく、「なぜ著者はそう考えたのか」「自分はどう感じるか」を常に反芻しながら読むことこそが、真の読書と言えるだろう。', 'Bài viết khẳng định: Đọc sách là cuộc đối thoại mang tính tư duy phản biện giữa người đọc và tác giả: 著者との対話であり、自ら深く思索する行為である.', 13),
    (358, 33, 'reading', '問：本文で述べられている「真の読書」として適切なものはどれですか。', '読書とは、単に他人の考えを受動的に吸収する行為ではない。本に書かれた著者の思索と、自分自身の経験や知性が対峙し、新たな問いや洞察が生まれるダイナミックな対話である。したがって、著者の意見にただ盲従するのではなく、「なぜ著者はそう考えたのか」「自分はどう感じるか」を常に反芻しながら読むことこそが、真の読書と言えるだろう。', 'Chân lý đọc sách là tự vấn và chiêm nghiệm độc lập: 著者の考えに盲従せず、自分の頭で問い直しながら読むこと.', 14),
    (359, 33, 'reading', '問：筆者によると、言語が思考に与える影響とは何ですか。', '言葉は単なる意思疎通の道具に留まらない。私たちが世界をどう分節し、どう知覚するかという枠組みそのものを決定づけている。例えば、特定の色や感情を表す語彙を豊かに持つ文化圏の人々は、そうでない人々に比べて、微細なニュアンスをより鮮明に認識できるという実験結果もある。つまり、母語の豊かさは、その人の思考の解像度そのものに直結しているのである。', 'Ngôn ngữ quyết định cách ta nhận thức thế giới: Ngôn ngữ càng phong phú thì độ phân giải tư duy càng sâu sắc.', 15),
    (360, 33, 'reading', '問：筆者の主張と最も一致するものはどれですか。', '言葉は単なる意思疎通の道具に留まらない。私たちが世界をどう分節し、どう知覚するかという枠組みそのものを決定づけている。例えば、特定の色や感情を表す語彙を豊かに持つ文化圏の人々は、そうでない人々に比べて、微細なニュアンスをより鮮明に認識できるという実験結果もある。つまり、母語の豊かさは、その人の思考の解像度そのものに直結しているのである。', 'Từ ngữ dồi dào sẽ nâng cao năng lực cảm thụ và tư duy: 語彙が豊かであるほど、世界の微細な違いを深く認識・思考できる.', 16);

INSERT INTO jlpt_options (id, question_id, option_text, is_correct)
VALUES
    (1377, 345, 'たくみ', 1),
    (1378, 345, 'たくみの', 0),
    (1379, 345, 'たぐみ', 0),
    (1380, 345, 'こうみ', 0),
    (1381, 346, 'まぎらわしい', 1),
    (1382, 346, 'わずらわしい', 0),
    (1383, 346, 'あつかましい', 0),
    (1384, 346, 'めざましい', 0),
    (1385, 347, '弁解', 1),
    (1386, 347, '弁開', 0),
    (1387, 347, '弁回', 0),
    (1388, 347, '別解', 0),
    (1389, 348, '拘束', 1),
    (1390, 348, '拘測', 0),
    (1391, 348, '公束', 0),
    (1392, 348, '拘速', 0),
    (1393, 349, '謙虚', 1),
    (1394, 349, '頑固', 0),
    (1395, 349, '傲慢', 0),
    (1396, 349, '淡白', 0),
    (1397, 350, '柔軟な', 1),
    (1398, 350, '強情な', 0),
    (1399, 350, '頑丈な', 0),
    (1400, 350, '無礼な', 0),
    (1401, 351, 'を皮切りに', 1),
    (1402, 351, 'を限りに', 0),
    (1403, 351, 'をきっかけに', 0),
    (1404, 351, 'を契機に', 0),
    (1405, 352, 'ならではの', 1),
    (1406, 352, 'にあっての', 0),
    (1407, 352, 'ならでは', 0),
    (1408, 352, 'にいたっての', 0),
    (1409, 353, 'ともなると', 1),
    (1410, 353, 'にしたって', 0),
    (1411, 353, 'からいうと', 0),
    (1412, 353, 'としたところで', 0),
    (1413, 354, 'なくしては', 1),
    (1414, 354, 'なしには', 0),
    (1415, 354, 'なくては', 0),
    (1416, 354, 'ないまでも', 0),
    (1417, 355, 'に至っては', 1),
    (1418, 355, 'にかけては', 0),
    (1419, 355, 'にかかわっては', 0),
    (1420, 355, 'に即しては', 0),
    (1421, 356, 'かたがた', 1),
    (1422, 356, 'ついでに', 0),
    (1423, 356, 'がてら', 0),
    (1424, 356, 'そばから', 0),
    (1425, 357, '著者との対話であり、自ら深く思索する行為である', 1),
    (1426, 357, '本に書かれた知識をそのまま暗記すること', 0),
    (1427, 357, '著者の考えにひたすら同意すること', 0),
    (1428, 357, 'できるだけ多くの冊数を速読すること', 0),
    (1429, 358, '著者の考えに盲従せず、自分の頭で問い直しながら読むこと', 1),
    (1430, 358, '著者の経歴を細かく調べてから読むこと', 0),
    (1431, 358, '難しい本は読まず、平易な解説書だけを読むこと', 0),
    (1432, 358, '内容に疑問を持たず素直に受け入れること', 0),
    (1433, 359, '言語の語彙の豊かさが、世界を捉える思考の解像度を決める', 1),
    (1434, 359, '言葉は道具にすぎず、思考とは無関係である', 0),
    (1435, 359, '外国語を学んでも思考力には影響しない', 0),
    (1436, 359, '言語がなくても人間は全く同じように世界を知覚できる', 0),
    (1437, 360, '語彙が豊かであるほど、世界の微細な違いを深く認識・思考できる', 1),
    (1438, 360, '言葉の数は少なければ少ないほど混乱を防げる', 0),
    (1439, 360, 'どんな言語でも思考の深さに差は生じない', 0),
    (1440, 360, '感情を言葉にすることは思考の妨げになる', 0);


-- =============================================================================
-- PHẦN II: DỮ LIỆU TỪ ĐIỂN MỞ RỘNG (N5, N4, N3, N2, N1)
-- Bổ sung đầy đủ Hán tự, Từ vựng, Ngữ pháp và Câu ví dụ song ngữ
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. BỔ SUNG HÁN TỰ (KANJIS) CHO N5, N4, N3, N2, N1
-- -----------------------------------------------------------------------------
INSERT INTO kanjis (kanji_char, han_viet, radical, stroke_count, onyomi, kunyomi, jlpt_level, meaning) VALUES
-- N5
('男', 'NAM', '田', 7, 'ダン・ナン', 'おとこ・お', 'N5', 'nam giới; đàn ông; con trai'),
('女', 'NỮ', '女', 3, 'ジョ・ニョ', 'おんな・め', 'N5', 'nữ giới; phụ nữ; con gái'),
('子', 'TỬ', '子', 3, 'シ・ス', 'こ・ね', 'N5', 'đứa trẻ; con cái'),
('父', 'PHỤ', '父', 4, 'フ', 'ちち・とう', 'N5', 'cha; bố'),
('母', 'MẪU', '母', 5, 'ボ', 'はは・かあ', 'N5', 'mẹ'),
('大', 'ĐẠI', '大', 3, 'ダイ・タイ', 'おおきい・おおいに', 'N5', 'to lớn; rộng lớn'),
('小', 'TIỂU', '小', 3, 'ショウ', 'ちいさい・こ・お', 'N5', 'nhỏ bé; ít ỏi'),
('中', 'TRUNG', '丨', 4, 'チュウ', 'なか・うち', 'N5', 'ở giữa; bên trong; Trung Quốc'),
('上', 'THƯỢNG', '一', 3, 'ジョウ・ショウ', 'うえ・あがる・のぼる', 'N5', 'phía trên; lên; vượt trội'),
('下', 'HẠ', '一', 3, 'カ・ゲ', 'した・さがる・くだる', 'N5', 'phía dưới; xuống; cấp dưới'),

-- N4
('心', 'TÂM', '心', 4, 'シン', 'こころ', 'N4', 'trái tim; tấm lòng; tâm trí'),
('思', 'TƯ', '心', 9, 'シ', 'おもう', 'N4', 'suy nghĩ; nhớ nhung; cảm thấy'),
('急', 'CẤP', '心', 9, 'キュウ', 'いそぐ・せく', 'N4', 'khẩn cấp; vội vã; nhanh chóng'),
('悪', 'ÁC', '心', 11, 'アク・オ', 'わるい', 'N4', 'xấu xa; độc ác; kém cỏi'),
('意', 'Ý', '心', 13, 'イ', NULL, 'N4', 'ý chí; ý kiến; ý nghĩa'),
('医', 'Y', '匚', 7, 'イ', NULL, 'N4', 'y học; thầy thuốc; chữa bệnh'),
('者', 'GIẢ', '老', 8, 'シャ', 'もの', 'N4', 'người; kẻ; học giả'),
('院', 'VIỆN', '阜', 10, 'イン', NULL, 'N4', 'học viện; bệnh viện; cơ quan'),
('病', 'BỆNH', '疒', 10, 'ビョウ・ヘイ', 'やむ・やまい', 'N4', 'bệnh tật; đau ốm'),
('運', 'VẬN', '辵', 12, 'ウン', 'はこぶ', 'N4', 'vận chuyển; vận mệnh; may mắn'),

-- N3
('経', 'KINH', '糸', 11, 'ケイ・キョウ', 'へる・たつ', 'N3', 'kinh qua; kinh tế; kinh điển'),
('済', 'TẾ', '水', 11, 'サイ・セイ', 'すむ・すます', 'N3', 'kinh tế; cứu tế; xong xuôi'),
('技', 'KỸ', '手', 7, 'ギ', 'わざ', 'N3', 'kỹ năng; kỹ thuật; tài nghệ'),
('術', 'THUẬT', '行', 11, 'ジュツ', 'すべ', 'N3', 'kỹ thuật; học thuật; phương pháp'),
('環', 'HOÀN', '玉', 17, 'カン', 'わ', 'N3', 'vòng quanh; tuần hoàn; môi trường'),
('境', 'CẢNH', '土', 14, 'キョウ・ケイ', 'さかい', 'N3', 'hoàn cảnh; biên cảnh; ranh giới'),
('相', 'TƯƠNG', '目', 9, 'ソウ・ショウ', 'あい', 'N3', 'tương hỗ; tướng mạo; thủ tướng'),
('談', 'ĐÀM', '言', 15, 'ダン', NULL, 'N3', 'bàn luận; đàm thoại; trao đổi'),
('質', 'CHẤT', '貝', 15, 'シツ・シチ', 'たち・ただす', 'N3', 'chất lượng; bản chất; chất vấn'),
('問', 'VẤN', '門', 11, 'モン', 'とう・とい', 'N3', 'câu hỏi; thẩm vấn; hỏi thăm'),

-- N2
('制', 'CHẾ', '刀', 8, 'セイ', NULL, 'N2', 'chế độ; chế áp; quy định'),
('度', 'ĐỘ', '广', 9, 'ド・ト・タク', 'たび・たどる', 'N2', 'mức độ; chế độ; lần lượt'),
('状', 'TRẠNG', '犬', 7, 'ジョウ', NULL, 'N2', 'tình trạng; hình trạng; thư từ'),
('況', 'HUỐNG', '水', 8, 'キョウ', 'いわんや', 'N2', 'tình huống; hoàn cảnh'),
('影', 'ẢNH', '彡', 15, 'エイ', 'かげ', 'N2', 'hình bóng; ảnh hưởng; bóng râm'),
('響', 'HƯỞNG', '音', 20, 'キョウ', 'ひびく', 'N2', 'ảnh hưởng; âm vang; dao động'),
('責', 'TRÁCH', '貝', 11, 'セキ', 'せめる', 'N2', 'trách nhiệm; khiển trách'),
('任', 'NHIỆM', '人', 6, 'ニン', 'まかせる・まかす', 'N2', 'nhiệm vụ; tín nhiệm; giao phó'),
('維', 'DUY', '糸', 14, 'イ', NULL, 'N2', 'duy trì; liên kết; gìn giữ'),
('持', 'TRÌ', '手', 9, 'ジ', 'もつ・もてる', 'N2', 'duy trì; nắm giữ; cầm lấy'),

-- N1
('概', 'KHÁI', '木', 14, 'ガイ', 'おおむね', 'N1', 'khái niệm; đại khái; bao quát'),
('念', 'NIỆM', '心', 8, 'ネン', NULL, 'N1', 'ý niệm; kỷ niệm; suy nghĩ'),
('握', 'ÁC', '手', 12, 'アク', 'にぎる', 'N1', 'nắm giữ; thấu suốt (bảo ác/hạ ác)'),
('著', 'TRỨ', '艸', 11, 'チョ', 'いちじるしい・あらわす', 'N1', 'nổi tiếng; rõ rệt; sáng tác'),
('乏', 'PHẠP', '丿', 4, 'ボウ', 'とぼしい・ともしい', 'N1', 'thiếu thốn; nghèo nàn'),
('懸', 'HUYỀN', '心', 20, 'ケン・ケ', 'かける・かかる', 'N1', 'lo ngại; treo lơ lửng; dốc lòng'),
('是', 'THỊ', '日', 9, 'ゼ', 'これ', 'N1', 'đúng đắn; điều phải (thị phi, thị chính)'),
('妥', 'THỎA', '女', 7, 'ダ', NULL, 'N1', 'thỏa hiệp; yên ổn; vừa vặn'),
('協', 'HIỆP', '十', 8, 'キョウ', NULL, 'N1', 'hợp tác; tương trợ; hiệp lực'),
('遂', 'TOẠI', '辵', 12, 'スイ', 'とげる', 'N1', 'thực hiện xong; toại nguyện; đạt được')
ON DUPLICATE KEY UPDATE
    han_viet = VALUES(han_viet),
    radical = VALUES(radical),
    stroke_count = VALUES(stroke_count),
    onyomi = VALUES(onyomi),
    kunyomi = VALUES(kunyomi),
    jlpt_level = VALUES(jlpt_level),
    meaning = VALUES(meaning);

-- -----------------------------------------------------------------------------
-- 2. BỔ SUNG TỪ VỰNG (WORDS & WORD_MEANINGS) CHO N5 ĐẾN N1
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO words (word, reading, romaji, jlpt_level) VALUES
-- N5
('男の人', 'おとこのひと', 'otokonohito', 'N5'),
('女の人', 'おんなのひと', 'onnanohito', 'N5'),
('男の子', 'おとこのこ', 'otokonoko', 'N5'),
('女の子', 'おんなのこ', 'onnanoko', 'N5'),
('お父さん', 'おとうさん', 'otousan', 'N5'),
('お母さん', 'おかあさん', 'okaasan', 'N5'),
('大人', 'おとな', 'otona', 'N5'),
('一日', 'ついたち', 'tsuitachi', 'N5'),
('上着', 'うわぎ', 'uwagi', 'N5'),
('地下鉄', 'ちかてつ', 'chikatetsu', 'N5'),

-- N4
('医者', 'いしゃ', 'isha', 'N4'),
('看護師', 'かんごし', 'kangoshi', 'N4'),
('運転手', 'うんてんしゅ', 'untenshu', 'N4'),
('案内所', 'あんないじょ', 'annaijo', 'N4'),
('危険', 'きけん', 'kiken', 'N4'),
('安全', 'あんぜん', 'anzen', 'N4'),
('用意', 'ようい', 'youi', 'N4'),
('注意', 'ちゅうい', 'chuui', 'N4'),
('遠慮', 'えんりょ', 'enryo', 'N4'),
('賛成', 'さんせい', 'sansei', 'N4'),

-- N3
('景気', 'けいき', 'keiki', 'N3'),
('物価', 'ぶっか', 'bukka', 'N3'),
('消費税', 'しょうひぜい', 'shouhizei', 'N3'),
('専門家', 'せんもんか', 'senmonka', 'N3'),
('開発', 'かいはつ', 'kaihatsu', 'N3'),
('国際化', 'こくさいか', 'kokusaika', 'N3'),
('温暖化', 'おんだんか', 'ondanka', 'N3'),
('深刻', 'しんこく', 'shinkoku', 'N3'),
('貴重', 'きちょう', 'kichou', 'N3'),
('独特', 'どくとく', 'dokutoku', 'N3'),

-- N2
('慎重', 'しんちょう', 'shinchou', 'N2'),
('柔軟', 'じゅうなん', 'juunan', 'N2'),
('契機', 'けいき', 'keiki', 'N2'),
('普及', 'ふきゅう', 'fukyuu', 'N2'),
('効率', 'こうりつ', 'kouritsu', 'N2'),
('把握', 'はあく', 'haaku', 'N2'),
('維持', 'いじ', 'iji', 'N2'),
('傾向', 'けいこう', 'keikou', 'N2'),
('責任', 'せきにん', 'sekinin', 'N2'),
('影響', 'えいきょう', 'eikyou', 'N2'),

-- N1
('著しい', 'いちじるしい', 'ichijirushii', 'N1'),
('乏しい', 'とぼしい', 'toboshii', 'N1'),
('模索', 'もさく', 'mosaku', 'N1'),
('是正', 'ぜせい', 'zesei', 'N1'),
('懸念', 'けねん', 'kenen', 'N1'),
('遂行', 'すいこう', 'suikou', 'N1'),
('踏まえる', 'ふまえる', 'fumaeru', 'N1'),
('巧み', 'たくみ', 'takumi', 'N1'),
('紛らわしい', 'まぎらわしい', 'magirawashii', 'N1'),
('謙虚', 'けんきょ', 'kenkyo', 'N1');

-- Chèn nghĩa tiếng Việt cho các từ mới
INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Người đàn ông, nam giới'
FROM words w WHERE w.word = '男の人' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Người phụ nữ, nữ giới'
FROM words w WHERE w.word = '女の人' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Bé trai, cậu bé'
FROM words w WHERE w.word = '男の子' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Bé gái, cô bé'
FROM words w WHERE w.word = '女の子' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Bác sĩ, thầy thuốc'
FROM words w WHERE w.word = '医者' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Y tá, điều dưỡng viên'
FROM words w WHERE w.word = '看護師' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Tài xế, người lái xe'
FROM words w WHERE w.word = '運転手' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ な; danh từ', 'Nguy hiểm, sự hiểm nghèo'
FROM words w WHERE w.word = '危険' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ な; danh từ', 'An toàn, sự bình an'
FROM words w WHERE w.word = '安全' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Tình hình kinh tế, thị trường'
FROM words w WHERE w.word = '景気' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Vật giá, giá cả hàng hóa'
FROM words w WHERE w.word = '物価' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Phát triển, mở mang'
FROM words w WHERE w.word = '開発' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ な', 'Thận trọng, cẩn trọng, chu đáo'
FROM words w WHERE w.word = '慎重' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ な', 'Mềm dẻo, linh hoạt, uyển chuyển'
FROM words w WHERE w.word = '柔軟' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ', 'Thời cơ, cơ hội, bước ngoặt'
FROM words w WHERE w.word = '契機' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Phổ biến, phổ cập rộng rãi'
FROM words w WHERE w.word = '普及' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ い', 'Đáng kể, rõ rệt, nổi bật'
FROM words w WHERE w.word = '著しい' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ い', 'Nghèo nàn, thiếu thốn, ít ỏi'
FROM words w WHERE w.word = '乏しい' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Tìm tòi, mò mẫm, tìm phương hướng'
FROM words w WHERE w.word = '模索' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'danh từ; động từする', 'Sửa đổi, uốn nắn, khắc phục điều sai'
FROM words w WHERE w.word = '是正' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ な', 'Khéo léo, tài tình, tinh xảo'
FROM words w WHERE w.word = '巧み' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

INSERT INTO word_meanings (word_id, lang_code, part_of_speech, meaning)
SELECT w.id, 'vi', 'tính từ い', 'Mơ hồ, dễ nhầm lẫn'
FROM words w WHERE w.word = '紛らわしい' AND NOT EXISTS (SELECT 1 FROM word_meanings wm WHERE wm.word_id = w.id);

-- -----------------------------------------------------------------------------
-- 3. BỔ SUNG NGỮ PHÁP (GRAMMARS) CHO N5, N4, N3, N2, N1
-- -----------------------------------------------------------------------------
INSERT INTO grammars (structure, meaning, usage_note, jlpt_level) VALUES
-- N5
('～は～です', 'A là B (cấu trúc khẳng định lịch sự)', 'Danh từ 1 + は + Danh từ 2 + です.', 'N5'),
('～じゃありません / ～ではありません', 'A không phải là B (phủ định lịch sự)', 'Dùng phủ định danh từ và tính từ đuôi な.', 'N5'),
('～があります / ～がいます', 'Có cái gì / Có ai đó (tồn tại)', 'があります dùng cho vật/đồ vật; がいます dùng cho người/động vật.', 'N5'),
('～へ行きます / 来ます / 帰ります', 'Đi / Đến / Về một địa điểm nào đó', 'Danh từ chỉ địa điểm + へ + động từ di chuyển.', 'N5'),

-- N3
('～をはじめ', 'Trước tiên phải kể đến là / Tiêu biểu là...', 'N + をはじめ (とする + N / として).', 'N3'),
('～に関して', 'Liên quan đến / Về vấn đề...', 'N + に関して / に関する + N.', 'N3'),
('～に対して', 'Đối với / Trái ngược với...', 'N + に対して / に対する + N.', 'N3'),
('～において', 'Tại / Ở / Trong bối cảnh...', 'N + において / における + N (chỉ địa điểm/thời gian trang trọng).', 'N3'),

-- N2
('～に際して', 'Nhân dịp / Khi bắt đầu làm việc gì...', 'V(thể từ điển) / N + に際して.', 'N2'),
('～に基づいて', 'Dựa trên / Căn cứ vào...', 'N + に基づいて / に基づく + N.', 'N2'),
('～わけにはいかない', 'Không thể làm vì đạo đức, lương tâm, lẽ thường', 'V(thể từ điển) + わけにはいかない.', 'N2'),
('～かねない', 'Có nguy cơ / Rất có thể sẽ dẫn đến kết quả xấu', 'V(bỏ ます) + かねない.', 'N2'),
('～ざるを得ない', 'Đành phải / Buộc phải làm dù không muốn', 'V(thể ない bỏ ない) + ざるを得ない (する -> せざるを得ない).', 'N2'),
('～反面', 'Mặt khác / Trái lại (hai mặt đối lập)', 'Thể thông thường / A な / N である + 反面.', 'N2'),

-- N1
('～を余儀なくされる', 'Bị buộc phải làm / Rơi vào thế không còn cách nào khác', 'N + を余儀なくされる / を余儀なくさせる.', 'N1'),
('～いかんに関わらず', 'Bất kể thế nào / Dù lý do hay hoàn cảnh ra sao', 'N (の) + いかんに関わらず / いかんによらず.', 'N1'),
('～極まりない', 'Cực kỳ / Vô cùng (thể hiện cảm xúc đỉnh điểm)', 'A(な) / A(い) + 極まりない / 極まる.', 'N1'),
('～ならではの', 'Chỉ có ở / Độc đáo đặc sắc chỉ riêng ai đó mới có', 'N + ならでは / ならではの + N.', 'N1'),
('～なくしては', 'Nếu không có... thì không thể thành hiện thực', 'N / V ること + なくしては～ない.', 'N1'),
('～かたがた', 'Tiện thể / Nhân tiện kết hợp hai mục đích trang trọng', 'N / V(bỏ ます) + かたがた.', 'N1')
ON DUPLICATE KEY UPDATE
    meaning = VALUES(meaning),
    usage_note = VALUES(usage_note),
    jlpt_level = VALUES(jlpt_level);

-- -----------------------------------------------------------------------------
-- 4. BỔ SUNG CÂU VÍ DỤ SONG NGỮ (EXAMPLES) CHO NGỮ PHÁP MỚI
-- -----------------------------------------------------------------------------
INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '日本を旅行するに際して、ビザを申請しました。', 'Nihon o ryokou suru ni saishite, biza o shinsei shimashita.', 'Nhân dịp đi du lịch Nhật Bản, tôi đã nộp đơn xin visa.', 'vi'
FROM grammars g WHERE g.structure LIKE '%に際して%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, 'アンケート結果に基づいて、新しいサービスを開発しました。', 'Ankeeto kekka ni motozuite, atarashii saabisu o kaihatsu shimashita.', 'Căn cứ vào kết quả khảo sát, chúng tôi đã phát triển dịch vụ mới.', 'vi'
FROM grammars g WHERE g.structure LIKE '%に基づいて%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '大事な試験があるから、休むわけにはいきません。', 'Daiji na shiken ga aru kara, yasumu wake ni wa ikimasen.', 'Vì có kỳ thi quan trọng nên tôi không thể nghỉ được.', 'vi'
FROM grammars g WHERE g.structure LIKE '%わけにはいかない%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, '台風の影響で、イベントの中止を余儀なくされました。', 'Taifuu no eikyou de, ibento no chuushi o yoginaku saremashita.', 'Do ảnh hưởng của bão, sự kiện đã buộc lòng phải hủy bỏ.', 'vi'
FROM grammars g WHERE g.structure LIKE '%余儀なくされる%' LIMIT 1;

INSERT INTO examples (grammar_id, japanese_sentence, transliteration, meaning, lang_code)
SELECT g.id, 'この伝統的な工芸品は、京都ならではの技術で作られています。', 'Kono dentouteki na kougeihin wa, Kyoutoならではno gijutsu de tsukurarete imasu.', 'Sản phẩm thủ công truyền thống này được làm từ kỹ thuật độc đáo chỉ riêng Kyoto mới có.', 'vi'
FROM grammars g WHERE g.structure LIKE '%ならではの%' LIMIT 1;

