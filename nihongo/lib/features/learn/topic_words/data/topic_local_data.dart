import '../models/topic_word_model.dart';

/// Dữ liệu từ vựng local cho các chủ đề JLPT, Chuyên ngành và Khác.
/// Dữ liệu này dùng khi không có kết nối tới Backend Spring Boot.
class TopicLocalData {
  const TopicLocalData._();

  static List<TopicWord> getWords(String topicCode) {
    switch (topicCode) {
      case 'tu_vung_n4':
        return _tuVungN4;
      case 'han_tu_n4':
        return _hanTuN4;
      case 'ngu_phap_n4':
        return _nguPhapN4;
      case 'tu_vung_n5':
        return _tuVungN5;
      case 'xe_co':
        return _xeCo;
      case 'vat_lieu_dien_nuoc':
        return _vatLieuDienNuoc;
      case 'tho_co_khi':
        return _thoCoKhi;
      case 'loi_song':
        return _loiSong;
      case 'it_cntt':
        return _itCntt;
      case 'xay_dung':
        return _xayDung;
      case 'dieu_duong':
        return _dieuDuong;
      case 'khach_san_nha_hang':
        return _khachSanNhaHang;
      case 'nong_nghiep':
        return _nongNghiep;
      case 'che_bien_thuc_pham':
        return _cheBienThucPham;
      case 'may_mac':
        return _mayMac;
      case 'kinh_doanh':
        return _kinhDoanh;
      case 'giao_tiep_hang_ngay':
        return _giaoTiepHangNgay;
      case 'du_lich_am_thuc':
        return _duLichAmThuc;
      default:
        return _tuVungN4;
    }
  }

