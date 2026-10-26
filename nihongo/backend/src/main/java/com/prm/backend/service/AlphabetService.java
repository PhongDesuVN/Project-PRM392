package com.prm.backend.service;

import com.prm.backend.dto.alphabet.AlphabetDtos.AlphabetItem;
import com.prm.backend.dto.alphabet.AlphabetDtos.AlphabetResponse;
import com.prm.backend.dto.alphabet.AlphabetDtos.AlphabetSection;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

/**
 * Service cung cấp dữ liệu đầy đủ bảng chữ cái tiếng Nhật:
 * - Hiragana & Katakana
 * - 3 kiểu phân loại: Gojuuon (Ngũ thập âm), Dakuon & Handakuon (Biến âm & Bán biến âm), Youon (Ảo âm / Âm ghép)
 */
@Service
public class AlphabetService {

    public AlphabetResponse getAlphabet(String script) {
        if ("katakana".equalsIgnoreCase(script) || "kata".equalsIgnoreCase(script)) {
            return getKatakanaAlphabet();
        }
        return getHiraganaAlphabet();
    }

    /**
     * Dữ liệu đầy đủ bảng chữ cái Hiragana (Hira).
     */
    public AlphabetResponse getHiraganaAlphabet() {
        return new AlphabetResponse(
                "hiragana",
                "Bảng chữ cái Hira",
                List.of(
                        buildHiraganaGojuuon(),
                        buildHiraganaDakuon(),
                        buildHiraganaYouon()
                )
        );
    }

    /**
     * Dữ liệu đầy đủ bảng chữ cái Katakana (Kata).
     */
    public AlphabetResponse getKatakanaAlphabet() {
        return new AlphabetResponse(
                "katakana",
                "Bảng chữ cái Kata",
                List.of(
                        buildKatakanaGojuuon(),
                        buildKatakanaDakuon(),
                        buildKatakanaYouon()
                )
        );
    }

    // =========================================================================
    // HIRAGANA BUILDERS
    // =========================================================================

    private AlphabetSection buildHiraganaGojuuon() {
        List<List<AlphabetItem>> grid = List.of(
                row(it("あ", "a"), it("い", "i"), it("う", "u"), it("え", "e"), it("お", "o")),
                row(it("か", "ka"), it("き", "ki"), it("く", "ku"), it("け", "ke"), it("こ", "ko")),
                row(it("さ", "sa"), it("し", "shi"), it("す", "su"), it("せ", "se"), it("そ", "so")),
                row(it("た", "ta"), it("ち", "chi"), it("つ", "tsu"), it("て", "te"), it("と", "to")),
                row(it("な", "na"), it("に", "ni"), it("ぬ", "nu"), it("ね", "ne"), it("の", "no")),
                row(it("は", "ha"), it("ひ", "hi"), it("ふ", "fu"), it("へ", "he"), it("ほ", "ho")),
                row(it("ま", "ma"), it("み", "mi"), it("む", "mu"), it("め", "me"), it("も", "mo")),
                row(it("や", "ya"), null, it("ゆ", "yu"), null, it("よ", "yo")),
                row(it("ら", "ra"), it("り", "ri"), it("る", "ru"), it("れ", "re"), it("ろ", "ro")),
                row(it("わ", "wa"), null, null, null, it("を", "wo")),
                row(it("ん", "n"), null, null, null, null)
        );

        return new AlphabetSection("gojuuon", "Gojuuon", 5, grid);
    }

    private AlphabetSection buildHiraganaDakuon() {
        List<List<AlphabetItem>> grid = List.of(
                row(it("が", "ga"), it("ぎ", "gi"), it("ぐ", "gu"), it("げ", "ge"), it("ご", "go")),
                row(it("ざ", "za"), it("じ", "ji"), it("ず", "zu"), it("ぜ", "ze"), it("ぞ", "zo")),
                row(it("だ", "da"), it("ぢ", "ji"), it("づ", "zu"), it("で", "de"), it("ど", "do")),
                row(it("ば", "ba"), it("び", "bi"), it("ぶ", "bu"), it("べ", "be"), it("ぼ", "bo")),
                row(it("ぱ", "pa"), it("ぴ", "pi"), it("ぷ", "pu"), it("ぺ", "pe"), it("ぽ", "po"))
        );

        return new AlphabetSection("dakuon", "Dakuon & Handakuon", 5, grid);
    }

