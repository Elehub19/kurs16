# Трассировка требований

Таблица связывает каждое требование из [документа требований](Requirements.md) с задачей (Issue) в GitHub,
веткой и Pull Request, а также с кодом и тестами, которые его реализуют.

> **Как заполнять.** Колонки «Issue», «Ветка» и «Pull Request» заполняются, когда задачи заведены и выполнены:
> задачи можно создать скриптом [`docs/tracker/create-issues.sh`](../tracker/create-issues.sh) (тексты задач — в
> [`issues.md`](../tracker/issues.md)). В каждой Issue укажите ID требования в заголовке, ссылку на ветку и Pull Request;
> в Pull Request добавьте `Closes #N`, тогда задача закроется автоматически, а в проекте GitHub карточка перейдёт
> в колонку Done. Формат ветки: `feature/us-04-create-rule`, `fix/…`, `docs/…`.

## Функциональные требования

| ID | Требование | Issue | Ветка | Pull Request | Реализация | Тесты |
|----|-----------|-------|-------|--------------|-----------|-------|
| US-01 | Рекомендации по REST | #__ | `feature/us-01-…` | #__ | `RecommendationController`, `RecommendationService` | `RecommendationServiceTest` |
| US-02 | Пустой список вместо ошибки | #__ | `feature/us-02-…` | #__ | `RecommendationService` | `RecommendationServiceTest` |
| US-03 | Фиксированные правила из ТЗ №1 | #__ | `feature/us-03-…` | #__ | `Invest500RuleSet`, `TopSavingRuleSet`, `SimpleCreditRuleSet`, `TransactionsRepository` | `Invest500RuleSetTest` |
| US-04 | Добавление динамического правила | #__ | `feature/us-04-…` | #__ | `RuleController.create`, `RuleService.create`, `RuleEntity`, `RuleQueryEntity`, миграция `001-create-rules-tables` | `RuleServiceTest` |
| US-05 | Удаление правила | #__ | `feature/us-05-…` | #__ | `RuleController.delete`, `RuleService.delete` | `RuleServiceTest` |
| US-06 | Список правил | #__ | `feature/us-06-…` | #__ | `RuleController.findAll`, `RuleService.findAll` | — |
| US-07 | Четыре типа запросов и `negate` | #__ | `feature/us-07-…` | #__ | пакет `dynamic`: `DynamicRuleEvaluator`, `UserOfQueryHandler`, `ActiveUserOfQueryHandler`, `TransactionSumCompareQueryHandler`, `TransactionSumCompareDepositWithdrawQueryHandler` | `DynamicRuleEvaluatorTest` |
| US-08 | Фиксированные и динамические правила вместе | #__ | `feature/us-08-…` | #__ | `RecommendationService` | `RecommendationServiceTest` |
| US-09 | Приветствие и справка бота | #__ | `feature/us-09-…` | #__ | `BotService`, `TelegramBotListener`, `TelegramBotConfiguration` | `BotServiceTest` |
| US-10 | Команда `/recommend username` | #__ | `feature/us-10-…` | #__ | `BotService`, `UsersRepository` | `BotServiceTest` |
| US-11 | «Пользователь не найден» | #__ | `feature/us-11-…` | #__ | `BotService` | `BotServiceTest` |
| US-12 | Статистика срабатываний | #__ | `feature/us-12-…` | #__ | `RuleStatsService`, `RuleStatEntity`, `RuleStatRepository`, `RuleController.stats`, миграция `002-create-rule-stats` | `RuleStatsServiceTest`, `RecommendationServiceTest` |
| US-13 | Удаление статистики вместе с правилом | #__ | `feature/us-13-…` | #__ | внешний ключ `fk_rule_stats_rule … ON DELETE CASCADE`, `RuleService.delete` | `RuleServiceTest` |
| US-14 | Сброс кешей | #__ | `feature/us-14-…` | #__ | `ManagementController.clearCaches`, `TransactionsRepository.clearCaches` | `ManagementControllerTest`, `TransactionsRepositoryTest` |
| US-15 | Информация о сервисе | #__ | `feature/us-15-…` | #__ | `ManagementController.info`, цель `build-info` в `pom.xml` | `ManagementControllerTest` |

## Нефункциональные требования

| ID | Требование | Issue | Ветка | Pull Request | Реализация | Тесты |
|----|-----------|-------|-------|--------------|-----------|-------|
| NFR-01 | Кеширование запросов к базе клиентов | #__ | `feature/nfr-01-…` | #__ | `TransactionsRepository` (два кеша Caffeine) | `TransactionsRepositoryTest` |
| NFR-02 | Атомарность счётчика, каскадное удаление, миграции, чтение из БД клиентов только на чтение | #__ | `feature/nfr-02-…` | #__ | `RuleStatRepository.incrementCount`, миграции Liquibase, `DataSourceConfiguration` | `RuleStatsServiceTest` |
| NFR-03 | Обработка ошибок и логирование | #__ | `feature/nfr-03-…` | #__ | `ApiExceptionHandler`, `RecommendationService`, `TelegramBotListener` | `DynamicRuleEvaluatorTest`, `RecommendationServiceTest` |
| NFR-04 | Секреты только в переменных среды | #__ | `feature/nfr-04-…` | #__ | `TelegramBotConfiguration`, `application.properties`, `.gitignore` | — |
| NFR-05 | Расширяемость и модульные тесты | #__ | `feature/nfr-05-…` | #__ | интерфейсы `RecommendationRuleSet`, `RuleQueryHandler` | все тесты (`mvn test`) |
| NFR-06 | Совместимость REST API с ТЗ | #__ | `feature/nfr-06-…` | #__ | контроллеры, [`openapi.yaml`](../openapi.yaml) | — |

## Задачи без требований (оформление проекта)

| Задача | Issue | Ветка | Pull Request |
|--------|-------|-------|--------------|
| Вики и диаграммы | #__ | `docs/wiki` | #__ |
| Инструкция по развёртыванию, Maven Wrapper | #__ | `docs/deployment` | #__ |
| Javadoc, форматирование, удаление закомментированного кода | #__ | `chore/code-style` | #__ |
