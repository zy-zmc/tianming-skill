---
module: constants.global
load_trigger: 冷启动 / 任何引用 [VAR:xxx] 的协议
meta_tag: 核心配置
---

# 全局常数与戒律

[ID:global.constants]

本文件是系统的**唯一常数表**。所有协议中出现的 `[VAR:xxx]` 引用，
必须以本文件中定义的值为准。

修改本文件中的任何常数，等同于修改整个系统的运行参数。

---

## 格式戒律

[ID:global.formatting]

| 常数 ID | 值 | 说明 |
|---|---|---|
| `[VAR:global.formatting.atomic_chapter_identifier]` | `[卷名]_[章序]` | 原子章节标识符 |

### 章序演算法则

#### 默认法则：绝对序列

在执行任何目录生成指令（`「天命：规划」`、`「天命：目录」`）时，
系统必须、且只能采用【绝对序列制】进行章序演算。

#### 演算细则

第二卷的起始章序，必须是第一卷的最终章序加一。

此法则在所有卷之间以数学精度严格递推，不得存在任何跳跃、中断或重置。

---

## 字数戒律

[ID:global.word_count]

*[Ω 级]*

| 常数 ID | 值 | 说明 |
|---|---|---|
| `[VAR:global.word_count.lower_bound]` | **3500 净字** | 下限【净字·铁律】 |
| `[VAR:global.word_count.upper_bound]` | **4000 净字** | 上限【净字·铁律】 |

> **净字定义**：以「不含标点的纯粹文字数量」作为唯一计量标准。
> 详见 [REF:protocol.main_body.word_count_stabilizer]。

---

## 结构戒律

[ID:global.structure]

| 常数 ID | 值 | 说明 |
|---|---|---|
| `[VAR:global.structure.total_buffer_ratio]` | **37%** | 总缓冲比 |
| `[VAR:global.structure.usable_buffer_ratio]` | **30%** | 可用缓冲比 |
| `[VAR:global.structure.calibration_buffer_ratio]` | **7%** | 校准章缓冲比 |

### 验证关系

```
total_buffer_ratio = usable_buffer_ratio + calibration_buffer_ratio
        37%        =       30%           +         7%
```

---

## 生产戒律

[ID:global.production]

| 常数 ID | 值 | 说明 |
|---|---|---|
| `[VAR:global.production.toc_max_batch_size]` | **50** | 目录标准批次容量上限 |
| `[VAR:global.production.toc_target_batch_size]` | **30** | 目录目标批次容量 |
| `[VAR:global.production.breakpoint_scan_window]` | **5** | 叙事断点扫描窗口 |

---

## 悬念戒律

[ID:global.suspense]

| 常数 ID | 值 | 说明 |
|---|---|---|
| `[VAR:global.suspense.dormant_threshold]` | **50** | 沉睡伏笔激活阈值（章数） |

---

## 叙事戒律

[ID:global.narrative]

| 常数 ID | 值 | 说明 |
|---|---|---|
| `[VAR:global.narrative.singularity_quota]` | **3** | 奇点事件配额（次/卷） |
| `[VAR:global.narrative.backstory_cycle]` | **70** | 伏笔子链周期 |
| `[VAR:global.narrative.min_safe_spacing]` | **3** | 最小安全间距（章） |
| `[VAR:global.narrative.cross_volume_retrieval_min]` | **60%** | 跨卷回收率下限 |
| `[VAR:global.narrative.cross_volume_foreshadow_min]` | **40%** | 跨卷伏笔占比下限 |
| `[VAR:global.narrative.main_conflict_density_min]` | **30%** | 主冲突浓度下限 |
| `[VAR:global.narrative.macro_pacing_ratio]` | **"20:30:30:20"** | 宏观节奏比例（起/承/转/合） |
| `[VAR:global.narrative.overload_tolerance]` | **1.05** | 章节超载容忍度 |
| `[VAR:global.narrative.buffer_fluctuation_range]` | **2%** | 缓冲比浮动范围 |
| `[VAR:global.narrative.obscurity_rate]` | **98%** | 伏笔暗埋率 |
| `[VAR:global.narrative.core_retrieval_min]` | **80%** | 核心回收率下限 |
| `[VAR:global.narrative.info_decryption_max]` | **30%** | 单章信息解密上限 |
| `[VAR:global.narrative.intra_volume_closure_min]` | **85%** | 卷内闭环率下限 |
| `[VAR:global.narrative.peak_safe_spacing]` | **2** | 峰值安全间距（章） |
| `[VAR:global.narrative.audit_failure_threshold]` | **15%** | 卷末校验失败阈值 |

---

## 风格戒律

风格类的「戒律」属于**美学准则**而非可量化常数，
其定义详见 `aesthetic/` 目录下的相关文件：

| 戒律名 | 文件位置 |
|---|---|
| 文气溯源最高指令 | `aesthetic/style-genesis.md` |
| 口语化风格内化 | `aesthetic/style-genesis.md` |
| 打破常规戒律 | `aesthetic/writing-edicts.md` |
| 凝练语言戒律 | `aesthetic/writing-edicts.md` |
| AI 指纹黑名单 | `aesthetic/ai-signature-blacklist.md` |

---

## 修改约定

### 何时可以修改本文件

- 用户基于自己的写作风格和小说体量，决定调整字数下限/上限时
- 用户对叙事节奏有特殊偏好，需要重新校准比例时
- 用户在多次实战后发现某项常数与其创作目标不匹配时

### 修改时必须做的事

1. 修改完成后，必须执行 `「天命：体检」` 重新校验《世界基石.md》
   是否仍能通过新约束
2. 重大修改（如字数、缓冲比）必须重启会话（触发冷启动），
   以让 [REF:core.boot.arbitration] 的 VAR 编译重新生效
3. 在 `Docs/CHANGELOG.md`（如有）记录修改原因与日期

### 严禁修改的常数

以下常数若被修改，可能导致系统级架构失衡，**强烈不建议**：

- `[VAR:global.structure.total_buffer_ratio]` — 修改将打破熵增抑制法典
- `[VAR:global.narrative.obscurity_rate]` — 修改将影响伏笔系统的整体保密度
- `[VAR:global.narrative.peak_safe_spacing]` — 修改将影响峰值禁区生效逻辑
