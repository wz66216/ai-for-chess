# AI for Chess · 国际象棋战术题形式化

> **团队仓库说明**
>
> 本目录保存 LQX 的“国际象棋战术题形式化”子项目核心新增成果快照。
> 完整、可直接使用 Lake / Lean 复现的 Chess.lean 开发仓库位于：
> https://github.com/Mrsokhub/Chess.lean
>
> 本目录没有复制完整 Chess.lean 上游底座，因此这里主要用于组内查看代码、实验结果和研究思路；完整 Lean 编译复现请使用上述独立仓库。


> AI for Math 暑期学校 · 数学形式化 / 创造性形式化验证  
> Lean 4.15.0 + dwrensha/Chess.lean + Python / python-chess

---

## 1. 我在做什么

本项目研究的主题是：

**国际象棋战术题形式化——形式语言验证与直接计算验证的对比。**

我们把一个具体的国际象棋断言，例如：

> “在这个局面中，白方走某一步可以强制获胜。”

分别交给两种验证方式。

### 直接计算验证

使用 Python 的 `python-chess`，沿答案作者给出的具体变化逐步检查：

- 每一步是否合法；
- 最终局面是否为将杀；
- 部分实验中进一步进行有限深度搜索和分支穷举。

### 形式化验证

使用 Lean 4 和 `dwrensha/Chess.lean` 中的 `ForcedWin`。

与只检查一条给定棋路不同，Lean 中的证明过程会按照形式化棋规展开对手的合法应手，并要求需要覆盖的分支都被证明。

本项目的核心问题不是：

> “Lean、Stockfish、Python 或大语言模型谁更聪明？”

而是：

> **不同验证方式分别能提供什么保证，以及各自会在哪里失效？**

目前得到的核心结论是：

> **直接计算验证可以证明一条给定路径确实走得通，但可能漏掉答案作者没有写出的其他对手应手；形式化验证能够强制暴露未覆盖的分支，但它只能保证证明忠实于形式定义，并不能自动保证这个定义本身忠实于真实棋规。**

---

## 2. 项目基于什么

本项目基于开源 Lean 国际象棋项目：

- `dwrensha/Chess.lean`
- Lean 4.15.0
- Mathlib
- Python
- `python-chess`

本项目**没有修改 Chess.lean 上游核心实现**。

例如以下原始核心文件均保持不变：

- `Chess/Basic.lean`
- `Chess/Tactics.lean`
- `Chess/Fen.lean`
- `Chess/Examples.lean`

本项目采用的方式是：

> 保留原 Chess.lean 底座，在外围新增独立的形式化实验、Python 验证器和 evidence 证据层。

---

## 3. 项目整体结构

目前与本课题直接相关的主要文件如下：

```text
Chess.lean/
│
├── AI_FOR_CHESS_README.md
├── NOTES.md
│
├── Chess/
│   └── Puzzles/
│       ├── Stalemate.lean
│       ├── Lemmas.lean
│       └── LLMTest.lean
│
├── tools/
│   ├── verify_line.py
│   └── verify_llm.py
│
└── evidence/
    ├── day2/
    └── day3/
```

其中三个 Lean 文件分别承担不同功能。

### `Chess/Puzzles/Stalemate.lean`

Day1–Day2 的主要实验文件，包括：

- 真将杀控制组；
- 逼和反例；
- 从白胜局面进入逼和的路径；
- 加黑兵控制变量；
- Qh2 漏分支实验；
- Re2 正确强制两步杀实验。

### `Chess/Puzzles/Lemmas.lean`

Day3 的形式引理文件。

把 Day1–Day2 观察到的现象进一步写成可由 Lean 检查的正式命题，例如：

- 逼和局面没有合法着法；
- 逼和不是将死；
- 将死局面同样没有合法着法；
- 将死与逼和在语义上不同；
- 空的合法应手集合会使旧 ForcedWin.Opponent 中的全称条件平凡成立。

### `Chess/Puzzles/LLMTest.lean`

Day3 的 LLM 实验文件。

将 DeepSeek 对国际象棋局面的第一次原始回答送入 Lean，检查模型给出的着法能否形成相应的形式化证明或触发明确的失败结果。

## 4. Day1：复现逼和边界问题

Day1 首先回答：

旧版 ForcedWin 是否真的会在逼和边界产生语义问题？

主要完成：

