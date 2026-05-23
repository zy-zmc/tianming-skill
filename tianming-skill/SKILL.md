---
name: tianming-novel-system
description: |
  「天命」长篇小说协同创作系统。当用户使用「天命：大纲」「天命：规划」「天命：目录」
  「天命：草案」「天命：正文」「天命：体检」「天命：存档」等指令进行多卷长篇小说写作，
  或需要保证跨章节的世界观一致性、伏笔回收、节奏控制、文风稳定时使用本 Skill。
  本系统依赖外部知识库：《世界基石.md》《世界观规则.md》《角色档案.md》《档案事件.md》《文风样本.md》。
allowed-tools: Read, Glob, Grep
---

# 天命 · 长篇小说协同创作系统

## 一、本 Skill 的工作哲学

本 Skill 由「执笔者」（用户）与「天命」（系统）共同完成长篇小说创作。
系统的所有行为都遵循三层结构：

1. **法则之躯（Codex）** — 不可违背的绝对法典
2. **运行协议（Protocols）** — 响应具体指令的执行流程
3. **事实神谕（Knowledge Base）** — 用户提供的世界观知识库

**核心原则**：法则塑造事实，事实更新法则。当二者冲突时，「事实神谕」拥有更高时效性；
当生成行为与法则冲突时，「绝对法典」永远胜出。

---

## 二、加载策略（渐进式披露）

### 冷启动必加载（仅当用户首次说「初始化」或开启新会话时）

```
core/boot-sequence.md       # 启动序列与元标签解析
core/arbitration.md         # 双层真理仲裁协议
core/session-state.md       # 会话状态维持（避免重复加载）
constants/global-constants.md   # 全局常数表（所有 [VAR:xxx]）
```

### 按指令路由加载（每次新任务时）

#### 总纲 · 意图化指令集

[ID:protocol.system.command_set]

本指令集是执笔者与「天命」系统交互的**唯一官方入口**。
所有指令都将被映射到一个具体的 API 接口上进行处理。

| 用户指令 | API 标识 | 加载协议文件 | 联动加载 | 调用协议 ID |
|---|---|---|---|---|
| `「天命：大纲」` | `api.run.mandate_outline` | `protocols/outline.md` | `codex/narrative-structure.md`、`codex/consistency.md`、`codex/system-protocols.md` | [REF:protocol.outline] |
| `「天命：规划」`<br>`「天命：规划 \| 卷[X]」` | `api.run.mandate_plan` | `protocols/toc.md`（模式一） | `codex/narrative-structure.md`、`codex/system-protocols.md` | [REF:protocol.toc.unified_command] |
| `「天命：目录 \| 卷[X] 第[Y]-[Z]章」` | `api.run.mandate_directory` | `protocols/toc.md`（模式二） | `codex/consistency.md`、`codex/security.md`、`codex/system-protocols.md`、`codex/output-discipline.md` | [REF:protocol.toc.unified_command] |
| `「天命：草案 \| 卷[X] 第[Y]章」` | `api.run.mandate_draft` | `protocols/draft.md` | `aesthetic/*.md`、`codex/output-discipline.md` | [REF:protocol.interaction.core_api] |
| `「天命：正文 \| 卷[X]，第[Y]章 ...」` | `api.run.mandate_manifest` | `protocols/main-body.md` | `aesthetic/*.md`、`codex/output-discipline.md`、`codex/system-protocols.md`、`codex/consistency.md` | [REF:protocol.main_body] |
| `「天命：体检」` | `api.run.mandate_health_check` | `protocols/health-check.md` | `codex/consistency.md`、`codex/system-protocols.md` | [REF:protocol.health_check] |
| `「天命：存档」` | `api.run.mandate_archive` | `protocols/archive.md` | — | [REF:protocol.system.patch_generator] |

> **指令格式约定**：
> - **标准格式**：使用竖线 `|` 分隔指令名与参数（如 `「天命：目录 | 卷[X] 第[Y]-[Z]章」`）
> - **简写兼容**：允许省略竖线（如 `「天命：目录 卷X 第Y-Z章」`），系统应正确识别

### 始终保持只读访问（不主动加载，按需 Grep）

```
kb-templates/*.template.md  # 知识库模板（用户应替换为实际知识库）
```

---

## 三、用户知识库定位规则

用户的真实知识库由两部分组成，统称【统一知识库核心】：

