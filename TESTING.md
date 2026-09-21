# TESTING

## Smoke canônico
```bash
godot --headless --path . --import
godot --headless --path . --scene res://tests/Smoke.tscn
```

Valida Main.tscn, 16 evidências/source IDs, cinco puzzles e save/load.

## FlowProbe
```bash
godot --headless --path . --scene res://tests/FlowProbe.tscn
```

Percorre o caminho completo 0.4 até o relatório final.

## Windows
Run: 35581278726 — SUCCESS.

## Android
Preset: `Android APK`.
Workflow: `.github/workflows/build-android.yml`.
Etapas:
1. Java 17;
2. Godot 4.7.2 + templates;
3. Android SDK/build-tools;
4. debug keystore efêmera no runner;
5. import + Smoke;
6. FlowProbe;
7. export debug APK;
8. `apksigner verify --verbose`;
9. upload do artifact.

Primeira tentativa Android: falhou somente porque ETC2/ASTC não estava habilitado.
Correção: `rendering/textures/vram_compression/import_etc2_astc=true`.

Validação final:
- Commit: `d3d0ea845e9ac853bb7f3452955368de6da893f0`.
- Validate run 35581278719: SUCCESS.
- Build Android run 35581279290: SUCCESS.
- Artifact: `linha-de-sombra-android-0.4.0-d3d0ea8`.
- Artifact ID: 10630735963.
- SHA-256 do artifact ZIP: `c6b1c460bcf7f380880d3e718ddc7b73051bb2824b53609c6443ecffb5550100`.

## Playtest humano Android pendente
Verificar: botões esquerda/direita, Examinar/Reconstruir, Quadro, toque em painéis/selects, rolagem, escala 16:9/20:9, safe areas, áudio, desempenho e instalação do APK.
