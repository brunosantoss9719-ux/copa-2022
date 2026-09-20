# PROJECT_STATE

## Snapshot
Versão: 0.1.0
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Target: Windows x86_64
Commit de software/build validado: e0bb85a15450c9cf788477c557a7ce25a8555c21

## Estado implementado
- sala investigativa lateral 2.5D com parallax procedural;
- movimentação por teclado e controle;
- seis evidências data-driven com source/status;
- caderno/quadro funcional;
- Puzzle 1: cronologia documental;
- reconstrução curta no espaço da sala;
- Puzzle 2: classificação factual;
- conclusão narrativa provisória;
- save/load versionado;
- áudio procedural: ambiência, passos, UI e descoberta;
- smoke tests e workflows de validação/build Windows.

## Fatos usados
O slice usa somente claims espelhados em SOURCES.md. A sala, a investigadora e o rascunho interno são FICÇÃO_DRAMÁTICA.

## Validação automática confirmada
Validate run 35518386903: SUCCESS.
Build Windows run 35518386912: SUCCESS.
Smoke canônico: res://tests/Smoke.tscn, executado dentro do contexto normal do projeto.
Cobertura do smoke: Main.tscn, EvidenceDB/source IDs, soluções corretas/incorretas dos dois puzzles e round-trip básico de save/load.

## Build
Artifact: linha-de-sombra-0.1.0-e0bb85a
Artifact ID: 10607512143
Tamanho do ZIP: 38.966.655 bytes
SHA-256 do artifact: 08f8b6e6cfd845ee422fb0735f15d4fcc5d078b52f7c411fb2fb41f01b3f33aa
Retenção observada: até 04/10/2026.
Build produzida a partir do commit e0bb85a15450c9cf788477c557a7ce25a8555c21.

## Correções de CI desta sessão
1. Tipagem explícita no AudioManager para ficar warning-clean na Godot 4.7.2.
2. Smoke deixou de rodar como script isolado e passou a rodar como cena do projeto, preservando autoloads.

## Limitação humana
A composição visual, conforto do áudio, legibilidade dos hotspots, navegação por controle e ritmo dos puzzles ainda precisam de playtest humano.

## Próxima ação canônica
Executar um playtest humano completo da build 0.1.0 no Windows e registrar em 09 — PLAYTESTS E PROBLEMAS apenas problemas observáveis do caminho crítico, priorizando legibilidade, controle, áudio e sensação das duas deduções.
