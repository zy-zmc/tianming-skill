<#
.SYNOPSIS
    天命 Skill 引用完整性 Lint 工具

.DESCRIPTION
    扫描 tianming-skill 目录下所有 .md 文件，检查：
    - 所有 [REF:xxx] 是否能在 [ID:xxx] 中找到
    - 所有 [KERNEL_REF:xxx] 是否能在 [ID:xxx] 中找到
    - 所有 [VAR:xxx] 是否能在 constants/global-constants.md 中找到
    - 是否存在不规范的带空格引用 [REF: xxx] / [VAR: xxx] / [KERNEL_REF: xxx]
    - 原始提示词中的所有 [ID] 是否已迁移（可选）

.PARAMETER SkillPath
    Skill 根目录路径，默认为脚本所在目录的父目录

.PARAMETER OriginalPrompt
    可选：原始提示词文件路径，用于"迁移完整性"反推校验

.PARAMETER Json
    输出 JSON 报告而非彩色控制台报告

.EXAMPLE
    .\reference-linter.ps1
    .\reference-linter.ps1 -SkillPath E:\AI\tianming-skill
    .\reference-linter.ps1 -OriginalPrompt E:\AI\提示词.md
    .\reference-linter.ps1 -Json | Out-File lint-report.json

.OUTPUTS
    退出码 0 = 通过；退出码 1 = 发现问题
#>

[CmdletBinding()]
param(
    [string]$SkillPath = '',
    [string]$OriginalPrompt = '',
    [switch]$Json
)

if ([string]::IsNullOrWhiteSpace($SkillPath)) {
    $scriptRoot = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $PSScriptRoot
    }
    elseif ($MyInvocation.MyCommand.Path) {
        Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    else {
        Join-Path (Get-Location).Path 'scripts'
    }
    $SkillPath = Split-Path -Parent $scriptRoot
}

# ============================================================================
# 工具函数
# ============================================================================

function Get-AllText {
    param([string]$Path)
    $files = Get-ChildItem -Path $Path -Recurse -File -Filter *.md
    $perFile = @{}
    foreach ($f in $files) {
        $rel = $f.FullName.Replace($Path + '\', '')
        $perFile[$rel] = Get-Content -Raw -Encoding UTF8 $f.FullName
    }
    return $perFile
}

# 把 fenced code block (```) 和 inline code (`...`) 区域用占位符替换
# 用于"定义"类提取（[ID:...]）：定义只在正文有效，代码块内是展示用法
function Strip-CodeRegions {
    param([string]$Text)
    # 1. 移除 fenced code blocks
    $text = [regex]::Replace($Text, '(?ms)^```.*?^```', '<<<CODEBLOCK>>>')
    # 2. 移除 inline code spans (反引号包裹)
    $text = [regex]::Replace($text, '`[^`\r\n]*`', '<<<INLINE>>>')
    return $text
}

function Extract-Tokens {
    param(
        [hashtable]$PerFile,
        [string]$Pattern,
        [switch]$StripCode  # 是否剥离代码区（仅用于 ID 定义提取）
    )
    $items = @()
    foreach ($file in $PerFile.Keys) {
        $text = $PerFile[$file]
        if ($StripCode) {
            $text = Strip-CodeRegions -Text $text
        }
        $lines = $text -split "`r?`n"
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            foreach ($m in [regex]::Matches($line, $Pattern)) {
                $raw = $m.Groups[1].Value.Trim()
                # 支持 [KERNEL_REF:a, b] 形式的多目标拆分
                foreach ($x in ($raw -split ',')) {
                    $v = $x.Trim()
                    if ($v) {
                        $items += [PSCustomObject]@{
                            Token = $v
                            File  = $file
                            Line  = $i + 1
                        }
                    }
                }
            }
        }
    }
    return $items
}

function Write-Section {
    param([string]$Title, [string]$Color = 'Cyan')
    if (-not $Json) {
        Write-Host ''
        Write-Host ('=' * 70) -ForegroundColor $Color
        Write-Host "  $Title" -ForegroundColor $Color
        Write-Host ('=' * 70) -ForegroundColor $Color
    }
}

# ============================================================================
# 主流程
# ============================================================================

if (-not (Test-Path $SkillPath)) {
    Write-Error "Skill 路径不存在：$SkillPath"
    exit 2
}

$perFile = Get-AllText -Path $SkillPath

# 抽取所有 token
# - ID 定义需要剥离代码区，否则反引号内的 `[ID:xxx]` 字面示例会被误识别为重复定义
# - REF/KERNEL_REF/VAR 引用保留代码区，因为示例文档里的引用也应被校验完整性
$ids       = Extract-Tokens -PerFile $perFile -Pattern '\[ID:\s*([^\]]+)\]' -StripCode
$refs      = Extract-Tokens -PerFile $perFile -Pattern '\[REF:\s*([^\]]+)\]'
$krefs     = Extract-Tokens -PerFile $perFile -Pattern '\[KERNEL_REF:\s*([^\]]+)\]'
$vars      = Extract-Tokens -PerFile $perFile -Pattern '\[VAR:\s*([^\]]+)\]'

