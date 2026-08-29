#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
verify_line.py —— 直接计算验证器

它做的事：照着给定的一条走法路线走一遍，检查两件事——
    (1) 每一步是否合法
    (2) 终局是不是将杀

它只看这一条线。
黑方还有哪些别的应手，它不会主动穷举。
"""

import chess


def verify(name, fen, ucis):
    print(f"\n=== {name} ===")
    print(f"起始 FEN: {fen}")
    board = chess.Board(fen)

    for i, uci in enumerate(ucis, 1):
        try:
            mv = chess.Move.from_uci(uci)
        except ValueError:
            print(f"  第{i}步 {uci}: ❌ UCI 格式错误")
            return

        if mv not in board.legal_moves:
            print(f"  第{i}步 {uci}: ❌ 非法着法")
            return

        san = board.san(mv)
        board.push(mv)

        tag = ""
        if board.is_checkmate():
            tag = "  ← 将杀"
        elif board.is_check():
            tag = "  ← 将军"
        elif board.is_stalemate():
            tag = "  ← 逼和(和棋)"

        print(f"  第{i}步 {uci} = {san}{tag}")

    if board.is_checkmate():
        winner = "白" if not board.turn else "黑"
        print(f"✅ 通过：终局是将杀，{winner}方赢")
    elif board.is_stalemate():
        print("⚠️  终局是逼和(和棋)，不是将杀")
    else:
        print("❌ 终局既不是将杀也不是逼和，这条线没走完")


if __name__ == "__main__":
    boardA = "7Q/p7/K1N5/4R3/8/1r6/k7/8 w - - 0 1"
    anchor = "7k/5K2/8/6Q1/8/8/8/8 w - - 0 1"

    # 1. 正解：Re2+ Ka3 Qa1#
    verify(
        "棋盘A / 正解  1.Re2+ Ka3 2.Qa1#",
        boardA,
        ["e5e2", "a2a3", "h8a1"],
    )

    # 2. 陷阱：这条单独路线本身完全合法，而且终局确实将杀
    verify(
        "棋盘A / 陷阱  1.Qh2+ Ka3 2.Ra5#",
        boardA,
        ["h8h2", "a2a3", "e5a5"],
    )

    # 3. 同样 Qh2+，如果黑方改走 Ka1，这条答案就没有继续覆盖
    verify(
        "棋盘A / 陷阱变一手  1.Qh2+ Ka1 ...白方无杀",
        boardA,
        ["h8h2", "a2a1"],
    )

    # 4. 棋盘 B：Qg6 后直接形成逼和
    verify(
        "棋盘B / 贪吃翻车  1.Qg6 → 逼和",
        anchor,
        ["g5g6"],
    )