# TESTING

## Smoke canônico
```bash
godot --headless --path . --import
godot --headless --path . --scene res://tests/Smoke.tscn
```

Valida carregamento da Main, EvidenceDB/source IDs, soluções corretas/incorretas dos dois puzzles e round-trip básico de save/load.

## Flow probe
```bash
godot --headless --path . --scene res://tests/FlowProbe.tscn
```

Percorre a orquestração real da cena:
1. inicia novo jogo;
2. registra as seis evidências;
3. preenche e valida a cronologia;
4. percorre as três etapas da reconstrução;
5. classifica alegação/decisão/ficção;
6. confirma relatório final, slice_complete e save.

## Export Windows
```bash
godot --headless --path . --export-release "Windows x86_64" dist/linha-de-sombra-copa-2022.exe
```

## Última validação automática
Commit de software/build: `73796c7f7d99a6ad1b30e8e849288e3c89639ef6`.
- Validate run 35518660928: sucesso.
- `SMOKE_OK`: sucesso.
- `FLOW_OK`: sucesso.
- Build Windows run 35518660807: sucesso.
- Artifact: `linha-de-sombra-0.1.0-73796c7`.

## Validação humana pendente
Legibilidade dos hotspots, conforto do áudio, parallax/câmera, navegação por controle e ritmo/sensação dos puzzles.
