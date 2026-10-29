package com.prm.backend.repository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class SearchHistoryRepositoryIntegrationTest {

    @Autowired
    private SearchHistoryRepository repository;

    @Test
    void testDatabaseOperations() {
        // Test add
        repository.addKeyword("桜_test");
        repository.addKeyword("生活_test");

        List<String> keywords = repository.getRecentKeywords(20);
        assertTrue(keywords.contains("生活_test"));
        assertTrue(keywords.contains("桜_test"));

        // Test delete
        repository.deleteKeyword("桜_test");
        repository.deleteKeyword("生活_test");
        keywords = repository.getRecentKeywords(20);
        assertFalse(keywords.contains("桜_test"));
        assertFalse(keywords.contains("生活_test"));
    }
}

