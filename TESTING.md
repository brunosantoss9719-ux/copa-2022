# TESTING

## Smoke canônico
```bash
godot --headless --path . --import
godot --headless --path . --scene res://tests/Smoke.tscn
```

Valida Main.tscn, 16 evidências/source IDs, soluções corretas/incorretas dos cinco puzzles e save/load. Inclui teste específico para impedir que tese defensiva e decisão judicial sejam invertidas.

## Flow probe
```bash
godot --headless --path . --scene res://tests/FlowProbe.tscn
```

Percorre o caminho 0.4:
1. novo jogo e Arquivo I;
2. cronologia + reconstrução + classificação;
3. Arquivo II e rastro documental;
4. Arquivo III e individualização;
5. liberação física/visual do Arquivo IV;
6. coleta de quatro peças do contraditório;
7. foco automático no Puzzle 5;
8. pareamento de tese e resultado para Bernardo e Márcio;
9. relatório final e save.

## Export Windows
```bash
godot --headless --path . --export-release "Windows x86_64" dist/linha-de-sombra-copa-2022.exe
```

## Última validação automática
Commit: `2ec4ed10e8926e12074e63cf2531173c7ac81f1e`.
- Validate run 35579286186: sucesso.
- Smoke: sucesso.
- FlowProbe: sucesso.
- Build Windows run 35579286166: sucesso.
- Artifact: `linha-de-sombra-0.4.0-2ec4ed1`.

## Validação humana pendente
Legibilidade das quatro alas, navegação por controle, rolagem do quadro, conforto do áudio e, principalmente, se os cinco puzzles mantêm sensação de dedução em vez de repetição de formulários.
