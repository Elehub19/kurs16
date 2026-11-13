#!/usr/bin/env bash
# Создаёт в GitHub метки и задачи (Issues) по требованиям проекта.
# Использование: bash docs/tracker/create-issues.sh OWNER/REPO
# Нужен GitHub CLI (gh) и вход: gh auth login. Запускайте один раз, иначе задачи задвоятся.
set -euo pipefail

REPO="${1:?Укажите репозиторий: OWNER/REPO}"

gh label create user-story     --repo "$REPO" --color 1d76db --description "Функциональное требование" --force
gh label create nfr            --repo "$REPO" --color 5319e7 --description "Нефункциональное требование" --force
gh label create documentation  --repo "$REPO" --color 0075ca --description "Документация" --force
gh label create chore          --repo "$REPO" --color cfd3d7 --description "Оформление проекта" --force

# issue <ID> <метка> <заголовок> <требование> <критерии через |> <код>
issue() {
  local id="$1" label="$2" title="$3" req="$4" criteria="$5" code="$6" body list=""
  IFS="|" read -ra items <<< "$criteria"
  for c in "${items[@]}"; do list+="- [ ] ${c}"$'\n'; done
  body=$(printf "**Требование %s**\n\n%s\n\n**Критерии приёмки**\n\n%s\n**Где в коде:** %s\n\n**Ветка:** _указать_\n**Pull Request:** _указать_\n\nСм. docs/wiki/Requirements.md и docs/wiki/Traceability.md." "$id" "$req" "$list" "$code")
  gh issue create --repo "$REPO" --title "[$id] $title" --label "$label" --body "$body"
}

