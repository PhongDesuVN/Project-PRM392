package com.prm.backend.service;

import com.prm.backend.dto.notebook.NotebookDtos.CreateNotebookRequest;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookItemDto;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookListResponse;
import com.prm.backend.repository.NotebookRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class NotebookServiceTest {

    private NotebookRepository repository;
    private NotebookService service;

    @BeforeEach
    void setUp() {
        repository = Mockito.mock(NotebookRepository.class);
        service = new NotebookService(repository);
    }

    @Test
    void testGetNotebooks() {
        List<NotebookItemDto> list = Arrays.asList(
                new NotebookItemDto(1, 1, "Tesr", "Sổ tay Tesr", 0, "29/10/2026"),
                new NotebookItemDto(2, 1, "Huy", "Sổ tay Huy", 12, "29/10/2026")
        );
        when(repository.findAllNotebooks(1)).thenReturn(list);

        NotebookListResponse response = service.getNotebooks(1);
        assertNotNull(response);
        assertEquals(2, response.notebooks().size());
        assertEquals(12, response.totalWords());
        assertEquals("Tesr", response.notebooks().get(0).title());
    }

    @Test
    void testCreateNotebook() {
        NotebookItemDto created = new NotebookItemDto(3, 1, "Từ vựng N5", "Ghi chú", 0, "29/10/2026");
        when(repository.createNotebook(1, "Từ vựng N5", "Ghi chú")).thenReturn(created);

        NotebookItemDto result = service.createNotebook(1, new CreateNotebookRequest("Từ vựng N5", "Ghi chú"));
        assertNotNull(result);
        assertEquals("Từ vựng N5", result.title());
        assertEquals(3, result.id());
    }

    @Test
    void testDeleteNotebook() {
        when(repository.deleteNotebook(2)).thenReturn(true);

        boolean deleted = service.deleteNotebook(2);
        assertTrue(deleted);
        verify(repository, times(1)).deleteNotebook(2);
    }
}

