package com.prm.backend.controller;

import com.prm.backend.dto.mockexam.MockExamDtos.ExamDetail;
import com.prm.backend.dto.mockexam.MockExamDtos.ExamListResponse;
import com.prm.backend.dto.mockexam.MockExamDtos.SubmitRequest;
import com.prm.backend.dto.mockexam.MockExamDtos.SubmitResponse;
import com.prm.backend.service.MockExamService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/mock-exam")
public class MockExamController {

    private final MockExamService mockExamService;

    public MockExamController(MockExamService mockExamService) {
        this.mockExamService = mockExamService;
    }

    /** level: N5/N4/N3; type: vocabulary | grammar | jlpt (deu la tuy chon). */
    @GetMapping("/tests")
    public ResponseEntity<ExamListResponse> getTests(
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String type) {
        return ResponseEntity.ok(mockExamService.getTests(level, type));
    }

    @GetMapping("/tests/{id}")
    public ResponseEntity<ExamDetail> getTest(@PathVariable int id) {
        return ResponseEntity.ok(mockExamService.getTest(id));
    }

    @PostMapping("/tests/{id}/submit")
    public ResponseEntity<SubmitResponse> submit(@PathVariable int id, @RequestBody SubmitRequest request) {
        return ResponseEntity.ok(mockExamService.submit(id, request));
    }
}
