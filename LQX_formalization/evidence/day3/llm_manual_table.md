# Day3 DeepSeek 手动采样结果表

| # | 局面 | 模型原样答案 | 结果 | 分类 | 说明 |
|---|---|---|---|---|---|
| 01 | anchor | Qg7 | 正确，一步将杀 | ✅ | canonical prompt form = Qg7 |
| 02 | anchor+黑兵 | Qg6 | 合法但非将军/将杀 | C | IsCheckmate false |
| 03 | 棋盘A | Ra5 | 两步强制杀失败 | T | 黑方 Kb1 / Ra3 两应手后均无 mate-in-1 |
| 04 | Ka3 分支 | Qxa1 | 棋理正确但 SAN 不规范 | S1 | canonical prompt form = Qa1 |
| 05 | Kb1 分支 | Qb2 | 将军但非将杀 | C | IsCheckmate false |
| 06 | Rb2 分支 | Qxa1 | 非法着法 | C | Python IllegalMoveError；Lean failed to make move |
| 07 | 低升变 | exf1=Q | 合法且将军，但非将杀 | C | canonical SAN exf1=Q+；正确解为低升变 |
| 08 | 后排升变 | c8=Q | 正确，一步将杀 | ✅ | canonical prompt form = c8=Q |
| 09 | 后排杀 | Re1 | 正确，一步将杀 | ✅ | canonical prompt form = Re1 |
| 10 | 吃过路兵题 | Qh4 | 合法但非将军/将杀 | C | IsCheckmate false |
| 11 | 闷杀 | Qf7 | 四步内无强制杀 | C | 独立强制搜索 FALSE，2931 nodes |
| 12 | 死路判断 | Qb2 | 错误；该局面无一步杀 | C | ALL_MATE_IN_1_MOVES=[]，正确回答应为 NONE |

## 分类统计

✅ 正确：3 / 12 = 25.0%

S1：1 / 12 = 8.3%

S2：0 / 12 = 0%

C：7 / 12 = 58.3%

T：1 / 12 = 8.3%

## 说明

- S1/S2/C/T 不混成单一错误率。
- 第04题棋理正确但不是规范 SAN，因此属于 S1。
- 第07题虽存在 Chess.lean 接口问题，但标准 SAN 侧也证明它不是将杀，因此主分类为 C，而非 S2。
- 第03题由 Lean 的 2 个未解 goals 与 python-chess 的两条逃脱分支交叉确认。
- 第12题由穷举确认不存在任何一步杀，因此正确回答应为 NONE。
