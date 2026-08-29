import Chess.Basic
import Chess.Tactics
import Chess.Widgets

/-
  D1 取证：逼和反例
  分支：main（未修复的 ForcedWin 定义）
  日期：2026-08-26
-/

-- ① 交叉验证：同一批棋子，白先走 Qg7 是真将杀。
--    这条能证通 = 棋盘摆对了、着法解析正常。
theorem cross_check_real_mate :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♚]║
      ║▓▓░░▓▓░░▓▓♔}▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░♕]░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  with_panel_widgets [ForcedWinWidget]
  move "Qg7"
  checkmate

#print axioms cross_check_real_mate



-- ② 核心：逼和局面本身。轮到黑方走，黑方 0 种合法走法、且未被将军，
--    按棋规是【和棋】。旧定义却判白方必胜。
theorem false_win_on_stalemate :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♚}║
      ║▓▓░░▓▓░░▓▓♔]▓▓░░║
      ║░░▓▓░░▓▓░░▓▓♕]▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  with_panel_widgets [ForcedWinWidget]
  opponent_move

#print axioms false_win_on_stalemate


-- ③ 可达性：白方从①那个局面走一步 Qg6，就落进②那个逼和局面。
-- 注意：这条定理的陈述是真的，假的是这条证明路径。
theorem reachable_from_anchor :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♚]║
      ║▓▓░░▓▓░░▓▓♔}▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░♕]░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  with_panel_widgets [ForcedWinWidget]
  move "Qg6"
  opponent_move

#print axioms reachable_from_anchor


-- ④ 控制变量：把逼和局面加一个黑兵 a7，其它一格不动。
--    FEN: 7k/p4K2/6Q1/8/8/8/8/8 b - - 1 1
--    黑方从 0 种应手变成【恰好 2 种】(a6 / a5)，两条都被 Qg7# 杀死。
--    所以这个局面白方是【真的】必胜 —— 旧定义在这里给的答案是对的。
--    意义：漏洞只在"对手 0 种合法走法"这个边界处发生。
--    分支：main（旧定义）
theorem true_win_with_pawn :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♚}║
      ║♟]░░▓▓░░▓▓♔]▓▓░░║
      ║░░▓▓░░▓▓░░▓▓♕]▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  with_panel_widgets [ForcedWinWidget]
  opponent_move
  all_goals first
    | (move "Qg7"; checkmate)
    | (simp; move "Qg7"; checkmate)
    | exact ne_of_beq_false rfl

#print axioms true_win_with_pawn


-- ⑤ Qh2 陷阱：
--    白棋若改走 1.Qh2+，黑方有 4 种应手，白棋只能一步杀掉其中 2 条：
--        1...Ka3 → Ra5#      ✅
--        1...Kb1 → Re1#      ✅
--        1...Ka1 → 无一步杀   ❌
--        1...Rb2 → 无一步杀   ❌
--    所以 "1.Qh2+ Ka3 2.Ra5#" 这条答案本身每一步合法、终局确实将杀，
--    但它没有覆盖黑方的全部应手。
--
--    ⚠️ 这里被否掉的是“这个两步杀答案”，不是 Qh2 这步棋本身。
--       ForcedWin 不限深度，剩下两个 goal 只是不能用一步 move + checkmate 关掉。
--    分支：main
theorem qh2_trap :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♕]║
      ║♟]░░▓▓░░▓▓░░▓▓░░║
      ║♔}▓▓♘]▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░♖]░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓♜]▓▓░░▓▓░░▓▓░░║
      ║♚]▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  with_panel_widgets [ForcedWinWidget]
  move "Qh2"
  opponent_move
  rotate_left
  move "Ra5"
  checkmate
  rotate_left
  move "Re1"
  checkmate


-- ⑥ Re2 扇出正面证明：
--    同一个棋盘 A，白方走正确首着 1.Re2+。
--    黑方恰好 3 种应手：
--      1...Ka3 → Qa1#
--      1...Kb1 → Qh1#
--      1...Rb2 → Q×b2#
--
--    与 qh2_trap 对照：
--    Qh2+ 后有 4 个分支且给定两步答案漏掉 2 条；
--    Re2+ 后 3 个分支可以全部由 Lean 关闭。
theorem win_via_Re2 :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♕]║
      ║♟]░░▓▓░░▓▓░░▓▓░░║
      ║♔}▓▓♘]▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░♖]░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓♜]▓▓░░▓▓░░▓▓░░║
      ║♚]▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  with_panel_widgets [ForcedWinWidget]
  move "Re2"
  opponent_move
  all_goals first
    | (move "Qa1"; checkmate)
    | (move "Qh1"; checkmate)
    | (move "Q×b2"; checkmate)

#print axioms win_via_Re2
