CREATE TABLE IF NOT EXISTS jlpt_tests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    level VARCHAR(5) NOT NULL,
    duration_minutes INT DEFAULT 60,
    total_questions INT DEFAULT 0,
    INDEX idx_jlpt_tests_level (level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS jlpt_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_id INT NOT NULL,
    section ENUM('vocabulary', 'grammar', 'reading', 'listening') NOT NULL,
    question_text TEXT NOT NULL,
    audio_url VARCHAR(500),
    passage_text TEXT,
    INDEX idx_jlpt_questions_test_section (test_id, section),
    CONSTRAINT fk_jlpt_questions_test
        FOREIGN KEY (test_id) REFERENCES jlpt_tests(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS jlpt_options (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    INDEX idx_jlpt_options_question_id (question_id),
    CONSTRAINT fk_jlpt_options_question
        FOREIGN KEY (question_id) REFERENCES jlpt_questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;