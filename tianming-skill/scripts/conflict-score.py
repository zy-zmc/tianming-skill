#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
天命 Skill · 冲突值量化算法

实现 codex/system-protocols.md 中 [ID:protocol.system.conflict_quantification]
定义的冲突值计算公式：

    冲突值【分值】 = 基础分 + Σ(权重 × 触发次数)

并将分值映射为一至五星【★】评级。

用法：
    python conflict-score.py                  # 交互式输入
    python conflict-score.py --json input.json  # 从 JSON 读入
    python conflict-score.py --demo           # 跑示例

JSON 输入格式（例）：
    {
      "core_character_state_change": 1,
      "tier1_foreshadow": 0,
      "tier2_foreshadow": 1,
      "singularity_event": 0,
      "core_character_count": 2,
      "important_entity_change": 0
    }
"""

import argparse
import json
import math
import sys
from dataclasses import dataclass
from typing import Dict, List, Tuple


# ============================================================================
# 客观加权因子表
# ============================================================================

@dataclass(frozen=True)
class Factor:
    key: str
    name: str
    weight: int
    description: str
    per_unit: bool = False  # True 表示按每个角色/每件物品累加，而非一次性加权


FACTORS: List[Factor] = [
    Factor(
        key="core_character_state_change",
        name="核心角色状态根本性改变",
        weight=8,
        description="如死亡、黑化、核心能力获得/失去",
    ),
    Factor(
        key="tier1_foreshadow",
        name="Tier-1【战略级】伏笔回收/埋设",
        weight=8,
        description="对世界结局或主角命运有决定性影响",
    ),
    Factor(
        key="tier2_foreshadow",
        name="Tier-2【战役级】伏笔回收/埋设",
        weight=5,
        description="对当前卷或主要派系有重大影响",
    ),
    Factor(
        key="singularity_event",
        name="奇点事件发生",
        weight=5,
        description="触发了破格行为",
    ),
    Factor(
        key="core_character_count",
        name="核心角色参与",
        weight=2,
        description="每增加一位核心角色参与核心事件",
        per_unit=True,
    ),
    Factor(
        key="important_entity_change",
        name="重要实体（组织/物品）状态改变",
        weight=3,
        description="如组织覆灭、神器易主",
    ),
]

BASE_SCORE = 1


# ============================================================================
# 评级映射
# ============================================================================

@dataclass(frozen=True)
class Rating:
    stars: str
    name: str
    threshold: int       # 该评级的最小分值
    is_peak: bool = False


RATINGS: List[Rating] = [
    Rating("★★★★★", "核心峰值",       16, True),
    Rating("★★★★☆", "重要冲突/峰值",  12, True),
    Rating("★★★☆☆", "中度冲突",        8),
    Rating("★★☆☆☆", "次要冲突",        5),
    Rating("★☆☆☆☆", "低冲突",          0),
]


def score_to_rating(score: int) -> Rating:
    for r in RATINGS:
        if score >= r.threshold:
            return r
    return RATINGS[-1]


# ============================================================================
# 计算核心
# ============================================================================

def compute_score(triggers: Dict[str, int], base_score: int = BASE_SCORE) -> Tuple[int, List[Tuple[Factor, int, int]]]:
    """
    计算冲突值。

    triggers: 因子 key -> 触发次数（per_unit 因子表示数量，其他因子表示是否触发 0/1）
    返回 (总分, 详细加分明细)
    """
    score = base_score
    breakdown: List[Tuple[Factor, int, int]] = []  # (factor, count, contribution)

    for f in FACTORS:
        count = max(0, int(triggers.get(f.key, 0)))
        contribution = f.weight * count
        if contribution > 0:
            breakdown.append((f, count, contribution))
        score += contribution

    return score, breakdown


# ============================================================================
# 输出格式
# ============================================================================

def format_report(score: int, breakdown: List[Tuple[Factor, int, int]], base_score: int = BASE_SCORE) -> str:
    rating = score_to_rating(score)
    lines = []
    lines.append("=" * 60)
    lines.append("  冲突值量化报告")
    lines.append("=" * 60)
    lines.append(f"  基础分      : {base_score}")
    if breakdown:
        lines.append("  加权明细    :")
        for f, count, contrib in breakdown:
            unit = "次" if not f.per_unit else "位"
            lines.append(f"    + {f.name:30s}  权重 {f.weight} × {count} {unit} = {contrib}")
    else:
        lines.append("  加权明细    : (无任何加权因子触发)")
    lines.append("-" * 60)
    lines.append(f"  最终冲突值  : {score}")
    lines.append(f"  评级        : {rating.stars}  ({rating.name})")
    if rating.is_peak:
        lines.append("  峰值标记    : ⚠ 峰值章节")
        lines.append("                  - 触发 [REF:codex.narrative.scene_pacing]：「思考」「对话」节拍占比应压缩至 10% 以下")
        lines.append("                  - 触发 [REF:protocol.toc.rhythm_regulator]：后续 1-3 章必须强制呼吸（缓冲-代价/缓冲-对话）")
    lines.append("=" * 60)
    return "\n".join(lines)


def format_json(score: int, breakdown: List[Tuple[Factor, int, int]], base_score: int = BASE_SCORE) -> str:
    rating = score_to_rating(score)
    payload = {
        "base_score": base_score,
        "score": score,
        "rating": {
            "stars": rating.stars,
            "name": rating.name,
            "is_peak": rating.is_peak,
        },
        "breakdown": [
            {
                "factor_key": f.key,
                "factor_name": f.name,
                "weight": f.weight,
                "count": count,
                "contribution": contrib,
            }
            for f, count, contrib in breakdown
        ],
    }
    return json.dumps(payload, ensure_ascii=False, indent=2)


# ============================================================================
# 输入路径
# ============================================================================

def load_from_json(path: str) -> Dict[str, int]:
    with open(path, "r", encoding="utf-8") as fp:
        return json.load(fp)


def interactive_input() -> Dict[str, int]:
    print("=" * 60)
    print("  天命 · 冲突值量化交互输入")
    print("=" * 60)
    print(f"  基础分默认为 {BASE_SCORE}，无需输入。")
    print("  对每个因子，输入触发次数（直接回车 = 0）。")
    print("-" * 60)

    triggers: Dict[str, int] = {}
    for f in FACTORS:
        unit_hint = "（按位数）" if f.per_unit else "（0/1）"
        prompt = f"  {f.name} {unit_hint}\n    [+{f.weight}] {f.description}\n  > "
        raw = input(prompt).strip()
        try:
            count = int(raw) if raw else 0
        except ValueError:
            count = 0
        triggers[f.key] = max(0, count)
        print()

    return triggers


def demo() -> Dict[str, int]:
    """官方示例：一个典型的卷一峰值章节"""
    return {
        "core_character_state_change": 1,   # 主角失去某能力
        "tier1_foreshadow": 0,
        "tier2_foreshadow": 1,              # 回收一个 Tier-2 伏笔
        "singularity_event": 0,
        "core_character_count": 3,          # 三位核心角色参与
        "important_entity_change": 0,
    }


# ============================================================================
# 主入口
# ============================================================================

def main(argv: List[str] = None) -> int:
    parser = argparse.ArgumentParser(
        description="天命 Skill · 冲突值量化算法",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--json", dest="json_path", metavar="FILE", help="从 JSON 文件读取触发数据")
    parser.add_argument("--demo", action="store_true", help="运行内置示例")
    parser.add_argument("--output", choices=["text", "json"], default="text", help="输出格式")
    parser.add_argument("--base", type=int, default=BASE_SCORE, help=f"基础分（默认 {BASE_SCORE}）")

    args = parser.parse_args(argv)

    if args.demo:
        triggers = demo()
        if args.output == "text":
            print("[demo] 使用内置示例数据：")
            print(json.dumps(triggers, ensure_ascii=False, indent=2))
            print()
    elif args.json_path:
        triggers = load_from_json(args.json_path)
    else:
        triggers = interactive_input()

    score, breakdown = compute_score(triggers, base_score=args.base)

    if args.output == "json":
        print(format_json(score, breakdown, base_score=args.base))
    else:
        print(format_report(score, breakdown, base_score=args.base))

    return 0


if __name__ == "__main__":
    sys.exit(main())
