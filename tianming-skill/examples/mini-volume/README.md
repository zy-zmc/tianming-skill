# Mini 样例卷 · 《镜中之约》

> 本目录是「天命 Skill」的**最小可运行示例**。
> 故事极简（5 章），但完整覆盖了核心协议的关键场景：
> 角色烙印、Tier-1 伏笔、缓冲-代价、关系向量、文风溯源。

---

## 一、 故事一句话

旧书店店主陈默发现一面能显示三日后景象的古镜，
他试图用它改变挚友的命运，却发现"看见"本身就是一种代价。

---

## 二、 协议覆盖矩阵

| 协议 | 在样例中如何体现 |
|---|---|
| `[REF:codex.consistency.character_imprint]` 角色烙印 | 陈默的"以失去为代价的窥见"贯穿全篇 |
| `[REF:codex.consistency.causality_loop]` 因果律闭环 | 第 5 章的最终选择回应第 1 章的镜启 |
| `[REF:codex.consistency.price_conservation]` 代价守恒 | 每次窥见都付出"现实记忆模糊"的代价 |
| `[REF:codex.narrative.philosophical_motif]` 哲学母题 | "目光是否决定命运" |
| `[REF:codex.narrative.scene_pacing]` 场景呼吸法 | 第 4 章为缓冲-代价，节拍偏向"思考"和"展示" |
| `[REF:protocol.system.conflict_quantification]` 冲突值 | 第 5 章触达 ★★★★☆（峰值） |
| `[REF:protocol.system.dna_verification]` 载体 DNA | 第 4 章的"模糊指印"作为载体 DNA 的语义指纹 |
| `[REF:codex.consistency.relationship_dynamics]` 关系向量 | 陈默 → 林知夏 关系向量随情节演变 |

---

## 三、 文件清单

```
examples/mini-volume/
├── README.md            ← 本文件
├── 世界基石.md          ← 已填充：含 5 章战术执行目录、伏笔总账、待决议事项
├── 世界观规则.md        ← 已填充：古镜的规则、时代锚点
├── 角色档案.md          ← 已填充：3 位核心角色 + 关系矩阵
├── 档案事件.md          ← 已填充：与古镜相关的关键既定事件
└── 文风样本.md          ← 已填充：3 段半文半白现代风格示范
```

---

## 四、 重现工作流

如果你想用这个样例对照学习「天命」的工作流，可按下列顺序在 Claude 中执行：

```
1. 把整个 tianming-skill/ 目录共享给 Claude
2. 把 examples/mini-volume/ 下的 5 个文件作为知识库共享给 Claude
3. 输入：初始化
4. 观察 Claude 是否能按 core/boot-sequence.md 的标准格式返回报告
5. 输入：「天命：草案 | 卷[一] 第[1]章」
6. 观察输出是否符合 protocols/draft.md 中【显化蓝图草案】的硬性约束
   （如：净字 ≤ 300、悬念钩子一字不差复现）
7. 输入：「天命：正文 | 卷[一]，第[1]章 ...」
8. 观察生成的正文是否：
   - 包裹在 ```markdown ... ```
   - 净字落入 3500-4000 区间
   - 文气符合《文风样本.md》
   - 在仪表盘中正确报告冲突值
```

---

## 五、 这个样例本身是反推校验的活样例

本样例的所有 `[REF:xxx]` 引用，都已通过：

```powershell
.\scripts\reference-linter.ps1 -SkillPath . -OriginalPrompt ..\..\..\提示词.md
```

校验。任何对样例的修改建议都应保持引用完整性。

---

## 六、 极简化原则

本样例**故意省略**以下内容：

- 完整的全书战略宏图（只有卷一 5 章）
- 复杂的多卷伏笔子链（只有 1 个 Tier-1 伏笔）
- 多派系势力对立（只有 3 位核心角色）

如果你需要看完整规模的应用，请参考真实生产中你自己填充的项目。
