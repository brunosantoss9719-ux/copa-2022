# PROJECT_STATE

## Snapshot
Versão: 0.2.0
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Target: Windows x86_64
Commit de software/build validado: d35fc99277f13d3dd5a63f034c499cdf23785de4

## Estado implementado
- sala investigativa lateral 2.5D com parallax procedural e segunda ala desbloqueável;
- movimentação por teclado e controle;
- nove evidências data-driven com source/status;
- Puzzle 1: cronologia documental;
- reconstrução curta no espaço da sala;
- Puzzle 2: classificação factual;
- Puzzle 3: rastro documental de “Copa 2022”;
- distinção jogável entre investigação, recebimento da denúncia, posição da acusação e julgamento;
- conclusão narrativa 0.2;
- save/load compatível com saves 0.1;
- áudio procedural;
- smoke e FlowProbe cobrindo o caminho completo;
- CI/build Windows.

## Fatos usados
O 0.2 acrescenta LS-F006 a LS-F008 ao ledger. O jogo trata como alegação oficial o conteúdo atribuído à PF e à PGR, e como decisão judicial os marcos processuais/julgamento documentados. A sala e a investigadora permanecem FICÇÃO_DRAMÁTICA.

## Validação automática confirmada
Validate run 35541790873: SUCCESS.
Build Windows run 35541790892: SUCCESS.
Smoke: sucesso — Main, 9 evidências/source IDs, três puzzles e save/load.
FlowProbe: sucesso — abertura → primeira ala → cronologia → reconstrução → classificação → segunda ala → três novas evidências → rastro documental → relatório final → save.

## Build
Artifact: linha-de-sombra-0.2.0-d35fc99
Artifact ID: 10615515801
Tamanho do ZIP: 38.974.796 bytes
SHA-256: 609aad97198c2cb0e2d15d848b21f9bf50a5b41fcc97bfca3d2d64a655c6cdcc
Retenção observada: até 04/10/2026.
Build produzida a partir do commit d35fc99277f13d3dd5a63f034c499cdf23785de4.

## Limitação humana
Ainda falta playtest humano para legibilidade percebida, conforto do áudio, sensação do controle, rolagem do quadro e ritmo dos três puzzles.

## Próxima ação canônica
Playtest humano da build 0.2.0 no Windows. Se não houver bloqueador, o próximo incremento é melhorar apresentação/ritmo da segunda ala e iniciar o próximo bloco documental do Caso 1 somente após nova verificação factual.
