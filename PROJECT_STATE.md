# PROJECT_STATE

## Snapshot
Versão: 0.4.0
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Target: Windows x86_64
Commit de software/build validado: 2ec4ed10e8926e12074e63cf2531173c7ac81f1e

## Estado implementado
- sala investigativa lateral 2.5D com quatro arquivos/alas progressivos;
- 16 evidências data-driven com source/status;
- Puzzle 1: cronologia documental;
- reconstrução curta;
- Puzzle 2: classificação factual;
- Puzzle 3: rastro documental de “Copa 2022”;
- Puzzle 4: individualização de status processual;
- Puzzle 5: contraditório — tese defensiva ≠ decisão judicial;
- save/load compatível com saves anteriores;
- áudio procedural;
- Smoke e FlowProbe do caminho completo;
- CI/build Windows.

## Arquivo IV — Contraditório
O Arquivo IV é liberado após a individualização. Ele introduz TESE_DE_DEFESA no caminho crítico. O jogador monta dois pares documentais: o que a defesa sustentou e o que o tribunal decidiu depois, sem avaliar politicamente ou juridicamente qual tese “é melhor”.

Pares atuais:
- Bernardo: defesa pediu absolvição e questionou força/contexto das provas; resultado judicial registrou condenação.
- Márcio: defesa sustentou participação limitada e comparação com acusações rejeitadas; resultado judicial registrou condenação após reenquadramento para crimes menos graves do que os apontados na denúncia.

## Fatos usados
Claims ativos: LS-F001 a LS-F013.
Novos no 0.4:
- LS-F011 — TESE_DE_DEFESA: sustentação da defesa de Bernardo.
- LS-F012 — TESE_DE_DEFESA: sustentação da defesa de Márcio.
- LS-F013 — DECISÃO_JUDICIAL: resultado com reenquadramento de condutas de Márcio e Ronald.
As teses permanecem atribuídas às defesas; o resultado permanece separado como decisão judicial.

## Validação automática
Validate run 35579286186: SUCCESS.
Build Windows run 35579286166: SUCCESS.
Smoke: 16 evidências/source IDs, cinco puzzles e save/load.
FlowProbe: Arquivo I → II → III → IV → Puzzle 5 → relatório final → save.
A validação também rejeita inversão entre tese defensiva e resultado judicial.

## Build
Artifact: linha-de-sombra-0.4.0-2ec4ed1
Artifact ID: 10629756056
Tamanho do ZIP: 38.991.253 bytes
SHA-256: a6d2d942f7ffbec06aaccaee5d90f41e46c84fceaddc2cb79cd6194c2aeb7a8f
Retenção observada: até 05/10/2026.
Build produzida a partir do commit 2ec4ed10e8926e12074e63cf2531173c7ac81f1e.

## Limitação humana
Ainda não existe playtest humano da build 0.4.0. Automação não valida conforto, legibilidade percebida ou diversão/ritmo.

## Próxima ação canônica
Playtest humano da build 0.4.0 no Windows. Sem bloqueadores, o próximo trabalho não deve simplesmente adicionar outra ala: avaliar estrutura e variedade mecânica com base no playtest; qualquer novo conteúdo factual exige claim no ledger.
