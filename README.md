
# 🎲 Dice Summons - Game Design Document (GDD)

> ⚠️ **Atenção:** Este projeto está em **desenvolvimento ativo**. As mecânicas, regras e sistemas descritos neste documento estão sujeitos a alterações, ajustes e melhorias ao longo do processo.

---

## 📜 Visão Geral

**Dice Summons** é um jogo de tabuleiro digital competitivo, baseado em turnos, onde dois jogadores usam dados para disputar território, invocar criaturas e atacar o núcleo inimigo.

Inspirado em jogos de tabuleiro e no mini-game *"Dungeon Dice Monsters"* do anime *Yu-Gi-Oh!*, o projeto busca combinar estratégia, sorte e gestão de recursos.

> 🔧 **Status:** Projeto em fase de desenvolvimento, com mecânicas, sistemas e regras ainda sendo implementados e testados.

---

## 🕹️ Mecânicas Principais

* 🎲 **Uso de Dados:**
  Os jogadores possuem uma coleção de dados. A cada turno, rolam dados para acumular pontos de diferentes tipos (**Invocação**, **Movimento** e **Energia**) que serão usados para realizar ações.

* 🧠 **Estratégia de Terreno:**
  O posicionamento dos dados não só invoca criaturas, mas também gera caminhos exclusivos que os jogadores usam para mover suas unidades no tabuleiro.

* ⚔️ **Disputa Territorial:**
  O objetivo é construir um caminho até o núcleo inimigo e atacá-lo. Após **5 ataques bem-sucedidos**, o jogador vence.

* 🔮 **Sistema de Mana Aleatória:**
  A rolagem dos dados gera diferentes tipos de pontos, exigindo que o jogador se adapte à sorte e pense estrategicamente em cada turno.

* 🌟 **Criaturas e Magias Únicas:**
  Cada criatura possui atributos próprios, magias exclusivas e custo de energia variável.

---

## 🎯 Objetivo

* Formar um caminho até o núcleo inimigo.
* Atacar o núcleo até atingir **5 pontos de dano**.

---

## 🔥 Fluxo de Gameplay

1. **Início do Turno:**

   * Rolar dados para gerar pontos (**Invocação**, **Movimento**, **Energia**).
   * Escolher **1 dado entre 3 sorteados** da coleção (os outros retornam).

2. **Fase de Ação:**
   Gastar pontos para realizar ações:

   * 🧠 Invocar criaturas (usando um dado, que também cria caminho no tabuleiro).
   * 🚶‍♂️ Mover criaturas.
   * ⚔️ Atacar com criaturas ou usar magias.

3. **Finalizar Turno:**

   * Passa a vez para o oponente.

---

## 🧠 Regras Importantes

* 🔺 **Limite de Colocação:**
  Não é permitido posicionar dados acima do ponto mais alto no eixo **Y** dos seus próprios caminhos.

  * Caso não haja caminho formado ainda, o limite é a linha **4 no eixo Y**.

* ☠️ **Descarte:**
  Quando uma criatura é destruída, ela é enviada para a **zona de descarte**.

---

## 🏹 Summons

Cada criatura possui:

* **Custo de Invocação:** Pontos necessários para invocar.
* **Dano de Ataque:** Dano base em ataques diretos.
* **Magias:**

  * Custam pontos de **Energia**.
  * Podem afetar **inimigos**, **aliados** ou a **própria criatura**.

---

## ✨ Magias

* Magias podem ser:

  * Ofensivas ⚔️
  * Defensivas 🛡️
  * De suporte ✨
  * De manipulação de terreno 🧠

---

## 🎮 Controles - PC

| Ação       | Tecla             |
| ---------- | ----------------- |
| Movimentar | W A S D / ↑ ↓ ← → |
| Confirmar  | Enter             |

---

## 🔍 Referências

* 🎲 *Yu-Gi-Oh! Dungeon Dice Monsters* (Episódios 48 e 49 - Duel Monsters)
* 🎲 Jogos de tabuleiro tradicionais

---

## 🚧 Status do Desenvolvimento

> Este projeto encontra-se em desenvolvimento.
> ✅ Algumas funcionalidades já foram implementadas.
> 🔧 Outras estão em fase de teste, ajustes ou desenvolvimento ativo.

### Tarefas em Andamento:

* Atualizar movimentação das unidades
* Implementar restrição da área de colocação dos dados
* Refinar o sistema de posicionamento dos dados
* Desenvolver o sistema de popular summons

---

## 💡 Observações Finais

Este documento representa a visão atual do projeto e serve como referência para seu desenvolvimento. Todos os elementos aqui descritos podem ser modificados, ajustados ou expandidos conforme o projeto evolui.

---
