package com.prm.backend.controller;

import com.prm.backend.dto.search.SearchHistoryDtos.AddSearchHistoryRequest;
import com.prm.backend.dto.search.SearchHistoryDtos.SearchHistoryResponse;
import com.prm.backend.security.UserResolver;
import com.prm.backend.service.SearchHistoryService;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/search-history")
public class SearchHistoryController {

    private final SearchHistoryService searchHistoryService;
    private final UserResolver userResolver;

    public SearchHistoryController(SearchHistoryService searchHistoryService, UserResolver userResolver) {
        this.searchHistoryService = searchHistoryService;
        this.userResolver = userResolver;
    }

    @GetMapping
    public ResponseEntity<SearchHistoryResponse> getRecentKeywords(HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new SearchHistoryResponse(List.of()));
        }
        return ResponseEntity.ok(searchHistoryService.getRecentKeywords(userId));
    }

    @PostMapping
    public ResponseEntity<SearchHistoryResponse> addKeyword(
            @RequestBody AddSearchHistoryRequest req,
            HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new SearchHistoryResponse(List.of()));
        }
        return ResponseEntity.ok(searchHistoryService.addKeyword(userId, req.query()));
    }

    @DeleteMapping
    public ResponseEntity<SearchHistoryResponse> deleteKeyword(
            @RequestParam String query,
            HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new SearchHistoryResponse(List.of()));
        }
        return ResponseEntity.ok(searchHistoryService.deleteKeyword(userId, query));
    }

    @DeleteMapping("/clear")
    public ResponseEntity<SearchHistoryResponse> clearAll(HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new SearchHistoryResponse(List.of()));
        }
        return ResponseEntity.ok(searchHistoryService.clearAll(userId));
    }
}
