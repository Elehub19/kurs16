package ru.star.recommendation.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import ru.star.recommendation.entity.RuleEntity;

import java.util.List;
import java.util.UUID;

/**
 * Хранилище динамических правил (основная БД).
 */
public interface RuleRepository extends JpaRepository<RuleEntity, Long> {

    /**
     * Удаляет все правила, рекомендующие продукт с данным id.
     *
     * @return количество удалённых правил
     */
    long deleteByProductId(UUID productId);

    /**
     * Идентификаторы всех правил по возрастанию (для статистики без загрузки запросов).
     */
    @Query("select r.id from RuleEntity r order by r.id")
    List<Long> findAllIds();
}