- `cross_check_real_mate`
- `false_win_on_stalemate`
- `reachable_from_anchor`
- `#print axioms` 审计
- `NOTES.md` 实验记录

其中一个关键局面满足：

- 黑方合法着法 = 0
- 黑王没有被将军

按照国际象棋规则，这是：

> stalemate

即逼和，结果应为和棋。

但是旧版 ForcedWin 的形式定义可以接受这个局面作为白方获胜证明的一部分。

与此同时，相应成功定理的：

```lean
#print axioms
```

没有出现：

- `sorryAx`

因此这里的问题不是：

> “Lean 没有真正检查证明。”

而是：

Lean 正确地执行了当前形式定义，但这个定义在零合法应手的边界上没有充分区分 stalemate 与 checkmate。

## 5. Day2：用版本对照和控制变量定位原因

Day2 不再只展示一个反例，而是进一步回答：

这个现象到底是偶然，还是可以精确定位到定义中的某个边界？

### main / PR #10 对照

实验同时使用：

- main：旧版 ForcedWin
- pr10：上游社区 PR #10 的修复版本

pr10 是通过上游 PR 获取的对照版本，本项目没有在该分支自行开发新的核心实现。

同一组实验分别在两个版本上运行。

结果表明：

- 真正的将杀控制组仍然可以通过；
- 加入一个黑兵，使黑方存在合法应手后，真实获胜局面仍然可以通过；
- 原来的逼和假证明在 PR #10 上会留下新的未完成目标：

```lean
valid_moves ... ≠ ∅
```

因此问题被进一步定位到：

对手合法应手集合为空，即 `valid_moves = ∅` 的边界。

## 6. 路径验证 ≠ 强制策略验证

棋盘 A 使用局面：

```text
7Q/p7/K1N5/4R3/8/1r6/k7/8
```

这是本项目用来比较“单路径验证”和“强制策略验证”的主要实验局面。

### 正确策略：`Re2`

白方首着：

```text
Re2+
```

Lean 展开黑方三个应手。

三个分支随后分别使用不同的杀着关闭，包括：

- `Qa1#`
- `Qh1#`
- `Q×b2#`

最终所有需要证明的分支均得到关闭。

这说明：

当给出的确实是一份完整强制策略时，Lean 能够把全部分支完整证明。

### 对照实验：`Qh2`

考虑具体变化：

```text
1.Qh2+ Ka3 2.Ra5#
```

这条具体棋路：

- 每一步合法；
- 最终确实为将杀。

因此 python-chess 单路径验证器会给出：

✅ 通过

但是把同一个首着 Qh2 送入 Lean 后，形式验证会展开黑方全部合法应手。

黑方实际存在四个应手。

给定的这份两步答案只能关闭其中部分分支，最终留下两个未解决的：

```lean
⊢ ForcedWin Side.white ...
```

因此得到对照：

- 直接计算验证：✅ 给定路径成立
- 形式化验证：    ❌ 给定证书没有覆盖全部分支

这里需要特别说明：

这并不意味着我们证明了 Qh2 是输棋。

ForcedWin 本身不限制搜索深度。

本实验真正说明的是：

一条具体杀棋路径成立，不等于已经给出了一份覆盖全部对手应手的强制获胜证书。

## 7. 为什么逼和会得到“白胜证明”

旧版 ForcedWin.Opponent 的核心逻辑可以理解为：

对手的每一种合法应手之后，我都有继续获胜的方法。

形式上具有类似：

```lean
∀ m ∈ valid_moves(p), ...
```

的全称结构。

但是如果：

```lean
valid_moves(p) = ∅
```

那么这个全称条件会自动成立。

这就是逻辑中的：

vacuous truth，即空集上的全称量词平凡为真。

因此：

没有任何合法应手

本身不能区分：

- checkmate

与：

- stalemate

因为两者都可能满足：

```lean
valid_moves = ∅
```

真正的国际象棋语义还需要考虑：

当前一方是否处于被将军状态。

Day3 的 Lemmas.lean 对这一点进行了独立的形式化验证。

## 8. Day3：把实验现象升级为形式引理

Day3 新增：

### `Chess/Puzzles/Lemmas.lean`

其中完成 6 条核心 theorem：

```lean
stalemate_no_legal_moves
stalemate_not_checkmate
mate_no_legal_moves
mate_is_checkmate
stalemate_ne_checkmate
stalemate_vacuous_hypothesis
```

这些引理不通过修改争议中的 ForcedWin 定义来得到结论，而是直接从已经存在的棋局状态和棋规相关定义出发。

