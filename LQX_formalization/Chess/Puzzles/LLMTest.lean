import Chess.Basic
import Chess.Tactics
import Chess.Widgets

/-
  D3：DeepSeek 手动测试
  规则：move "..." 里的字符串均为模型第一次原样输出，未做任何修改。
  第12题“死路判断”留到 Python 侧验证，不强行写成 Lean 一步杀定理。
-/

-- 01 DeepSeek raw: Qg7
-- Final classification: ✅
theorem llm_01 :
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
  move "Qg7"
  checkmate

-- 02 DeepSeek raw: Qg6
-- Final classification: C
-- Lean: IsCheckmate ... is false
/-
theorem llm_02 :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♚]║
      ║♟]░░▓▓░░▓▓♔}▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░♕]░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  move "Qg6"
  checkmate
-/

-- 03 DeepSeek raw: Ra5
-- Final classification: T
-- Lean: opponent_move -> 2 goals
-- Python: Kb1 / Ra3 后均无 mate-in-1
/-
theorem llm_03 :
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
  move "Ra5"
  opponent_move
-/

-- 04 DeepSeek raw: Qxa1
-- Final classification: S1
-- Lean accepts and checkmates; canonical prompt SAN is Qa1
theorem llm_04 :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♕]║
      ║♟]░░▓▓░░▓▓░░▓▓░░║
      ║♔}▓▓♘]▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║♚]♜]▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓♖]▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  move "Qxa1"
  checkmate

-- 05 DeepSeek raw: Qb2
-- Final classification: C
-- Lean: IsCheckmate ... is false
/-
theorem llm_05 :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♕]║
      ║♟]░░▓▓░░▓▓░░▓▓░░║
      ║♔}▓▓♘]▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓♜]▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓♖]▓▓░░▓▓║
      ║▓▓♚]▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  move "Qb2"
  checkmate
-/

-- 06 DeepSeek raw: Qxa1
-- Final classification: C
-- Python: IllegalMoveError; Lean: failed to make move
/-
theorem llm_06 :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓░░♕]║
      ║♟]░░▓▓░░▓▓░░▓▓░░║
      ║♔}▓▓♘]▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║♚]♜]░░▓▓♖]▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ╚════════════════╝ := by
  move "Qxa1"
  checkmate
-/

-- 07 DeepSeek raw: exf1=Q
-- Final classification: C
-- Python: legal/check, but not mate; Lean: failed to make move
/-
theorem llm_07 :
    ForcedWin .black
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓♚}▓▓║
      ║♟]░░▓▓░░▓▓♟]♟]♟]║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓♙]♙]♗]║
      ║♙]♙]░░▓▓♟]♙]♔]♙]║
      ║▓▓░░▓▓░░▓▓♘]♖]♖]║
      ╚════════════════╝ := by
  move "exf1=Q"
  checkmate
-/

-- 08 DeepSeek raw: c8=Q
-- Final classification: ✅
theorem llm_08 :
    ForcedWin .white
      ╔════════════════╗
      ║░░▓▓░░▓▓░░▓▓♚]▓▓║
      ║♟]░░♙]░░▓▓♟]♟]♟]║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║♙]♙]░░▓▓░░♙]♙]♙]║
      ║▓▓░░▓▓░░▓▓░░♔}░░║
      ╚════════════════╝ := by
  move "c8=Q"
  checkmate

-- 09 DeepSeek raw: Re1
-- Final classification: ✅
theorem llm_09 :
    ForcedWin .black
      ╔════════════════╗
      ║░░▓▓░░▓▓♜]▓▓♚}▓▓║
      ║♟]░░▓▓░░▓▓♟]♟]♟]║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░▓▓░░▓▓║
      ║▓▓░░▓▓░░▓▓░░▓▓░░║
      ║♙]♙]♙]▓▓░░♙]♙]♙]║
      ║▓▓░░▓▓░░▓▓░░♔]░░║
      ╚════════════════╝ := by
  move "Re1"
  checkmate

-- 10 DeepSeek raw: Qh4
-- Final classification: C
-- Lean: IsCheckmate ... is false
/-
theorem llm_10 :
    ForcedWin .white
    ╔════════════════╗
    ║♜]░░♝]♛]▓▓♜]▓▓░░║
    ║♟]♟]░░▓▓♞]▓▓░░▓▓║
    ║▓▓░░▓▓░░♘]░░▒▒♚]║
    ║░░▓▓░░♟]♙]♟]♟]♙]║
    ║▓▓♝]▓▓♞]▓▓░░♕]░░║
    ║░░▓▓♘]▓▓░░▓▓░░▓▓║
    ║♙]♙]▓▓░░▓▓♙]♙]░░║
    ║♖]▓▓♗]▓▓♔}▓▓░░♖]║
    ╚════════════════╝:= by
  move "Qh4"
  checkmate
-/

-- 11 DeepSeek raw: Qf7
-- Final classification: C
-- Python forced-mate search: FALSE, 2931 nodes
/-
theorem llm_11 :
    ForcedWin .white
      ╔════════════════╗
      ║▓▓░░▓▓░░♜]░░▓▓♚]║
      ║♟]▓▓♟]♖]♙]▓▓♟]♟]║
      ║▓▓░░♟]░░▓▓░░▓▓░░║
      ║░░▓▓░░▓▓░░♟]♘]▓▓║
      ║▓▓░░♕]░░▓▓░░♞]░░║
      ║♛]▓▓░░▓▓░░▓▓♙]▓▓║
      ║♙]░░▓▓░░♙]♙]▓▓♙]║
      ║░░▓▓░░▓▓░░▓▓♔}▓▓║
      ╚════════════════╝ := by
  with_panel_widgets [ForcedWinWidget]
    move "Qf7"
    opponent_move
-/

-- 12 DeepSeek raw: Qb2
-- Final classification: C
-- Python: ALL_MATE_IN_1_MOVES = []; correct response is NONE