# VAR 定义来自 constants/global-constants.md 中 `[VAR:xxx]` 反引号样式
$constantsFile = $perFile.Keys | Where-Object { $_ -like 'constants*global-constants.md' } | Select-Object -First 1
$varDefSet = New-Object 'System.Collections.Generic.HashSet[string]'
if ($constantsFile) {
    foreach ($m in [regex]::Matches($perFile[$constantsFile], '`\[VAR:([^\]]+)\]`')) {
        [void]$varDefSet.Add($m.Groups[1].Value.Trim())
    }
}

$idSet = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($i in $ids) { [void]$idSet.Add($i.Token) }

# 文档示例占位符：用于在 README/说明性文字中演示引用格式时的占位符
# 这些 token 不参与悬空检查
$placeholders = @('xxx', 'yyy', 'zzz', '...', '元标签:...', 'a, b', 'a', 'b')
$phSet = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($p in $placeholders) { [void]$phSet.Add($p) }

function Is-RealReference {
    param([PSCustomObject]$Item)
    return -not $phSet.Contains($Item.Token)
}

# 检查 1：[REF] 悬空（排除示例占位）
$badRefs = $refs | Where-Object { (Is-RealReference $_) -and -not $idSet.Contains($_.Token) }

# 检查 2：[KERNEL_REF] 悬空
$badKrefs = $krefs | Where-Object { (Is-RealReference $_) -and -not $idSet.Contains($_.Token) }

# 检查 3：[VAR] 悬空
$badVars = $vars | Where-Object { (Is-RealReference $_) -and -not $varDefSet.Contains($_.Token) }

# 检查 4：不规范的带空格引用
$badSpaceRefs = Extract-Tokens -PerFile $perFile -Pattern '\[REF:\s+([^\]]+)\]'
$badSpaceKrefs = Extract-Tokens -PerFile $perFile -Pattern '\[KERNEL_REF:\s+([^\]]+)\]'
$badSpaceVars = Extract-Tokens -PerFile $perFile -Pattern '\[VAR:\s+([^\]]+)\]'

# 检查 5：重复定义的 [ID]（同一个 ID 在多处定义）
$dupIds = $ids | Group-Object Token | Where-Object { $_.Count -gt 1 } | ForEach-Object {
    [PSCustomObject]@{
        Token = $_.Name
        Count = $_.Count
        Files = ($_.Group | ForEach-Object { "$($_.File):$($_.Line)" }) -join '; '
    }
}

# 检查 6（可选）：与原始提示词的迁移完整性
$origMissing = @()
if ($OriginalPrompt -and (Test-Path $OriginalPrompt)) {
    $origText = Get-Content -Raw -Encoding UTF8 $OriginalPrompt
    $origIds = @()
    foreach ($m in [regex]::Matches($origText, '\[ID:\s*([^\]]+)\]')) {
        $origIds += $m.Groups[1].Value.Trim()
    }
    $origIds = $origIds | Sort-Object -Unique
    foreach ($oi in $origIds) {
        if ($phSet.Contains($oi)) { continue }
        if (-not $idSet.Contains($oi)) {
            $origMissing += $oi
        }
    }
}

# ============================================================================
# 输出报告
# ============================================================================

$totalIssues = $badRefs.Count + $badKrefs.Count + $badVars.Count +
               $badSpaceRefs.Count + $badSpaceKrefs.Count + $badSpaceVars.Count +
               $dupIds.Count + $origMissing.Count

