# Empleos Finder

Buscador de vagas com match inteligente, nota de currículo, avaliações de empresa e ingestão de vagas externas.

## Funcionalidades
- Busca de vagas por cargo, localização e raio (km), salário mínimo.
- Match 0–100% entre currículo e vaga (OpenAI).
- Upload de currículo em PDF com avaliação e pontos de melhoria.
- Avaliação de empresas (estrelas + score 0–10).
- Cadastro de empresas e vagas (contas de empresa).
- Painel com currículos, vagas e avaliações.
- Ingestão de vagas externas (pipeline básico).

## Stack
- Next.js (App Router)
- React
- PostgreSQL + Prisma
- OpenAI (embeddings + avaliação)

## Screenshots
Adicione as imagens em `public/screens/` e atualize os links abaixo.

![Home](public/screens/home.png)
![Detalhe da vaga](public/screens/job-detail.png)
![Painel](public/screens/dashboard.png)
![Login](public/screens/login.png)

## Requisitos
- Node.js 18+
- PostgreSQL

## Setup
```bash
npm install
cp .env.example .env
```

Preencha o `.env`:
```
DATABASE_URL="postgresql://USER:PASSWORD@localhost:5432/empleos_finder?schema=public"
OPENAI_API_KEY=""
AUTH_SECRET=""
INGEST_SOURCES="mock"
INGEST_PUBLISH="false"
```

Crie o banco e rode a migração:
```bash
npx prisma migrate dev
```

Suba o projeto:
```bash
npm run dev
```

Acesse: `http://localhost:3000`

## Scripts úteis
```bash
npm run dev
npm run build
npm run start
npm run lint
npm run prisma:generate
npm run prisma:migrate
npm run ingest
```

## Pipeline de ingestão
O script `npm run ingest` lê as fontes definidas em `INGEST_SOURCES`.

Modo de teste:
```
INGEST_SOURCES="mock"
INGEST_PUBLISH="true"
```

Isso cria vagas internas baseadas em dados de exemplo.

## Principais rotas
- `GET /api/jobs` (filtros + match opcional)
- `POST /api/jobs` (criação de vaga, requer login)
- `POST /api/companies` (criação de empresa, requer login)
- `POST /api/resume` (upload de currículo, requer login)
- `POST /api/reviews` (avaliação de empresa, requer login)
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/logout`

## Observações
- Geocoding usa Nominatim (OpenStreetMap).
- O match calcula embeddings e retorna score 0–100.
- Para performance, o match atual é limitado às 10 primeiras vagas.

## Roadmap (próximos passos)
- Integrações reais com APIs de vagas e scraping.
- Match em massa com cache/embeddings.
- Perfil de candidato mais completo (skills e preferências).
- Painel avançado para empresas (edição de vagas e métricas).
