# PR #10 语义修复笔记

## 1. 旧定义的问题

旧版 `ForcedWin.Opponent` 的逻辑是：

“如果对手的每一种合法应手之后，我方都仍然 `ForcedWin`，那么当前局面也是 `ForcedWin`。”

形式上：

`(∀ vm ∈ valid_moves p, ForcedWin p.turn.other vm.snd) → ForcedWin p.turn.other p`

问题在于，当：

`valid_moves p = ∅`

也就是对手根本没有合法应手时，“对所有合法应手……”是空集上的全称量词，会平凡为真（vacuous truth）。

因此，逼和局面可能被旧 `ForcedWin` 错误接受为白方必胜。

---

## 2. PR #10 的真实修复

我们实际查看 `Chess/Basic.lean` 的 diff 后确认，PR #10 给 `Opponent` 新增了一个前提：

`valid_moves p ≠ ∅`

即：使用 `Opponent` 规则时，必须额外证明对手至少真的存在一种合法走法。

修复后的核心逻辑是：

`(∀ vm ∈ valid_moves p, ForcedWin p.turn.other vm.snd) → valid_moves p ≠ ∅ → ForcedWin p.turn.other p`

真实 diff 中没有“或者对手已经被将军”这一支。

“无合法着法且被将军”的情况由单独的 `Checkmate` 规则处理。

---

## 3. main / pr10 实验结果

| 定理 | main（旧定义） | pr10（修复版） |
|---|---|---|
| `cross_check_real_mate` | ✅ `[propext]` | ✅ `[propext]` |
| `true_win_with_pawn` | ✅ `[propext]` | ✅ `[propext]` |
| `false_win_on_stalemate` | ✅ 错误接受逼和 | ❌ `unsolved goals` |
| `reachable_from_anchor` | ✅ | ❌ `unsolved goals` |

在 pr10 上，两个失败证明都会留下：

`⊢ valid_moves ... ≠ ∅`

而逼和局面实际上满足：

`valid_moves ... = ∅`

所以这个目标无法证明。

---

## 4. 控制变量实验

逼和局面：

`7k/5K2/6Q1/8/8/8/8/8 b - - 1 1`

黑方 0 种合法着法，而且没有被将军，所以是和棋。

只增加一个黑兵 a7：

`7k/p4K2/6Q1/8/8/8/8/8 b - - 1 1`

黑方恰好有 2 种应手：`a5`、`a6`。

两条之后白方都可以 `Qg7#` 将杀。

因此两个棋盘只差一个黑兵：

- 逼和局面：`valid_moves = ∅`
- 加兵局面：`valid_moves ≠ ∅`

在 pr10 上，加兵局面的新增 goal 可以由：

`exact ne_of_beq_false rfl`

关闭，而逼和局面的同一个 goal 无法关闭。

所以漏洞被精确定位在“对手合法应手集合为空”这个边界情况。

---

## 5. 一个重要的路径对照

`cross_check_real_mate` 和 `reachable_from_anchor` 使用的是同一个初始棋盘。

区别只在证明路径：

- `cross_check_real_mate`：走 `Qg7`，直接将杀 → pr10 ✅
- `reachable_from_anchor`：走 `Qg6`，进入逼和 → pr10 ❌

所以 pr10 否掉的不是“这个初始局面白方必胜”这个命题，而是走 `Qg6` 进入逼和的这条证明路径。

---

## 6. 项目口径

不能说“我们发现了一个 bug”。

源码中已经有 FIXME，社区也已经存在 PR #10。

更准确的说法是：

这是一个已知的语义漏洞。我们没有修改底座，而是把这个已有问题转化成了一组可以重复检查的形式化实验：

1. 旧定义能够成功证明的逼和反例；
2. `#print axioms` 审计；
3. 只增加一个黑兵的控制变量；
4. main / pr10 的对照实验；
5. 对 PR #10 真实源码修改的核对。

原始 diff 和实验日志统一保存在：

`evidence/day2/`