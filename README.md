> ## 🖥️ 寻找软件版？
>
> 如果你更喜欢**开箱即用的桌面应用**体验，请移步 👉 **[天命-智能小说创作软件](https://github.com/zy-zmc/tianming-novel-ai-writer)**
>
> 无需任何提示词知识，下载即用，内置完整天命系统。

---

# 天命 · 长篇小说协同创作 Skill

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

> **TianMing** — A modular AI Skill for co-writing long-form novels with Claude.
> Restructured from a 995-line monolithic prompt into 30+ protocol files with
> progressive disclosure, intent-based command routing, and built-in consistency enforcement.

---

> 由 2025 年「天命」长 Prompt 系统（995 行）拆分重构而成的 Claude Skill。
> 通过渐进式披露（Progressive Disclosure）机制，按指令路由按需加载相关协议，
> 实现 token 消耗下降 50-70% 与跨平台复用。

---

## 一、 这个 Skill 是什么

「天命」是一个为长篇小说创作而设计的、高度结构化的 AI 协同写作系统。
它的核心思想是：

- **执笔者（用户）** 负责创意、世界观、人物烙印、文风样本
- **天命（系统）** 负责保证跨章节的世界观一致性、伏笔回收、节奏控制、文风稳定

整个系统通过一套**指令式 API**（如 `「天命：大纲」`、`「天命：正文」`）
进行交互，让长篇小说创作具备工程化的可控性。

---

## 二、 快速开始

### 1. 准备知识库

把 `kb-templates/` 下的 5 个模板复制到你的小说项目目录，并按模板说明填充：

```
你的小说项目/
├── 世界基石.md           ← 由系统自动维护（初始可为空模板）
├── 世界观规则.md         ← 你必须填写
├── 角色档案.md           ← 你必须填写
├── 档案事件.md           ← 同人/前传必填，原创可选填
└── 文风样本.md           ← 必填，越完整越好
```

### 2. 加载 Skill

将整个 `tianming-skill/` 目录放到 Claude 可访问的位置（Skill 注册方式
依赖你使用的 Claude 平台，详见 Anthropic 官方文档）。

### 3. 初始化

在与 Claude 的对话中输入：

```
初始化
```

系统会执行 [REF:core.boot.arbitration] 的【第一阶段：内殿铸魂】，
检查所有协议绑定状态与知识库连接状态，并返回标准化报告。

### 4. 开始创作

按以下指令顺序推进：

| 步骤 | 指令 | 产出 |
|---|---|---|
| 1 | `「天命：大纲」` | 【战略宏图】 + 【宏观节奏宪章】 |
| 2 | `「天命：规划」` | 【全书战役总蓝图】 + 【指令序列】 |
| 3 | `「天命：目录 卷1 第1-30章」` | 详细章节目录（30 章 / 批） |
| 4 | `「天命：草案 卷1 第1章」` | （可选）章节骨架蓝图，供审查 |
| 5 | `「天命：正文 卷1 第1章」` | 完整章节正文（3500-4000 净字） |
| 6 | 重复 4-5 直到本卷完成 | — |
| 7 | `「天命：体检」` | 《世界基石.md》健康报告 |
| 8 | `「天命：存档」` | 结构化更新补丁 |

---

## 三、 目录结构

```
tianming-skill/
├── SKILL.md                          ← 主入口（路由表 + 启动清单）
├── README.md                         ← 本文件
│
├── core/                             ← 系统内核（冷启动必加载）
│   ├── boot-sequence.md              ← 启动序列
│   ├── arbitration.md                ← 双层真理仲裁协议
│   └── session-state.md              ← 会话状态维持（避免重复加载）
│
├── codex/                            ← 绝对法典（按指令路由加载）
│   ├── consistency.md                ← 世界观一致性（因果律/代价守恒/角色烙印/实体时序）
│   ├── narrative-structure.md        ← 宏观叙事（哲学母题/主题回响/熵增/呼吸法）
│   ├── output-discipline.md          ← 输出纪律（圣堂法令/文脉丰盈/封装/仪表盘）
│   ├── security.md                   ← 系统安全（仲裁/熔断/驳回/奇点豁免）
│   └── system-protocols.md           ← 全局唯一系统协议（冲突值/时空/载体DNA/类型穿透）
│
├── protocols/                        ← 运行协议（响应具体指令）
│   ├── outline.md                    ← 「天命：大纲」
│   ├── toc.md                        ← 「天命：规划」/「天命：目录」
│   ├── draft.md                      ← 「天命：草案」
│   ├── main-body.md                  ← 「天命：正文」
│   ├── health-check.md               ← 「天命：体检」
│   └── archive.md                    ← 「天命：存档」
│
├── aesthetic/                        ← 天书铁律（草案/正文加载）
│   ├── style-genesis.md              ← 文气溯源 + 口语化
│   ├── writing-edicts.md             ← 创作戒律（打破常规/凝练语言）
│   ├── rendering-tools.md            ← 渲染工具（人物/对话/打斗）
│   └── ai-signature-blacklist.md     ← AI 指纹黑名单
│
├── constants/
│   └── global-constants.md           ← 所有 [VAR:xxx] 全局常数
│
├── kb-templates/                     ← 用户知识库模板（用户应替换）
│   ├── world-stone.template.md       ← 《世界基石.md》模板
│   ├── world-rules.template.md       ← 《世界观规则.md》模板
│   ├── character-archive.template.md ← 《角色档案.md》模板
│   ├── archive-events.template.md    ← 《档案事件.md》模板
│   └── style-sample.template.md      ← 《文风样本.md》模板
│
├── scripts/                          ← 维护工具脚本
│   ├── reference-linter.ps1          ← 引用完整性 lint（PowerShell 5+）
│   └── conflict-score.py             ← 冲突值量化算法（Python 3.7+）
│
└── examples/                         ← 实战样例
    └── mini-volume/                  ← 5 章极简样例卷《镜中之约》
        ├── README.md
        ├── 世界基石.md
        ├── 世界观规则.md
        ├── 角色档案.md
        ├── 档案事件.md
        └── 文风样本.md
```

---

## 四、 术语速查表

### 系统术语

| 术语 | 含义 |
|---|---|
| **执笔者** | 你（用户） |
| **天命** | 系统本身 |
| **统一知识库核心** | 《世界基石.md》+ 四件静态基石的总称 |
| **战略宏图** | 故事的最高纲领，由 `「天命：大纲」` 生成 |
| **战役总蓝图** | 全书的战略推演，由 `「天命：规划」` 生成 |
| **战术执行目录** | 详细章节目录，由 `「天命：目录」` 生成 |
| **显化蓝图草案** | 章节骨架，由 `「天命：草案」` 生成 |
| **当前章之绝对蓝图** | 正文协议从目录中锁定的当前章信息 |
| **精修初稿** | 4500-5500 字的预渲染稿，待打磨成最终成品 |

### 引用规范

| 格式 | 含义 |
|---|---|
| `[ID:xxx]` | 当前协议的唯一标识符 |
| `[REF:xxx]` | 引用其他协议（普通调用） |
| `[KERNEL_REF:xxx]` | 强制注入其他协议（内核级、不可协商） |
| `[VAR:xxx]` | 引用 `constants/global-constants.md` 的常数 |
| `[元标签:...]` | 协议的功能分类标签 |

### 叙事术语

| 术语 | 含义 |
|---|---|
| **Tier-1 战略级** | 影响主角命运/世界结局的伏笔 |
| **Tier-2 战役级** | 影响当前卷/派系的伏笔 |
| **Tier-3 战术级** | 影响局部冲突的伏笔 |
| **峰值章节** | 冲突值 ≥ ★★★★☆ 的章节 |
| **奇点事件** | 临时挂起力量上限的破格章节 |
| **载体 DNA** | 悬念钩子的语义指纹 |
| **缓冲-代价** | 用于代价清算的缓冲章 |
| **缓冲-对话** | 用于关系演变的缓冲章 |
| **缓冲-线索** | 用于伏笔/信息揭露的缓冲章 |

---

## 五、 与原始 Prompt 的差异

### 1. 已完成的改进

- ✅ **拆分**：995 行单文件 → 24 个核心模块文件
- ✅ **路由化**：按指令路由按需加载（`SKILL.md` 包含完整路由表）
- ✅ **引用规范化**：`[REF: xxx]` → `[REF:xxx]`（冒号后无空格）
- ✅ **元数据补全**：每个文件顶部添加 frontmatter，标注加载条件、依赖
- ✅ **常数集中**：所有数值常数集中到 `constants/global-constants.md`
- ✅ **模板分离**：知识库与协议解耦，模板放在 `kb-templates/` 供用户填充
- ✅ **指令格式统一**：所有含参数指令统一为 `「天命：xxx | 卷[X] 第[Y]章」` 标准格式 + 简写兼容
- ✅ **引用 Lint**：`scripts/reference-linter.ps1` 自动校验 `[ID]/[REF]/[KERNEL_REF]/[VAR]` 完整性
- ✅ **冲突值脚本化**：`scripts/conflict-score.py` 让冲突值量化可被 Claude 用 code-execution 调用
- ✅ **样例库**：`examples/mini-volume/` 提供 5 章极简样例卷《镜中之约》

### 2. 故意保留的"原貌"

以下设计虽然在 Skill 体系下略显冗余，但**故意保留**以维持原系统的完整性：

- `[KERNEL_REF:xxx]` 与 `[REF:xxx]` 的语义区别
- Ω 级 / L1-L6 熔断级别
- 双层真理仲裁的"内殿铸魂 / 外层神谕"二段制

### 3. 后续可优化方向

- ⏳ **可视化体检**：`「天命：体检」` 的输出可以加入 ASCII 图表或 Mermaid 图
- ⏳ **CI 集成**：把 `scripts/reference-linter.ps1` 接入 git pre-commit hook
- ⏳ **缓冲比脚本**：把"缓冲比健康度"也写成 Python 校验脚本

---

## 五-bis、 维护工具用法

### 引用完整性 Lint

```powershell
# 仅检查 Skill 内部一致性
.\scripts\reference-linter.ps1

# 检查 + 与原始提示词反推校验
.\scripts\reference-linter.ps1 -OriginalPrompt E:\AI\提示词.md

# 输出 JSON 报告
.\scripts\reference-linter.ps1 -Json | Out-File lint-report.json
```

退出码 `0` = 通过；`1` = 发现问题。

### 冲突值量化

```bash
# 交互式输入
python scripts/conflict-score.py

# 跑内置示例
python scripts/conflict-score.py --demo

# 从 JSON 输入 + 输出 JSON
python scripts/conflict-score.py --json input.json --output json
```

依赖：Python 3.7+，无第三方依赖。

---

## 六、 故障排查

### 系统报告 `FATAL_ERROR: Blueprint_Mismatch`

**原因**：`「天命：正文」` 或 `「天命：草案」` 指令的章序，
在《世界基石.md》的【战术执行目录】中找不到对应条目。

**解决**：
1. 先执行 `「天命：目录」` 生成该章的目录条目
2. 或检查指令中卷号/章号是否正确

### 系统报告 `FATAL_ERROR: Causality_Chain_Broken`

**原因**：当前章节要发生的重大事件，在前文找不到逻辑先导。

**解决**：
1. 回到目录协议，在前面章节补充铺垫
2. 或修改当前章节的核心事件，使其能从前文推导

### 系统报告 `FATAL_ERROR: Temporal_Anomaly_Detected`

**原因**：草稿中出现了不属于当前时代的实体（如卷一出现卷三才该出现的角色）。

**解决**：
1. 检查《档案事件.md》中该实体的时间锚点是否正确
2. 或在目录协议阶段拒绝该实体的提前出现

### 系统报告 `FATAL_ERROR: Singularity_Quota_Exceeded`

**原因**：本卷的「奇点事件」使用次数已超过
[VAR:global.narrative.singularity_quota] = **3 次**。

**解决**：
1. 不允许在本卷再使用「奇点事件」标记
2. 或修改 `constants/global-constants.md` 中的配额（不推荐）

### 输出字数始终低于下限

**原因**：[REF:protocol.main_body.ore_foundry]【精修初稿】的渲染失败，
触发了 [REF:codex.output.forced_expansion]【最高优先级扩写】，
但仍未达标。

**解决**：
1. 检查《文风样本.md》是否提供了足够多的"高密度"样本
2. 检查目录中该章的【核心事件】是否过于贫瘠（事件密度不够）

---

## 七、 版本与维护

* **基础版本**：基于 2025 年初版「天命提示词.md」（995 行）拆分而成
* **拆分日期**：2026 年
* **维护策略**：
  - 协议层（`protocols/`、`codex/`、`aesthetic/`）按 semver 独立迭代
  - 常数层（`constants/`）变更必须触发会话重启
  - 知识库层（`kb-templates/`）模板更新不影响已使用的真实知识库

---

## 八、 致谢与版权

本 Skill 的设计哲学来源于 2025 年的「天命」长 Prompt 系统。
所有的核心法典、协议、戒律均保留原作者意图，仅做了结构化重组与引用规范化。

任何商用，请联系原作者 子夜（229164036）。

---

## 🙏 致谢

感谢真诚、友善、团结、专业的 Linuxdo 社区，让我学到了那么多有关 AI 相关知识。

[![LinuxDo community](https://img.shields.io/badge/LinuxDo-community-blue)](https://linux.do/)

- [LinuxDo](https://linux.do/) 学 ai, 上 L 站!

---

## 💬 交流群

- [点击链接加入群聊【天命-智能创作（BUG收集）】](https://qm.qq.com/q/YWivpFjKou)

群号：414086347
