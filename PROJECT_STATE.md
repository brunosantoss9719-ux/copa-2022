# PROJECT_STATE

## Snapshot
Versão: 0.5.0
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Targets validados: Windows x86_64 e Android arm64
Último commit de software/build validado: 242258c0df8c13393218368880cae000973b4c84

## Estado implementado
- quatro setores investigativos, 16 evidências e cinco problemas de dedução;
- exploração lateral 2.5D, reconstrução espacial, dicas, save/load e áudio procedural;
- teclado/controle + touch Android;
- Windows x86_64 e APK Android arm64;
- Smoke, FlowProbe e MobileTouchProbe;
- CI Windows + Android e APK publicado em GitHub Release.

## Reforma 0.5.0 — jogabilidade
A 0.5.0 substitui o antigo quadro com vários OptionButtons empilhados por uma investigação focada em uma pergunta ativa por vez.

Fluxo atual:
- explorar o espaço e localizar peças;
- examinar a peça sem receber a solução do puzzle;
- abrir a hipótese ativa;
- selecionar cartões na bandeja e encaixá-los em slots de raciocínio;
- classificar autoridade documental com carimbos;
- voltar à sala para confrontar a cronologia em três projeções espaciais;
- liberar novos setores e repetir o ciclo com nova pergunta;
- concluir o contraditório separando tese de defesa de resultado judicial.

O painel de evidência não revela mais o factual_status das peças da triagem antes da etapa de classificação.

## Reforma 0.5.0 — visual
O cenário procedural foi recomposto em setores com identidade própria:
- Setor A: triagem, mesa longa, monitor e arquivo;
- Setor B: arquivo processual com estantes;
- Setor C: mesa de comparação e painéis;
- Setor D: dois painéis contrapostos para tese e resultado.

Também foram redesenhados:
- silhueta da investigadora;
- evidências, com formas distintas por natureza documental;
- projeções da reconstrução;
- portais de acesso entre setores;
- janelas, chuva, profundidade arquitetônica, piso e primeiro plano.

A arte continua procedural/provisória. CI não mede qualidade estética; a próxima rodada deve ser guiada por leitura visual e sensação real de jogo, não por expansão de conteúdo.

## Fatos usados
Claims ativos permanecem LS-F001 a LS-F013.
Nenhum claim político/processual, resultado judicial ou tese de defesa foi alterado na 0.5.0.

## Validação automática
Commit: 242258c0df8c13393218368880cae000973b4c84.
Validate run 35585327343: SUCCESS.
Build Windows run 35585327331: SUCCESS.
Build Android run 35585327567: SUCCESS.
Smoke: SUCCESS.
FlowProbe: SUCCESS.
MobileTouchProbe: SUCCESS.
Export Windows: SUCCESS.
Export Android: SUCCESS.
apksigner: SUCCESS.
GitHub Release: SUCCESS.

## Builds
Windows artifact: `linha-de-sombra-0.5.0-242258c`.
Windows artifact ID: 10632310441.
Windows artifact ZIP SHA-256: 91d0160a340500f43002223861e2f50e1f63ba1cef3bce15ba34a59d2d72806b.

Android Actions artifact: `linha-de-sombra-android-0.5.0-242258c`.
Android artifact ID: 10632006968.
Android artifact ZIP SHA-256: 45a11dec269638394c63bc97853827ee0acf89180188c6d996f87269bfbfe323.

Android Release:
- tag: `android-0.5.0-242258c`
- release ID: 392844173
- asset: `Linha-de-Sombra-Copa-2022-Android-242258c.apk`
- asset ID: 578740529
- APK: 28.352.403 bytes
- APK SHA-256: 233c637347141aa297b3ba4c51d6317503c3f0f4a64cea73331aafc438a61a50
- download direto: https://github.com/brunosantoss9719-ux/copa-2022/releases/download/android-0.5.0-242258c/Linha-de-Sombra-Copa-2022-Android-242258c.apk

## Feedback humano que motivou 0.5.0
A 0.4.1 foi considerada visualmente fraca e com jogabilidade sem sentido, especialmente porque o quadro se comportava como um formulário longo. A 0.5.0 é a resposta direta a esse problema e não uma expansão de conteúdo.

## Próxima ação canônica
Fazer um passe de qualidade sobre a 0.5.0 focado em composição, legibilidade, sensação de descoberta e qualidade dos puzzles. Corrigir o que ainda parecer genérico, feio, óbvio ou burocrático antes de criar novo arquivo/caso.
