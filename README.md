# GarageSale Madrid

Aplicativo Flutter de marketplace local com foco em:
- compra e venda rápida por proximidade
- gestão de anúncios
- alertas de busca
- mensagens
- módulo de empregos e candidaturas

## Visão geral

O app é organizado em fluxos:
- onboarding + autenticação
- descoberta de anúncios (home, categorias, filtros, busca semântica)
- publicação de venda em etapas
- relacionamento (favoritos, mensagens, notificações)
- perfil e verificação
- vagas de emprego e inscrições

Navegação principal (bottom navigation):
- `Home`
- `Favoritos`
- `Publicar`
- `Mensagens`
- `Perfil`

## Tecnologias

- Flutter (Material 3)
- Gerenciamento de estado com `ValueNotifier`
- `image_picker` para seleção/captura de imagens
- Dados mockados locais (`mock_sales`, `mock_jobs`)

## Como rodar

Pré-requisitos:
- Flutter instalado
- Xcode (iOS) e/ou Android SDK (Android)

Comandos:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d "iPhone 16 Plus"     # exemplo iOS simulator
flutter run -d emulator-5554         # exemplo Android emulator
```

## Rotas principais

- `/splash`
- `/onboarding`
- `/auth`
- `/login`
- `/register`
- `/profile-verification`
- `/categories`
- `/category` (dinâmica via argumento)
- `/filters`
- `/search-alerts`
- `/jobs`
- `/job-applications`
- `/home` (shell com abas)

## Funcionalidades por tela

### 1) Splash (`SplashScreen`)
- Exibe marca/logo.
- Redireciona automaticamente para onboarding após ~1.2s.

### 2) Onboarding (`OnboardingScreen`)
- Carrossel com 3 páginas de apresentação.
- Indicadores de página.
- Botão `Pular` para ir direto à autenticação.
- Botão `Próximo/Começar` com avanço progressivo.

### 3) Autenticação inicial (`AuthScreen`)
- Escolha entre `Entrar` e `Criar conta`.
- Redireciona para telas de login/cadastro.

### 4) Login (`LoginScreen`)
- Campos: email e senha.
- Validação de formulário.
- Mostrar/ocultar senha.
- Ação de login navega para `/home`.
- Link visual de “Esqueci a senha” (placeholder).

### 5) Cadastro (`RegisterScreen`)
- Campos: nome, email, telefone, senha.
- Validação de formulário.
- Alternância de visibilidade da senha.
- Cadastro válido navega para `/home`.

### 6) Verificação de perfil (`ProfileVerificationScreen`)
- Formulário com dados pessoais obrigatórios.
- Upload de foto do documento (galeria).
- Captura de selfie (câmera).
- Só conclui quando formulário é válido e os dois arquivos foram enviados.
- Marca `ProfileState.isVerified = true`.

### 7) Home (`HomeScreen`)
- Busca semântica de anúncios (ranking por relevância, preço e proximidade).
- Alteração de cidade por bottom sheet.
- Acesso rápido para:
  - publicar venda
  - criar evento (sheet informativo de checkout)
  - empregos
  - alertas de busca
- Chips de categorias com acionamento rápido de busca.
- Exibe resumo da busca semântica quando há query.
- Feed com banners e cards de produto.
- Suporte a filtro de categoria global (`HomeState.selectedCategory`).

### 8) Mapa/Feed principal (`MapScreen`)
- Header com busca visual, localização e botão de filtros.
- Atalhos de categorias e acesso ao catálogo completo.
- Feed misto com:
  - cards de anúncio
  - seção “Perto de você agora”
  - bloco de recomendações
  - card de evento
  - prévia de chat
- CTA fixo `Vender agora`.
- Guarda de verificação: se perfil não estiver verificado, abre diálogo para completar perfil.

### 9) Todas as categorias (`CategoriesScreen`)
- Grid com todas as categorias.
- Card visual por categoria (capa, ícone, subtítulo).
- Toque navega para detalhe da categoria.

### 10) Detalhe da categoria (`CategoryDetailScreen`)
- Hero visual da categoria.
- Subcategorias listadas.
- Ações rápidas:
  - `Ver anúncios`: aplica categoria na Home e volta ao `/home`.
  - `Home`: limpa filtro e volta ao `/home`.

### 11) Filtros de anúncios (`FiltersScreen`)
- Filtro de preço máximo (slider).
- Filtro de distância (slider).
- Toggle “Somente hoje”.
- Ações `Aplicar filtros` e `Limpar`.

### 12) Criar venda (`CreateSaleScreen`)
- Fluxo em Stepper com 4 etapas:
  1. Cadastro rápido (nome/email/telefone)
  2. Local + data/hora
  3. Itens e fotos (categoria, título, preço, descrição, upload)
  4. Destaque opcional + simulação de pagamento
- Regras de publicação:
  - exige perfil verificado
  - exige foto para categorias obrigatórias
  - até 12 fotos
- Gatilhos de feedback:
  - dicas de performance conforme quantidade de fotos
  - snackbar de sucesso ao publicar
- Integração com alertas:
  - ao publicar, verifica correspondência com buscas ativas
  - gera notificação em `NotificationsState` quando houver match

### 13) Lista de vendas publicadas (`ListScreen`)
- Visão de gestão de anúncios do usuário.
- Busca local por título/categoria/preço.
- Ordenação por preço (asc/desc).
- Contadores por status: ativo, pausado, vendido.
- Filtros por status.
- Seleção em lote:
  - selecionar/desmarcar tudo (filtrados)
  - apagar selecionados
- Ações por item:
  - detalhes
  - enviar mensagem
  - pausar/reativar
  - marcar como vendido
  - apagar

### 14) Favoritos (`FavoritesScreen`)
- Lista de anúncios salvos.
- Remoção individual de favorito.
- Estado vazio quando não há itens.

### 15) Mensagens (`MessagesScreen`)
- Inbox unificada para chats de compra e recrutamento.
- Indicadores: não lidas, abertas, total.
- Swipe para apagar conversa individual.
- Ação para apagar todas as conversas.
- Toque abre sheet de resposta rápida.
- Mensagens não lidas mudam para lidas ao abrir.

### 16) Perfil (`ProfileScreen`)
- Card de status de verificação (com CTA para completar).
- Resumo do usuário (nome, reputação, pontos).
- Métricas:
  - vendas
  - compras
  - ranking
- Histórico com atalhos para telas relacionadas.
- Bottom sheets de:
  - avaliações recentes
  - ranking semanal

### 17) Notificações (`NotificationsScreen`)
- Lista combinando:
  - notificações dinâmicas de estado
  - notificações base mockadas
- Tipos dinâmicos atualmente suportados:
  - novo anúncio compatível com alerta de busca
  - nova candidatura recebida em vaga publicada

### 18) Alertas de busca (`SearchAlertsScreen`)
- Criação de alerta textual.
- Evita duplicidade de termo (normalização acentuação/case).
- Lista de alertas ativos.
- Remoção de alertas.
- Integra com publicação de venda para disparo automático de notificação.

### 19) Empregos (`JobsScreen`)
- Lista de vagas recomendadas.
- Busca por cargo, empresa, localização, tipo, descrição e salário.
- Filtros:
  - remoto
  - tipo de vaga
  - com salário explícito
  - novas hoje
- Chips rápidos e filtros avançados (bottom sheet).
- Card de destaque de vagas novas no dia.
- Publicação de vaga (form completo em bottom sheet):
  - título, empresa, celular da empresa
  - localização opcional / região aproximada com raio
  - salário (ou “a combinar”)
  - tipo de vaga
  - modalidade presencial/remota
  - descrição
- Validações:
  - todos campos obrigatórios da vaga
  - celular único e válido
- Ações por vaga:
  - `Detalhes` (sheet com informações completas)
  - `Candidatar` (sheet de inscrição)

### 20) Candidaturas (`JobApplicationsScreen`)
- Exibe candidaturas recebidas.
- Agrupa por vaga.
- Ordena por data de envio.
- `ExpansionTile` por vaga com lista de candidatos.
- Mostra dados do candidato, horário e mensagem opcional.

## Estados globais e integrações

- `ProfileState.isVerified`
  - controla bloqueios e CTAs de verificação.

- `HomeState.selectedCategory`
  - permite que telas de categoria influenciem filtro da Home.

- `SearchAlertState.alerts`
  - armazena alertas ativos.
  - realiza `matchTerm` no texto de novos anúncios.

- `NotificationsState.items`
  - recebe notificações geradas por:
    - match de alerta de busca
    - nova candidatura em vaga

- `JobApplicationsState.items`
  - armazena candidaturas enviadas pelo fluxo de empregos.

## Busca semântica (resumo técnico)

Implementada em `SemanticSaleSearch`:
- normaliza acentos/case
- aplica tokenização
- mapeia tokens para categorias
- pondera intenção de:
  - preço baixo (`barato`, `oferta`, etc.)
  - proximidade (`perto`, `bairro`, etc.)
- retorna lista ordenada por score + resumo explicativo da busca

## Estrutura relevante

- `lib/app.dart`: tema, rotas e shell principal
- `lib/screens/`: todas as telas
- `lib/state/`: estados globais com `ValueNotifier`
- `lib/data/`: dados mock
- `lib/search/semantic_search.dart`: motor de busca semântica

## Observações

- Projeto atualmente orientado a dados mockados (sem backend real).
- Alguns botões representam integração futura (pagamentos, eventos, etc.), mas já possuem fluxo visual e feedback de UX.
