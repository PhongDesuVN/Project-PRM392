package com.prm.backend.controller;

import com.prm.backend.dto.notebook.NotebookDtos.CreateNotebookRequest;
import com.prm.backend.dto.notebook.NotebookDtos.MessageResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookItemDto;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookListResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookSyncRequest;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.UpdateNotebookRequest;
import com.prm.backend.service.NotebookService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notebook")
public class NotebookController {

    private final NotebookService notebookService;

    public NotebookController(NotebookService notebookService) {
        this.notebookService = notebookService;
    }

    @GetMapping("/list")
    public ResponseEntity<NotebookListResponse> getNotebooks() {
        return ResponseEntity.ok(notebookService.getNotebooks(1));
    }

    @PostMapping
    public ResponseEntity<NotebookItemDto> createNotebook(@RequestBody CreateNotebookRequest request) {
        return ResponseEntity.ok(notebookService.createNotebook(1, request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<NotebookItemDto> updateNotebook(
            @PathVariable int id,
            @RequestBody UpdateNotebookRequest request) {
        return ResponseEntity.ok(notebookService.updateNotebook(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteNotebook(@PathVariable int id) {
        boolean deleted = notebookService.deleteNotebook(id);
        return ResponseEntity.ok(new MessageResponse(deleted, deleted ? "Xóa sổ tay thành công" : "Không tìm thấy sổ tay"));
    }

    @GetMapping("/{id}/words")
    public ResponseEntity<NotebookWordsResponse> getNotebookWords(@PathVariable int id) {
        return ResponseEntity.ok(new NotebookWordsResponse(notebookService.getWordsForNotebook(id)));
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
