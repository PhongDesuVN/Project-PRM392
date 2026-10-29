package com.prm.backend.controller;

import com.prm.backend.dto.search.SearchHistoryDtos.AddSearchHistoryRequest;
import com.prm.backend.dto.search.SearchHistoryDtos.SearchHistoryResponse;
import com.prm.backend.service.SearchHistoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/search-history")
public class SearchHistoryController {

    private final SearchHistoryService searchHistoryService;

    public SearchHistoryController(SearchHistoryService searchHistoryService) {
        this.searchHistoryService = searchHistoryService;
    }

    @GetMapping
    public ResponseEntity<SearchHistoryResponse> getRecentKeywords() {
        return ResponseEntity.ok(searchHistoryService.getRecentKeywords());
    }

    @PostMapping
    public ResponseEntity<SearchHistoryResponse> addKeyword(@RequestBody AddSearchHistoryRequest request) {
        return ResponseEntity.ok(searchHistoryService.addKeyword(request.query()));
    }

    @DeleteMapping
    public ResponseEntity<SearchHistoryResponse> deleteKeyword(@RequestParam String query) {
        return ResponseEntity.ok(searchHistoryService.deleteKeyword(query));
    }

    @DeleteMapping("/clear")
    public ResponseEntity<SearchHistoryResponse> clearAll() {
        return ResponseEntity.ok(searchHistoryService.clearAll());
    }
}

