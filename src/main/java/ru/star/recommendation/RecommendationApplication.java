package ru.star.recommendation;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Точка входа сервиса рекомендаций банка «Стар».
 */
@SpringBootApplication
public class RecommendationApplication {

    /**
     * Запускает Spring Boot-приложение.
     */
    public static void main(String[] args) {
        SpringApplication.run(RecommendationApplication.class, args);
    }
}
