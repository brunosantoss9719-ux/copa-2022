# TESTING

## Smoke
godot --headless --path . --import
godot --headless --path . --script tests/smoke.gd

Verifica:
- Main.tscn carrega e instancia;
- pelo menos cinco evidências existem;
- source_id resolve no ledger;
- Puzzle 1 aceita a ordem correta e recusa a errada;
- Puzzle 2 aceita o conjunto correto e recusa classificação errada;
- save/load preserva evidência e flags mínimas.

## Export Windows
godot --headless --path . --export-release "Windows x86_64" dist/linha-de-sombra-copa-2022.exe

## Validação humana pendente
Legibilidade dos hotspots, conforto do áudio, parallax/câmera, navegação por controle e ritmo dos puzzles.
