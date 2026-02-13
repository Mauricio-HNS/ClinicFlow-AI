# Garage Sales Backend (MVP IA)

Backend inicial em `ASP.NET Core` para suportar o app e evolução para arquitetura de microserviços.

## Stack inicial
- .NET 9
- ASP.NET Core Web API
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

Health check: `/health`

## Endpoints IA (MVP)
- `POST /api/ai/chat-seller`
- `POST /api/ai/listing/generate`
- `POST /api/ai/search/semantic`
- `POST /api/ai/pricing/suggest`
- `POST /api/ai/reviews/summarize`

## Endpoints de autenticação
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me` (Bearer token)

## Endpoints de anúncios
- `GET /api/listings/mine` (Bearer token)
- `POST /api/listings` (Bearer token)
- `PUT /api/listings/{listingId}` (Bearer token)
- `DELETE /api/listings/{listingId}` (Bearer token)
- Regra de evento pago:
  - se `isEvent=true` e `consumeEventCredit=false`, enviar `eventPaymentId` com pagamento `paid` do próprio usuário.

## Endpoints de favoritos
- `GET /api/favorites` (Bearer token)
- `POST /api/favorites` (Bearer token)
- `DELETE /api/favorites/{listingId}` (Bearer token)

## Endpoints de mensagens
- `GET /api/messages/mine` (Bearer token)
- `POST /api/messages` (Bearer token)
- `PUT /api/messages/{messageId}/open` (Bearer token)
- `DELETE /api/messages/{messageId}` (Bearer token)
- `DELETE /api/messages/mine` (Bearer token)

## Endpoints de candidaturas
- `GET /api/job-applications/mine` (Bearer token)
- `POST /api/job-applications` (Bearer token)

## Endpoints de pagamentos
- `POST /api/payments/event/checkout` (Bearer token)
- `GET /api/payments/mine` (Bearer token)
- `GET /api/payments/{paymentId}` (Bearer token)
- `POST /api/payments/confirm/{paymentId}` (Bearer token; fluxo mock/dev)
- `POST /api/payments/webhook/stripe` (webhook Stripe)

## Configuração de auth
- `Auth:Secret` (opcional): segredo usado para assinar tokens.
- Em desenvolvimento, se não for informado, a API usa um valor padrão local.

## Configuração de pagamentos
- `Payments:Stripe:SecretKey` (opcional): chave secreta da Stripe.
- `Payments:Stripe:WebhookSecret` (opcional): segredo de assinatura do webhook Stripe.
- Sem `SecretKey`, o backend opera em modo `mock` para desenvolvimento.

## Observação importante
Nesta fase, as respostas são heurísticas (mock inteligente) para acelerar integração de frontend e contratos.
Próximo passo é plugar orquestrador real (`Semantic Kernel`) + provedor LLM + vector DB.
