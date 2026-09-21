# PROJECT_STATE

## Snapshot
Versão: 0.4.1
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Targets validados: Windows x86_64 e Android arm64
Commit de software/build validado: 032a7d943cf1fc1939b4ab391f0065acbdebef90

## Estado implementado
- quatro arquivos/alas, 16 evidências e cinco puzzles;
- reconstrução, dicas, save/load e áudio procedural;
- teclado/controle + touch Android;
- APK Android arm64 em paisagem;
- Smoke, FlowProbe e MobileTouchProbe;
- CI Windows + Android;
- APK publicado como artifact e GitHub Release de download direto.

## Android 0.4.1
A 0.4.1 não altera claims, narrativa nem soluções dos puzzles. É um incremento de entrega e validação mobile.

MobileTouchProbe valida criação dos controles, movimento touch, Examinar contextual e Quadro.

Assinatura de playtest:
- o workflow usa cache do debug keystore com chave `linha-de-sombra-android-debug-keystore-v1`;
- a partir da 0.4.1, builds geradas com esse cache mantêm a mesma assinatura enquanto o cache persistir;
- a 0.4.0 anterior usou chave efêmera diferente e pode exigir desinstalação única antes da 0.4.1.

## Fatos usados
Claims ativos permanecem LS-F001 a LS-F013.
Nenhum conteúdo político/processual foi alterado na 0.4.1.

## Validação automática
Commit: 032a7d943cf1fc1939b4ab391f0065acbdebef90.
Validate run 35583074787: SUCCESS.
Build Windows run 35583074692: SUCCESS.
Build Android run 35583074710: SUCCESS.
Smoke: SUCCESS.
FlowProbe: SUCCESS.
MobileTouchProbe: SUCCESS.
apksigner: SUCCESS.
Publicação do GitHub Release: SUCCESS.

## Builds
Windows artifact: `linha-de-sombra-0.4.1-032a7d9`.
Windows artifact ID: 10630719434.
Windows artifact ZIP SHA-256: 2c6dc3dfff490816ead3974ec9a10144bc5cd1b3877e62c08d959cc716a56a91.

Android Actions artifact: `linha-de-sombra-android-0.4.1-032a7d9`.
Android artifact ID: 10630851907.
Android artifact ZIP SHA-256: ed033b4a7c5313b2668f9feca426b34114a366e0110360800c8ffba506500bdc.

Android Release:
- tag: `android-0.4.1-032a7d9`
- release ID: 392829087
- asset: `Linha-de-Sombra-Copa-2022-Android-032a7d9.apk`
- asset ID: 578700024
- APK: 28.336.019 bytes
- APK SHA-256: 177d3a11d1f3e36c336b42525b87921e7ef16ef9c0fffe97d56592138ce843b3
- download direto: https://github.com/brunosantoss9719-ux/copa-2022/releases/download/android-0.4.1-032a7d9/Linha-de-Sombra-Copa-2022-Android-032a7d9.apk

## Limitação humana
O APK ainda precisa de execução física no aparelho para validar ergonomia real, escala, safe areas, desempenho e áudio.

## Próxima ação canônica
Playtest humano Android da 0.4.1. Corrigir somente problemas observados no aparelho antes de expandir conteúdo.
