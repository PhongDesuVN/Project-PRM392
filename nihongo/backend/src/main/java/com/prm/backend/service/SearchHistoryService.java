package com.prm.backend.service;

import com.prm.backend.dto.search.SearchHistoryDtos.SearchHistoryResponse;
import com.prm.backend.repository.SearchHistoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SearchHistoryService {

    private final SearchHistoryRepository repository;

    public SearchHistoryService(SearchHistoryRepository repository) {
        this.repository = repository;
    }

    public SearchHistoryResponse addKeyword(String query) {
        repository.addKeyword(query);
        return getRecentKeywords();
    }

    public SearchHistoryResponse getRecentKeywords() {
        List<String> keywords = repository.getRecentKeywords(20);
        return new SearchHistoryResponse(keywords);
    }

    public SearchHistoryResponse deleteKeyword(String query) {
        repository.deleteKeyword(query);
        return getRecentKeywords();
    }

    public SearchHistoryResponse clearAll() {
        repository.clearAll();
        return getRecentKeywords();
    }
}

