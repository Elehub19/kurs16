package ru.star.recommendation.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import ru.star.recommendation.dto.RecommendationResponse;
import ru.star.recommendation.service.RecommendationService;

import java.util.UUID;

/**
 * REST-контроллер выдачи рекомендаций: {@code GET /recommendation/{user_id}}.
 */
@RestController
public class RecommendationController {

    private final RecommendationService service;

    public RecommendationController(RecommendationService service) {
        this.service = service;
    }

    /**
     * Возвращает рекомендации для пользователя; если подходящих продуктов нет, список пустой.
     */
    @GetMapping("/recommendation/{userId}")
    public RecommendationResponse getRecommendations(@PathVariable("userId") UUID userId) {
        return new RecommendationResponse(userId, service.getRecommendations(userId));
    }
}
