# PROJECT_STATE

## Snapshot
Versão: 0.4.0
Repo: brunosantoss9719-ux/copa-2022
Branch: main
Toolchain: Godot 4.7.2-stable / GDScript
Targets validados: Windows x86_64 e Android arm64
Commit de software/build validado: d3d0ea845e9ac853bb7f3452955368de6da893f0

## Estado implementado
- sala investigativa lateral 2.5D com quatro arquivos/alas progressivos;
- 16 evidências data-driven com source/status;
- cinco puzzles + reconstrução;
- save/load compatível;
- áudio procedural;
- controles teclado/controle;
- controles touch Android em paisagem: esquerda, direita, examinar/reconstruir e quadro;
- painéis, botões, ScrollContainer e OptionButtons operáveis por toque;
- Smoke e FlowProbe do caminho completo;
- CI Windows + Android.

## Android
Preset: Android APK.
Arquitetura: arm64-v8a.
Orientação: paisagem.
Render: GL Compatibility.
ETC2/ASTC habilitado para export Android.
APK de playtest usa assinatura debug gerada no CI; não é build de Play Store.

O primeiro Android export falhou apenas na etapa de empacotamento porque ETC2/ASTC não estava habilitado. Após adicionar `rendering/textures/vram_compression/import_etc2_astc=true`, a reexecução exportou e verificou o APK com apksigner.

## Fatos usados
Claims ativos continuam LS-F001 a LS-F013.
Nenhum claim, diálogo factual ou solução narrativa foi alterado para o porte Android.

## Validação automática
Commit: d3d0ea845e9ac853bb7f3452955368de6da893f0.
Validate run 35581278719: SUCCESS.
Build Windows run 35581278726: SUCCESS.
Build Android run 35581279290: SUCCESS.
Smoke e FlowProbe: SUCCESS.
APK: exportado e verificado por apksigner.

## Builds
Windows: linha-de-sombra-0.4.0-d3d0ea8.
Android: linha-de-sombra-android-0.4.0-d3d0ea8.
Android Artifact ID: 10630735963.
Android ZIP artifact: 28.102.023 bytes.
Android artifact SHA-256: c6b1c460bcf7f380880d3e718ddc7b73051bb2824b53609c6443ecffb5550100.
Retenção observada: até 05/10/2026.

## Limitação humana
O APK foi validado por exportação/assinatura e testes headless do jogo, mas ainda precisa de playtest físico Android para toque, escala visual, safe areas, desempenho e áudio no aparelho.

## Próxima ação canônica
Playtest humano Android da build `linha-de-sombra-android-0.4.0-d3d0ea8`. Registrar problemas concretos de toque/escala/layout e corrigi-los antes de qualquer nova expansão de conteúdo.
