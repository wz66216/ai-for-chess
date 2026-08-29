# Lean 错误类型原文记录

## 1. 成功通过

成功定理的典型输出：

`depends on axioms: [propext]`

例如：

`'true_win_with_pawn' depends on axioms: [propext]`

---

## 2. 棋理 / 分支覆盖不全

`qh2_trap` 中，Qh2+ 后黑方有 4 种应手，
给出的两步杀方案只能关闭其中 2 个分支。

典型报错：

`error: unsolved goals`

剩余目标类型：

`ForcedWin Side.white ...`

含义：着法本身可以合法执行，但证明没有覆盖对手的全部应手。

---

## 3. 着法字符串解析失败

故意使用：

`move "Zz9"`

实际 Lean 报错原文：

`error: failed to parse move`

含义：着法字符串本身无法被 Chess.lean 的 move parser 解析。

---

## 4. PR #10 新前提未满足

在 pr10 上，逼和反例会出现：

`error: unsolved goals`

并留下：

`⊢ valid_moves ... ≠ ∅`

含义：修复后的 `ForcedWin.Opponent` 要求对手至少存在一种合法应手，
而逼和局面实际满足 `valid_moves = ∅`，因此证明失败。

---

## 备注

- `qh2_trap`：策略覆盖不全
- `failed to parse move`：着法字符串解析失败
- `valid_moves ... ≠ ∅`：PR #10 新增非空性条件未满足
- 成功定理应为 `[propext]`
- 最终 Lean 文件不得残留 `sorry`

---

## Day3 实际遇到的错误类型

Day3 第6段 `Chess/Puzzles/LLMTest.lean` 原始答案进入 Lean 后，实际遇到以下错误类型。

### `IsCheckmate ... is false`

真实原文摘要：

`error: tactic 'decide' proved that the proposition ... IsCheckmate ... is false`

对应题号：

- 02：`Qg6`
- 05：`Qb2`
- 10：`Qh4`

### `failed to make move`

真实原文摘要：

`error: failed to make move`

对应题号：

- 06：`Qxa1`
- 07：`exf1=Q`

### `unsolved goals`

真实原文摘要：

`error: unsolved goals`

对应题号：

- 03：`Ra5` 后 `opponent_move` 留下 2 个 goals
- 11：`Qf7` 后 `opponent_move` 留下 36 个 goals

备注：Day3 没有伪造或记录不存在的 `failed to parse move`。
