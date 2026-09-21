# PROJECT_STATE

## Snapshot
Versão: 0.3.0
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Target: Windows x86_64
Commit de software/build validado: f37634f300367aec5a106b2a86279f2d12bb7c60

## Estado implementado
- sala investigativa lateral 2.5D com três alas progressivas;
- movimentação por teclado e controle;
- doze evidências data-driven com source/status;
- Puzzle 1: cronologia documental;
- reconstrução curta no espaço da sala;
- Puzzle 2: classificação factual;
- Puzzle 3: rastro documental de “Copa 2022”;
- Puzzle 4: individualização de status processual;
- save/load compatível com saves anteriores;
- áudio procedural;
- Smoke e FlowProbe cobrindo o caminho completo;
- CI/build Windows.

## Arquivo III — Individualização
O Arquivo III é liberado somente após o Puzzle 3. Ele usa duas decisões oficiais e uma nota ficcional de método para testar uma regra: o rótulo de grupo não substitui o resultado individual de cada pessoa em cada etapa processual. A nota ficcional pode orientar a leitura, mas não é aceita como prova judicial.

## Fatos usados
Claims ativos: LS-F001 a LS-F010.
Novos no 0.3:
- LS-F009: decisão de 20/05/2025 em que a Primeira Turma recebeu a denúncia contra dez acusados e rejeitou acusações contra outros dois militares.
- LS-F010: resultado de 18/11/2025 em que nove dos dez réus foram condenados e um foi absolvido por insuficiência de provas.
Os cartões de interface continuam explicitamente dramatizados; o resultado jurídico vem das fontes institucionais.

## Validação automática confirmada
Validate run 35549567654: SUCCESS.
Build Windows run 35549567628: SUCCESS.
Smoke: sucesso — Main, 12 evidências/source IDs, quatro puzzles e save/load.
FlowProbe: sucesso — primeira ala → cronologia → reconstrução → classificação → Arquivo II → rastro documental → Arquivo III → individualização → relatório final → save.
Também valida que a nota ficcional não é aceita como prova judicial.

## Build
Artifact: linha-de-sombra-0.3.0-f37634f
Artifact ID: 10617813527
Tamanho do ZIP: 38.985.164 bytes
SHA-256: 27d9ba4707bd79a8e00d96976d759cd6635fa8600997fc255a63429e1282a9e1
Retenção observada: até 05/10/2026.
Build produzida a partir do commit f37634f300367aec5a106b2a86279f2d12bb7c60.

## Incidente de validação
A primeira execução 0.3 falhou apenas porque o FlowProbe herdou uma asserção da 0.2 que exigia todas as evidências após a segunda ala. Com a terceira ala, esse ponto correto é 9/12. O teste foi corrigido para verificar 9 após o Arquivo II e 12 após o Arquivo III; a reexecução passou integralmente.

## Limitação humana
Ainda falta playtest humano para legibilidade percebida, sensação do controle, conforto do áudio e qualidade subjetiva/ritmo dos quatro puzzles.

## Próxima ação canônica
Playtest humano da build 0.3.0 no Windows. Sem bloqueadores, pesquisar o próximo bloco documental do Caso 1 antes de qualquer nova evidência; novo fato político/processual exige claim no ledger.
