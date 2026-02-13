# Garage Sales

Marketplace mobile (Flutter) para compra e venda local, com gestão de anúncios, favoritos, mensagens, perfil, módulo de vagas e base de backend em ASP.NET Core para evolução com IA.

## Status do projeto
- Frontend Flutter funcional com fluxos principais de marketplace.
- Gestão de vendas publicada com edição/remoção/alteração de status.
- Favoritos, notificações e candidaturas com estado local.
- Backend inicial em `backend/` com endpoints IA MVP.

## Stack
- Flutter (Material 3)
- Estado local com `ValueNotifier`
- `image_picker`
- Backend: .NET 9 + ASP.NET Core Web API

## Estrutura
- `lib/` aplicação Flutter
- `assets/` imagens, onboarding e logo
- `ios/` projeto iOS
- `android/` projeto Android
- `backend/` API (MVP IA)

## Como rodar o app
Pré-requisitos:
- Flutter instalado
- Xcode para iOS simulator
- Android SDK (opcional)

Comandos:
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d "iPhone 16 Plus"
```

## Como rodar o backend
```bash
cd backend/src/GarageSales.Api
dotnet restore
dotnet run
```

Health check:
- `GET /health`

## Endpoints IA MVP
- `POST /api/ai/chat-seller`
- `POST /api/ai/listing/generate`
- `POST /api/ai/search/semantic`
- `POST /api/ai/pricing/suggest`
- `POST /api/ai/reviews/summarize`

Documentação técnica:
- `backend/README.md`
- `backend/docs/ai-architecture.md`
- `backend/docs/roadmap.md`

## Rotas Flutter
- `/splash`
- `/onboarding`
- `/auth`
- `/login`
- `/register`
- `/profile-verification`
- `/categories`
- `/category`
- `/filters`
- `/search-alerts`
- `/jobs`
- `/job-applications`
- `/home`

## Funcionalidades por tela
### Splash
- Exibe marca e redireciona para onboarding.

### Onboarding
- 3 páginas de introdução com progresso.

### Auth / Login / Register
- Entrada e criação de conta com validação.
- Login e sessão persistida entre reinícios do app.

### Home
- Busca semântica local.
- Atalhos para publicar, empregos e alertas.
- Feed de anúncios e categorias.

### Categorias e detalhe
- Navegação por categorias e aplicação de filtro global.

### Filtros
- Preço, distância e opção de “somente hoje”.

### Publicar item
- Fluxo com dados, local, item, fotos e confirmação.
- Integra com estado de vendas publicadas.

### Minhas vendas
- Lista dos anúncios do usuário.
- Alterar status (ativo/pausado/vendido).
- Editar preço, descrição, contato, localização e fotos.
- Remover anúncio individual ou em lote.

### Favoritos
- Salvar e remover anúncios favoritos.

### Mensagens
- Conversas com marcação de lida e exclusão.

### Perfil
- Resumo da conta e reputação.
- Acesso para verificação de perfil.
- Gestão de currículo com consentimento LGPD.

### Empregos e candidaturas
- Busca/filtro de vagas.
- Candidatura com registro local.
- Tela de candidaturas recebidas.

## Estados globais principais
- `ProfileState`: perfil e verificação
- `PublishedSalesState`: anúncios publicados (CRUD local)
- `FavoritesState`: favoritos
- `NotificationsState`: notificações do app
- `JobApplicationsState`: candidaturas
- `SearchAlertState`: alertas de busca
- `ReputationState`: reputação/pontos
- `EventRewardsState`: recompensa por meta de vendas

## Regras de produto já aplicadas
- Fluxo de vendas separado para publicação/gestão dos anúncios.
- Favoritos conectados ao feed de anúncios.
- Consentimento LGPD obrigatório ao salvar currículo.

## Próximos passos recomendados
1. Conectar Flutter ao backend real (HTTP client + repositórios).
2. Persistência em PostgreSQL.
3. Autenticação JWT real.
4. Evolução IA com RAG (LLM + pgvector).

## Publicação nas lojas
- Checklist de release: `docs/release/STORE_RELEASE_CHECKLIST.md`
- Build Android release: `./scripts/build_android_release.sh https://api.seudominio.com`
- Build iOS release: `./scripts/build_ios_release.sh https://api.seudominio.com`
