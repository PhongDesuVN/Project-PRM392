import '../models/alphabet_models.dart';

/// Dữ liệu cục bộ đầy đủ của Bảng chữ cái Hiragana & Katakana.
/// Đảm bảo ứng dụng chạy mượt mà ngay cả khi chưa bật backend hoặc đang ngoại tuyến.
class AlphabetLocalData {
  const AlphabetLocalData._();

  static AlphabetResponse getAlphabet(AlphabetScript script) {
    return script == AlphabetScript.katakana
        ? getKatakanaAlphabet()
        : getHiraganaAlphabet();
  }

  // =========================================================================
  // HIRAGANA
  // =========================================================================
  static AlphabetResponse getHiraganaAlphabet() {
    return AlphabetResponse(
      script: 'hiragana',
      title: 'Bảng chữ cái Hira',
      sections: [
        _hiraganaGojuuon,
        _hiraganaDakuon,
        _hiraganaYouon,
      ],
    );
  }

  static const AlphabetSection _hiraganaGojuuon = AlphabetSection(
    type: 'gojuuon',
    title: 'Gojuuon',
    columns: 5,
    grid: [
      [
        AlphabetItem(character: 'あ', romaji: 'a'),
        AlphabetItem(character: 'い', romaji: 'i'),
        AlphabetItem(character: 'う', romaji: 'u'),
        AlphabetItem(character: 'え', romaji: 'e'),
        AlphabetItem(character: 'お', romaji: 'o'),
      ],
      [
        AlphabetItem(character: 'か', romaji: 'ka'),
        AlphabetItem(character: 'き', romaji: 'ki'),
        AlphabetItem(character: 'く', romaji: 'ku'),
        AlphabetItem(character: 'け', romaji: 'ke'),
        AlphabetItem(character: 'こ', romaji: 'ko'),
      ],
      [
        AlphabetItem(character: 'さ', romaji: 'sa'),
        AlphabetItem(character: 'し', romaji: 'shi'),
        AlphabetItem(character: 'す', romaji: 'su'),
        AlphabetItem(character: 'せ', romaji: 'se'),
        AlphabetItem(character: 'そ', romaji: 'so'),
      ],
      [
        AlphabetItem(character: 'た', romaji: 'ta'),
        AlphabetItem(character: 'ち', romaji: 'chi'),
        AlphabetItem(character: 'つ', romaji: 'tsu'),
        AlphabetItem(character: 'て', romaji: 'te'),
        AlphabetItem(character: 'と', romaji: 'to'),
      ],
      [
        AlphabetItem(character: 'な', romaji: 'na'),
        AlphabetItem(character: 'に', romaji: 'ni'),
        AlphabetItem(character: 'ぬ', romaji: 'nu'),
        AlphabetItem(character: 'ね', romaji: 'ne'),
        AlphabetItem(character: 'の', romaji: 'no'),
      ],
      [
        AlphabetItem(character: 'は', romaji: 'ha'),
        AlphabetItem(character: 'ひ', romaji: 'hi'),
        AlphabetItem(character: 'ふ', romaji: 'fu'),
        AlphabetItem(character: 'へ', romaji: 'he'),
        AlphabetItem(character: 'ほ', romaji: 'ho'),
      ],
      [
        AlphabetItem(character: 'ま', romaji: 'ma'),
        AlphabetItem(character: 'み', romaji: 'mi'),
        AlphabetItem(character: 'む', romaji: 'mu'),
        AlphabetItem(character: 'め', romaji: 'me'),
        AlphabetItem(character: 'も', romaji: 'mo'),
      ],
      [
        AlphabetItem(character: 'や', romaji: 'ya'),
        null,
        AlphabetItem(character: 'ゆ', romaji: 'yu'),
        null,
        AlphabetItem(character: 'よ', romaji: 'yo'),
      ],
      [
        AlphabetItem(character: 'ら', romaji: 'ra'),
        AlphabetItem(character: 'り', romaji: 'ri'),
        AlphabetItem(character: 'る', romaji: 'ru'),
        AlphabetItem(character: 'れ', romaji: 're'),
        AlphabetItem(character: 'ろ', romaji: 'ro'),
      ],
      [
        AlphabetItem(character: 'わ', romaji: 'wa'),
        null,
        null,
        null,
        AlphabetItem(character: 'を', romaji: 'wo'),
      ],
      [
        AlphabetItem(character: 'ん', romaji: 'n'),
        null,
        null,
        null,
        null,
      ],
    ],
  );

