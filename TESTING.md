# TESTING

## Smoke canônico
```bash
godot --headless --path . --import
godot --headless --path . --scene res://tests/Smoke.tscn
```

O smoke roda dentro da árvore normal do projeto para que os autoloads existam no mesmo contexto usado pelo jogo.

Verifica:
- `Main.tscn` carrega e instancia;
- pelo menos cinco evidências existem;
- cada `source_id` resolve no ledger;
- Puzzle 1 aceita a ordem correta e recusa a errada;
- Puzzle 2 aceita o conjunto correto e recusa classificação errada;
- save/load preserva evidência e flags mínimas.

## Export Windows
```bash
godot --headless --path . --export-release "Windows x86_64" dist/linha-de-sombra-copa-2022.exe
```

## Última validação automática
Commit de software/build: `e0bb85a15450c9cf788477c557a7ce25a8555c21`.

- Validate: sucesso.
- Smoke: sucesso.
- Build Windows x86_64: sucesso.
- Artifact: `linha-de-sombra-0.1.0-e0bb85a`.

## Validação humana pendente
Legibilidade dos hotspots, conforto do áudio, parallax/câmera, navegação por controle e ritmo dos puzzles.
