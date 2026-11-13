# REST API

Полное описание в формате OpenAPI 3.0: [`docs/openapi.yaml`](../openapi.yaml).
Чтобы посмотреть его в виде Swagger UI, откройте <https://editor.swagger.io> и вставьте содержимое файла
(File → Import file).

## Эндпоинты

| Метод | Путь | Назначение | Успешный ответ |
|-------|------|-----------|----------------|
| GET | `/recommendation/{user_id}` | Рекомендации для пользователя | 200, `RecommendationResponse` |
| POST | `/rule` | Создать динамическое правило | 200, `RuleResponse` |
| GET | `/rule` | Список динамических правил | 200, `RuleList` |
| GET | `/rule/stats` | Статистика срабатываний правил | 200, `RuleStatsResponse` |
| DELETE | `/rule/{id}` | Удалить правило и его статистику | 204, без тела |
| POST | `/management/clear-caches` | Сбросить кеши | 200, без тела |
| GET | `/management/info` | Имя и версия сервиса | 200, `ServiceInfo` |

Ошибки (`400`) возвращаются в виде `{"error": "описание"}`.

## Схемы и примеры

### GET /recommendation/{user_id}

`user_id` — UUID пользователя из базы клиентов.

```json
{
  "user_id": "cd515076-5d8a-44be-930e-8d4fcb79f42d",
  "recommendations": [
    {"name": "Invest 500", "id": "147f6a0f-3b91-413b-ab99-87f081d60d5a", "text": "..."}
  ]
}
```

Если рекомендаций нет, `recommendations` — пустой массив.

### POST /rule

Запрос:

```json
{
  "product_name": "Простой кредит",
  "product_id": "ab138afb-f3ba-4a93-b74f-0fcee86d447f",
  "product_text": "Откройте мир выгодных кредитов с нами!",
  "rule": [
    {"query": "USER_OF", "arguments": ["CREDIT"], "negate": true},
    {"query": "TRANSACTION_SUM_COMPARE_DEPOSIT_WITHDRAW", "arguments": ["DEBIT", ">"], "negate": false},
    {"query": "TRANSACTION_SUM_COMPARE", "arguments": ["DEBIT", "WITHDRAW", ">", "100000"], "negate": false}
  ]
}
```

Ответ 200 — то же правило с полем `id` (число, присваивается сервисом).
Если правило некорректно — 400, например:
`{"error": "Недопустимый тип продукта: GOLD. Допустимые: [DEBIT, SAVING, INVEST, CREDIT]"}`.

Типы запросов:

| query | arguments |
|-------|-----------|
| `USER_OF` | `[тип продукта]` — есть хотя бы одна транзакция |
| `ACTIVE_USER_OF` | `[тип продукта]` — не меньше 5 транзакций |
| `TRANSACTION_SUM_COMPARE` | `[тип продукта, тип транзакции, операция, константа]` |
| `TRANSACTION_SUM_COMPARE_DEPOSIT_WITHDRAW` | `[тип продукта, операция]` — пополнения сравниваются с тратами |

Типы продуктов: `DEBIT`, `CREDIT`, `INVEST`, `SAVING`. Типы транзакций: `DEPOSIT`, `WITHDRAW`.
Операции: `>`, `<`, `=`, `>=`, `<=`. Константа — неотрицательное целое число, помещающееся в `int`.

### GET /rule

```json
{
  "data": [
    {"id": 1, "product_name": "...", "product_id": "...", "product_text": "...", "rule": [ ... ]}
  ]
}
```

### GET /rule/stats

```json
{
  "stats": [
    {"rule_id": 1, "count": 12},
    {"rule_id": 2, "count": 0}
  ]
}
```

В списке есть все правила, в том числе ни разу не сработавшие (`count: 0`).

### DELETE /rule/{id}

`id` — идентификатор правила (число) **или** `product_id` продукта (UUID; удаляются все правила продукта).
Ответ 204 без тела; если правила не было, ответ тоже 204. Статистика правила удаляется вместе с ним.

### POST /management/clear-caches

Без тела. Очищает кеши запросов к базе клиентов, ответ 200.

### GET /management/info

```json
{"name": "star-recommendation", "version": "0.0.1-SNAPSHOT"}
```

Значения берутся из `pom.xml` во время сборки Maven (см. [Развёртывание](Deployment.md)).
