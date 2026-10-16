CREATE TABLE IF NOT EXISTS search_histories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    query_text VARCHAR(255) NOT NULL,
    item_type ENUM('word', 'kanji', 'grammar'),
    item_id INT,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_search_histories_user_date (user_id, searched_at),
    INDEX idx_search_histories_target (item_type, item_id),
    CONSTRAINT fk_search_histories_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_settings (
    user_id INT PRIMARY KEY,
    interface_lang VARCHAR(10) DEFAULT 'vi',
    theme ENUM('light', 'dark', 'system') DEFAULT 'system',
    daily_reminder_time TIME DEFAULT '20:00:00',
    enable_notifications BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_user_settings_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;