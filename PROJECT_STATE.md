# PROJECT_STATE

## Snapshot
Versão: 0.2.1
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Target: Windows x86_64
Commit de software/build validado: 3c95f0bcb008ecdbadb08af6df8277f167f1940d

## Estado implementado
- sala investigativa lateral 2.5D com duas alas;
- movimentação por teclado e controle;
- nove evidências data-driven com source/status;
- Puzzle 1: cronologia documental;
- reconstrução curta no espaço da sala;
- Puzzle 2: classificação factual;
- Puzzle 3: rastro documental de “Copa 2022”;
- save/load compatível com saves 0.1;
- áudio procedural;
- smoke e FlowProbe cobrindo o caminho completo;
- CI/build Windows.

## Polimento 0.2.1
- a Ala II fica fisicamente inacessível até a conclusão do Puzzle 2;
- marco visual procedural “ARQUIVO II” indica acesso pendente/liberado;
- a liberação exibe uma transição curta de tela;
- ao abrir o quadro com o Puzzle 3 ativo, a rolagem foca automaticamente essa seção;
- nenhum claim, solução factual ou conteúdo político foi alterado.

## Fatos usados
Claims ativos permanecem LS-F001 a LS-F008. O 0.2.1 não muda o ledger factual nem o texto das evidências.

## Validação automática confirmada
Validate run 35542394710: SUCCESS.
Build Windows run 35542394689: SUCCESS.
Smoke: sucesso.
FlowProbe: sucesso, incluindo:
- bloqueio físico da Ala II antes do Puzzle 2;
- liberação física após o Puzzle 2;
- sincronização imediata do marco visual;
- exibição da transição ARQUIVO II;
- foco automático do Puzzle 3 no quadro;
- caminho completo até relatório final e save.

## Build
Artifact: linha-de-sombra-0.2.1-3c95f0b
Artifact ID: 10615397086
Tamanho do ZIP: 38.978.584 bytes
SHA-256: 595dba460355bcbefd28559aba52938f1c468041b245eb8301837d30c7a10666
Retenção observada: até 04/10/2026.
Build produzida a partir do commit 3c95f0bcb008ecdbadb08af6df8277f167f1940d.

## Incidente de validação
O primeiro FlowProbe do polimento falhou por checar o estado antes do frame físico/_process correto. O comportamento do jogo foi mantido e o teste foi corrigido para observar após o frame adequado. O marco visual também passou a sincronizar imediatamente no momento da liberação.

## Limitação humana
Ainda falta playtest humano para legibilidade percebida, conforto do áudio, sensação do controle e ritmo dos três puzzles.

## Próxima ação canônica
Playtest humano da build 0.2.1 no Windows. Sem bloqueadores, pesquisar e implementar o próximo bloco documental do Caso 1; qualquer novo fato político/processual exige claim novo no ledger antes do conteúdo.
