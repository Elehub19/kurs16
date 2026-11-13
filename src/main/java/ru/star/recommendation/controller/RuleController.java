package ru.star.recommendation.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import ru.star.recommendation.dto.RuleListResponse;
import ru.star.recommendation.dto.RuleRequest;
import ru.star.recommendation.dto.RuleResponse;
import ru.star.recommendation.dto.RuleStatsResponse;
import ru.star.recommendation.service.RuleService;
import ru.star.recommendation.service.RuleStatsService;

/**
 * REST API динамических правил рекомендаций и статистики их срабатываний.
 */
@RestController
@RequestMapping("/rule")
public class RuleController {

    private final RuleService ruleService;
    private final RuleStatsService statsService;

    public RuleController(RuleService ruleService, RuleStatsService statsService) {
        this.ruleService = ruleService;
        this.statsService = statsService;
    }

    /**
     * Создаёт динамическое правило и возвращает его с присвоенным {@code id}.
     */
    @PostMapping
    public RuleResponse create(@Valid @RequestBody RuleRequest request) {
        return ruleService.create(request);
    }

    /**
     * Возвращает все динамические правила.
     */
    @GetMapping
    public RuleListResponse findAll() {
        return new RuleListResponse(ruleService.findAll());
    }

    /**
     * Возвращает число срабатываний каждого правила (для правил без срабатываний — 0).
     */
    @GetMapping("/stats")
    public RuleStatsResponse stats() {
        return new RuleStatsResponse(statsService.getStats());
    }

    /**
     * Удаляет правило вместе с его статистикой. Ответ 204, даже если правила не было.
     */
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable("id") String id) {
        ruleService.delete(id);
    }
}
