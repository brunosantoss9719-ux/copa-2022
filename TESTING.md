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

Percorre o caminho 0.2:
1. novo jogo;
2. seis evidências da primeira ala;
3. cronologia;
4. reconstrução 3/3;
5. classificação factual;
6. desbloqueio da segunda ala;
7. três novas evidências;
8. puzzle de rastro documental;
9. relatório final e save.

## Export Windows
```bash
godot --headless --path . --export-release "Windows x86_64" dist/linha-de-sombra-copa-2022.exe
```

## Última validação automática
Commit: `d35fc99277f13d3dd5a63f034c499cdf23785de4`.
- Validate run 35541790873: sucesso.
- Smoke: sucesso.
- FlowProbe: sucesso.
- Build Windows run 35541790892: sucesso.
- Artifact: `linha-de-sombra-0.2.0-d35fc99`.

## Validação humana pendente
Legibilidade dos hotspots, conforto do áudio, parallax/câmera, navegação por controle, rolagem do quadro e ritmo dos três puzzles.
