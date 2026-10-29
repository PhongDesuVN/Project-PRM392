package com.prm.backend.repository;

import com.prm.backend.dto.notebook.NotebookDtos.NotebookItemDto;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class NotebookRepositoryIntegrationTest {

    @Autowired
    private NotebookRepository repository;

    @Test
    void testNotebookDatabaseIntegration() {
        // 1. Lấy danh sách sổ tay mặc định
        List<NotebookItemDto> notebooks = repository.findAllNotebooks(1);
        assertNotNull(notebooks);
        assertTrue(notebooks.stream().anyMatch(n -> n.title().equals("Tesr") || n.title().equals("Huy")));

        // 2. Tạo sổ tay mới vào database
        NotebookItemDto created = repository.createNotebook(1, "Test Sổ Tay DB", "Mô tả test");
        assertNotNull(created);
        assertEquals("Test Sổ Tay DB", created.title());

        // 3. Kiểm tra danh sách có sổ tay vừa tạo
        List<NotebookItemDto> updatedList = repository.findAllNotebooks(1);
        assertTrue(updatedList.stream().anyMatch(n -> n.id().equals(created.id())));

        // 4. Sửa sổ tay
        NotebookItemDto updated = repository.updateNotebook(created.id(), "Test Sổ Tay Updated", "Mô tả mới");
        assertEquals("Test Sổ Tay Updated", updated.title());

        // 5. Xóa sổ tay
        boolean deleted = repository.deleteNotebook(created.id());
        assertTrue(deleted);

        // 6. Kiểm tra stats
        NotebookStatsResponse stats = repository.getStats();
        assertNotNull(stats);
        assertTrue(stats.total() >= 0);
    }
}

