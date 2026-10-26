package com.prm.backend.service;

import com.prm.backend.dto.notebook.NotebookDtos.NotebookProgressItem;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordItem;
import com.prm.backend.repository.NotebookRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotebookService {

    private final NotebookRepository notebookRepository;

    public NotebookService(NotebookRepository notebookRepository) {
        this.notebookRepository = notebookRepository;
    }

    public void syncProgress(List<NotebookProgressItem> items) {
        if (items == null || items.isEmpty()) return;
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
