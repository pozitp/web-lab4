# Web Lab 4 - Spring + Vue.js

**Вариант 641** | Мухамедьяров Артур Альбертович | P3209

## Стек

- Backend: Spring Boot 3.2, Spring Data JPA, Spring Security
- Frontend: Vue.js 3, Vue Router, Vite
- Database: PostgreSQL (Docker)

## Быстрый старт с Docker

### 1. Запустить PostgreSQL

```powershell
cd c:\Users\pozit\IdeaProjects\web_lab4
docker-compose up -d
```

Подождите ~10 секунд пока PostgreSQL запустится.

### 2. Собрать фронтенд

```powershell
cd frontend
npm install
npm run build
```

### 3. Запустить приложение

```powershell
cd c:\Users\pozit\IdeaProjects\web_lab4
.\gradlew bootRun
```

Открыть: <http://localhost:8080>

## Режим разработки

### Терминал 1 - Backend

```powershell
.\gradlew bootRun
```

### Терминал 2 - Frontend (hot-reload)

```powershell
cd frontend
npm run dev
```

Открыть: <http://localhost:3000>

## REST API

### Auth

- `POST /api/auth/register` - регистрация `{username, password}`
- `POST /api/auth/login` - вход `{username, password}`
- `POST /api/auth/logout` - выход
- `GET /api/auth/check` - проверка сессии

### Points

- `GET /api/points` - история
- `POST /api/points` - проверка `{x, y, r}` (строки для точности)
- `DELETE /api/points` - очистить историю

## Технические детали

### BigDecimal

Числа передаются как строки в JSON для сохранения точности.
Backend использует `BigDecimal` с 18 знаками после запятой.

### Нет PRG

SPA не использует PRG - все запросы через AJAX.
Перезагрузка страницы не дублирует POST запросы.
История загружается с сервера при каждом открытии.

### Адаптивность

- Desktop: >= 1202px
- Tablet: 744px - 1201px  
- Mobile: < 744px

## Область (Вариант 641)

- Прямоугольник III четверть: [-R/2, 0] x [-R, 0]
- Треугольник IV четверть: (0,0), (R,0), (0,-R/2)
- Четверть круга II четверть: радиус R/2

## GitOps & CI/CD

### Multi-stage GitOps Pipeline

Проект использует Tekton для CI/CD и ArgoCD для GitOps:

- **Tekton Pipeline**: Автоматизация сборки, тестирования и деплоя
- **ArgoCD**: Непрерывное развертывание из Git
- **Argo Rollouts**: Canary deployment с автоматическим постепенным увеличением трафика

Подробности в [GITOPS_README.md](GITOPS_README.md)

### Feature Flags & A/B Testing

Система feature flags для A/B тестирования:

- **API**: `/api/feature-flags/{flagName}`
- **Варианты**: `variant-a`, `variant-b`, `default`
- **Распределение**: Настраиваемые проценты для каждого варианта

Пример создания feature flag:

```bash
curl -X POST http://localhost:8080/api/feature-flags/ui-variant \
  -H "Content-Type: application/json" \
  -u username:password \
  -d '{
    "enabled": true,
    "variantAPercentage": 50,
    "variantBPercentage": 50
  }'
```

Frontend автоматически загружает вариант пользователя и применяет соответствующие стили.