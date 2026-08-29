import sys
import time
from functools import lru_cache

try:
    import chess
except ImportError as exc:
    print(f"IMPORT_ERROR: {type(exc).__name__}: {exc}")
    sys.exit(1)


QUESTIONS = [
    {
        "id": "01",
        "name": "anchor",
        "fen": "7k/5K2/8/6Q1/8/8/8/8 w - - 0 1",
        "answer": "Qg7",
    },
    {
        "id": "02",
        "name": "anchor+pawn",
        "fen": "7k/p4K2/8/6Q1/8/8/8/8 w - - 0 1",
        "answer": "Qg6",
    },
    {
        "id": "03",
        "name": "board-A",
        "fen": "7Q/p7/K1N5/4R3/8/1r6/k7/8 w - - 0 1",
        "answer": "Ra5",
    },
    {
        "id": "04",
        "name": "branch-Ka3",
        "fen": "7Q/p7/K1N5/8/8/kr6/4R3/8 w - - 2 2",
        "answer": "Qxa1",
    },
    {
        "id": "05",
        "name": "branch-Kb1",
        "fen": "7Q/p7/K1N5/8/8/1r6/4R3/1k6 w - - 2 2",
        "answer": "Qb2",
    },
    {
        "id": "06",
        "name": "branch-Rb2",
        "fen": "7Q/p7/K1N5/8/8/8/kr2R3/8 w - - 2 2",
        "answer": "Qxa1",
    },
    {
        "id": "07",
        "name": "underpromotion",
        "fen": "6k1/p4ppp/8/8/8/5PPB/PP2pPKP/5NRR b - - 0 1",
        "answer": "exf1=Q",
    },
    {
        "id": "08",
        "name": "back-rank-promotion",
        "fen": "6k1/p1P2ppp/8/8/8/8/PP3PPP/6K1 w - - 0 1",
        "answer": "c8=Q",
    },
    {
        "id": "09",
        "name": "back-rank-mate",
        "fen": "4r1k1/p4ppp/8/8/8/8/PPP2PPP/6K1 b - - 0 1",
        "answer": "Re1",
    },
    {
        "id": "10",
        "name": "en-passant",
        "fen": "r1bq1r2/pp2n3/4N2k/3pPppP/1b1n2Q1/2N5/PP3PP1/R1B1K2R w - g6 0 1",
        "answer": "Qh4",
    },
    {
        "id": "11",
        "name": "smothered-mate",
        "fen": "4r2k/p1pRP1pp/2p5/5pN1/2Q3n1/q5P1/P3PP1P/6K1 w - - 0 1",
        "answer": "Qf7",
    },
    {
        "id": "12",
        "name": "dead-end",
        "fen": "8/p7/K1N5/4R3/8/1r6/7Q/k7 w - - 2 2",
        "answer": "Qb2",
    },
]


def parse_and_push(question):
    board = chess.Board(question["fen"])
    answer = question["answer"]
    try:
        move = board.parse_san(answer)
    except Exception as exc:
        return {
            "parse_ok": False,
            "exception_type": type(exc).__name__,
            "exception_text": str(exc),
        }

    canonical_san = board.san(move)
    canonical_prompt_form = canonical_san.removesuffix("+").removesuffix("#")
    board.push(move)
    return {
        "parse_ok": True,
        "uci": move.uci(),
        "canonical_san": canonical_san,
        "canonical_prompt_form": canonical_prompt_form,
        "format_match": answer == canonical_prompt_form,
        "is_checkmate": board.is_checkmate(),
        "is_stalemate": board.is_stalemate(),
        "is_check": board.is_check(),
    }


def print_basic_results(results):
    print("=== STANDARD_SAN_RESULTS ===")
    for question, result in results:
        print(f"QUESTION {question['id']} {question['name']}")
        print(f"FEN = {question['fen']}")
        print(f"ANSWER = {question['answer']}")
        if result["parse_ok"]:
            print("SAN_PARSE = OK")
            print(f"UCI = {result['uci']}")
            print(f"CANONICAL_SAN = {result['canonical_san']}")
            print(f"CANONICAL_PROMPT_FORM = {result['canonical_prompt_form']}")
            print(f"FORMAT_MATCH = {result['format_match']}")
            print(f"AFTER_PUSH_IS_CHECKMATE = {result['is_checkmate']}")
            print(f"AFTER_PUSH_IS_STALEMATE = {result['is_stalemate']}")
            print(f"AFTER_PUSH_IS_CHECK = {result['is_check']}")
        else:
            print("SAN_PARSE = FAIL")
            print(f"EXCEPTION_TYPE = {result['exception_type']}")
            print(f"EXCEPTION_TEXT = {result['exception_text']}")
        print()


def san_list(board, moves):
    return [board.san(move) for move in moves]


