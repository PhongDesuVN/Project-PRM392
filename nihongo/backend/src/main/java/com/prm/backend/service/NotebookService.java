package com.prm.backend.service;

import com.prm.backend.dto.notebook.NotebookDtos.AddWordRequest;
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

    public NotebookWordItem addWordToNotebook(int userId, int notebookId, AddWordRequest request) {
        return notebookRepository.addWordToNotebook(userId, notebookId, request);
    }

    public void syncProgress(int userId, List<NotebookProgressItem> items) {
        if (items == null || items.isEmpty())
            return;
        for (NotebookProgressItem item : items) {
            notebookRepository.upsertWordProgress(userId, item);
        }
    }

    public NotebookStatsResponse getStats(int userId) {
        return notebookRepository.getStats(userId);
    }

    public List<NotebookWordItem> getWordsByStatus(int userId, String status) {
        return notebookRepository.findWordsByStatus(userId, status);
    }

    public List<NotebookWordItem> getAllReviewWords(int userId) {
        return notebookRepository.findAllReviewWords(userId);
    }

    public List<NotebookWordItem> getAllWords(int userId) {
        return notebookRepository.findAllWords(userId);
    }

    public int getOrCreateUserId(String email, String fullName) {
        return notebookRepository.getOrCreateUserId(email, fullName);
    }
}
