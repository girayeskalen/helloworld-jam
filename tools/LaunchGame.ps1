$ErrorActionPreference = 'Stop'
$gameRoot = Split-Path -Parent $PSScriptRoot
# Old npm caches may remain on a teammate's machine after pulling the migration.
# Exclude them from Godot's importer without deleting any local data.
foreach ($gameCacheName in @('node_modules', 'dist', 'test-results', 'playwright-report')) {
    $gameCacheDirectory = Join-Path $gameRoot $gameCacheName
    if (Test-Path -LiteralPath $gameCacheDirectory -PathType Container) {
        [IO.File]::WriteAllText((Join-Path $gameCacheDirectory '.gdignore'), '')
    }
}
$gameEngine = $env:GODOT_BIN
if (-not $gameEngine -or -not (Test-Path -LiteralPath $gameEngine -PathType Leaf)) {
    $gameSearchRoots = @(
        [Environment]::GetFolderPath('Desktop'),
        (Join-Path $env:USERPROFILE 'Downloads')
    ) | Select-Object -Unique
    $gameCandidates = foreach ($gameSearchRoot in $gameSearchRoots) {
        if (Test-Path -LiteralPath $gameSearchRoot) {
            Get-ChildItem -LiteralPath $gameSearchRoot -Filter 'Godot*' -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.PSIsContainer) {
                    Get-ChildItem -LiteralPath $_.FullName -Filter 'Godot*.exe' -File -ErrorAction SilentlyContinue
                } elseif ($_.Extension -eq '.exe') { $_ }
            }
        }
    }
    $gameEngine = $gameCandidates | Where-Object { $_.Name -notlike '*console*' -and $_.Name -notlike '*mono*' } | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $gameEngine) {
    Write-Host 'Godot bulunamadi. Godot 4.3+ ile bu klasordeki project.godot dosyasini acip F5 tusuna basin.'
    exit 1
}
Start-Process -FilePath $gameEngine -ArgumentList @('--path', ('"' + $gameRoot + '"')) -WorkingDirectory $gameRoot
