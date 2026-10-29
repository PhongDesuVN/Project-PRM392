

CREATE DATABASE IF NOT EXISTS PRM
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE PRM;

-- =============================================================================
-- NHÓM 1: QUẢN LÝ NGƯỜI DÙNG & TÀI KHOẢN (AUTH)
-- =============================================================================

-- 1. Bảng Người dùng
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    full_name VARCHAR(100),
    avatar_url VARCHAR(500),
    role ENUM('user', 'admin', 'moderator') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Bảng Token quên mật khẩu (dùng một lần, bảo mật bằng SHA-256)
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reset_token_hash (token_hash),
    INDEX idx_reset_user (user_id, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Bảng Cài đặt người dùng
CREATE TABLE IF NOT EXISTS user_settings (
    user_id INT PRIMARY KEY,
    interface_lang VARCHAR(10) DEFAULT 'vi',
    theme ENUM('light', 'dark', 'system') DEFAULT 'system',
    daily_reminder_time TIME DEFAULT '20:00:00',
    enable_notifications BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- NHÓM 2: DỮ LIỆU TỪ ĐIỂN, HÁN TỰ & NGỮ PHÁP (DICTIONARY CORE)
-- =============================================================================

-- 4. Bảng Từ vựng cơ sở
CREATE TABLE IF NOT EXISTS words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    word VARCHAR(255) NOT NULL,
    reading VARCHAR(255) NOT NULL,
    romaji VARCHAR(255),
    jlpt_level VARCHAR(5),
    audio_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_words_search (word, reading),
    INDEX idx_words_jlpt (jlpt_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Bảng Nghĩa từ vựng (đa ngôn ngữ)
CREATE TABLE IF NOT EXISTS word_meanings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    word_id INT NOT NULL,
    lang_code VARCHAR(10) DEFAULT 'vi',
    part_of_speech VARCHAR(100),
    meaning TEXT NOT NULL,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
    INDEX idx_meaning_lang (word_id, lang_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Bảng Câu ví dụ song ngữ Nhật - Việt
CREATE TABLE IF NOT EXISTS examples (
    id INT PRIMARY KEY AUTO_INCREMENT,
    word_meaning_id INT NOT NULL,
    japanese_sentence TEXT NOT NULL,
    transliteration TEXT,
    meaning TEXT NOT NULL,
    lang_code VARCHAR(10) DEFAULT 'vi',
    FOREIGN KEY (word_meaning_id) REFERENCES word_meanings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Bảng Hán tự (Kanji)
CREATE TABLE IF NOT EXISTS kanjis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    kanji_char VARCHAR(10) UNIQUE NOT NULL,
    han_viet VARCHAR(100),
    radical VARCHAR(50),
    stroke_count INT,
    onyomi VARCHAR(255),
    kunyomi VARCHAR(255),
    jlpt_level VARCHAR(5),
    stroke_order_svg_url VARCHAR(500),
    meaning TEXT NOT NULL,
    INDEX idx_kanji_char (kanji_char),
    INDEX idx_kanji_han_viet (han_viet)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Bảng Ngữ pháp (Grammar)
CREATE TABLE IF NOT EXISTS grammars (
    id INT PRIMARY KEY AUTO_INCREMENT,
    structure VARCHAR(255) NOT NULL,
    meaning TEXT NOT NULL,
    usage_note TEXT,
    jlpt_level VARCHAR(5),
    INDEX idx_grammar_structure (structure)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Bảng liên kết Kanji & Từ vựng (N - N)
CREATE TABLE IF NOT EXISTS kanji_words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    kanji_id INT NOT NULL,
    word_id INT NOT NULL,
    FOREIGN KEY (kanji_id) REFERENCES kanjis(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
    UNIQUE KEY uq_kanji_word (kanji_id, word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- NHÓM 3: HỌC THEO CHỦ ĐỀ & LUYỆN TẬP FLASHCARD
-- (Phục vụ trực tiếp màn hình JLPT / Chuyên ngành / Khác và Flashcard)
-- =============================================================================

-- 10. Bảng Danh mục chủ đề học tập
CREATE TABLE IF NOT EXISTS study_topics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    topic_code VARCHAR(100) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'JLPT', 'CHUYEN_NGANH', 'KHAC'
    item_count_text VARCHAR(50) DEFAULT '0 từ',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_topic_code (topic_code),
    INDEX idx_topic_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Bảng Từ vựng phục vụ luyện tập Flashcard theo chủ đề
CREATE TABLE IF NOT EXISTS topic_words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    topic_code VARCHAR(100) NOT NULL,
    word VARCHAR(100) NOT NULL,
    reading VARCHAR(150) NOT NULL,
    romaji VARCHAR(150),
    meaning VARCHAR(255) NOT NULL,
    example_jp VARCHAR(255),
    example_vi VARCHAR(255),
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (topic_code) REFERENCES study_topics(topic_code) ON DELETE CASCADE,
    INDEX idx_topic_words_code (topic_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- NHÓM 4: SỔ TAY CÁ NHÂN & TIẾN ĐỘ ÔN TẬP NGẮT QUÃNG (SRS)
-- =============================================================================

-- 12. Bảng Sổ tay từ vựng
CREATE TABLE IF NOT EXISTS notebooks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. Bảng Chi tiết mục trong sổ tay (lưu từ vựng / kanji / ngữ pháp)
CREATE TABLE IF NOT EXISTS notebook_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    notebook_id INT NOT NULL,
    word_id INT NULL,
    kanji_id INT NULL,
    grammar_id INT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (notebook_id) REFERENCES notebooks(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
    FOREIGN KEY (kanji_id) REFERENCES kanjis(id) ON DELETE CASCADE,
    FOREIGN KEY (grammar_id) REFERENCES grammars(id) ON DELETE CASCADE,
    CONSTRAINT chk_notebook_item_type CHECK (
        (word_id IS NOT NULL AND kanji_id IS NULL AND grammar_id IS NULL) OR
        (word_id IS NULL AND kanji_id IS NOT NULL AND grammar_id IS NULL) OR
        (word_id IS NULL AND kanji_id IS NULL AND grammar_id IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Bảng Tiến độ ôn tập lặp lại ngắt quãng (Spaced Repetition System - SRS)
CREATE TABLE IF NOT EXISTS user_srs_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    word_id INT NULL,
    kanji_id INT NULL,
    grammar_id INT NULL,
    interval_days INT DEFAULT 1,
    ease_factor FLOAT DEFAULT 2.5,
    repetitions INT DEFAULT 0,
    next_review_at DATETIME NOT NULL,
    last_reviewed_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
    FOREIGN KEY (kanji_id) REFERENCES kanjis(id) ON DELETE CASCADE,
    FOREIGN KEY (grammar_id) REFERENCES grammars(id) ON DELETE CASCADE,
    CONSTRAINT chk_srs_item_type CHECK (
        (word_id IS NOT NULL AND kanji_id IS NULL AND grammar_id IS NULL) OR
        (word_id IS NULL AND kanji_id IS NOT NULL AND grammar_id IS NULL) OR
        (word_id IS NULL AND kanji_id IS NULL AND grammar_id IS NOT NULL)
    ),
    INDEX idx_user_srs_next_review (user_id, next_review_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. Bảng Sổ tay tiến độ từ vựng theo 4 trạng thái (Chưa thuộc, Thuộc lơ mơ, Thuộc kha khá, Thuộc làu làu)
CREATE TABLE IF NOT EXISTS user_notebook_words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT DEFAULT 1,
    word VARCHAR(100) NOT NULL,
    reading VARCHAR(150) NOT NULL,
    romaji VARCHAR(150),
    meaning VARCHAR(255) NOT NULL,
    status ENUM('chua_thuoc', 'thuoc_lo_mo', 'thuoc_kha_kha', 'thuoc_lau_lau') NOT NULL,
    review_count INT DEFAULT 1,
    last_studied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    notebook_id INT NULL,
    FOREIGN KEY (notebook_id) REFERENCES notebooks(id) ON DELETE SET NULL,
    UNIQUE KEY uq_user_word (user_id, word),
    INDEX idx_notebook_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. Bảng Lịch sử tra cứu
CREATE TABLE IF NOT EXISTS search_histories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    query_text VARCHAR(255) NOT NULL,
    word_id INT NULL,
    kanji_id INT NULL,
    grammar_id INT NULL,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE SET NULL,
    FOREIGN KEY (kanji_id) REFERENCES kanjis(id) ON DELETE SET NULL,
    FOREIGN KEY (grammar_id) REFERENCES grammars(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- NHÓM 5: THI THỬ JLPT (MOCK EXAM)
-- =============================================================================

-- 16. Bảng Đề thi JLPT
CREATE TABLE IF NOT EXISTS jlpt_tests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    level VARCHAR(5) NOT NULL,
    duration_minutes INT DEFAULT 60,
    total_questions INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 17. Bảng Câu hỏi đề thi
CREATE TABLE IF NOT EXISTS jlpt_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_id INT NOT NULL,
    section ENUM('vocabulary', 'grammar', 'reading', 'listening') NOT NULL,
    question_text TEXT NOT NULL,
    audio_url VARCHAR(500),
    passage_text TEXT,
    FOREIGN KEY (test_id) REFERENCES jlpt_tests(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 18. Bảng Đáp án lựa chọn
CREATE TABLE IF NOT EXISTS jlpt_options (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES jlpt_questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 19. Bảng Lượt làm bài thi của người dùng
CREATE TABLE IF NOT EXISTS jlpt_user_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    test_id INT NOT NULL,
    score INT DEFAULT 0,
    completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (test_id) REFERENCES jlpt_tests(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 20. Bảng Chi tiết đáp án người dùng đã chọn
CREATE TABLE IF NOT EXISTS jlpt_user_answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option_id INT NOT NULL,
    FOREIGN KEY (attempt_id) REFERENCES jlpt_user_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES jlpt_questions(id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option_id) REFERENCES jlpt_options(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
