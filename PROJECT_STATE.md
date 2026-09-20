# PROJECT_STATE

## Snapshot
Versão: 0.1.0
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Target: Windows x86_64
Commit de software/build validado: 73796c7f7d99a6ad1b30e8e849288e3c89639ef6

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
- smoke canônico e flow probe ponta a ponta;
- workflows de validação/build Windows.

## Fatos usados
O slice usa somente claims espelhados em SOURCES.md. A sala, a investigadora e o rascunho interno são FICÇÃO_DRAMÁTICA.

## Validação automática confirmada
Validate run 35518660928: SUCCESS.
Build Windows run 35518660807: SUCCESS.
Smoke: SMOKE_OK.
Flow probe: FLOW_OK — abertura → novo jogo → seis evidências → cronologia → reconstrução 3/3 → classificação factual → relatório final → save.

## Build
Artifact: linha-de-sombra-0.1.0-73796c7
Artifact ID: 10607757057
Tamanho do ZIP: 38.970.471 bytes
SHA-256 do artifact: 53a3a7166cf5cd3b55410f867488a318dd4ad1cca96c12d457f3ab54bd081aad
Retenção observada: até 04/10/2026.
Build produzida a partir do commit 73796c7f7d99a6ad1b30e8e849288e3c89639ef6.

## Correções/fortalecimento de CI
1. AudioManager tipado explicitamente para ficar warning-clean na Godot 4.7.2.
2. Smoke roda como cena do projeto, preservando autoloads.
3. FlowProbe.tscn percorre programaticamente o caminho crítico completo antes de liberar a exportação Windows.

## Limitação humana
A automação confirma funcionamento lógico/runtime, mas não mede conforto do áudio, legibilidade visual percebida, sensação do controle, ritmo ou qualidade subjetiva das deduções.

## Próxima ação canônica
Playtest humano da build 0.1.0 no Windows, registrando em 09 — PLAYTESTS E PROBLEMAS apenas problemas observáveis. Se não houver bloqueador, iniciar o próximo incremento documental do Caso 1 sobre a origem/encadeamento da expressão “Copa 2022”.
