package com.prm.backend.controller;

import com.prm.backend.dto.dictionary.DictionaryDtos.SearchResponse;
import com.prm.backend.service.DictionaryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dictionary")
public class DictionaryController {

    private final DictionaryService dictionaryService;

    public DictionaryController(DictionaryService dictionaryService) {
        this.dictionaryService = dictionaryService;
    }

    @GetMapping("/search")
    public ResponseEntity<SearchResponse> search(
            @RequestParam String q,
            @RequestParam(defaultValue = "vi") String lang,
            @RequestParam(defaultValue = "20") int limit
    ) {
        return ResponseEntity.ok(dictionaryService.search(q, lang, limit));
    }
}