  static const AlphabetSection _hiraganaDakuon = AlphabetSection(
    type: 'dakuon',
    title: 'Dakuon & Handakuon',
    columns: 5,
    grid: [
      [
        AlphabetItem(character: 'が', romaji: 'ga'),
        AlphabetItem(character: 'ぎ', romaji: 'gi'),
        AlphabetItem(character: 'ぐ', romaji: 'gu'),
        AlphabetItem(character: 'げ', romaji: 'ge'),
        AlphabetItem(character: 'ご', romaji: 'go'),
      ],
      [
        AlphabetItem(character: 'ざ', romaji: 'za'),
        AlphabetItem(character: 'じ', romaji: 'ji'),
        AlphabetItem(character: 'ず', romaji: 'zu'),
        AlphabetItem(character: 'ぜ', romaji: 'ze'),
        AlphabetItem(character: 'ぞ', romaji: 'zo'),
      ],
      [
        AlphabetItem(character: 'だ', romaji: 'da'),
        AlphabetItem(character: 'ぢ', romaji: 'ji'),
        AlphabetItem(character: 'づ', romaji: 'zu'),
        AlphabetItem(character: 'で', romaji: 'de'),
        AlphabetItem(character: 'ど', romaji: 'do'),
      ],
      [
        AlphabetItem(character: 'ば', romaji: 'ba'),
        AlphabetItem(character: 'び', romaji: 'bi'),
        AlphabetItem(character: 'ぶ', romaji: 'bu'),
        AlphabetItem(character: 'べ', romaji: 'be'),
        AlphabetItem(character: 'ぼ', romaji: 'bo'),
      ],
      [
        AlphabetItem(character: 'ぱ', romaji: 'pa'),
        AlphabetItem(character: 'ぴ', romaji: 'pi'),
        AlphabetItem(character: 'ぷ', romaji: 'pu'),
        AlphabetItem(character: 'ぺ', romaji: 'pe'),
        AlphabetItem(character: 'ぽ', romaji: 'po'),
      ],
    ],
  );

  static const AlphabetSection _hiraganaYouon = AlphabetSection(
    type: 'youon',
    title: 'Youon',
    columns: 3,
    grid: [
      [
        AlphabetItem(character: 'きゃ', romaji: 'kya'),
        AlphabetItem(character: 'きゅ', romaji: 'kyu'),
        AlphabetItem(character: 'きょ', romaji: 'kyo'),
      ],
      [
        AlphabetItem(character: 'ぎゃ', romaji: 'gya'),
        AlphabetItem(character: 'ぎゅ', romaji: 'gyu'),
        AlphabetItem(character: 'ぎょ', romaji: 'gyo'),
      ],
      [
        AlphabetItem(character: 'しゃ', romaji: 'sha'),
        AlphabetItem(character: 'しゅ', romaji: 'shu'),
        AlphabetItem(character: 'しょ', romaji: 'sho'),
      ],
      [
        AlphabetItem(character: 'じゃ', romaji: 'ja'),
        AlphabetItem(character: 'じゅ', romaji: 'ju'),
        AlphabetItem(character: 'じょ', romaji: 'jo'),
      ],
      [
        AlphabetItem(character: 'ちゃ', romaji: 'cha'),
        AlphabetItem(character: 'ちゅ', romaji: 'chu'),
        AlphabetItem(character: 'ちょ', romaji: 'cho'),
      ],
      [
        AlphabetItem(character: 'ぢゃ', romaji: 'ja'),
        AlphabetItem(character: 'ぢゅ', romaji: 'ju'),
        AlphabetItem(character: 'ぢょ', romaji: 'jo'),
      ],
      [
        AlphabetItem(character: 'にゃ', romaji: 'nya'),
        AlphabetItem(character: 'にゅ', romaji: 'nyu'),
        AlphabetItem(character: 'にょ', romaji: 'nyo'),
      ],
      [
        AlphabetItem(character: 'ひゃ', romaji: 'hya'),
        AlphabetItem(character: 'ひゅ', romaji: 'hyu'),
        AlphabetItem(character: 'ひょ', romaji: 'hyo'),
      ],
      [
        AlphabetItem(character: 'びゃ', romaji: 'bya'),
        AlphabetItem(character: 'びゅ', romaji: 'byu'),
        AlphabetItem(character: 'びょ', romaji: 'byo'),
      ],
      [
        AlphabetItem(character: 'ぴゃ', romaji: 'pya'),
        AlphabetItem(character: 'ぴゅ', romaji: 'pyu'),
        AlphabetItem(character: 'ぴょ', romaji: 'pyo'),
      ],
      [
        AlphabetItem(character: 'みゃ', romaji: 'mya'),
        AlphabetItem(character: 'みゅ', romaji: 'myu'),
        AlphabetItem(character: 'みょ', romaji: 'myo'),
      ],
      [
        AlphabetItem(character: 'りゃ', romaji: 'rya'),
        AlphabetItem(character: 'りゅ', romaji: 'ryu'),
        AlphabetItem(character: 'りょ', romaji: 'ryo'),
      ],
    ],
  );

