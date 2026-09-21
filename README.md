# Linha de Sombra — Copa 2022

Thriller investigativo 2.5D em Godot sobre reconstrução documental de acontecimentos ligados aos nomes públicos “Copa 2022” e “Punhal Verde e Amarelo”.

## Estado
Fatia vertical **0.4.1** em Godot 4.7.2-stable, GDScript, com Windows x86_64 como build de referência.

## Executar
1. Instale Godot 4.7.2-stable.
2. Abra `project.godot` ou rode `godot --path .`.
3. Teclado: A/D ou setas movem; E interage; Tab abre o quadro; H pede dica; Esc fecha painéis.
4. Controle: analógico/direcional move; A interage; Y abre o quadro; RB pede dica.

## Loop demonstrado
Explorar → observar → coletar → cruzar → reconstruir → formular hipótese → validar → atualizar o caso.

O 0.2 acrescenta uma segunda ala investigativa com um puzzle de proveniência documental: investigação → recebimento da denúncia → julgamento. Na 0.2.1, a ala permanece fisicamente bloqueada até ser liberada. A 0.3 acrescenta o **Arquivo III — Individualização**, em que o jogador usa decisões oficiais para derrubar generalizações sobre resultados processuais individuais. A 0.4 acrescenta o **Arquivo IV — Contraditório**, que obriga a parear teses de defesa com os resultados judiciais posteriores sem tratar uma categoria como substituta da outra.

## Princípios
- personagem jogável fictícia/composta da Polícia Federal;
- fatos reais com `source_id` e status factual auditável;
- reconstruções explicitamente dramatizadas;
- sem mecânica de execução ou otimização de violência política.

Consulte `PROJECT_STATE.md` para retomada e `SOURCES.md` para o espelho do ledger factual.

## Android

A versão 0.4.1 inclui preset Android APK e controles touch em paisagem: esquerda, direita, examinar/reconstruir e quadro. Os painéis e seletores continuam sendo operados por toque nativo da UI.

O CI gera um APK debug assinado para playtest fora da Play Store.

A 0.4.1 também adiciona MobileTouchProbe automatizado, assinatura debug persistente por cache do CI e publicação do APK em GitHub Release para download direto.


### Download Android direto — 0.4.1

https://github.com/brunosantoss9719-ux/copa-2022/releases/download/android-0.4.1-032a7d9/Linha-de-Sombra-Copa-2022-Android-032a7d9.apk
