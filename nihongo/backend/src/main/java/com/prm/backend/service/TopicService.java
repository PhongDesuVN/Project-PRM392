package com.prm.backend.service;

import com.prm.backend.dto.topic.TopicDtos.TopicInfo;
import com.prm.backend.dto.topic.TopicDtos.TopicWordItem;
import com.prm.backend.dto.topic.TopicDtos.TopicWordsResponse;
import com.prm.backend.repository.TopicRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TopicService {

    private final TopicRepository topicRepository;

    public TopicService(TopicRepository topicRepository) {
        this.topicRepository = topicRepository;
    }

    public List<TopicInfo> getAllTopics() {
        return topicRepository.findAllTopics();
    }

    public TopicWordsResponse getTopicWords(String topicCode) {
        List<TopicWordItem> words = topicRepository.findWordsByTopicCode(topicCode);
        String title = topicRepository.findAllTopics().stream()
                .filter(t -> t.code().equalsIgnoreCase(topicCode))
                .map(TopicInfo::title)
                .findFirst()
                .orElse("Từ vựng " + topicCode);

        return new TopicWordsResponse(topicCode, title, words.size(), words);
    }
}
