package ru.star.recommendation.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import ru.star.recommendation.dynamic.InvalidRuleException;

import java.util.Map;
import java.util.stream.Collectors;

/**
 * Преобразует ошибки в ответы REST API: код 400 и поле {@code error} с описанием.
 */
@RestControllerAdvice
public class ApiExceptionHandler {

    /**
     * Некорректное динамическое правило или идентификатор.
     */
    @ExceptionHandler(InvalidRuleException.class)
    public ResponseEntity<Map<String, String>> handleInvalidRule(InvalidRuleException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
    }

    /**
     * Тело запроса не прошло проверку Bean Validation: перечисляет поля с ошибками.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidation(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.joining("; "));
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", message));
    }
}
