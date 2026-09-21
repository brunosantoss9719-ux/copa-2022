# TESTING

## Smoke canônico
```bash
godot --headless --path . --import
godot --headless --path . --scene res://tests/Smoke.tscn
```

Valida Main.tscn, doze evidências/source IDs, soluções corretas/incorretas dos quatro puzzles e save/load. Também verifica que a nota ficcional de método não pode ocupar um slot que exige prova judicial.

## Flow probe
```bash
godot --headless --path . --scene res://tests/FlowProbe.tscn
```

Percorre o caminho 0.3:
1. novo jogo e bloqueio inicial da Ala II;
2. seis evidências da primeira ala;
3. cronologia;
4. reconstrução 3/3;
5. classificação factual;
6. liberação do Arquivo II;
7. três evidências do rastro documental;
8. Puzzle 3;
9. liberação do Arquivo III;
10. três evidências da individualização;
11. foco automático no Puzzle 4;
12. individualização;
13. relatório final e save.

## Incidente corrigido
O primeiro FlowProbe 0.3 manteve uma asserção antiga que comparava as nove evidências coletadas até a Ala II com o total global. Como o 0.3 possui doze evidências, a asserção foi corrigida para 9 nesse ponto e 12 depois do Arquivo III.

## Export Windows
```bash
godot --headless --path . --export-release "Windows x86_64" dist/linha-de-sombra-copa-2022.exe
```

## Última validação automática
Commit: `f37634f300367aec5a106b2a86279f2d12bb7c60`.
- Validate run 35549567654: sucesso.
- Smoke: sucesso.
- FlowProbe: sucesso.
- Build Windows run 35549567628: sucesso.
- Artifact: `linha-de-sombra-0.3.0-f37634f`.

## Validação humana pendente
Legibilidade dos três arquivos/alas, conforto do áudio, parallax/câmera, navegação por controle, rolagem do quadro e sensação de dedução dos quatro puzzles.