因此项目从：

“程序跑出了一个异常现象”

进一步升级为：

“用独立的形式命题解释这个异常为什么发生。”

## 9. Axioms 审计

Day2 的 5 条成功定理与 Day3 的 6 条形式引理，共计：

11 条成功 theorem

其：

```lean
#print axioms
```

结果均为：

```text
[propext]
```

未发现：

- `sorryAx`
- `Lean.ofReduceBool`

同时项目自己的 `Chess/Puzzles/*.lean` 中没有使用：

- `sorry`
- `native_decide`

因此这些成功结果不是通过 sorry 或 native_decide 绕过证明得到的。

## 10. DeepSeek → Lean 实验

Day3 对 DeepSeek 进行了 12 个国际象棋局面的受控测试。

实验规则包括：

- 每道题开启新的 DeepSeek 对话；
- 使用固定 prompt；
- 使用快速模式；
- 关闭深度思考；
- 关闭智能搜索；
- 只保存模型第一次回答；
- 不因为回答错误而重新提问；
- 不修改模型回答中的字符；
- 不提前告诉模型 Chess.lean 自己的记谱方言。

随后实验流程为：

```text
DeepSeek 第一次 raw answer
            ↓
       原样记录
            ↓
        Lean move "..."
            ↓
      形式验证结果
            ↓
 python-chess 独立交叉验证
```

所有原始回答和后续验证结果均保存在 evidence 中。

## 11. DeepSeek 12 题最终结果

最终分类如下：

| 类别 | 含义 | 数量 |
|---|---|---:|
| ✅ | 正确 | 3 |
| S1 | 输出格式 / 标准 SAN 问题 | 1 |
| S2 | 标准 SAN 正确，但与 Chess.lean 记谱接口不一致 | 0 |
| C | 棋理错误 | 7 |
| T | 着法本身可走，但没有形成题目要求的完整强制策略 | 1 |

总计：

12

本项目没有把所有失败简单合并成一个“错误率”。

原因是：

模型棋理错误、标准记谱格式问题、工具接口不兼容、强制策略中的分支遗漏，是不同层次的问题。

特别地，本次真实 12 题实验中：

```text
S2 = 0
```

没有为了让分类表显得完整而人为制造一个 S2 样本。

## 12. 与组内 ChessExplain / AI for Chess 平台的关系

组内 ChessExplain 平台可以提供包括：

- 国际象棋棋盘交互；
- Stockfish 评估；
- Stockfish Multi-PV 候选线路；
- DeepSeek 战术复盘；
- Opening Book；
- Alpha-Beta / White-box Search；
- 搜索树可视化；
- FEN 局面编辑等功能。

本形式化子项目承担的是另一层工作：

```text
ChessExplain / Stockfish / LLM / 棋题答案
                    ↓
                给出断言
                    ↓
        Lean / Python 验证层
                    ↓
      分析这个断言得到了什么保证
```

因此二者不是简单的竞争关系。

可以将其理解为：

```text
断言 / 搜索 / 解释层
        +
形式化验证 / 交叉验证层
```

需要说明：

Day3 的 12 个 DeepSeek 正式实验样本使用的是 DeepSeek 官方网页中的受控独立对话，而不是 ChessExplain 平台生成的结构化输出。

这是为了尽量保存模型在没有其他引擎、schema 或字符串后处理干预情况下的第一次原始回答。

## 13. 两个 Python 验证器

### `tools/verify_line.py`

用于 Day2 的单路径直接计算验证。

输入大致为：

```text
FEN + 一条具体棋路
```

它逐步检查：

- 着法是否合法
- 终局是否 checkmate / stalemate

这个实验展示了：

一条棋路本身完全合法并最终将杀，不等于该首着已经构成强制获胜策略。

### `tools/verify_llm.py`

用于 Day3 的 12 题 LLM 交叉验证。

其功能包括：

- 标准 SAN 解析；
- 合法性检查；
- check / checkmate / stalemate 判断；
- mate-in-2 分支检查；
- 有限深度强制杀搜索；
- mate-in-1 穷举；
- canonical SAN 审计。

它与 Lean 验证共同组成：

```text
LLM 输出
   ↓
Lean 形式验证
   +
python-chess 独立交叉验证
```

## 14. 当前项目最重要的三个结论

### 结论 1：单路径正确 ≠ 强制策略完整