  // =========================================================================
  // KATAKANA
  // =========================================================================
  static AlphabetResponse getKatakanaAlphabet() {
    return AlphabetResponse(
      script: 'katakana',
      title: 'Bảng chữ cái Kata',
      sections: [
        _katakanaGojuuon,
        _katakanaDakuon,
        _katakanaYouon,
      ],
    );
  }

  static const AlphabetSection _katakanaGojuuon = AlphabetSection(
    type: 'gojuuon',
    title: 'Gojuuon',
    columns: 5,
    grid: [
      [
        AlphabetItem(character: 'ア', romaji: 'a'),
        AlphabetItem(character: 'イ', romaji: 'i'),
        AlphabetItem(character: 'ウ', romaji: 'u'),
        AlphabetItem(character: 'エ', romaji: 'e'),
        AlphabetItem(character: 'オ', romaji: 'o'),
      ],
      [
        AlphabetItem(character: 'カ', romaji: 'ka'),
        AlphabetItem(character: 'キ', romaji: 'ki'),
        AlphabetItem(character: 'ク', romaji: 'ku'),
        AlphabetItem(character: 'ケ', romaji: 'ke'),
        AlphabetItem(character: 'コ', romaji: 'ko'),
      ],
      [
        AlphabetItem(character: 'サ', romaji: 'sa'),
        AlphabetItem(character: 'シ', romaji: 'shi'),
        AlphabetItem(character: 'ス', romaji: 'su'),
        AlphabetItem(character: 'セ', romaji: 'se'),
        AlphabetItem(character: 'ソ', romaji: 'so'),
      ],
      [
        AlphabetItem(character: 'タ', romaji: 'ta'),
        AlphabetItem(character: 'チ', romaji: 'chi'),
        AlphabetItem(character: 'ツ', romaji: 'tsu'),
        AlphabetItem(character: 'テ', romaji: 'te'),
        AlphabetItem(character: 'ト', romaji: 'to'),
      ],
      [
        AlphabetItem(character: 'ナ', romaji: 'na'),
        AlphabetItem(character: 'ニ', romaji: 'ni'),
        AlphabetItem(character: 'ヌ', romaji: 'nu'),
        AlphabetItem(character: 'ネ', romaji: 'ne'),
        AlphabetItem(character: 'ノ', romaji: 'no'),
      ],
      [
        AlphabetItem(character: 'ハ', romaji: 'ha'),
        AlphabetItem(character: 'ヒ', romaji: 'hi'),
        AlphabetItem(character: 'フ', romaji: 'fu'),
        AlphabetItem(character: 'ヘ', romaji: 'he'),
        AlphabetItem(character: 'ホ', romaji: 'ho'),
      ],
      [
        AlphabetItem(character: 'マ', romaji: 'ma'),
        AlphabetItem(character: 'ミ', romaji: 'mi'),
        AlphabetItem(character: 'ム', romaji: 'mu'),
        AlphabetItem(character: 'メ', romaji: 'me'),
        AlphabetItem(character: 'モ', romaji: 'mo'),
      ],
      [
        AlphabetItem(character: 'ヤ', romaji: 'ya'),
        null,
        AlphabetItem(character: 'ユ', romaji: 'yu'),
        null,
        AlphabetItem(character: 'ヨ', romaji: 'yo'),
      ],
      [
        AlphabetItem(character: 'ラ', romaji: 'ra'),
        AlphabetItem(character: 'リ', romaji: 'ri'),
        AlphabetItem(character: 'ル', romaji: 'ru'),
        AlphabetItem(character: 'レ', romaji: 're'),
        AlphabetItem(character: 'ロ', romaji: 'ro'),
      ],
      [
        AlphabetItem(character: 'ワ', romaji: 'wa'),
        null,
        null,
        null,
        AlphabetItem(character: 'ヲ', romaji: 'wo'),
      ],
      [
        AlphabetItem(character: 'ン', romaji: 'n'),
        null,
        null,
        null,
        null,
      ],
    ],
  );

