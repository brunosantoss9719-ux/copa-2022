# TESTING

## Smoke canônico
```bash
godot --headless --path . --import
godot --headless --path . --scene res://tests/Smoke.tscn
```

Valida Main.tscn, nove evidências/source IDs, soluções corretas/incorretas dos três puzzles e save/load.

## Flow probe
```bash
godot --headless --path . --scene res://tests/FlowProbe.tscn
```

Percorre o caminho 0.2.1:
1. inicia novo jogo;
2. tenta acessar a Ala II e confirma o bloqueio físico;
3. resolve primeira ala, cronologia, reconstrução e classificação;
4. confirma liberação física/visual da Ala II;
5. confirma a transição “ARQUIVO II”;
6. abre o quadro e confirma foco automático no Puzzle 3;
7. coleta as três evidências da segunda ala;
8. resolve o rastro documental;
9. confirma relatório final e save.

## Nota de temporização
O primeiro probe do polimento checou movimento e atualização visual antes do frame físico/_process correspondente e gerou falso negativo. O probe final aguarda o frame correto; o marco visual também é sincronizado imediatamente ao desbloquear a Ala II.

## Export Windows
```bash
godot --headless --path . --export-release "Windows x86_64" dist/linha-de-sombra-copa-2022.exe
```

## Última validação automática
Commit: `3c95f0bcb008ecdbadb08af6df8277f167f1940d`.
- Validate run 35542394710: sucesso.
- Smoke: sucesso.
- FlowProbe: sucesso.
- Build Windows run 35542394689: sucesso.
- Artifact: `linha-de-sombra-0.2.1-3c95f0b`.

## Validação humana pendente
Legibilidade dos hotspots e marco da ala, conforto do áudio, parallax/câmera, navegação por controle e ritmo dos três puzzles.
