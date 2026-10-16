CREATE TABLE IF NOT EXISTS words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    word VARCHAR(255) NOT NULL,
    reading VARCHAR(255) NOT NULL,
    romaji VARCHAR(255),
    jlpt_level VARCHAR(5),
    audio_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_words_word (word),
    INDEX idx_words_reading (reading),
    INDEX idx_words_jlpt_level (jlpt_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS word_meanings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    word_id INT NOT NULL,
    lang_code VARCHAR(10) DEFAULT 'vi',
    part_of_speech VARCHAR(100),
    meaning TEXT NOT NULL,
    INDEX idx_word_meanings_word_id (word_id),
    CONSTRAINT fk_word_meanings_word
        FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS examples (
    id INT PRIMARY KEY AUTO_INCREMENT,
    word_id INT NOT NULL,
    japanese_sentence TEXT NOT NULL,
    transliteration TEXT,
    meaning TEXT NOT NULL,
    lang_code VARCHAR(10) DEFAULT 'vi',
    INDEX idx_examples_word_id (word_id),
    CONSTRAINT fk_examples_word
        FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS kanjis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    character VARCHAR(10) NOT NULL UNIQUE,
    han_viet VARCHAR(100),
    radical VARCHAR(50),
    stroke_count INT,
    onyomi VARCHAR(255),
    kunyomi VARCHAR(255),
    jlpt_level VARCHAR(5),
    stroke_order_svg_url VARCHAR(500),
    meaning TEXT NOT NULL,
    INDEX idx_kanjis_jlpt_level (jlpt_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS grammars (
    id INT PRIMARY KEY AUTO_INCREMENT,
    structure VARCHAR(255) NOT NULL,
    meaning TEXT NOT NULL,
    usage_note TEXT,
    jlpt_level VARCHAR(5),
    INDEX idx_grammars_jlpt_level (jlpt_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS kanji_words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    kanji_id INT NOT NULL,
    word_id INT NOT NULL,
    UNIQUE KEY uq_kanji_words_pair (kanji_id, word_id),
    INDEX idx_kanji_words_word_id (word_id),
    CONSTRAINT fk_kanji_words_kanji
        FOREIGN KEY (kanji_id) REFERENCES kanjis(id) ON DELETE CASCADE,
    CONSTRAINT fk_kanji_words_word
        FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;