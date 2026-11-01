package com.prm.backend.controller;

import com.prm.backend.dto.mockexam.MockExamDtos.ExamDetail;
import com.prm.backend.dto.mockexam.MockExamDtos.ExamListResponse;
import com.prm.backend.dto.mockexam.MockExamDtos.SubmitRequest;
import com.prm.backend.dto.mockexam.MockExamDtos.SubmitResponse;
import com.prm.backend.security.UserResolver;
import com.prm.backend.service.MockExamService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/mock-exam")
public class MockExamController {

    private final MockExamService mockExamService;
    private final UserResolver userResolver;

    public MockExamController(MockExamService mockExamService, UserResolver userResolver) {
        this.mockExamService = mockExamService;
        this.userResolver = userResolver;
    }

    /** level: N5/N4/N3; type: vocabulary | grammar | jlpt (deu la tuy chon). */
    @GetMapping("/tests")
    public ResponseEntity<ExamListResponse> getTests(
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String type,
            HttpServletRequest request) {
        Integer userId = userResolver.resolveOptionalUserId(request);
        return ResponseEntity.ok(mockExamService.getTests(userId, level, type));
    }

    @GetMapping("/tests/{id}")
    public ResponseEntity<ExamDetail> getTest(@PathVariable int id) {
        return ResponseEntity.ok(mockExamService.getTest(id));
    }

    @PostMapping("/tests/{id}/submit")
    public ResponseEntity<SubmitResponse> submit(
            @PathVariable int id,
            @RequestBody SubmitRequest req,
            HttpServletRequest request) {
        int userId = userResolver.resolveUserId(request);
        return ResponseEntity.ok(mockExamService.submit(userId, id, req));
    }
}
