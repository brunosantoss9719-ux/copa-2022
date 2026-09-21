# PROJECT_STATE

## Snapshot
Versão: 0.5.0 — quality pass
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Targets validados: Windows x86_64 e Android arm64
Último commit de software/build validado: 32b40c94ff67e32fe60cb8bc4c0fe4ac3bfedbd5

## Estado implementado
- quatro setores investigativos, 16 evidências e cinco problemas de dedução;
- exploração lateral 2.5D, reconstrução espacial, dicas, save/load e áudio procedural;
- quadro de hipótese com cartões, slots, carimbos e prévia de conteúdo;
- teclado/controle + touch Android;
- Windows x86_64 e APK Android arm64;
- Smoke, FlowProbe e MobileTouchProbe;
- CI Windows + Android e APK publicado em GitHub Release.

## Quality pass 0.5.0 — inferência
A revisão 32b40c9 aprofunda o loop sem adicionar conteúdo factual.

Mudanças:
- rótulos da bandeja agora são códigos neutros de arquivo, sem repetir a função/resultado da peça;
- selecionar um código abre uma prévia com título, fonte e resumo da evidência já examinada;
- a decisão passa a depender da leitura do conteúdo, não de correspondência verbal do botão;
- a cronologia usa três slots horizontais;
- o contraditório é apresentado em dois dossiês paralelos, Bernardo e Márcio;
- progresso do quadro mostra peças relevantes ao problema ativo;
- o FlowProbe bloqueia regressões em que rótulo ou aparência entreguem a solução.

## Quality pass 0.5.0 — anti-spoiler visual
Antes da classificação de autoridade, as peças da triagem compartilham silhueta e cor neutras.
Forma e cor específicas de alegação, decisão e ficção só aparecem depois de GameState.status_solved.
Isso corrige a pista visual involuntária da revisão anterior.

## Quality pass 0.5.0 — apresentação
- câmera ganhou look-ahead conforme direção de movimento;
- setores ganharam hierarquia de luz e áreas bloqueadas recuam para a sombra;
- investigadora usa silhueta mais gráfica/poligonal;
- interações ganharam sons procedurais distintos de papel, alfinete, carimbo e projetor;
- nenhum asset externo ou dependência nova foi adicionado.

## Fatos usados
Claims ativos permanecem LS-F001 a LS-F013.
Nenhum claim político/processual, resultado judicial ou tese de defesa foi alterado nesta revisão.

## Validação automática
Commit: 32b40c94ff67e32fe60cb8bc4c0fe4ac3bfedbd5.
Validate run 35588942756: SUCCESS.
Build Windows run 35588942672: SUCCESS.
Build Android run 35588942668: SUCCESS.
Smoke: SUCCESS.
FlowProbe: SUCCESS.
MobileTouchProbe: SUCCESS.
Export Windows: SUCCESS.
Export Android: SUCCESS.
apksigner: SUCCESS.
GitHub Release: SUCCESS.

FlowProbe também confirma:
- classificação visual não é revelada antes do puzzle;
- rótulos neutros não contêm termos que entreguem as respostas testadas;
- prévia da evidência fornece conteúdo suficiente para inferência;
- classificação visual aparece após a resolução.

MobileTouchProbe confirma também a abertura da prévia pelo cartão no quadro touch.

## Builds
Windows artifact: `linha-de-sombra-0.5.0-32b40c9`.
Windows artifact ID: 10633447809.
Windows artifact ZIP SHA-256: dc4bccd651c9003d858083600b460fd05ef29a4bd5c9022ca8bfbf19025e5ea2.

Android Actions artifact: `linha-de-sombra-android-0.5.0-32b40c9`.
Android artifact ID: 10633333053.
Android artifact ZIP SHA-256: 0df804ffc45c4cb5d691cb50c60be4f6d1e0508c7e202f069e09959f5405908b.

Android Release:
- tag: `android-0.5.0-32b40c9`
- release ID: 392867847
- asset: `Linha-de-Sombra-Copa-2022-Android-32b40c9.apk`
- asset ID: 578805453
- APK: 28.364.691 bytes
- APK SHA-256: 151557d803dc42b56346aac4e6dcbc01e22f93f9dbbad57e3d1c4054c4337cb1
- download direto: https://github.com/brunosantoss9719-ux/copa-2022/releases/download/android-0.5.0-32b40c9/Linha-de-Sombra-Copa-2022-Android-32b40c9.apk

## Limite da validação
Automação comprova parsing, fluxo crítico, ausência das regressões cobertas, touch e exportação. Não comprova por si só beleza, ritmo ou satisfação do puzzle.

## Próxima ação canônica
Avaliar a revisão 32b40c9 como produto, com foco em composição, legibilidade, ritmo e se os códigos neutros + prévia realmente exigem leitura/inferência. Corrigir somente problemas concretos observados antes de expandir conteúdo; Arquivo V continua bloqueado.