def check_question_03():
    question = QUESTIONS[2]
    board = chess.Board(question["fen"])
    print("=== QUESTION_03_MATE_IN_2_CHECK ===")
    try:
        model_move = board.parse_san(question["answer"])
    except Exception as exc:
        print("MODEL_MOVE_SAN_PARSE = FAIL")
        print(f"EXCEPTION_TYPE = {type(exc).__name__}")
        print(f"EXCEPTION_TEXT = {exc}")
        print("FORCED_MATE_IN_2_AFTER_MODEL_MOVE = UNKNOWN")
        print()
        return

    print("MODEL_MOVE_SAN_PARSE = OK")
    print(f"MODEL_MOVE_UCI = {model_move.uci()}")
    board.push(model_move)

    black_replies = list(board.legal_moves)
    print(f"BLACK_REPLY_COUNT = {len(black_replies)}")
    forced = True
    for reply in black_replies:
        reply_san = board.san(reply)
        board.push(reply)
        mate_moves = []
        for white_move in list(board.legal_moves):
            white_san = board.san(white_move)
            board.push(white_move)
            if board.is_checkmate():
                mate_moves.append(white_san)
            board.pop()
        print(f"BLACK_REPLY {reply_san} -> mate-in-1 replies: {mate_moves}")
        if not mate_moves:
            forced = False
        board.pop()

    print(f"FORCED_MATE_IN_2_AFTER_MODEL_MOVE = {str(forced).upper()}")
    print()


def check_question_11():
    question = QUESTIONS[10]
    root = chess.Board(question["fen"])
    print("=== QUESTION_11_QF7_FORCE_CHECK ===")
    try:
        model_move = root.parse_san(question["answer"])
    except Exception as exc:
        print("MODEL_MOVE_SAN_PARSE = FAIL")
        print(f"EXCEPTION_TYPE = {type(exc).__name__}")
        print(f"EXCEPTION_TEXT = {exc}")
        print("QF7_FORCED_MATE_WITHIN_4 = UNKNOWN")
        print("NODES = 0")
        print("ELAPSED_SECONDS = 0.000")
        print()
        return

    root.push(model_move)
    print("MODEL_MOVE_SAN_PARSE = OK")
    print(f"MODEL_MOVE_UCI = {model_move.uci()}")

    max_nodes = 300000
    time_limit = 30.0
    start = time.monotonic()
    nodes = 0
    timed_out = False
    node_limited = False

    def ordered_legal_moves(board):
        moves = list(board.legal_moves)
        return sorted(moves, key=lambda move: not board.gives_check(move))

    @lru_cache(maxsize=None)
    def forced_mate(fen, depth):
        nonlocal nodes, timed_out, node_limited
        if time.monotonic() - start > time_limit:
            timed_out = True
            return None
        if nodes >= max_nodes:
            node_limited = True
            return None

        board = chess.Board(fen)
        nodes += 1

        if board.is_checkmate():
            return board.turn == chess.BLACK
        if board.is_stalemate():
            return False
        if depth == 0:
            return False

        moves = ordered_legal_moves(board)
        if board.turn == chess.WHITE:
            saw_unknown = False
            for move in moves:
                board.push(move)
                result = forced_mate(board.fen(), depth - 1)
                board.pop()
                if result is True:
                    return True
                if result is None:
                    saw_unknown = True
            return None if saw_unknown else False

        saw_unknown = False
        for move in moves:
            board.push(move)
            result = forced_mate(board.fen(), depth - 1)
            board.pop()
            if result is False:
                return False
            if result is None:
                saw_unknown = True
        return None if saw_unknown else True

    result = forced_mate(root.fen(), 6)
    elapsed = time.monotonic() - start
    if result is True:
        status = "TRUE"
    elif result is False:
        status = "FALSE"
    else:
        status = "UNKNOWN"

    print(f"QF7_FORCED_MATE_WITHIN_4 = {status}")
    print(f"NODES = {nodes}")
    print(f"ELAPSED_SECONDS = {elapsed:.3f}")
    print(f"TIMEOUT = {timed_out}")
    print(f"NODE_LIMIT = {node_limited}")
    print()


def check_question_12():
    question = QUESTIONS[11]
    board = chess.Board(question["fen"])
    print("=== QUESTION_12_MATE_IN_1_ENUMERATION ===")
    mate_moves = []
    for move in list(board.legal_moves):
        move_san = board.san(move)
        board.push(move)
        if board.is_checkmate():
            mate_moves.append(move_san)
        board.pop()

    print(f"ALL_MATE_IN_1_MOVES = {mate_moves}")
    print(f"NO_MATE_IN_1 = {str(len(mate_moves) == 0).upper()}")

    board = chess.Board(question["fen"])
    try:
        model_move = board.parse_san(question["answer"])
    except Exception as exc:
        print("QB2_SAN_PARSE = FAIL")
        print(f"EXCEPTION_TYPE = {type(exc).__name__}")
        print(f"EXCEPTION_TEXT = {exc}")
        print("QB2_IMMEDIATE_CHECKMATE = FALSE")
        print()
        return

    board.push(model_move)
    print("QB2_SAN_PARSE = OK")
    print(f"QB2_UCI = {model_move.uci()}")
    print(f"QB2_IMMEDIATE_CHECKMATE = {str(board.is_checkmate()).upper()}")
    print()


def main():
    results = [(question, parse_and_push(question)) for question in QUESTIONS]
    print_basic_results(results)
    check_question_03()
    check_question_11()
    check_question_12()


if __name__ == "__main__":
    main()
