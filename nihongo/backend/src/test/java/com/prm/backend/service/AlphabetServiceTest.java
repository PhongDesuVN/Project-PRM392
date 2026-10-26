package com.prm.backend.service;

import com.prm.backend.dto.alphabet.AlphabetDtos.AlphabetResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AlphabetServiceTest {

    private AlphabetService alphabetService;

    @BeforeEach
    void setUp() {
        alphabetService = new AlphabetService();
    }

    @Test
    void testGetHiraganaAlphabet() {
        AlphabetResponse res = alphabetService.getHiraganaAlphabet();
        assertNotNull(res);
        assertEquals("hiragana", res.script());
        assertEquals("Bảng chữ cái Hira", res.title());
        assertEquals(3, res.sections().size());

        // Gojuuon
        assertEquals("gojuuon", res.sections().get(0).type());
        assertEquals(5, res.sections().get(0).columns());
        assertEquals("あ", res.sections().get(0).grid().get(0).get(0).character());

        // Dakuon & Handakuon
        assertEquals("dakuon", res.sections().get(1).type());
        assertEquals(5, res.sections().get(1).columns());
        assertEquals("が", res.sections().get(1).grid().get(0).get(0).character());

        // Youon
        assertEquals("youon", res.sections().get(2).type());
        assertEquals(3, res.sections().get(2).columns());
        assertEquals("きゃ", res.sections().get(2).grid().get(0).get(0).character());
    }

    @Test
    void testGetKatakanaAlphabet() {
        AlphabetResponse res = alphabetService.getKatakanaAlphabet();
        assertNotNull(res);
        assertEquals("katakana", res.script());
        assertEquals("Bảng chữ cái Kata", res.title());
        assertEquals(3, res.sections().size());

        // Gojuuon
        assertEquals("gojuuon", res.sections().get(0).type());
        assertEquals(5, res.sections().get(0).columns());
        assertEquals("ア", res.sections().get(0).grid().get(0).get(0).character());

        // Dakuon & Handakuon
        assertEquals("dakuon", res.sections().get(1).type());
        assertEquals(5, res.sections().get(1).columns());
        assertEquals("ガ", res.sections().get(1).grid().get(0).get(0).character());

        // Youon
        assertEquals("youon", res.sections().get(2).type());
        assertEquals(3, res.sections().get(2).columns());
        assertEquals("キャ", res.sections().get(2).grid().get(0).get(0).character());
    }
}