issue 'US-01' 'user-story' 'Рекомендации по REST: GET /recommendation/{user_id}' 'Как Пользователь, я хочу получить по своему идентификатору список рекомендованных продуктов, чтобы узнать, какие предложения банка мне подходят.' 'Ответ 200 и JSON {user_id, recommendations:[{name,id,text}]}|Формат и пути строго по ТЗ' 'RecommendationController, RecommendationService'
issue 'US-02' 'user-story' 'Пустой список рекомендаций вместо ошибки' 'Как Пользователь, я хочу получить пустой список, если мне пока ничего не подходит, чтобы клиентское приложение работало одинаково во всех случаях.' 'Ответ 200, recommendations: []' 'RecommendationService'
issue 'US-03' 'user-story' 'Фиксированные правила Invest 500, Top Saving, Простой кредит' 'Как Менеджер, я хочу, чтобы три продукта из ТЗ №1 рекомендовались по заданным правилам сразу после запуска.' 'Для тестовых пользователей из ТЗ выдаются соответствующие продукты|Правила объединяются по «И»|Запросы к БД параметризованные и общие' 'Invest500RuleSet, TopSavingRuleSet, SimpleCreditRuleSet, TransactionsRepository'
issue 'US-04' 'user-story' 'Добавление динамического правила: POST /rule' 'Как Менеджер, я хочу добавить новое правило рекомендации, чтобы запустить новый продукт без изменения кода.' 'Правило сохраняется в PostgreSQL, ответ 200 с присвоенным id|Некорректное правило — 400 с описанием причины|Таблицы создаются миграцией Liquibase' 'RuleController, RuleService, RuleEntity, db/changelog'
issue 'US-05' 'user-story' 'Удаление правила: DELETE /rule/{id}' 'Как Менеджер, я хочу удалить правило, чтобы убрать устаревший продукт из рекомендаций.' 'Ответ 204|Принимается id правила или product_id продукта' 'RuleController, RuleService'
issue 'US-06' 'user-story' 'Список правил: GET /rule' 'Как Менеджер, я хочу видеть список всех правил, чтобы контролировать, что рекомендует система.' 'Ответ 200, {data:[...]}' 'RuleController, RuleService'
issue 'US-07' 'user-story' 'Четыре типа запросов динамических правил и negate' 'Как Менеджер, я хочу описывать правила запросами USER_OF, ACTIVE_USER_OF, TRANSACTION_SUM_COMPARE, TRANSACTION_SUM_COMPARE_DEPOSIT_WITHDRAW с модификатором negate.' 'Правило выполняется, если все запросы true|Операции сравнения: > < = >= <=|Константа — неотрицательное целое типа int' 'пакет dynamic'
issue 'US-08' 'user-story' 'Динамические и фиксированные правила в одной выдаче' 'Как Пользователь, я хочу получать рекомендации и по динамическим, и по фиксированным правилам.' 'Продукт не повторяется в ответе|Правила одного продукта работают как «ИЛИ»' 'RecommendationService'
issue 'US-09' 'user-story' 'Telegram-бот: приветствие и справка' 'Как Пользователь, я хочу, чтобы при первом обращении бот поздоровался и показал справку.' 'Приветствие и справка при первом сообщении, по /start и /help' 'BotService, TelegramBotListener'
issue 'US-10' 'user-story' 'Telegram-бот: команда /recommend username' 'Как Пользователь, я хочу получить рекомендации командой /recommend username.' '«Здравствуйте Имя Фамилия»|Секция «Новые продукты для вас:» и список с маркерами' 'BotService, UsersRepository'
issue 'US-11' 'user-story' 'Telegram-бот: «Пользователь не найден»' 'Как Пользователь, я хочу получить понятное сообщение, если имя неизвестно или неоднозначно.' 'Сообщение «Пользователь не найден» при 0 и при более чем 1 найденном пользователе' 'BotService'
issue 'US-12' 'user-story' 'Статистика срабатываний: GET /rule/stats' 'Как Менеджер, я хочу получить число срабатываний каждого динамического правила.' 'Ответ 200, {stats:[{rule_id,count}]}|Правила без срабатываний присутствуют со значением 0|Счётчик растёт на 1 при каждой выданной рекомендации (атомарно)' 'RuleStatsService, RuleStatEntity, миграция 002'
issue 'US-13' 'user-story' 'Удаление статистики вместе с правилом' 'Как Менеджер, я хочу, чтобы статистика удалялась вместе с правилом.' 'После удаления правила его нет в /rule/stats|Каскадное удаление на уровне внешнего ключа' 'миграция 002, RuleService.delete'
issue 'US-14' 'user-story' 'Сброс кешей: POST /management/clear-caches' 'Как Внешняя система, я хочу сбросить закешированные результаты, чтобы сервис увидел обновлённые данные.' 'POST без тела, ответ 200|Следующие запросы снова обращаются к базе' 'ManagementController, TransactionsRepository'
issue 'US-15' 'user-story' 'Информация о сервисе: GET /management/info' 'Как Внешняя система, я хочу получить имя и версию сервиса для списка сервисов банка.' 'JSON {name, version}|Значения берутся из pom.xml (build-info)' 'ManagementController, pom.xml'
issue 'NFR-01' 'nfr' 'Кеширование запросов к базе клиентов' 'Результаты SQL-запросов кешируются (Caffeine): по одному кешу на метод репозитория, ключ — все параметры запроса.' 'Повторный запрос рекомендаций не обращается в базу клиентов|Не больше трёх методов репозитория и трёх кешей' 'TransactionsRepository'
issue 'NFR-02' 'nfr' 'Целостность данных: атомарный счётчик, каскадное удаление, миграции' 'Инкремент счётчика атомарный, статистика удаляется каскадно, таблицы создаются только Liquibase, база клиентов — только чтение.' 'Один SQL UPDATE hit_count = hit_count + 1|ON DELETE CASCADE во внешнем ключе' 'RuleStatRepository, db/changelog, DataSourceConfiguration'
issue 'NFR-03' 'nfr' 'Обработка ошибок и логирование' 'Некорректное правило — 400 с причиной; повреждённое правило пропускается с записью в лог; ошибка одного сообщения Telegram не останавливает бота.' 'Тесты на отклонение некорректных правил и пропуск повреждённых' 'ApiExceptionHandler, RecommendationService, TelegramBotListener'
issue 'NFR-04' 'nfr' 'Секреты только в переменных среды' 'Токен бота и пароль БД не хранятся в репозитории; без токена сервис работает без бота.' 'Токен задаётся TELEGRAM_BOT_TOKEN|application-local.properties и .env в .gitignore' 'TelegramBotConfiguration, .gitignore'
issue 'NFR-05' 'nfr' 'Расширяемость и модульные тесты' 'Новый тип запроса или фиксированное правило добавляется новым классом с @Component; компоненты покрыты тестами JUnit и Mockito.' 'mvn test проходит|Описано в документе «Архитектура»' 'RecommendationRuleSet, RuleQueryHandler'
issue 'NFR-06' 'nfr' 'Совместимость REST API с ТЗ' 'Пути, методы и поля REST API соответствуют техническим заданиям без изменений.' 'Описание в docs/openapi.yaml совпадает с реализацией' 'контроллеры, docs/openapi.yaml'
issue 'DOC-01' 'documentation' 'Вики: главная, требования, трассировка, архитектура' 'Подготовить страницы вики, диаграмму вариантов использования, диаграммы компонентов и деятельности.' 'Все страницы лежат в docs/wiki и опубликованы в вики GitHub|Диаграммы актуальны' 'docs/wiki, docs/diagrams'
issue 'DOC-02' 'documentation' 'Инструкция по развёртыванию и Maven Wrapper' 'Описать нужные сервисы, команды сборки и запуска, переменные среды; добавить mvnw в репозиторий.' 'Команды ./mvnw clean package и java -jar проверены на чистой машине' 'docs/wiki/Deployment.md'
issue 'CHORE-01' 'chore' 'Оформление кода: форматирование, Javadoc, комментарии' 'Отформатировать код (Code → Reformat Code в IntelliJ IDEA), удалить закомментированный код, добавить Javadoc к публичным методам и сервисам.' 'Нет закомментированного кода|У публичных методов и сервисов есть Javadoc' 'весь код'
