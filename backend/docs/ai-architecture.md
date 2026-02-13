# Arquitetura IA - Garage Sales

## Objetivo
Adicionar IA generativa com ganho real em conversão e velocidade de publicação.

## Fluxo-alvo
Frontend -> API Gateway -> AI Orchestrator -> (LLM + Vector DB + Tools)

## Componentes
- API Gateway (`GarageSales.Api`): autenticação, rate-limit, roteamento
- AI Orchestrator (futuro): centraliza prompts, memória curta, fallback e guardrails
- LLM Provider: OpenAI/Azure OpenAI
- Vector DB: PostgreSQL + pgvector (preferencial) ou Pinecone
- Data store transacional: PostgreSQL
- Cache: Redis
- Workers: geração de embeddings e tarefas assíncronas

## Módulos de produto (microserviços por domínio)
- `Identity Service` (auth/usuários)
- `Listings Service` (anúncios)
- `Search Service` (busca semântica + ranking)
- `Messaging Service` (chat)
- `Jobs Service` (vagas/candidaturas)
- `AI Service` (prompts, RAG, geração de conteúdo)
- `Reputation & Rewards Service` (pontos, estrelas, créditos)

## Princípios técnicos
- Contratos versionados por endpoint (`/v1` quando estabilizar)
- Telemetria desde o início (request-id, latência, custo/token)
- Segurança: PII masking, consentimento LGPD, auditoria de prompts
- Resiliência: timeout curto, retries controlados, fallback sem IA

## RAG para vendedor inteligente
1. Consulta do usuário -> embedding
2. Busca vetorial de itens relevantes
3. Montagem de contexto com inventário real
4. Prompt para LLM com política "responda só com o contexto"
5. Resposta com sugestões e justificativas

## Compliance (LGPD/RGPD)
- Consentimento explícito para uso de dados de currículo/perfil
- Finalidade clara: matching de vagas, contato comercial e análise de performance
- Direito de revogação e exclusão
- Registro de data/hora e versão do termo aceito
