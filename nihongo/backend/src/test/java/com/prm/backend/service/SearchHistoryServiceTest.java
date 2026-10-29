package com.prm.backend.service;

import com.prm.backend.dto.search.SearchHistoryDtos.SearchHistoryResponse;
import com.prm.backend.repository.SearchHistoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class SearchHistoryServiceTest {

    private SearchHistoryRepository repository;
    private SearchHistoryService service;

    @BeforeEach
    void setUp() {
        repository = Mockito.mock(SearchHistoryRepository.class);
        service = new SearchHistoryService(repository);
    }

    @Test
    void testGetRecentKeywords() {
        when(repository.getRecentKeywords(20)).thenReturn(Arrays.asList("桜", "生活", "日"));

        SearchHistoryResponse response = service.getRecentKeywords();
        assertNotNull(response);
        assertEquals(3, response.keywords().size());
        assertEquals("桜", response.keywords().get(0));
        verify(repository, times(1)).getRecentKeywords(20);
    }

    @Test
    void testAddKeyword() {
        when(repository.getRecentKeywords(20)).thenReturn(Arrays.asList("先生", "桜"));

        SearchHistoryResponse response = service.addKeyword("先生");
        assertNotNull(response);
        assertEquals(2, response.keywords().size());
        verify(repository, times(1)).addKeyword("先生");
        verify(repository, times(1)).getRecentKeywords(20);
    }

    @Test
    void testDeleteKeyword() {
        when(repository.getRecentKeywords(20)).thenReturn(List.of("桜"));

        SearchHistoryResponse response = service.deleteKeyword("先生");
        assertNotNull(response);
        assertEquals(1, response.keywords().size());
        verify(repository, times(1)).deleteKeyword("先生");
    }

    @Test
    void testClearAll() {
        when(repository.getRecentKeywords(20)).thenReturn(List.of());

        SearchHistoryResponse response = service.clearAll();
        assertNotNull(response);
        assertTrue(response.keywords().isEmpty());
        verify(repository, times(1)).clearAll();
    }
}

