# Развёртывание

## Какие сервисы нужны

| Сервис | Версия | Обязательность | Зачем |
|--------|--------|---------------|-------|
| Java (JRE или JDK) | 17 или новее | обязательно | запуск приложения |
| PostgreSQL | 14 или новее (проверено на 16) | обязательно | динамические правила и статистика; таблицы создаст Liquibase при старте |
| Файл `transaction.mv.db` | — | обязательно | база клиентов (H2); лежит в корне проекта, рядом с `pom.xml` |
| Доступ в интернет к `api.telegram.org` | — | только для бота | Telegram Bot API |
| JDK 17 и Maven (или Maven Wrapper) | Maven 3.9+ | только для сборки | сборка JAR |

Чтобы быстро поднять PostgreSQL для разработки, в корне проекта есть `docker-compose.yml`:

```
docker compose up -d
```

Он создаёт базу `star_recommendation` (пользователь и пароль `star`, порт 5432).

## Сборка JAR

### Maven Wrapper

Скрипты `mvnw` и `mvnw.cmd` нужно один раз создать и добавить в репозиторий. Если их ещё нет, выполните
(понадобится установленный Maven; в IntelliJ IDEA — Run Anything → двойное нажатие Ctrl):

```
mvn wrapper:wrapper -Dmaven=3.9.9
```

Затем закоммитьте `mvnw`, `mvnw.cmd` и папку `.mvn/`.

### Команда сборки

Linux и macOS:

```
./mvnw clean package
```

Windows (PowerShell или cmd):

```
mvnw.cmd clean package
```

Команда компилирует проект, запускает тесты и собирает исполняемый JAR `target/star-recommendation-0.0.1-SNAPSHOT.jar`.
Заодно плагин Spring Boot создаёт `META-INF/build-info.properties` — из него `/management/info` берёт имя и версию
из `pom.xml`. Чтобы пропустить тесты: добавьте `-DskipTests`.

## Запуск

Запускайте из папки, где лежит `transaction.mv.db` (путь к базе клиентов по умолчанию относительный):

```
java -jar target/star-recommendation-0.0.1-SNAPSHOT.jar
```

Пример с параметрами (Linux):

```
export SPRING_DATASOURCE_URL=jdbc:postgresql://db.example.com:5432/star_recommendation
export SPRING_DATASOURCE_USERNAME=star
export SPRING_DATASOURCE_PASSWORD='секретный-пароль'
export APPLICATION_RECOMMENDATIONS_DB_URL=jdbc:h2:file:/opt/star/transaction
export TELEGRAM_BOT_TOKEN=123456:ABC...
java -jar star-recommendation-0.0.1-SNAPSHOT.jar
```

Windows (PowerShell):

```powershell
$env:SPRING_DATASOURCE_URL = "jdbc:postgresql://localhost:5432/star_recommendation"
$env:SPRING_DATASOURCE_USERNAME = "star"
$env:SPRING_DATASOURCE_PASSWORD = "star"
java -jar target\star-recommendation-0.0.1-SNAPSHOT.jar
```

Для разработки без PostgreSQL: `java -jar target/star-recommendation-0.0.1-SNAPSHOT.jar --spring.profiles.active=h2` (правила хранятся в памяти и теряются при
перезапуске).

## Переменные среды

Переменная среды получается из свойства Spring Boot заменой точек и дефисов на `_` и переводом в верхний регистр.

| Переменная | Свойство | Значение по умолчанию | Назначение |
|-----------|----------|----------------------|-----------|
| `SPRING_DATASOURCE_URL` | `spring.datasource.url` | `jdbc:postgresql://localhost:5432/star_recommendation` | **PostgreSQL:** адрес базы правил |
| `SPRING_DATASOURCE_USERNAME` | `spring.datasource.username` | `star` | **PostgreSQL:** пользователь |
| `SPRING_DATASOURCE_PASSWORD` | `spring.datasource.password` | `star` | **PostgreSQL:** пароль (в рабочей среде обязательно сменить) |
| `SPRING_DATASOURCE_DRIVER_CLASS_NAME` | `spring.datasource.driver-class-name` | `org.postgresql.Driver` | Драйвер основной БД |
| `APPLICATION_RECOMMENDATIONS_DB_URL` | `application.recommendations-db.url` | `jdbc:h2:file:./transaction` | **H2:** путь к базе клиентов, без суффикса `.mv.db` |
| `APPLICATION_RECOMMENDATIONS_DB_DRIVER_CLASS_NAME` | `application.recommendations-db.driver-class-name` | `org.h2.Driver` | Драйвер базы клиентов |
| `TELEGRAM_BOT_TOKEN` | `telegram.bot.token` | не задан | Токен бота от @BotFather; без него бот не запускается |
| `SPRING_PROFILES_ACTIVE` | `spring.profiles.active` | не задан | `h2` — правила в памяти (для разработки) |
| `SERVER_PORT` | `server.port` | `8080` | Порт REST API |

## Проверка после запуска

```
curl http://localhost:8080/management/info
curl http://localhost:8080/recommendation/cd515076-5d8a-44be-930e-8d4fcb79f42d
curl http://localhost:8080/rule/stats
```

`/management/info` должен вернуть имя `star-recommendation` и версию из `pom.xml`. Если версия `unknown`, JAR собран
не Maven-ом — пересоберите командой `./mvnw clean package`. Если задан токен, в логе появится строка
«Telegram-бот запущен».

## Частые проблемы

| Симптом | Причина и решение |
|---------|------------------|
| `Connection to localhost:5432 refused` | PostgreSQL не запущен или неверный `SPRING_DATASOURCE_URL`. |
| `Database may be already in use` / `Locked by another process` | Файл `transaction.mv.db` открыт в другой программе (DBeaver) или запущен второй экземпляр. Закройте соединение. |
| `Table "TRANSACTIONS" not found` | Приложение запущено не из папки с `transaction.mv.db`, и H2 создала пустую базу. Задайте `APPLICATION_RECOMMENDATIONS_DB_URL` с абсолютным путём. |
| Приложение не может записать в папку с базой | H2 создаёт служебные файлы рядом с базой: у пользователя, под которым запущен сервис, должны быть права на запись в эту папку. |
| Бот не отвечает | Не задан `TELEGRAM_BOT_TOKEN` или нет доступа к `api.telegram.org`. |
