package com.prm.backend.service;

import com.prm.backend.dto.notebook.NotebookDtos.CreateNotebookRequest;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookItemDto;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookListResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookProgressItem;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordItem;
import com.prm.backend.dto.notebook.NotebookDtos.UpdateNotebookRequest;
import com.prm.backend.repository.NotebookRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotebookService {

    private final NotebookRepository notebookRepository;

    public NotebookService(NotebookRepository notebookRepository) {
        this.notebookRepository = notebookRepository;
    }

    public NotebookListResponse getNotebooks(int userId) {
        List<NotebookItemDto> list = notebookRepository.findAllNotebooks(userId);
        int totalWords = list.stream().mapToInt(NotebookItemDto::wordCount).sum();
        return new NotebookListResponse(list, totalWords);
    }

    public NotebookItemDto createNotebook(int userId, CreateNotebookRequest request) {
        String title = request != null && request.title() != null ? request.title().trim() : "Sổ tay mới";
        String description = request != null ? request.description() : "";
        return notebookRepository.createNotebook(userId, title, description);
    }

    public NotebookItemDto updateNotebook(int id, UpdateNotebookRequest request) {
        String title = request != null && request.title() != null ? request.title().trim() : "Sổ tay";
        String description = request != null ? request.description() : "";
        return notebookRepository.updateNotebook(id, title, description);
    }

    public boolean deleteNotebook(int id) {
        return notebookRepository.deleteNotebook(id);
    }

    public List<NotebookWordItem> getWordsForNotebook(int notebookId) {
        return notebookRepository.findWordsByNotebookId(notebookId);
    }

    public void syncProgress(List<NotebookProgressItem> items) {
        if (items == null || items.isEmpty())
            return;
        for (NotebookProgressItem item : items) {
            notebookRepository.upsertWordProgress(item);
        }
    }

    public NotebookStatsResponse getStats() {
        return notebookRepository.getStats();
    }

    public List<NotebookWordItem> getWordsByStatus(String status) {
        return notebookRepository.findWordsByStatus(status);
    }

    public List<NotebookWordItem> getAllReviewWords() {
        return notebookRepository.findAllReviewWords();
    }
}