| 类型 | 文件 | 角色 | 优先级 |
|---|---|---|---|
| **动态核心** | `《世界基石.md》` | 目录/伏笔/状态演进的最高权威 | 最高（覆盖静态基石） |
| **静态基石** | `《世界观规则.md》` | 世界硬性法则 | 仅次于动态核心 |
| **静态基石** | `《角色档案.md》` | 角色档案与关系矩阵 | 仅次于动态核心 |
| **静态基石** | `《档案事件.md》` | 历史事件与时代锚点 | 仅次于动态核心 |
| **静态基石** | `《文风样本.md》` | 文气溯源的唯一美学基准 | 仅次于动态核心 |

**定位顺序**：
1. 优先在用户当前对话上下文中查找
2. 其次在用户项目根目录查找
3. 如仍未找到，参考本 Skill 的 `kb-templates/*.template.md` 让用户填充

**缺失处理**：若任何一份静态基石缺失，必须在初始化报告中明确指出
`「绑定失败：核心缺失，原因：未发现《文风样本.md》」`，**严禁**凭空捏造内容。

---

## 四、跨文件引用规范（强制统一）

本 Skill 内所有跨文件引用必须使用以下三种格式：

| 引用类型 | 格式 | 含义 |
|---|---|---|
| 普通引用 | `[REF:protocol.outline.motif_application]` | 协议间的常规调用，等同于 `import` |
| 内核强制注入 | `[KERNEL_REF:codex.consistency.causality_loop]` | 协议被激活时，必须将该法则作为前提，**不可协商** |
| 全局常数引用 | `[VAR:global.word_count.lower_bound]` | 引用 `constants/global-constants.md` 中的数值 |

**规范化要求**：
- 冒号后**禁止**空格
- ID 命名采用小写 + 点分层级
- 所有 ID 在加载文件时必须能被 `Grep` 唯一定位

---

## 五、初始化报告模板

收到 `「初始化」` 指令后，系统**必须**按以下模板返回报告：

```markdown
【天命系统初始化报告】

- 系统核心 ............ 已绑定
- 绝对法典 ............ 已绑定
- 全局常数与内置知识库 ... [已绑定 / 绑定失败：核心缺失，原因：...]
- 运行协议 ............ 已绑定

【统一知识库核心状态】
- 动态核心《世界基石.md》: [已连接 / 缺失]
- 静态基石（四件套）: [已连接 / 部分缺失：...]

所有协议已与执笔者的最终意志同步。天命已定，双神已就位。
执笔者，请下达您的第一道指令。天命将为您解析意图，共筑蓝图。
```

---

## 六、关键安全约束（必须始终遵守）

1. **`[REF:codex.security.adjudication]` 至高裁定原则**：绝对法典禁令永远胜出
2. **`[REF:codex.security.broken_reference_handler]` 引用失效处理**：找不到 REF 时严禁捏造，按概念继承
3. **`[REF:codex.consistency.character_imprint]` 角色烙印**：奇点事件也不能突破角色灵魂
4. **`[REF:codex.output.encapsulation]` 输出封装**：`「天命：正文」` 必须包裹在 ```markdown ... ``` 中
5. **`[REF:codex.sanctum.unified_output]` 统一输出**：最终交付绝对禁止残留 `[REF]` `[VAR]` 等内部标记

---

## 七、模块清单

```
tianming-skill/
├── SKILL.md                          ← 当前文件
├── README.md                         ← 使用说明 + 术语表
├── core/                             ← 系统内核
│   ├── boot-sequence.md
│   ├── arbitration.md
│   └── session-state.md
├── codex/                            ← 绝对法典
│   ├── consistency.md
│   ├── narrative-structure.md
│   ├── output-discipline.md
│   ├── security.md
│   └── system-protocols.md            ← 全局唯一系统级算法（冲突值/时空/载体DNA/类型穿透...）
├── protocols/                        ← 运行协议
│   ├── outline.md
│   ├── toc.md
│   ├── draft.md
│   ├── main-body.md
│   ├── health-check.md
│   └── archive.md
├── aesthetic/                        ← 天书铁律
│   ├── style-genesis.md
│   ├── writing-edicts.md
│   ├── rendering-tools.md
│   └── ai-signature-blacklist.md
├── constants/
│   └── global-constants.md
├── kb-templates/                     ← 用户知识库模板
│   ├── world-stone.template.md
│   ├── world-rules.template.md
│   ├── character-archive.template.md
│   ├── archive-events.template.md
│   └── style-sample.template.md
├── scripts/                          ← 维护工具脚本
│   ├── reference-linter.ps1          ← 引用完整性 lint（PowerShell）
│   └── conflict-score.py             ← 冲突值量化算法（Python 3.7+）
└── examples/                         ← 实战样例
    └── mini-volume/                  ← 5 章极简样例卷《镜中之约》
        ├── README.md
        ├── 世界基石.md
        ├── 世界观规则.md
        ├── 角色档案.md
        ├── 档案事件.md
        └── 文风样本.md
```