    private AlphabetSection buildHiraganaYouon() {
        List<List<AlphabetItem>> grid = List.of(
                row(it("きゃ", "kya"), it("きゅ", "kyu"), it("きょ", "kyo")),
                row(it("ぎゃ", "gya"), it("ぎゅ", "gyu"), it("ぎょ", "gyo")),
                row(it("しゃ", "sha"), it("しゅ", "shu"), it("しょ", "sho")),
                row(it("じゃ", "ja"), it("じゅ", "ju"), it("じょ", "jo")),
                row(it("ちゃ", "cha"), it("ちゅ", "chu"), it("ちょ", "cho")),
                row(it("ぢゃ", "ja"), it("ぢゅ", "ju"), it("ぢょ", "jo")),
                row(it("にゃ", "nya"), it("にゅ", "nyu"), it("にょ", "nyo")),
                row(it("ひゃ", "hya"), it("ひゅ", "hyu"), it("ひょ", "hyo")),
                row(it("びゃ", "bya"), it("びゅ", "byu"), it("びょ", "byo")),
                row(it("ぴゃ", "pya"), it("ぴゅ", "pyu"), it("ぴょ", "pyo")),
                row(it("みゃ", "mya"), it("みゅ", "myu"), it("みょ", "myo")),
                row(it("りゃ", "rya"), it("りゅ", "ryu"), it("りょ", "ryo"))
        );

        return new AlphabetSection("youon", "Youon", 3, grid);
    }

    // =========================================================================
    // KATAKANA BUILDERS
    // =========================================================================

    private AlphabetSection buildKatakanaGojuuon() {
        List<List<AlphabetItem>> grid = List.of(
                row(it("ア", "a"), it("イ", "i"), it("ウ", "u"), it("エ", "e"), it("オ", "o")),
                row(it("カ", "ka"), it("キ", "ki"), it("ク", "ku"), it("ケ", "ke"), it("コ", "ko")),
                row(it("サ", "sa"), it("シ", "shi"), it("ス", "su"), it("セ", "se"), it("ソ", "so")),
                row(it("タ", "ta"), it("チ", "chi"), it("ツ", "tsu"), it("テ", "te"), it("ト", "to")),
                row(it("ナ", "na"), it("ニ", "ni"), it("ヌ", "nu"), it("ネ", "ne"), it("ノ", "no")),
                row(it("ハ", "ha"), it("ヒ", "hi"), it("フ", "fu"), it("ヘ", "he"), it("ホ", "ho")),
                row(it("マ", "ma"), it("ミ", "mi"), it("ム", "mu"), it("メ", "me"), it("モ", "mo")),
                row(it("ヤ", "ya"), null, it("ユ", "yu"), null, it("ヨ", "yo")),
                row(it("ラ", "ra"), it("リ", "ri"), it("ル", "ru"), it("レ", "re"), it("ロ", "ro")),
                row(it("ワ", "wa"), null, null, null, it("ヲ", "wo")),
                row(it("ン", "n"), null, null, null, null)
        );

        return new AlphabetSection("gojuuon", "Gojuuon", 5, grid);
    }

    private AlphabetSection buildKatakanaDakuon() {
        List<List<AlphabetItem>> grid = List.of(
                row(it("ガ", "ga"), it("ギ", "gi"), it("グ", "gu"), it("ゲ", "ge"), it("ゴ", "go")),
                row(it("ザ", "za"), it("ジ", "ji"), it("ズ", "zu"), it("ゼ", "ze"), it("ゾ", "zo")),
                row(it("ダ", "da"), it("ヂ", "ji"), it("ヅ", "zu"), it("デ", "de"), it("ド", "do")),
                row(it("バ", "ba"), it("ビ", "bi"), it("ブ", "bu"), it("ベ", "be"), it("ボ", "bo")),
                row(it("パ", "pa"), it("ピ", "pi"), it("プ", "pu"), it("ペ", "pe"), it("ポ", "po"))
        );

        return new AlphabetSection("dakuon", "Dakuon & Handakuon", 5, grid);
    }

    private AlphabetSection buildKatakanaYouon() {
        List<List<AlphabetItem>> grid = List.of(
                row(it("キャ", "kya"), it("キュ", "kyu"), it("キョ", "kyo")),
                row(it("ギャ", "gya"), it("ギュ", "gyu"), it("ギョ", "gyo")),
                row(it("シャ", "sha"), it("シュ", "shu"), it("ショ", "sho")),
                row(it("ジャ", "ja"), it("ジュ", "ju"), it("ジョ", "jo")),
                row(it("チャ", "cha"), it("チュ", "chu"), it("チョ", "cho")),
                row(it("ヂャ", "ja"), it("ヂュ", "ju"), it("ヂョ", "jo")),
                row(it("ニャ", "nya"), it("ニュ", "nyu"), it("ニョ", "nyo")),
                row(it("ヒャ", "hya"), it("ヒュ", "hyu"), it("ヒョ", "hyo")),
                row(it("ビャ", "bya"), it("ビュ", "byu"), it("ビョ", "byo")),
                row(it("ピャ", "pya"), it("ピュ", "pyu"), it("ピョ", "pyo")),
                row(it("ミャ", "mya"), it("ミュ", "myu"), it("ミョ", "myo")),
                row(it("リャ", "rya"), it("リュ", "ryu"), it("リョ", "ryo"))
        );

        return new AlphabetSection("youon", "Youon", 3, grid);
    }

    // =========================================================================
    // HELPER METHODS
    // =========================================================================

    private AlphabetItem it(String character, String romaji) {
        return new AlphabetItem(character, romaji);
    }

    private List<AlphabetItem> row(AlphabetItem... items) {
        return Arrays.asList(items);
    }
}
