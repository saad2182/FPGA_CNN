$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$buildDir = Join-Path $repoRoot 'build\sim'

foreach ($command in @('iverilog', 'vvp', 'python')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command '$command' was not found on PATH."
    }
}

New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repoRoot 'data\memory\pattern_hex.txt') -Destination (Join-Path $buildDir 'pattern_hex.txt') -Force
Copy-Item -LiteralPath (Join-Path $repoRoot 'data\memory\sample_hex.txt') -Destination (Join-Path $buildDir 'sample_hex.txt') -Force

$sources = @(
    (Join-Path $repoRoot 'rtl\core\convpattern.v'),
    (Join-Path $repoRoot 'rtl\core\convsample.v'),
    (Join-Path $repoRoot 'rtl\core\dotproduct.v'),
    (Join-Path $repoRoot 'rtl\top\top_sim.v'),
    (Join-Path $repoRoot 'tb\top_tb.v')
)

Push-Location $buildDir
try {
    & iverilog -g2012 -s top_tb -o detector_sim @sources
    if ($LASTEXITCODE -ne 0) { throw 'Icarus Verilog compilation failed.' }

    & vvp .\detector_sim
    if ($LASTEXITCODE -ne 0) { throw 'Verilog simulation failed.' }

    & python (Join-Path $repoRoot 'scripts\show_image.py') 'test.txt' 'detections.png'
    if ($LASTEXITCODE -ne 0) { throw 'Detection-map reconstruction failed.' }
} finally {
    Pop-Location
}

Write-Output "Detection map: $buildDir\detections.png"
