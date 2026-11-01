package com.prm.backend.service;

import com.prm.backend.dto.mockexam.MockExamDtos.*;
import com.prm.backend.exception.GlobalExceptionHandler.BusinessException;
import com.prm.backend.repository.MockExamRepository;
import com.prm.backend.repository.MockExamRepository.AnswerKey;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class MockExamService {

    private final MockExamRepository repository;

    public MockExamService(MockExamRepository repository) {
        this.repository = repository;
    }

    public ExamListResponse getTests(int userId, String level, String type) {
        return getTests(Integer.valueOf(userId), level, type);
    }

    public ExamListResponse getTests(Integer userId, String level, String type) {
        return new ExamListResponse(repository.findTests(userId, level, type));
    }

    public ExamDetail getTest(int testId) {
        ExamSummary test = repository.findTest(testId)
                .orElseThrow(() -> new BusinessException("Không tìm thấy đề thi"));
        return new ExamDetail(test.id(), test.title(), test.level(), test.type(),
                test.durationMinutes(), repository.findQuestions(testId));
    }

    /** Cham diem tren server: client chi gui lua chon, khong bao gio nhan dap an truoc khi nop. */
    @Transactional
    public SubmitResponse submit(int userId, int testId, SubmitRequest request) {
        repository.findTest(testId).orElseThrow(() -> new BusinessException("Không tìm thấy đề thi"));
        Map<Integer, AnswerKey> keys = repository.findAnswerKeys(testId);
        if (keys.isEmpty()) {
            throw new BusinessException("Đề thi chưa có câu hỏi");
        }

        Map<Integer, Integer> selected = new LinkedHashMap<>();
        if (request != null && request.answers() != null) {
            for (AnswerItem a : request.answers()) {
                if (a == null || a.questionId() == null || a.optionId() == null) continue;
                AnswerKey key = keys.get(a.questionId());
                if (key != null && key.optionIds.contains(a.optionId())) {
                    selected.put(a.questionId(), a.optionId());
                }
            }
        }

        Map<String, int[]> bySection = new LinkedHashMap<>();
        List<ReviewItem> review = new ArrayList<>();
        int correct = 0;
        for (AnswerKey key : keys.values()) {
            Integer chosen = selected.get(key.questionId);
            boolean ok = chosen != null && chosen.equals(key.correctOptionId);
            if (ok) correct++;
            int[] counts = bySection.computeIfAbsent(key.section, s -> new int[2]);
            counts[1]++;
            if (ok) counts[0]++;
            review.add(new ReviewItem(key.questionId, chosen, key.correctOptionId, ok, key.explanation));
        }

        int total = keys.size();
        int attemptId = repository.saveAttempt(userId, testId, correct, selected);
        List<SectionResult> sections = bySection.entrySet().stream()
                .map(e -> new SectionResult(e.getKey(), e.getValue()[0], e.getValue()[1]))
                .toList();
        return new SubmitResponse(attemptId, correct, total, Math.round(correct * 100f / total), sections, review);
    }
}