直接计算验证能够回答：

> “你给我的这一条变化是否真的走得通？”

形式化验证进一步追问：

> “对手还有没有你没有列出来的其他合法应手？”

因此二者的关键差别不是简单的：

> “谁算得更准？”

而是：

谁对对手应手清单的完整性负责。

### 结论 2：形式证明正确 ≠ 形式定义天然正确

Lean 内核能够严格保证：

证明满足当前形式定义。

但是如果形式定义遗漏了真实规则中的边界条件，Lean 不会自动替我们修改这个定义。

因此：

一个经过内核验证的证明，其可靠性依赖于形式化规范本身是否正确表达了想要验证的语义。

### 结论 3：形式化验证也可以用于审计定义

本项目中逼和实验的价值不仅是得到一个异常结果，而是进一步建立：

```text
反例
  ↓
版本对照
  ↓
控制变量
  ↓
形式引理
  ↓
axioms 审计
```

最终把问题精确定位到：

```text
valid_moves = ∅
```

与旧 ForcedWin.Opponent 中 vacuous truth 的关系。

## 15. 如何复现实验

### Lean 形式引理

运行：

```bash
lake env lean Chess/Puzzles/Lemmas.lean
```

预期：

- 6 条 theorem 成功
- 无 error

### DeepSeek / Lean 测试文件

运行：

```bash
lake env lean Chess/Puzzles/LLMTest.lean
```

预期：

- 0 error

### Day1–Day2 主实验

运行：

```bash
lake env lean Chess/Puzzles/Stalemate.lean
```

这里需要特别注意：

该文件预期会出现 unsolved goals。

原因不是代码损坏。

文件中故意保留：

```lean
qh2_trap
```

作为“给定策略没有覆盖全部应手”的失败实验。

预期整体结果为：

- 5 条成功 theorem
- `qh2_trap` 留下 2 个 unsolved goals

这两个 unsolved goals 本身就是实验结果。

### Python 单路径验证

运行：

```bash
python3 tools/verify_line.py
```

### DeepSeek 批量交叉验证

运行：

```bash
python3 tools/verify_llm.py
```

## 16. Evidence

项目并没有只保存最后结论或截图。

主要实验原始输出位于：

- `evidence/day2/`
- `evidence/day3/`

其中包括：

- main 实验输出；
- PR #10 对照输出；
- PR diff；
- axioms 审计；
- Lean 原始错误；
- DeepSeek 第一次 raw answers；
- Python 交叉验证结果；
- DeepSeek 最终分类表。

此外：

`NOTES.md`

保存整个项目按 Day1、Day2、Day3 推进的实验与开发记录。

## 17. 当前进度

截至 Day3：

- Day1  ✅ 逼和反例复现

- Day2  ✅ main / PR #10 对照
  ✅ 控制变量实验
  ✅ Re2 正确强制策略
  ✅ Qh2 漏分支实验
  ✅ Python 单路径验证

- Day3  ✅ stalemate / checkmate 形式引理
  ✅ axioms 总审计
  ✅ DeepSeek 12 题受控实验
  ✅ Lean 验证
  ✅ Python 交叉验证
  ✅ S1 / S2 / C / T 分层分类

- Day4  → 最终报告
  → PPT
  → 截图整理
  → 答辩与复现验收

Day3 最终主分支 commit 为：

```text
c5e28b8
D3: stalemate lemmas, axioms audit, and DeepSeek error classification
```

## 18. 项目的研究演化

整个项目可以概括为三个阶段：

```text
Day1
找到一个可复查反例
        ↓
stalemate 被旧 ForcedWin 接受

Day2
通过版本对照和控制变量定位原因
        ↓
main vs PR #10
valid_moves = ∅
vacuous truth
        ↓
同时建立
单路径验证 vs 全分支验证对照

Day3
把原因提升为形式引理
        ↓
stalemate ≠ checkmate
        ↓
再把全分支验证思想迁移到
DeepSeek 国际象棋回答的系统分析
```

因此本项目不是简单地：

> “用 Lean 证明几道国际象棋题。”

而是逐步完成：

反例构造 → 对照实验 → 形式化解释 → LLM 输出验证。

## 19. 一句话总结

本项目不是让 Lean 替代棋力引擎，而是研究：当一个程序、引擎、大语言模型或棋题答案提出“这一步可以强制获胜”时，我们究竟可以怎样验证这个断言，以及不同验证方式分别能够保证什么。
