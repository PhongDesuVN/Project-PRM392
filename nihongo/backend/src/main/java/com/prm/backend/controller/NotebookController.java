package com.prm.backend.controller;

import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookSyncRequest;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordItem;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordsResponse;
import com.prm.backend.service.NotebookService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notebook")
public class NotebookController {

    private final NotebookService notebookService;

    public NotebookController(NotebookService notebookService) {
        this.notebookService = notebookService;
    }

    @PostMapping("/sync")
    public ResponseEntity<NotebookStatsResponse> syncProgress(@RequestBody NotebookSyncRequest request) {
        notebookService.syncProgress(request.words());
        return ResponseEntity.ok(notebookService.getStats());
    }

    @GetMapping("/stats")
    public ResponseEntity<NotebookStatsResponse> getStats() {
        return ResponseEntity.ok(notebookService.getStats());
    }

    @GetMapping("/words")
    public ResponseEntity<NotebookWordsResponse> getWords(
            @RequestParam(required = false) String status
    ) {
        if (status != null && !status.isBlank()) {
            return ResponseEntity.ok(new NotebookWordsResponse(notebookService.getWordsByStatus(status)));
        }
        return ResponseEntity.ok(new NotebookWordsResponse(notebookService.getAllReviewWords()));
    }
}
