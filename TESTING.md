# TESTING

## Smoke
```bash
godot --headless --path . --import
godot --headless --path . --scene res://tests/Smoke.tscn
```

## FlowProbe
```bash
godot --headless --path . --scene res://tests/FlowProbe.tscn
```

## MobileTouchProbe
```bash
godot --headless --path . --scene res://tests/MobileTouchProbe.tscn
```

Valida:
1. criação dos controles mobile;
2. ◀ pressiona/libera `move_left`;
3. ▶ pressiona/libera `move_right`;
4. Examinar contextual registra evidência e abre painel;
5. Quadro abre por touch;
6. controles retornam após fechar modal.

## Última validação
Commit: `032a7d943cf1fc1939b4ab391f0065acbdebef90`.
- Validate run 35583074787: SUCCESS.
- Build Windows run 35583074692: SUCCESS.
- Build Android run 35583074710: SUCCESS.
- Smoke: SUCCESS.
- FlowProbe: SUCCESS.
- MobileTouchProbe: SUCCESS.
- APK export: SUCCESS.
- apksigner: SUCCESS.
- GitHub Release: SUCCESS.

## Android signing
`~/.android/debug.keystore` é restaurado/salvo via Actions cache com chave `linha-de-sombra-android-debug-keystore-v1`.
A 0.4.0 anterior usou chave efêmera e pode não atualizar in-place para 0.4.1.

## Playtest humano Android pendente
Verificar instalação/upgrade, toque contínuo, interação, Quadro, rolagem, OptionButtons, safe area/notch, escala, áudio, desempenho e sensação dos puzzles.
