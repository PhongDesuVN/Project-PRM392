package com.prm.backend.dto.mockexam;

import java.util.List;

public final class MockExamDtos {

    private MockExamDtos() {}

    /** Mot de thi trong danh sach; attempts/bestPercent la lich su lam bai cua user. */
    public record ExamSummary(
            Integer id,
            String title,
            String level,
            String type,
            Integer durationMinutes,
            Integer totalQuestions,
            Integer attempts,
            Integer bestPercent
    ) {}

    public record ExamListResponse(List<ExamSummary> tests) {}

    public record ExamOption(Integer id, String text) {}

    /** Cau hoi gui cho client: khong co dap an dung. */
    public record ExamQuestion(
            Integer id,
            String section,
            String text,
            String passage,
            List<ExamOption> options
    ) {}

    public record ExamDetail(
            Integer id,
            String title,
            String level,
            String type,
            Integer durationMinutes,
            List<ExamQuestion> questions
    ) {}

    public record AnswerItem(Integer questionId, Integer optionId) {}

    public record SubmitRequest(List<AnswerItem> answers) {}

    public record SectionResult(String section, int correct, int total) {}

    public record ReviewItem(
            Integer questionId,
            Integer selectedOptionId,
            Integer correctOptionId,
            boolean correct,
            String explanation
    ) {}

    public record SubmitResponse(
            Integer attemptId,
            int correct,
            int total,
            int percent,
            List<SectionResult> sections,
            List<ReviewItem> review
    ) {}
}
