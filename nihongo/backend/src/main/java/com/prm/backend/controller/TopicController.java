package com.prm.backend.controller;

import com.prm.backend.dto.topic.TopicDtos.TopicInfo;
import com.prm.backend.dto.topic.TopicDtos.TopicWordsResponse;
import com.prm.backend.service.TopicService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/topics")
public class TopicController {

    private final TopicService topicService;

    public TopicController(TopicService topicService) {
        this.topicService = topicService;
    }

    @GetMapping
    public ResponseEntity<List<TopicInfo>> getTopics() {
        return ResponseEntity.ok(topicService.getAllTopics());
    }

    @GetMapping("/{topicCode}/words")
    public ResponseEntity<TopicWordsResponse> getTopicWords(@PathVariable String topicCode) {
        return ResponseEntity.ok(topicService.getTopicWords(topicCode));
    }
}