  // =========================================================================
  // JLPT: TỪ VỰNG N4 (Chứa các từ y hệt trong ảnh thiết kế: 日, あっ...)
  // =========================================================================
  static final List<TopicWord> _tuVungN4 = [
    const TopicWord(
      id: 1,
      topicCode: 'tu_vung_n4',
      word: '日',
      reading: '「 ひ 」「 にち 」「 か 」「 び 」「 ぴ 」',
      romaji: 'hi / nichi / ka',
      meaning: 'Ngày, mặt trời, chủ nhật',
      exampleJp: '日曜日には友達と映画を見に行きます。',
      exampleVi: 'Chủ nhật tôi sẽ đi xem phim cùng bạn bè.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 2,
      topicCode: 'tu_vung_n4',
      word: 'あっ',
      reading: '「 あっ 」',
      romaji: 'a',
      meaning: 'A! Á! Ôi! (thán từ thể hiện sự bất ngờ, nhớ ra điều gì)',
      exampleJp: 'あっ、財布を家に忘れてしまいました！',
      exampleVi: 'Á, tôi để quên ví ở nhà mất rồi!',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 3,
      topicCode: 'tu_vung_n4',
      word: '案内',
      reading: '「 あんない 」',
      romaji: 'annai',
      meaning: 'Hướng dẫn, dẫn đường, thông báo',
      exampleJp: '東京の街を案内してあげましょう。',
      exampleVi: 'Để tôi dẫn bạn đi tham quan Tokyo nhé.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 4,
      topicCode: 'tu_vung_n4',
      word: '意見',
      reading: '「 いけん 」',
      romaji: 'iken',
      meaning: 'Ý kiến, quan điểm',
      exampleJp: 'あなたの率直な意見を聞かせてください。',
      exampleVi: 'Xin hãy cho tôi biết ý kiến thẳng thắn của bạn.',
      displayOrder: 4,
    ),
    const TopicWord(
      id: 5,
      topicCode: 'tu_vung_n4',
      word: '安心',
      reading: '「 あんしん 」',
      romaji: 'anshin',
      meaning: 'An tâm, yên lòng',
      exampleJp: '無事だと分かって安心しました。',
      exampleVi: 'Biết bạn bình an tôi thấy thật yên lòng.',
      displayOrder: 5,
    ),
    const TopicWord(
      id: 6,
      topicCode: 'tu_vung_n4',
      word: '急ぐ',
      reading: '「 いそぐ 」',
      romaji: 'isogu',
      meaning: 'Vội vã, gấp rút',
      exampleJp: '電車に遅れないよう急ぎましょう。',
      exampleVi: 'Chúng ta hãy nhanh lên để không bị trễ tàu.',
      displayOrder: 6,
    ),
    const TopicWord(
      id: 7,
      topicCode: 'tu_vung_n4',
      word: '受付',
      reading: '「 うけつけ 」',
      romaji: 'uketsuke',
      meaning: 'Quầy tiếp tân, bàn lễ tân',
      exampleJp: '受付で身分証を提示してください。',
      exampleVi: 'Vui lòng xuất trình giấy tờ tùy thân tại quầy lễ tân.',
      displayOrder: 7,
    ),
    const TopicWord(
      id: 8,
      topicCode: 'tu_vung_n4',
      word: '運動',
      reading: '「 うんどう 」',
      romaji: 'undou',
      meaning: 'Vận động, tập thể thao',
      exampleJp: '健康のために毎朝運動しています。',
      exampleVi: 'Tôi tập thể dục mỗi sáng vì sức khỏe.',
      displayOrder: 8,
    ),
    const TopicWord(
      id: 9,
      topicCode: 'tu_vung_n4',
      word: '選ぶ',
      reading: '「 えらぶ 」',
      romaji: 'erabu',
      meaning: 'Chọn, lựa chọn',
      exampleJp: 'メニューから好きな料理を選んでください。',
      exampleVi: 'Hãy chọn món ăn yêu thích từ thực đơn nhé.',
      displayOrder: 9,
    ),
    const TopicWord(
      id: 10,
      topicCode: 'tu_vung_n4',
      word: '遅れる',
      reading: '「 おくれる 」',
      romaji: 'okureru',
      meaning: 'Đến muộn, trễ hẹn, chậm trễ',
      exampleJp: '渋滞のせいで約束の時間に遅れました。',
      exampleVi: 'Vì kẹt xe nên tôi đã đến trễ giờ hẹn.',
      displayOrder: 10,
    ),
    const TopicWord(
      id: 11,
      topicCode: 'tu_vung_n4',
      word: '送る',
      reading: '「 おくる 」',
      romaji: 'okuru',
      meaning: 'Gửi hàng, tiễn người',
      exampleJp: '荷物を故郷の母に送りました。',
      exampleVi: 'Tôi đã gửi bưu kiện về cho mẹ ở quê.',
      displayOrder: 11,
    ),
    const TopicWord(
      id: 12,
      topicCode: 'tu_vung_n4',
      word: '驚く',
      reading: '「 おどろく 」',
      romaji: 'odoroku',
      meaning: 'Kinh ngạc, giật mình, ngạc nhiên',
      exampleJp: '突然の知らせに大変驚きました。',
      exampleVi: 'Tôi đã rất kinh ngạc trước tin báo đột ngột.',
      displayOrder: 12,
    ),
    const TopicWord(
      id: 13,
      topicCode: 'tu_vung_n4',
      word: '会議',
      reading: '「 かいぎ 」',
      romaji: 'kaigi',
      meaning: 'Cuộc họp, hội nghị',
      exampleJp: '午後二時から大事な会議があります。',
      exampleVi: 'Từ 2 giờ chiều có cuộc họp quan trọng.',
      displayOrder: 13,
    ),
    const TopicWord(
      id: 14,
      topicCode: 'tu_vung_n4',
      word: '簡単',
      reading: '「 かんたん 」',
      romaji: 'kantan',
      meaning: 'Đơn giản, dễ dàng',
      exampleJp: 'この問題はとても簡単です。',
      exampleVi: 'Câu hỏi này rất dễ.',
      displayOrder: 14,
    ),
    const TopicWord(
      id: 15,
      topicCode: 'tu_vung_n4',
      word: '経験',
      reading: '「 けいけん 」',
      romaji: 'keiken',
      meaning: 'Kinh nghiệm, trải nghiệm',
      exampleJp: '日本でいろいろな良い経験ができました。',
      exampleVi: 'Tôi đã có nhiều trải nghiệm tốt ở Nhật.',
      displayOrder: 15,
    ),
    const TopicWord(
      id: 16,
      topicCode: 'tu_vung_n4',
      word: '故障',
      reading: '「 こしょう 」',
      romaji: 'koshou',
      meaning: 'Hỏng hóc, sự cố máy móc',
      exampleJp: '洗濯機が故障して動かない。',
      exampleVi: 'Máy giặt bị hỏng không hoạt động được.',
      displayOrder: 16,
    ),
    const TopicWord(
      id: 17,
      topicCode: 'tu_vung_n4',
      word: '複雑',
      reading: '「 ふくざつ 」',
      romaji: 'fukuzatsu',
      meaning: 'Phức tạp, rắc rối',
      exampleJp: 'この機械の操作は複雑です。',
      exampleVi: 'Thao tác máy này khá phức tạp.',
      displayOrder: 17,
    ),
    const TopicWord(
      id: 18,
      topicCode: 'tu_vung_n4',
      word: '連絡',
      reading: '「 れんらく 」',
      romaji: 'renraku',
      meaning: 'Liên lạc, thông tin qua lại',
      exampleJp: '着いたらすぐに連絡してください。',
      exampleVi: 'Đến nơi hãy liên lạc cho tôi ngay nhé.',
      displayOrder: 18,
    ),
    const TopicWord(
      id: 19,
      topicCode: 'tu_vung_n4',
      word: '予約',
      reading: '「 よやく 」',
      romaji: 'yoyaku',
      meaning: 'Đặt trước, đặt chỗ (vé, phòng)',
      exampleJp: 'レストランの予約を取りました。',
      exampleVi: 'Tôi đã đặt bàn ở nhà hàng rồi.',
      displayOrder: 19,
    ),
    const TopicWord(
      id: 20,
      topicCode: 'tu_vung_n4',
      word: '習慣',
      reading: '「 しゅうかん 」',
      romaji: 'shuukan',
      meaning: 'Tập quán, thói quen',
      exampleJp: '早起きはとても良い習慣です。',
      exampleVi: 'Dậy sớm là một thói quen rất tốt.',
      displayOrder: 20,
    ),
  ];