  static const AlphabetSection _katakanaDakuon = AlphabetSection(
    type: 'dakuon',
    title: 'Dakuon & Handakuon',
    columns: 5,
    grid: [
      [
        AlphabetItem(character: 'ガ', romaji: 'ga'),
        AlphabetItem(character: 'ギ', romaji: 'gi'),
        AlphabetItem(character: 'グ', romaji: 'gu'),
        AlphabetItem(character: 'ゲ', romaji: 'ge'),
        AlphabetItem(character: 'ゴ', romaji: 'go'),
      ],
      [
        AlphabetItem(character: 'ザ', romaji: 'za'),
        AlphabetItem(character: 'ジ', romaji: 'ji'),
        AlphabetItem(character: 'ズ', romaji: 'zu'),
        AlphabetItem(character: 'ゼ', romaji: 'ze'),
        AlphabetItem(character: 'ゾ', romaji: 'zo'),
      ],
      [
        AlphabetItem(character: 'ダ', romaji: 'da'),
        AlphabetItem(character: 'ヂ', romaji: 'ji'),
        AlphabetItem(character: 'ヅ', romaji: 'zu'),
        AlphabetItem(character: 'デ', romaji: 'de'),
        AlphabetItem(character: 'ド', romaji: 'do'),
      ],
      [
        AlphabetItem(character: 'バ', romaji: 'ba'),
        AlphabetItem(character: 'ビ', romaji: 'bi'),
        AlphabetItem(character: 'ブ', romaji: 'bu'),
        AlphabetItem(character: 'ベ', romaji: 'be'),
        AlphabetItem(character: 'ボ', romaji: 'bo'),
      ],
      [
        AlphabetItem(character: 'パ', romaji: 'pa'),
        AlphabetItem(character: 'ピ', romaji: 'pi'),
        AlphabetItem(character: 'プ', romaji: 'pu'),
        AlphabetItem(character: 'ペ', romaji: 'pe'),
        AlphabetItem(character: 'ポ', romaji: 'po'),
      ],
    ],
  );

  static const AlphabetSection _katakanaYouon = AlphabetSection(
    type: 'youon',
    title: 'Youon',
    columns: 3,
    grid: [
      [
        AlphabetItem(character: 'キャ', romaji: 'kya'),
        AlphabetItem(character: 'キュ', romaji: 'kyu'),
        AlphabetItem(character: 'キョ', romaji: 'kyo'),
      ],
      [
        AlphabetItem(character: 'ギャ', romaji: 'gya'),
        AlphabetItem(character: 'ギュ', romaji: 'gyu'),
        AlphabetItem(character: 'ギョ', romaji: 'gyo'),
      ],
      [
        AlphabetItem(character: 'シャ', romaji: 'sha'),
        AlphabetItem(character: 'シュ', romaji: 'shu'),
        AlphabetItem(character: 'ショ', romaji: 'sho'),
      ],
      [
        AlphabetItem(character: 'ジャ', romaji: 'ja'),
        AlphabetItem(character: 'ジュ', romaji: 'ju'),
        AlphabetItem(character: 'ジョ', romaji: 'jo'),
      ],
      [
        AlphabetItem(character: 'チャ', romaji: 'cha'),
        AlphabetItem(character: 'チュ', romaji: 'chu'),
        AlphabetItem(character: 'チョ', romaji: 'cho'),
      ],
      [
        AlphabetItem(character: 'ヂャ', romaji: 'ja'),
        AlphabetItem(character: 'ヂュ', romaji: 'ju'),
        AlphabetItem(character: 'ヂョ', romaji: 'jo'),
      ],
      [
        AlphabetItem(character: 'ニャ', romaji: 'nya'),
        AlphabetItem(character: 'ニュ', romaji: 'nyu'),
        AlphabetItem(character: 'ニョ', romaji: 'nyo'),
      ],
      [
        AlphabetItem(character: 'ヒャ', romaji: 'hya'),
        AlphabetItem(character: 'ヒュ', romaji: 'hyu'),
        AlphabetItem(character: 'ヒョ', romaji: 'hyo'),
      ],
      [
        AlphabetItem(character: 'ビャ', romaji: 'bya'),
        AlphabetItem(character: 'ビュ', romaji: 'byu'),
        AlphabetItem(character: 'ビョ', romaji: 'byo'),
      ],
      [
        AlphabetItem(character: 'ピャ', romaji: 'pya'),
        AlphabetItem(character: 'ピュ', romaji: 'pyu'),
        AlphabetItem(character: 'ピョ', romaji: 'pyo'),
      ],
      [
        AlphabetItem(character: 'ミャ', romaji: 'mya'),
        AlphabetItem(character: 'ミュ', romaji: 'myu'),
        AlphabetItem(character: 'ミョ', romaji: 'myo'),
      ],
      [
        AlphabetItem(character: 'リャ', romaji: 'rya'),
        AlphabetItem(character: 'リュ', romaji: 'ryu'),
        AlphabetItem(character: 'リョ', romaji: 'ryo'),
      ],
    ],
  );
}
