package com.prm.backend.dto.alphabet;

import java.util.List;

/**
 * Các Data Transfer Object (DTO) cho dữ liệu Bảng chữ cái tiếng Nhật (Hiragana / Katakana).
 */
public final class AlphabetDtos {

    private AlphabetDtos() {
    }

    /**
     * Một ô ký tự trong bảng chữ cái.
     * @param character Chữ cái tiếng Nhật (ví dụ: "あ" hoặc "ア")
     * @param romaji Cách đọc phiên âm Latin (ví dụ: "a")
     */
    public record AlphabetItem(
            String character,
            String romaji
    ) {
    }

    /**
     * Một phần phân loại của bảng chữ cái (Gojuuon, Dakuon & Handakuon, Youon).
     * @param type Mã loại ("gojuuon", "dakuon", "youon")
     * @param title Tiêu đề hiển thị ("Gojuuon", "Dakuon & Handakuon", "Youon")
     * @param columns Số cột hiển thị (5 cho Gojuuon / Dakuon, 3 cho Youon)
     * @param grid Ma trận các hàng và cột (chứa AlphabetItem hoặc null cho ô trống)
     */
    public record AlphabetSection(
            String type,
            String title,
            int columns,
            List<List<AlphabetItem>> grid
    ) {
    }

    /**
     * Kết quả trả về cho một bảng chữ cái (Hiragana hoặc Katakana).
     * @param script Loại chữ ("hiragana" hoặc "katakana")
     * @param title Tên hiển thị ("Bảng chữ cái Hira" hoặc "Bảng chữ cái Kata")
     * @param sections Danh sách 3 phần (Gojuuon, Dakuon & Handakuon, Youon)
     */
    public record AlphabetResponse(
            String script,
            String title,
            List<AlphabetSection> sections
    ) {
    }
}
