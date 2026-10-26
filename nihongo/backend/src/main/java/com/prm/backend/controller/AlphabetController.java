package com.prm.backend.controller;

import com.prm.backend.dto.alphabet.AlphabetDtos.AlphabetResponse;
import com.prm.backend.service.AlphabetService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller cung cấp REST API cho bảng chữ cái tiếng Nhật (Hiragana & Katakana).
 */
@RestController
@RequestMapping("/alphabet")
public class AlphabetController {

    private final AlphabetService alphabetService;

    public AlphabetController(AlphabetService alphabetService) {
        this.alphabetService = alphabetService;
    }

    /**
     * Lấy dữ liệu bảng chữ cái theo loại chữ (hiragana / katakana).
     * Ví dụ: GET /alphabet/hiragana hoặc GET /alphabet/katakana
     */
    @GetMapping("/{script}")
    public ResponseEntity<AlphabetResponse> getAlphabetByPath(@PathVariable String script) {
        return ResponseEntity.ok(alphabetService.getAlphabet(script));
    }

    /**
     * Lấy dữ liệu bảng chữ cái với query param (mặc định là hiragana).
     * Ví dụ: GET /alphabet?script=hiragana
     */
    @GetMapping
    public ResponseEntity<AlphabetResponse> getAlphabetByQuery(@RequestParam(defaultValue = "hiragana") String script) {
        return ResponseEntity.ok(alphabetService.getAlphabet(script));
    }
}