  // =========================================================================
  // JLPT: HÁN TỰ N4
  // =========================================================================
  static final List<TopicWord> _hanTuN4 = [
    const TopicWord(
      id: 101,
      topicCode: 'han_tu_n4',
      word: '日',
      reading: '「 ニチ / ジツ / ひ / か 」',
      romaji: 'nichi / hi',
      meaning: 'NHẬT: Mặt trời, ngày',
      exampleJp: '日曜日（にちようび）: Chủ nhật',
      exampleVi: 'Hôm nay là ngày Chủ nhật.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 102,
      topicCode: 'han_tu_n4',
      word: '月',
      reading: '「 ゲツ / ガツ / つき 」',
      romaji: 'getsu / tsuki',
      meaning: 'NGUYỆT: Mặt trăng, tháng',
      exampleJp: '月曜日（げつようび）: Thứ hai',
      exampleVi: 'Mặt trăng đêm nay thật tròn.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 103,
      topicCode: 'han_tu_n4',
      word: '火',
      reading: '「 カ / ひ 」',
      romaji: 'ka / hi',
      meaning: 'HỎA: Lửa',
      exampleJp: '火曜日（かようび）: Thứ ba',
      exampleVi: 'Cẩn thận với lửa khi nấu ăn.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 104,
      topicCode: 'han_tu_n4',
      word: '水',
      reading: '「 スイ / みず 」',
      romaji: 'sui / mizu',
      meaning: 'THỦY: Nước',
      exampleJp: '水曜日（すいようび）: Thứ tư',
      exampleVi: 'Uống nhiều nước mỗi ngày.',
      displayOrder: 4,
    ),
    const TopicWord(
      id: 105,
      topicCode: 'han_tu_n4',
      word: '木',
      reading: '「 モク / ボク / き 」',
      romaji: 'moku / ki',
      meaning: 'MỘC: Cây, gỗ',
      exampleJp: '木曜日（もくようび）: Thứ năm',
      exampleVi: 'Cây cối xanh tươi trong công viên.',
      displayOrder: 5,
    ),
  ];

  // =========================================================================
  // JLPT: NGỮ PHÁP N4
  // =========================================================================
  static final List<TopicWord> _nguPhapN4 = [
    const TopicWord(
      id: 201,
      topicCode: 'ngu_phap_n4',
      word: '〜てしまう',
      reading: '「 〜てしまう / 〜ちゃう 」',
      romaji: '~te shimau',
      meaning: 'Lỡ làm gì (hối tiếc) / Đã hoàn thành xong',
      exampleJp: '宿題を忘れてしまいました。',
      exampleVi: 'Tôi lỡ quên mất bài tập về nhà.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 202,
      topicCode: 'ngu_phap_n4',
      word: '〜やすい',
      reading: '「 V(bỏ ます) + やすい 」',
      romaji: '~yasui',
      meaning: 'Dễ làm một hành động nào đó',
      exampleJp: 'このペンは書きやすいです。',
      exampleVi: 'Cây bút này rất dễ viết.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 203,
      topicCode: 'ngu_phap_n4',
      word: '〜にくい',
      reading: '「 V(bỏ ます) + にくい 」',
      romaji: '~nikui',
      meaning: 'Khó làm một hành động nào đó',
      exampleJp: 'この薬は苦くて飲みにくい。',
      exampleVi: 'Thuốc này đắng nên khó uống.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 204,
      topicCode: 'ngu_phap_n4',
      word: '〜すぎる',
      reading: '「 〜すぎる 」',
      romaji: '~sugiru',
      meaning: 'Quá mức, vượt quá giới hạn',
      exampleJp: '昨日お酒を飲みすぎました。',
      exampleVi: 'Hôm qua tôi đã uống quá nhiều rượu.',
      displayOrder: 4,
    ),
    const TopicWord(
      id: 205,
      topicCode: 'ngu_phap_n4',
      word: '〜なければならない',
      reading: '「 V(bỏ ない) + なければならない 」',
      romaji: '~nakereba naranai',
      meaning: 'Phải làm gì đó (bắt buộc)',
      exampleJp: '明日早く起きなければなりません。',
      exampleVi: 'Ngày mai tôi phải dậy sớm.',
      displayOrder: 5,
    ),
    const TopicWord(
      id: 206,
      topicCode: 'ngu_phap_n4',
      word: '〜たことがある',
      reading: '「 V(thể た) + ことがある 」',
      romaji: '~ta koto ga aru',
      meaning: 'Đã từng làm gì (trải nghiệm quá khứ)',
      exampleJp: '日本へ行ったことがありますか。',
      exampleVi: 'Bạn đã từng đến Nhật Bản chưa?',
      displayOrder: 6,
    ),
    const TopicWord(
      id: 207,
      topicCode: 'ngu_phap_n4',
      word: '〜ほうがいい',
      reading: '「 V(thể た / ない) + ほうがいい 」',
      romaji: '~hou ga ii',
      meaning: 'Nên / Không nên làm gì (lời khuyên)',
      exampleJp: '病院に行ったほうがいいですよ。',
      exampleVi: 'Bạn nên đi bệnh viện khám đi.',
      displayOrder: 7,
    ),
    const TopicWord(
      id: 208,
      topicCode: 'ngu_phap_n4',
      word: '〜かもしれない',
      reading: '「 Thể thường + かもしれない 」',
      romaji: '~kamoshirenai',
      meaning: 'Có lẽ, có thể xảy ra (phỏng đoán 50%)',
      exampleJp: '明日は雨が降るかもしれません。',
      exampleVi: 'Ngày mai có thể trời sẽ mưa.',
      displayOrder: 8,
    ),
    const TopicWord(
      id: 209,
      topicCode: 'ngu_phap_n4',
      word: '〜つもり',
      reading: '「 V(thể từ điển / ない) + つもり 」',
      romaji: '~tsumori',
      meaning: 'Dự định làm / không làm gì đó',
      exampleJp: '来年日本に留学するつもりです。',
      exampleVi: 'Năm sau tôi dự định sẽ đi du học Nhật Bản.',
      displayOrder: 9,
    ),
    const TopicWord(
      id: 210,
      topicCode: 'ngu_phap_n4',
      word: '〜てはいけない',
      reading: '「 V(thể て) + はいけない 」',
      romaji: '~te wa ikenai',
      meaning: 'Không được phép làm gì (cấm đoán)',
      exampleJp: 'ここでタバコを吸ってはいけません。',
      exampleVi: 'Không được phép hút thuốc ở đây.',
      displayOrder: 10,
    ),
    const TopicWord(
      id: 211,
      topicCode: 'ngu_phap_n4',
      word: '〜てもいい',
      reading: '「 V(thể て) + もいい 」',
      romaji: '~te mo ii',
      meaning: 'Được phép làm gì đó (cho phép)',
      exampleJp: '写真を撮ってもいいですか。',
      exampleVi: 'Tôi có thể chụp ảnh được không?',
      displayOrder: 11,
    ),
    const TopicWord(
      id: 212,
      topicCode: 'ngu_phap_n4',
      word: '〜ながら',
      reading: '「 V(bỏ ます) + ながら 」',
      romaji: '~nagara',
      meaning: 'Vừa làm việc này vừa làm việc kia',
      exampleJp: '音楽を聞きながら勉強します。',
      exampleVi: 'Tôi vừa nghe nhạc vừa học bài.',
      displayOrder: 12,
    ),
    const TopicWord(
      id: 213,
      topicCode: 'ngu_phap_n4',
      word: '〜まえに',
      reading: '「 V(thể từ điển) + まえに 」',
      romaji: '~mae ni',
      meaning: 'Trước khi làm hành động nào đó',
      exampleJp: '寝る前に本を読みます。',
      exampleVi: 'Trước khi đi ngủ tôi đọc sách.',
      displayOrder: 13,
    ),
    const TopicWord(
      id: 214,
      topicCode: 'ngu_phap_n4',
      word: '〜あとで',
      reading: '「 V(thể た) / Nの + あとで 」',
      romaji: '~ato de',
      meaning: 'Sau khi làm xong hành động nào đó',
      exampleJp: 'ご飯を食べたあとで、薬を飲みます。',
      exampleVi: 'Sau khi ăn cơm xong, tôi sẽ uống thuốc.',
      displayOrder: 14,
    ),
    const TopicWord(
      id: 215,
      topicCode: 'ngu_phap_n4',
      word: '〜ために',
      reading: '「 V(thể từ điển) / Nの + ために 」',
      romaji: '~tame ni',
      meaning: 'Để làm gì / Vì lợi ích của ai',
      exampleJp: '健康のために毎日運動しています。',
      exampleVi: 'Tôi tập thể dục mỗi ngày vì sức khỏe.',
      displayOrder: 15,
    ),
    const TopicWord(
      id: 216,
      topicCode: 'ngu_phap_n4',
      word: '〜ことができる',
      reading: '「 V(thể từ điển) + ことができる 」',
      romaji: '~koto ga dekiru',
      meaning: 'Có thể làm được việc gì đó',
      exampleJp: '日本語を話すことができます。',
      exampleVi: 'Tôi có thể nói được tiếng Nhật.',
      displayOrder: 16,
    ),
  ];

