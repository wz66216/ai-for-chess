## D1 2026-08-26

- 环境：Codespaces + Lean 4.15.0，lake build 成功
- cross_check_real_mate：✅
- false_win_on_stalemate：✅，逼和局面被旧 ForcedWin 证明为白方必胜
- reachable_from_anchor：✅
- axioms：三条定理均只依赖 [propext]，无 sorryAx / Lean.ofReduceBool
- 下一步：D2 在修正版定义上做对照，并完成控制变量实验和棋盘 A


## Day 2（2026-08-28）

### 环境
- GitHub Codespaces
- 主分支：`main`
- PR #10 对照分支：`pr10`
- `pr10` 来源：`git fetch upstream pull/10/head:pr10`
- upstream：`dwrensha/Chess.lean`

### 1. ForcedWin 逼和语义问题：main / pr10 对照

我们构造了四个 Lean 定理，并在旧版 `main` 和修复版 `pr10` 上运行同一组实验。

| 定理 | 棋规上的实际含义 | main | pr10 |
|---|---|---|---|
| `cross_check_real_mate` | 白方真实将杀 | ✅ `[propext]` | ✅ `[propext]` |
| `true_win_with_pawn` | 白方真实必胜，黑方有 2 种应手 | ✅ `[propext]` | ✅ `[propext]` |
| `false_win_on_stalemate` | 实际为逼和，不是白胜 | ✅ `[propext]`，旧定义错误接受 | ❌ 剩 `valid_moves ≠ ∅` |
| `reachable_from_anchor` | 命题本身为真，但 `Qg6` 这条证明路径进入逼和 | ✅ `[propext]` | ❌ 剩 `valid_moves ≠ ∅` |

PR #10 的真实核心修改是给 `ForcedWin.Opponent` 增加：

`valid_moves p ≠ ∅`

因此旧定义中“对手没有任何合法走法”时出现的空集全称量词问题被排除。

详细记录见：

- `evidence/day2/pr10_diff_notes.md`
- `evidence/day2/pr10_diff_Basic_lean.txt`
- `evidence/day2/pr10_output_4thm_v3.txt`

### 2. 控制变量实验

逼和局面：

`7k/5K2/6Q1/8/8/8/8/8 b - - 1 1`

黑方合法应手数为 0。

只增加一个黑兵 `a7`：

`7k/p4K2/6Q1/8/8/8/8/8 b - - 1 1`

黑方变为恰好 2 种合法应手：`a5`、`a6`，两条之后均可 `Qg7#`。

因此问题被精确定位在：

`valid_moves = ∅`

这一边界情况。

### 3. 棋盘 A：正确策略与陷阱策略

同一个棋盘 A 上：

| 定理 | 首着 | `opponent_move` 展开的分支数 | 结果 |
|---|---|---:|---|
| `win_via_Re2` | `Re2+` | 3 | ✅ 三条全部关闭 |
| `qh2_trap` | `Qh2+` | 4 | ❌ 只关闭 2 条，剩 2 个 goals |

`win_via_Re2` 的三条分支：

- `Ka3 → Qa1#`
- `Kb1 → Qh1#`
- `Rb2 → Q×b2#`

`qh2_trap` 中给定的两步答案只能覆盖：

- `Ka3 → Ra5#`
- `Kb1 → Re1#`

而 `Ka1`、`Rb2` 两条分支仍然存在，因此 Lean 留下 2 个 `ForcedWin` goals。

### 4. 直接计算验证 vs 形式验证

新增：

`tools/verify_line.py`

直接计算验证结果：

- `1.Re2+ Ka3 2.Qa1#` → ✅ 合法且终局将杀
- `1.Qh2+ Ka3 2.Ra5#` → ✅ 合法且终局将杀
- `1.Qh2+ Ka1` → ❌ 路线没有走完
- 棋盘 B `1.Qg6` → ⚠️ 实际为逼和

这说明：

单路径计算验证只能检查“给出的这一条线是否每步合法、终局是否将杀”，
而 Lean 的 `ForcedWin` 证明会要求覆盖对手的所有合法应手。

因此 `Qh2+ Ka3 Ra5#` 这条具体路线虽然本身完全正确，
但不能证明它是一条完整的强制两步杀策略。

### 5. axioms 审计

main 上成功证明的 5 个定理：

- `cross_check_real_mate`
- `false_win_on_stalemate`
- `reachable_from_anchor`
- `true_win_with_pawn`
- `win_via_Re2`

全部为：

`depends on axioms: [propext]`

没有 `sorryAx`，没有 `Lean.ofReduceBool`。

原始汇总：

`evidence/day2/main_axioms_all.txt`

### 6. 错误类型记录

已记录四类结果：

1. 成功：`depends on axioms: [propext]`
2. 分支覆盖不全：`error: unsolved goals`
3. 着法解析失败：`error: failed to parse move`
4. pr10 新前提未满足：`⊢ valid_moves ... ≠ ∅`

记录见：

`evidence/day2/error_strings.md`

### 7. Day 2 当前成果

- 完成逼和语义漏洞的 main / pr10 对照实验
- 完成只增加一个黑兵的控制变量
- 完成 `qh2_trap` 漏分支实验
- 完成 `win_via_Re2` 正面三分支证明
- 完成 Python 单路径计算验证器
- 完成 `#print axioms` 审计
- 完成错误类型与 PR diff 存证
- `Chess/Puzzles/Stalemate.lean` 中无 `sorry`

### Day 3 预留

- 从棋规层独立形式化“逼和不是将死”的引理
- 汇总更多测试局面
- 进一步整理自动分类与实验表格

### Day3 formal lemmas

- stalemate_no_legal_moves
- stalemate_not_checkmate
- mate_no_legal_moves
- mate_is_checkmate
- stalemate_ne_checkmate
- stalemate_vacuous_hypothesis

逼和与将死都可能具有 0 个合法着法；区别在于是否被将军。
旧 `ForcedWin.Opponent` 的全称前提在空 `valid_moves` 上会发生 vacuous truth。

### axioms audit

`Stalemate.lean` + `Lemmas.lean` 共 11 条成功 theorem：
全部 only `[propext]`。

无 `sorryAx`。
无 `Lean.ofReduceBool`。

### DeepSeek controlled test

12 个局面，每题新对话，第一次回答原样保存。

最终统计：

- 正确：3/12 = 25.0%
- S1：1/12 = 8.3%
- S2：0/12 = 0%
- C：7/12 = 58.3%
- T：1/12 = 8.3%

语法/格式错误与棋理错误不能混成一个错误率。

第03题 `Ra5`：
Lean 展开得到 2 个未完成分支；
python-chess 独立验证 `Kb1` / `Ra3` 后均没有 mate-in-1。

第04题 `Qxa1`：
棋理正确并能将杀，但规范 SAN 应为 `Qa1`，因此归 S1。

第07题 `exf1=Q`：
标准 SAN 合法，但不是将杀，因此主分类为 C。

第11题 `Qf7`：
独立强制搜索 2931 nodes，四步内强制将杀为 FALSE。

第12题 `Qb2`：
穷举 `ALL_MATE_IN_1_MOVES=[]`，正确回答应为 `NONE`。
