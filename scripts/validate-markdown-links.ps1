[CmdletBinding()]
param(
    [string]$Root
)

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = Split-Path -Parent $PSScriptRoot
}

$Root = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\', '/')
$errors = [System.Collections.Generic.List[string]]::new()
$linkPattern = '\[[^\]]+\]\((?<target>[^)\s]+)'
$markdownFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.md' |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }

foreach ($file in $markdownFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw

    foreach ($match in [regex]::Matches($content, $linkPattern)) {
        $target = $match.Groups['target'].Value.Trim('<', '>')
        $targetPath = ($target -split '#', 2)[0]

        if ([string]::IsNullOrWhiteSpace($targetPath) -or
            $targetPath -match '^(https?|mailto|tel|data):') {
            continue
        }

        $candidate = Join-Path $file.DirectoryName ([uri]::UnescapeDataString($targetPath))
        if (-not (Test-Path -LiteralPath $candidate)) {
            $relativeFile = $file.FullName.Substring($Root.Length).TrimStart('\', '/')
            $errors.Add("${relativeFile}: $target")
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Error "Broken local Markdown links found:`n$($errors -join "`n")"
    exit 1
}

Write-Output "Local Markdown links valid across $($markdownFiles.Count) files."
