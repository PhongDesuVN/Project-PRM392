package com.prm.backend.dto.topic;

import java.util.List;

public final class TopicDtos {

    private TopicDtos() {}

    public record TopicInfo(
            String code,
            String title,
            String category,
            String itemCountText
    ) {}

    public record TopicWordItem(
            Integer id,
            String topicCode,
            String word,
            String reading,
            String romaji,
            String meaning,
            String exampleJp,
            String exampleVi,
            Integer displayOrder
    ) {}

    public record TopicWordsResponse(
            String topicCode,
            String title,
            int totalWords,
            List<TopicWordItem> words
    ) {}
}