if ($Json) {
    $report = [ordered]@{
        timestamp      = (Get-Date).ToString('o')
        skill_path     = $SkillPath
        stats = [ordered]@{
            files         = $perFile.Count
            ids           = $ids.Count
            unique_ids    = $idSet.Count
            refs          = $refs.Count
            krefs         = $krefs.Count
            vars          = $vars.Count
            var_defs      = $varDefSet.Count
        }
        issues = [ordered]@{
            unresolved_refs        = @($badRefs | ForEach-Object { @{ token = $_.Token; file = $_.File; line = $_.Line } })
            unresolved_krefs       = @($badKrefs | ForEach-Object { @{ token = $_.Token; file = $_.File; line = $_.Line } })
            unresolved_vars        = @($badVars | ForEach-Object { @{ token = $_.Token; file = $_.File; line = $_.Line } })
            malformed_space_refs   = @($badSpaceRefs | ForEach-Object { @{ token = $_.Token; file = $_.File; line = $_.Line } })
            malformed_space_krefs  = @($badSpaceKrefs | ForEach-Object { @{ token = $_.Token; file = $_.File; line = $_.Line } })
            malformed_space_vars   = @($badSpaceVars | ForEach-Object { @{ token = $_.Token; file = $_.File; line = $_.Line } })
            duplicate_ids          = @($dupIds | ForEach-Object { @{ token = $_.Token; count = $_.Count; files = $_.Files } })
            missing_from_original  = @($origMissing)
        }
        total_issues = $totalIssues
        pass = ($totalIssues -eq 0)
    }
    $report | ConvertTo-Json -Depth 8
}
else {
    Write-Section "天命 Skill · 引用完整性 Lint 报告"
    Write-Host "Skill 路径 : $SkillPath" -ForegroundColor Gray
    Write-Host "扫描时间   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    if ($OriginalPrompt) {
        Write-Host "原始提示词 : $OriginalPrompt" -ForegroundColor Gray
    }

    Write-Section "统计" 'Yellow'
    Write-Host ("  文件总数      : {0}" -f $perFile.Count)
    Write-Host ("  [ID] 总数     : {0} (唯一 {1})" -f $ids.Count, $idSet.Count)
    Write-Host ("  [REF] 引用    : {0}" -f $refs.Count)
    Write-Host ("  [KERNEL_REF]  : {0}" -f $krefs.Count)
    Write-Host ("  [VAR] 引用    : {0}" -f $vars.Count)
    Write-Host ("  [VAR] 定义    : {0}" -f $varDefSet.Count)

    Write-Section "问题检查" 'Yellow'

    if ($badRefs.Count -gt 0) {
        Write-Host "  [✗] 悬空 [REF] : $($badRefs.Count) 处" -ForegroundColor Red
        foreach ($b in $badRefs) {
            Write-Host "      $($b.File):$($b.Line)  →  [REF:$($b.Token)]" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  [✓] [REF]      : 全部能解析" -ForegroundColor Green
    }

    if ($badKrefs.Count -gt 0) {
        Write-Host "  [✗] 悬空 [KERNEL_REF] : $($badKrefs.Count) 处" -ForegroundColor Red
        foreach ($b in $badKrefs) {
            Write-Host "      $($b.File):$($b.Line)  →  [KERNEL_REF:$($b.Token)]" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  [✓] [KERNEL_REF]: 全部能解析" -ForegroundColor Green
    }

    if ($badVars.Count -gt 0) {
        Write-Host "  [✗] 悬空 [VAR] : $($badVars.Count) 处" -ForegroundColor Red
        foreach ($b in $badVars) {
            Write-Host "      $($b.File):$($b.Line)  →  [VAR:$($b.Token)]" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  [✓] [VAR]      : 全部能解析" -ForegroundColor Green
    }

    $spaceCount = $badSpaceRefs.Count + $badSpaceKrefs.Count + $badSpaceVars.Count
    if ($spaceCount -gt 0) {
        Write-Host "  [✗] 带空格不规范引用 : $spaceCount 处" -ForegroundColor Red
        foreach ($b in $badSpaceRefs)  { Write-Host "      $($b.File):$($b.Line)  →  [REF: $($b.Token)]"        -ForegroundColor Red }
        foreach ($b in $badSpaceKrefs) { Write-Host "      $($b.File):$($b.Line)  →  [KERNEL_REF: $($b.Token)]" -ForegroundColor Red }
        foreach ($b in $badSpaceVars)  { Write-Host "      $($b.File):$($b.Line)  →  [VAR: $($b.Token)]"        -ForegroundColor Red }
    }
    else {
        Write-Host "  [✓] 引用格式    : 全部符合规范（冒号后无空格）" -ForegroundColor Green
    }

    if ($dupIds.Count -gt 0) {
        Write-Host "  [!] 重复 [ID] 定义 : $($dupIds.Count) 个" -ForegroundColor Yellow
        Write-Host "      （注意：天命系统允许同一文件中放总入口+子协议双 ID，可能为合理重复）" -ForegroundColor DarkGray
        foreach ($d in $dupIds) {
            Write-Host "      [ID:$($d.Token)] 出现 $($d.Count) 次" -ForegroundColor Yellow
            Write-Host "         位置: $($d.Files)" -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "  [✓] [ID] 唯一性 : 无重复定义" -ForegroundColor Green
    }

    if ($OriginalPrompt) {
        if ($origMissing.Count -gt 0) {
            Write-Host "  [✗] 原始提示词迁移缺失 : $($origMissing.Count) 个 ID" -ForegroundColor Red
            foreach ($m in $origMissing) {
                Write-Host "      [ID:$m] 未在 Skill 中定义" -ForegroundColor Red
            }
        }
        else {
            Write-Host "  [✓] 原始迁移   : 原始所有 [ID] 已全部迁移" -ForegroundColor Green
        }
    }

    Write-Section "总结" $(if ($totalIssues -eq 0 -and $dupIds.Count -eq 0) { 'Green' } else { 'Red' })
    if ($totalIssues -eq 0 -and $dupIds.Count -eq 0) {
        Write-Host "  ✓ 所有引用完整性检查通过" -ForegroundColor Green
    }
    elseif ($totalIssues -eq 0) {
        Write-Host "  ✓ 引用完整性通过（仅 $($dupIds.Count) 个重复 ID 为合理设计）" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ 发现 $totalIssues 个问题，请检查上方明细" -ForegroundColor Red
    }
    Write-Host ''
}

# 退出码
# 重复 ID 不算硬错（合理设计），其他全算硬错
$hardIssues = $badRefs.Count + $badKrefs.Count + $badVars.Count +
              $badSpaceRefs.Count + $badSpaceKrefs.Count + $badSpaceVars.Count +
              $origMissing.Count

if ($hardIssues -gt 0) {
    exit 1
}
else {
    exit 0
}