  // =========================================================================
  // JLPT: TỪ VỰNG N5
  // =========================================================================
  static final List<TopicWord> _tuVungN5 = [
    const TopicWord(
      id: 301,
      topicCode: 'tu_vung_n5',
      word: '私',
      reading: '「 わたし 」',
      romaji: 'watashi',
      meaning: 'Tôi (đại từ nhân xưng ngôi thứ nhất)',
      exampleJp: '私はベトナム人です。',
      exampleVi: 'Tôi là người Việt Nam.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 302,
      topicCode: 'tu_vung_n5',
      word: '学生',
      reading: '「 がくせい 」',
      romaji: 'gakusei',
      meaning: 'Học sinh, sinh viên',
      exampleJp: '兄は大学生です。',
      exampleVi: 'Anh trai tôi là sinh viên đại học.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 303,
      topicCode: 'tu_vung_n5',
      word: '先生',
      reading: '「 せんせい 」',
      romaji: 'sensei',
      meaning: 'Thầy giáo, cô giáo, bác sĩ',
      exampleJp: '日本語の先生に質問しました。',
      exampleVi: 'Tôi đã đặt câu hỏi cho giáo viên tiếng Nhật.',
      displayOrder: 3,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: XE CỘ
  // =========================================================================
  static final List<TopicWord> _xeCo = [
    const TopicWord(
      id: 401,
      topicCode: 'xe_co',
      word: '車',
      reading: '「 くるま 」',
      romaji: 'kuruma',
      meaning: 'Xe hơi, ô tô',
      exampleJp: '車を駐車場に止めます。',
      exampleVi: 'Đỗ xe vào bãi đỗ xe.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 402,
      topicCode: 'xe_co',
      word: '自転車',
      reading: '「 じてんしゃ 」',
      romaji: 'jitensha',
      meaning: 'Xe đạp',
      exampleJp: '天気が良いので自転車で行きます。',
      exampleVi: 'Thời tiết đẹp nên tôi đi bằng xe đạp.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 403,
      topicCode: 'xe_co',
      word: 'バイク',
      reading: '「 ばいく 」',
      romaji: 'baiku',
      meaning: 'Xe máy, xe mô tô',
      exampleJp: 'バイクのヘルメットをかぶる。',
      exampleVi: 'Đội mũ bảo hiểm xe máy.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 404,
      topicCode: 'xe_co',
      word: 'エンジン',
      reading: '「 えんじん 」',
      romaji: 'enjin',
      meaning: 'Động cơ, cỗ máy',
      exampleJp: 'エンジンのオイルを交換する。',
      exampleVi: 'Thay dầu nhớt động cơ.',
      displayOrder: 4,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: VẬT LIỆU ĐIỆN VÀ NƯỚC
  // =========================================================================
  static final List<TopicWord> _vatLieuDienNuoc = [
    const TopicWord(
      id: 501,
      topicCode: 'vat_lieu_dien_nuoc',
      word: '電線',
      reading: '「 でんせん 」',
      romaji: 'densen',
      meaning: 'Dây dẫn điện',
      exampleJp: '電線に触れないでください。',
      exampleVi: 'Xin đừng chạm vào dây điện.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 502,
      topicCode: 'vat_lieu_dien_nuoc',
      word: '水道管',
      reading: '「 すいどうかん 」',
      romaji: 'suidoukan',
      meaning: 'Đường ống dẫn nước',
      exampleJp: '水道管の工事を行っています。',
      exampleVi: 'Đang tiến hành thi công đường ống nước.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 503,
      topicCode: 'vat_lieu_dien_nuoc',
      word: 'スイッチ',
      reading: '「 すいっち 」',
      romaji: 'suicchi',
      meaning: 'Công tắc bật/tắt điện',
      exampleJp: '部屋のスイッチを押す。',
      exampleVi: 'Bật công tắc đèn trong phòng.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 504,
      topicCode: 'vat_lieu_dien_nuoc',
      word: 'コンセント',
      reading: '「 こんせんと 」',
      romaji: 'konsento',
      meaning: 'Ổ cắm điện',
      exampleJp: 'スマホの充電器をコンセントに差し込む。',
      exampleVi: 'Cắm sạc điện thoại vào ổ cắm.',
      displayOrder: 4,
    ),
    const TopicWord(
      id: 505,
      topicCode: 'vat_lieu_dien_nuoc',
      word: '蛇口',
      reading: '「 じゃぐち 」',
      romaji: 'jaguchi',
      meaning: 'Vòi nước',
      exampleJp: '蛇口をしっかり閉めてください。',
      exampleVi: 'Hãy khóa chặt vòi nước lại.',
      displayOrder: 5,
    ),
    const TopicWord(
      id: 506,
      topicCode: 'vat_lieu_dien_nuoc',
      word: 'メーター',
      reading: '「 めーたー 」',
      romaji: 'meetaa',
      meaning: 'Đồng hồ đo điện/nước',
      exampleJp: '水道のメーターを確認する。',
      exampleVi: 'Kiểm tra đồng hồ đo nước.',
      displayOrder: 6,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: THỢ CƠ KHÍ
  // =========================================================================
  static final List<TopicWord> _thoCoKhi = [
    const TopicWord(
      id: 601,
      topicCode: 'tho_co_khi',
      word: 'レンチ',
      reading: '「 れんち 」',
      romaji: 'renchi',
      meaning: 'Cờ lê, mỏ lết',
      exampleJp: 'レンチでボルトを締める。',
      exampleVi: 'Dùng cờ lê siết chặt bu lông.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 602,
      topicCode: 'tho_co_khi',
      word: 'ドライバー',
      reading: '「 どらいばー 」',
      romaji: 'doraibaa',
      meaning: 'Tua vít',
      exampleJp: 'プラスドライバーを持ってきてください。',
      exampleVi: 'Vui lòng mang cho tôi cái tua vít 4 cạnh.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 603,
      topicCode: 'tho_co_khi',
      word: 'ボルト',
      reading: '「 ぼると 」',
      romaji: 'boruto',
      meaning: 'Bu lông (ốc vít lớn)',
      exampleJp: 'ボルトが緩んでいる。',
      exampleVi: 'Bu lông đang bị lỏng.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 604,
      topicCode: 'tho_co_khi',
      word: 'ナット',
      reading: '「 なっと 」',
      romaji: 'natto',
      meaning: 'Đai ốc, tán',
      exampleJp: 'ナットをしっかりと固定する。',
      exampleVi: 'Cố định chắc chắn đai ốc.',
      displayOrder: 4,
    ),
    const TopicWord(
      id: 605,
      topicCode: 'tho_co_khi',
      word: '溶接',
      reading: '「 ようせつ 」',
      romaji: 'yousetsu',
      meaning: 'Hàn kim loại, nghề hàn',
      exampleJp: '鉄板を溶接する作業。',
      exampleVi: 'Công việc hàn các tấm sắt thép.',
      displayOrder: 5,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: LỐI SỐNG
  // =========================================================================
  static final List<TopicWord> _loiSong = [
    const TopicWord(
      id: 701,
      topicCode: 'loi_song',
      word: '部屋',
      reading: '「 へや 」',
      romaji: 'heya',
      meaning: 'Căn phòng',
      exampleJp: '部屋をきれいに掃除します。',
      exampleVi: 'Tôi dọn dẹp phòng sạch sẽ.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 702,
      topicCode: 'loi_song',
      word: '掃除',
      reading: '「 そうじ 」',
      romaji: 'souji',
      meaning: 'Dọn dẹp, vệ sinh',
      exampleJp: '週末に部屋の掃除をします。',
      exampleVi: 'Cuối tuần tôi dọn dẹp phòng.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 703,
      topicCode: 'loi_song',
      word: '洗濯',
      reading: '「 せんたく 」',
      romaji: 'sentaku',
      meaning: 'Giặt giũ quần áo',
      exampleJp: '天気がいいので洗濯物を干す。',
      exampleVi: 'Trời đẹp nên tôi phơi quần áo.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 704,
      topicCode: 'loi_song',
      word: '料理',
      reading: '「 りょうり 」',
      romaji: 'ryouri',
      meaning: 'Nấu ăn, món ăn',
      exampleJp: '日本料理を作るのが好きです。',
      exampleVi: 'Tôi thích nấu các món ăn Nhật.',
      displayOrder: 4,
    ),
  ];

  // =========================================================================
  // KHÁC: GIAO TIẾP HÀNG NGÀY
  // =========================================================================
  static final List<TopicWord> _giaoTiepHangNgay = [
    const TopicWord(
      id: 801,
      topicCode: 'giao_tiep_hang_ngay',
      word: 'おはよう',
      reading: '「 おはようございます 」',
      romaji: 'ohayou gozaimasu',
      meaning: 'Chào buổi sáng (lịch sự)',
      exampleJp: '先生、おはようございます。',
      exampleVi: 'Thưa thầy, em chào thầy buổi sáng.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 802,
      topicCode: 'giao_tiep_hang_ngay',
      word: 'こんにちは',
      reading: '「 こんにちは 」',
      romaji: 'konnichiwa',
      meaning: 'Xin chào (buổi chiều / ban ngày)',
      exampleJp: '皆さん、こんにちは！',
      exampleVi: 'Xin chào mọi người!',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 803,
      topicCode: 'giao_tiep_hang_ngay',
      word: 'ありがとう',
      reading: '「 ありがとうございます 」',
      romaji: 'arigatou gozaimasu',
      meaning: 'Cảm ơn rất nhiều',
      exampleJp: '親切に教えてくれてありがとうございます。',
      exampleVi: 'Cảm ơn bạn đã chỉ bảo tận tình.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 804,
      topicCode: 'giao_tiep_hang_ngay',
      word: 'すみません',
      reading: '「 すみません 」',
      romaji: 'sumimasen',
      meaning: 'Xin lỗi / Làm phiền một chút',
      exampleJp: 'すみません、駅はどちらですか。',
      exampleVi: 'Xin lỗi, nhà ga đi lối nào vậy ạ?',
      displayOrder: 4,
    ),
    const TopicWord(
      id: 805,
      topicCode: 'giao_tiep_hang_ngay',
      word: 'お疲れ様',
      reading: '「 おつかれさまでした 」',
      romaji: 'otsukaresama deshita',
      meaning: 'Bạn đã vất vả rồi (lời chào khi tan làm, sau công việc)',
      exampleJp: '今日も一日お疲れ様でした。',
      exampleVi: 'Hôm nay mọi người đã làm việc vất vả rồi.',
      displayOrder: 5,
    ),
  ];

  // =========================================================================
  // KHÁC: DU LỊCH & ẨM THỰC
  // =========================================================================
  static final List<TopicWord> _duLichAmThuc = [
    const TopicWord(
      id: 901,
      topicCode: 'du_lich_am_thuc',
      word: '寿司',
      reading: '「 すし 」',
      romaji: 'sushi',
      meaning: 'Sushi (món cơm trộn giấm ăn với hải sản tươi)',
      exampleJp: '新鮮なサーモンの寿司を食べる。',
      exampleVi: 'Ăn sushi cá hồi tươi ngon.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 902,
      topicCode: 'du_lich_am_thuc',
      word: 'ラーメン',
      reading: '「 らーめん 」',
      romaji: 'raamen',
      meaning: 'Mì Ramen Nhật Bản',
      exampleJp: '熱いとんこつラーメンが一番好きです。',
      exampleVi: 'Tôi thích nhất món mì ramen nước hầm xương heo nóng hổi.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 903,
      topicCode: 'du_lich_am_thuc',
      word: '空港',
      reading: '「 くうこう 」',
      romaji: 'kuukou',
      meaning: 'Sân bay, phi trường',
      exampleJp: '成田空港に到着しました。',
      exampleVi: 'Tôi đã hạ cánh tại sân bay Narita.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 904,
      topicCode: 'du_lich_am_thuc',
      word: 'ホテル',
      reading: '「 ほてる 」',
      romaji: 'hoteru',
      meaning: 'Khách sạn',
      exampleJp: '駅の近くのホテルに泊まります。',
      exampleVi: 'Tôi ở khách sạn gần ga tàu.',
      displayOrder: 4,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: CÔNG NGHỆ THÔNG TIN (IT)
  // =========================================================================
  static final List<TopicWord> _itCntt = [
    const TopicWord(
      id: 1001,
      topicCode: 'it_cntt',
      word: '開発',
      reading: '「 かいはつ 」',
      romaji: 'kaihatsu',
      meaning: 'Phát triển phần mềm / hệ thống',
      exampleJp: '新しいアプリを開発しています。',
      exampleVi: 'Chúng tôi đang phát triển ứng dụng mới.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1002,
      topicCode: 'it_cntt',
      word: '設計',
      reading: '「 せっけい 」',
      romaji: 'sekkei',
      meaning: 'Thiết kế (Database / Kiến trúc hệ thống)',
      exampleJp: 'データベースの設計書を作成する。',
      exampleVi: 'Soạn thảo tài liệu thiết kế cơ sở dữ liệu.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1003,
      topicCode: 'it_cntt',
      word: '仕様書',
      reading: '「 しようしょ 」',
      romaji: 'shiyousho',
      meaning: 'Tài liệu đặc tả yêu cầu (Spec)',
      exampleJp: '仕様書をしっかり確認してください。',
      exampleVi: 'Vui lòng kiểm tra kỹ tài liệu đặc tả.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 1004,
      topicCode: 'it_cntt',
      word: 'バグ',
      reading: '「 ばぐ 」',
      romaji: 'bagu',
      meaning: 'Lỗi phần mềm (Bug)',
      exampleJp: '重大なバグを修正しました。',
      exampleVi: 'Đã sửa lỗi phần mềm nghiêm trọng.',
      displayOrder: 4,
    ),
    const TopicWord(
      id: 1005,
      topicCode: 'it_cntt',
      word: 'テスト',
      reading: '「 てすと 」',
      romaji: 'tesuto',
      meaning: 'Kiểm thử phần mềm',
      exampleJp: 'リリースの前にテストを行います。',
      exampleVi: 'Tiến hành kiểm thử trước khi phát hành.',
      displayOrder: 5,
    ),
    const TopicWord(
      id: 1006,
      topicCode: 'it_cntt',
      word: 'サーバー',
      reading: '「 さーばー 」',
      romaji: 'saabaa',
      meaning: 'Máy chủ (Server)',
      exampleJp: 'サーバーにデータを送信する。',
      exampleVi: 'Gửi dữ liệu lên máy chủ.',
      displayOrder: 6,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: XÂY DỰNG
  // =========================================================================
  static final List<TopicWord> _xayDung = [
    const TopicWord(
      id: 1101,
      topicCode: 'xay_dung',
      word: '現場',
      reading: '「 げんば 」',
      romaji: 'genba',
      meaning: 'Hiện trường, công trường thi công',
      exampleJp: '工事現場に入る時は注意してください。',
      exampleVi: 'Hãy chú ý khi bước vào công trường thi công.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1102,
      topicCode: 'xay_dung',
      word: '安全第一',
      reading: '「 あんぜんだいいち 」',
      romaji: 'anzen daiichi',
      meaning: 'An toàn là trên hết / An toàn là số 1',
      exampleJp: '現場では安全第一で作業します。',
      exampleVi: 'Tại công trường, an toàn luôn là ưu tiên số một.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1103,
      topicCode: 'xay_dung',
      word: 'ヘルメット',
      reading: '「 へるめっと 」',
      romaji: 'herumetto',
      meaning: 'Mũ bảo hộ lao động',
      exampleJp: '必ずヘルメットを着用してください。',
      exampleVi: 'Nhất định phải đội mũ bảo hộ.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 1104,
      topicCode: 'xay_dung',
      word: '足場',
      reading: '「 あしば 」',
      romaji: 'ashiba',
      meaning: 'Giàn giáo xây dựng',
      exampleJp: '足場を組み立てる。',
      exampleVi: 'Lắp ráp giàn giáo thi công.',
      displayOrder: 4,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: ĐIỀU DƯỠNG & Y TẾ
  // =========================================================================
  static final List<TopicWord> _dieuDuong = [
    const TopicWord(
      id: 1201,
      topicCode: 'dieu_duong',
      word: '介護',
      reading: '「 かいご 」',
      romaji: 'kaigo',
      meaning: 'Điều dưỡng, chăm sóc người già / bệnh nhân',
      exampleJp: '介護施設で働いています。',
      exampleVi: 'Tôi đang làm việc tại viện dưỡng lão.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1202,
      topicCode: 'dieu_duong',
      word: '体温',
      reading: '「 たいおん 」',
      romaji: 'taion',
      meaning: 'Thân nhiệt, nhiệt độ cơ thể',
      exampleJp: '毎朝体温を測ります。',
      exampleVi: 'Đo thân nhiệt mỗi buổi sáng.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1203,
      topicCode: 'dieu_duong',
      word: '血圧',
      reading: '「 けつあつ 」',
      romaji: 'ketsuatsu',
      meaning: 'Huyết áp',
      exampleJp: '血圧は正常です。',
      exampleVi: 'Huyết áp bình thường.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 1204,
      topicCode: 'dieu_duong',
      word: '車椅子',
      reading: '「 くるまいす 」',
      romaji: 'kurumaisu',
      meaning: 'Xe lăn',
      exampleJp: '車椅子を押してお散歩に行きます。',
      exampleVi: 'Đẩy xe lăn đưa người bệnh đi dạo.',
      displayOrder: 4,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: KHÁCH SẠN & NHÀ HÀNG
  // =========================================================================
  static final List<TopicWord> _khachSanNhaHang = [
    const TopicWord(
      id: 1301,
      topicCode: 'khach_san_nha_hang',
      word: 'いらっしゃいませ',
      reading: '「 いらっしゃいませ 」',
      romaji: 'irasshaimase',
      meaning: 'Kính chào quý khách! (lời chào khi khách vào quán)',
      exampleJp: 'いらっしゃいませ、何名様ですか。',
      exampleVi: 'Kính chào quý khách, quý khách đi mấy người ạ?',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1302,
      topicCode: 'khach_san_nha_hang',
      word: '注文',
      reading: '「 ちゅうもん 」',
      romaji: 'chuumon',
      meaning: 'Gọi món, đặt món, order',
      exampleJp: 'ご注文はお決まりですか。',
      exampleVi: 'Quý khách đã chọn được món chưa ạ?',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1303,
      topicCode: 'khach_san_nha_hang',
      word: '会計',
      reading: '「 かいけい 」',
      romaji: 'kaikei',
      meaning: 'Thanh toán, tính tiền',
      exampleJp: 'お会計をお願いします。',
      exampleVi: 'Làm ơn cho tôi thanh toán.',
      displayOrder: 3,
    ),
    const TopicWord(
      id: 1304,
      topicCode: 'khach_san_nha_hang',
      word: 'チェックイン',
      reading: '「 ちぇっくいん 」',
      romaji: 'chekkuin',
      meaning: 'Làm thủ tục nhận phòng (Check-in)',
      exampleJp: 'チェックインは何時からですか。',
      exampleVi: 'Mấy giờ có thể làm thủ tục nhận phòng ạ?',
      displayOrder: 4,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: NÔNG NGHIỆP
  // =========================================================================
  static final List<TopicWord> _nongNghiep = [
    const TopicWord(
      id: 1401,
      topicCode: 'nong_nghiep',
      word: '畑',
      reading: '「 はたけ 」',
      romaji: 'hatake',
      meaning: 'Cánh đồng rau, nương rẫy',
      exampleJp: '畑で野菜を育てています。',
      exampleVi: 'Tôi trồng rau ở ngoài vườn nương.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1402,
      topicCode: 'nong_nghiep',
      word: '収穫',
      reading: '「 しゅうかく 」',
      romaji: 'shuukaku',
      meaning: 'Thu hoạch hoa màu / trái cây',
      exampleJp: 'トマトをたくさん収穫しました。',
      exampleVi: 'Đã thu hoạch được rất nhiều cà chua.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1403,
      topicCode: 'nong_nghiep',
      word: '肥料',
      reading: '「 ひりょう 」',
      romaji: 'hiryou',
      meaning: 'Phân bón cây trồng',
      exampleJp: '土に肥料を混ぜる。',
      exampleVi: 'Trộn phân bón vào đất.',
      displayOrder: 3,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: CHẾ BIẾN THỰC PHẨM
  // =========================================================================
  static final List<TopicWord> _cheBienThucPham = [
    const TopicWord(
      id: 1501,
      topicCode: 'che_bien_thuc_pham',
      word: '衛生',
      reading: '「 えいせい 」',
      romaji: 'eisei',
      meaning: 'Vệ sinh an toàn thực phẩm',
      exampleJp: '工場の衛生管理を徹底する。',
      exampleVi: 'Thực hiện triệt để quản lý vệ sinh trong nhà xưởng.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1502,
      topicCode: 'che_bien_thuc_pham',
      word: '殺菌',
      reading: '「 さっきん 」',
      romaji: 'sakkin',
      meaning: 'Khử trùng, diệt khuẩn',
      exampleJp: '高温で殺菌処理を行います。',
      exampleVi: 'Tiến hành xử lý diệt khuẩn ở nhiệt độ cao.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1503,
      topicCode: 'che_bien_thuc_pham',
      word: '賞味期限',
      reading: '「 しょうみきげん 」',
      romaji: 'shoumikigen',
      meaning: 'Hạn sử dụng (ngon nhất)',
      exampleJp: '賞味期限を確認してください。',
      exampleVi: 'Xin vui lòng kiểm tra hạn sử dụng.',
      displayOrder: 3,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: MAY MẶC
  // =========================================================================
  static final List<TopicWord> _mayMac = [
    const TopicWord(
      id: 1601,
      topicCode: 'may_mac',
      word: 'ミシン',
      reading: '「 みしん 」',
      romaji: 'mishin',
      meaning: 'Máy khâu, máy may',
      exampleJp: '工業用ミシンを使う。',
      exampleVi: 'Sử dụng máy may công nghiệp.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1602,
      topicCode: 'may_mac',
      word: '縫製',
      reading: '「 ほうせい 」',
      romaji: 'housei',
      meaning: 'May mặc, gia công may vá',
      exampleJp: '洋服の縫製作業を行います。',
      exampleVi: 'Thực hiện công đoạn may quần áo.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1603,
      topicCode: 'may_mac',
      word: '生地',
      reading: '「 きじ 」',
      romaji: 'kiji',
      meaning: 'Vải, chất liệu vải may',
      exampleJp: '肌触りの良い生地を選ぶ。',
      exampleVi: 'Chọn loại vải mềm mại dễ chịu.',
      displayOrder: 3,
    ),
  ];

  // =========================================================================
  // CHUYÊN NGÀNH: KINH DOANH & THƯƠNG MẠI
  // =========================================================================
  static final List<TopicWord> _kinhDoanh = [
    const TopicWord(
      id: 1701,
      topicCode: 'kinh_doanh',
      word: '契約',
      reading: '「 けいやく 」',
      romaji: 'keiyaku',
      meaning: 'Hợp đồng, ký kết hợp đồng',
      exampleJp: '新しい契約を結びました。',
      exampleVi: 'Chúng tôi đã ký kết một hợp đồng mới.',
      displayOrder: 1,
    ),
    const TopicWord(
      id: 1702,
      topicCode: 'kinh_doanh',
      word: '取引先',
      reading: '「 とりひきさき 」',
      romaji: 'torihikisaki',
      meaning: 'Đối tác, khách hàng làm ăn',
      exampleJp: '取引先へ訪問します。',
      exampleVi: 'Đến thăm và làm việc với đối tác.',
      displayOrder: 2,
    ),
    const TopicWord(
      id: 1703,
      topicCode: 'kinh_doanh',
      word: '見積もり',
      reading: '「 みつもり 」',
      romaji: 'mitsumori',
      meaning: 'Bảng báo giá, dự toán chi phí',
      exampleJp: '見積書をメールで送付しました。',
      exampleVi: 'Tôi đã gửi bảng báo giá qua email.',
      displayOrder: 3,
    ),
  ];
}
