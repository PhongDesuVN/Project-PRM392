package com.prm.backend.dto.search;

import java.util.List;

public final class SearchHistoryDtos {
    private SearchHistoryDtos() {}

    public record AddSearchHistoryRequest(String query) {}

    public record SearchHistoryResponse(List<String> keywords) {}
}

