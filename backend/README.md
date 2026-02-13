# Garage Sales Backend (MVP IA)

Backend inicial em `ASP.NET Core` para suportar o app e evolução para arquitetura de microserviços.

## Stack inicial
- .NET 8
- ASP.NET Core Web API
- Swagger/OpenAPI
- CORS liberado para integração com frontend durante MVP

## Estrutura
- `backend/src/GarageSales.Api`: API principal (gateway inicial)
- `backend/src/GarageSales.Api/Controllers/AiController.cs`: endpoints IA do MVP
- `backend/src/GarageSales.Api/Contracts/AiDtos.cs`: contratos de request/response
- `backend/docs/ai-architecture.md`: blueprint de arquitetura
- `backend/docs/roadmap.md`: roadmap de evolução

## Rodar local
```bash
cd backend/src/GarageSales.Api
dotnet restore
dotnet run
```

API local padrão: `http://localhost:5000` (ou porta exibida no terminal)

Swagger: `/swagger`
Health check: `/health`

## Endpoints IA (MVP)
- `POST /api/ai/chat-seller`
- `POST /api/ai/listing/generate`
- `POST /api/ai/search/semantic`
- `POST /api/ai/pricing/suggest`
- `POST /api/ai/reviews/summarize`

## Observação importante
Nesta fase, as respostas são heurísticas (mock inteligente) para acelerar integração de frontend e contratos.
Próximo passo é plugar orquestrador real (`Semantic Kernel`) + provedor LLM + vector DB.
