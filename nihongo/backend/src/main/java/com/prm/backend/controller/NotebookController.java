package com.prm.backend.controller;

import com.prm.backend.dto.notebook.NotebookDtos.AddWordRequest;
import com.prm.backend.dto.notebook.NotebookDtos.CreateNotebookRequest;
import com.prm.backend.dto.notebook.NotebookDtos.MessageResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookItemDto;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookListResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookStatsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookSyncRequest;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordItem;
import com.prm.backend.dto.notebook.NotebookDtos.NotebookWordsResponse;
import com.prm.backend.dto.notebook.NotebookDtos.UpdateNotebookRequest;
import com.prm.backend.security.UserResolver;
import com.prm.backend.service.NotebookService;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notebook")
public class NotebookController {

    private final NotebookService notebookService;
    private final UserResolver userResolver;

    public NotebookController(NotebookService notebookService, UserResolver userResolver) {
        this.notebookService = notebookService;
        this.userResolver = userResolver;
    }

    @GetMapping("/list")
    public ResponseEntity<NotebookListResponse> getNotebooks(HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new NotebookListResponse(List.of(), 0));
        }
        return ResponseEntity.ok(notebookService.getNotebooks(userId));
    }

    @PostMapping
    public ResponseEntity<NotebookItemDto> createNotebook(@RequestBody CreateNotebookRequest requestBody,
            HttpServletRequest request) {
        int userId = userResolver.resolveUserId(request);
        return ResponseEntity.ok(notebookService.createNotebook(userId, requestBody));
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
        return ResponseEntity
                .ok(new MessageResponse(deleted, deleted ? "Xóa sổ tay thành công" : "Không tìm thấy sổ tay"));
    }

    @GetMapping("/{id}/words")
    public ResponseEntity<NotebookWordsResponse> getNotebookWords(@PathVariable int id) {
        return ResponseEntity.ok(new NotebookWordsResponse(notebookService.getWordsForNotebook(id)));
    }

    @PostMapping("/{id}/words")
    public ResponseEntity<NotebookWordItem> addWordToNotebook(
            @PathVariable int id,
            @RequestBody AddWordRequest requestBody,
            HttpServletRequest request) {
        int userId = userResolver.resolveUserId(request);
        return ResponseEntity.ok(notebookService.addWordToNotebook(userId, id, requestBody));
    }

    @PostMapping("/sync")
    public ResponseEntity<NotebookStatsResponse> syncProgress(@RequestBody NotebookSyncRequest requestBody,
            HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new NotebookStatsResponse(0, 0, 0, 0));
        }
        notebookService.syncProgress(userId, requestBody.words());
        return ResponseEntity.ok(notebookService.getStats(userId));
    }

    @GetMapping("/stats")
    public ResponseEntity<NotebookStatsResponse> getStats(HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new NotebookStatsResponse(0, 0, 0, 0));
        }
        return ResponseEntity.ok(notebookService.getStats(userId));
    }

    @GetMapping("/words")
    public ResponseEntity<NotebookWordsResponse> getWords(
            @RequestParam(required = false) String status,
            HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        if (userId == null) {
            return ResponseEntity.ok(new NotebookWordsResponse(List.of()));
        }
        if (status != null && !status.isBlank()) {
            if ("review".equalsIgnoreCase(status.trim())) {
                return ResponseEntity.ok(new NotebookWordsResponse(notebookService.getAllReviewWords(userId)));
            }
            return ResponseEntity.ok(new NotebookWordsResponse(notebookService.getWordsByStatus(userId, status)));
        }
        return ResponseEntity.ok(new NotebookWordsResponse(notebookService.getAllWords(userId)));
    }
}
