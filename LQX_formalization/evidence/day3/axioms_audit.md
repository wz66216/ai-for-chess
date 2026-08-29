# `#print axioms` 审计表（Day3 整理）

## 这张表在回答什么

一个 Lean 定理“编译通过”并不自动说明证明过程没有绕过证明义务，因此这里统一检查成功定理的 `#print axioms` 结果。

重点检查：

1. 是否出现 `sorryAx`；
2. 是否因为 `native_decide` 出现 `Lean.ofReduceBool`；
3. 是否依赖其他额外公理。

本项目尤其需要检查 `false_win_on_stalemate`：
它在标准国际象棋语义下把逼和局面判成了白方必胜，但我们需要确认，这个结果不是由 `sorry` 或 `native_decide` 人为制造出来的。

## 全部定理

| 文件 | 定理 | 实验/棋规含义 | axioms | `sorryAx` | `ofReduceBool` |
|---|---|---|---|---|---|
| Stalemate.lean | `cross_check_real_mate` | ✅ 真将死正例 | `[propext]` | 无 | 无 |
| Stalemate.lean | `false_win_on_stalemate` | ❌ 标准棋规下该局面是逼和，不是白胜 | `[propext]` | 无 | 无 |
| Stalemate.lean | `reachable_from_anchor` | ✅ anchor 本身确实是白胜局面，但旧定义也允许通过 `Qg6` 进入逼和后继续构造 `ForcedWin` | `[propext]` | 无 | 无 |
| Stalemate.lean | `true_win_with_pawn` | ✅ 真必胜对照 | `[propext]` | 无 | 无 |
| Stalemate.lean | `win_via_Re2` | ✅ 棋盘 A 的正确强制将杀策略 | `[propext]` | 无 | 无 |
| Stalemate.lean | `qh2_trap` | —— 故意证不完整，不属于成功定理 | 不在成功 axioms 列表中 | —— | —— |
| Lemmas.lean | `stalemate_no_legal_moves` | ✅ 逼和局面没有合法着法 | `[propext]` | 无 | 无 |
| Lemmas.lean | `stalemate_not_checkmate` | ✅ 逼和局面不是将死 | `[propext]` | 无 | 无 |
| Lemmas.lean | `mate_no_legal_moves` | ✅ 真将死局面同样没有合法着法 | `[propext]` | 无 | 无 |
| Lemmas.lean | `mate_is_checkmate` | ✅ 对照局面确实是将死 | `[propext]` | 无 | 无 |
| Lemmas.lean | `stalemate_ne_checkmate` | ✅ 0 合法着法并不足以区分逼和与将死 | `[propext]` | 无 | 无 |
| Lemmas.lean | `stalemate_vacuous_hypothesis` | ✅ 空应手集合使旧 `Opponent` 的全称前提平凡成立 | `[propext]` | 无 | 无 |

## 关键结论

1. `false_win_on_stalemate` 与正常真定理的 axioms 完全一样，均只有 `[propext]`。
   因此这个现象不是由 `sorry` 或其他跳过证明义务的方法造成的。

2. 成功定理中没有 `sorryAx`。
   即没有通过 `sorry` 跳过证明。

3. 成功定理中没有 `Lean.ofReduceBool`。
   即没有使用 `native_decide` 把编译器计算结果作为额外可信来源。

4. `qh2_trap` 不属于成功定理。
   它故意留下未解决的对手分支，因此不应出现在成功 axioms 列表中。

5. 本实验支持的结论是：
   **Lean 内核忠实地验证“证明是否符合形式定义”，但不会自动判断这个形式定义是否忠实于标准国际象棋语义。**

   因此这里的问题不是“Lean 证明错了”，而是旧 `ForcedWin.Opponent` 的定义允许逼和局面通过空集上的全称量词获得一份形式上的必胜证明。

## 原始输出

见：

`evidence/day3/axioms_all_raw.txt`
