param(
    [string]$Category
)

$ErrorActionPreference = 'Stop'

$suite = $PSScriptRoot
$repository = Split-Path -Parent (Split-Path -Parent $suite)
$compiler = Join-Path $repository 'bin\pabcnetcclear.exe'
if (!(Test-Path -LiteralPath $compiler -PathType Leaf)) {
    throw "Compiler not found: $compiler. Build the legacy compiler first."
}

$testDirectory = $suite
if ($Category) {
    $folder = Get-ChildItem -LiteralPath $suite -Directory | Where-Object Name -eq $Category
    if (!$folder) {
        throw "Unknown pattern test category: $Category"
    }
    $testDirectory = $folder.FullName
}

$tests = @(Get-ChildItem -LiteralPath $testDirectory -Filter '*.pas' -File -Recurse | Sort-Object FullName)
if ($tests.Count -eq 0) {
    throw "No Pascal tests found in $testDirectory"
}

$tempRoot = (Resolve-Path -LiteralPath ([System.IO.Path]::GetTempPath())).ProviderPath
$outputName = 'pabc-patterns-' + [guid]::NewGuid().ToString('N')
$output = (New-Item -ItemType Directory -Path (Join-Path $tempRoot $outputName)).FullName
$failures = @()
$testNumber = 0
try {
    foreach ($test in $tests) {
        $testName = $test.FullName.Substring($suite.Length + 1)
        $testNumber++
        $testOutput = Join-Path $output ([string]$testNumber)
        New-Item -ItemType Directory -Path $testOutput | Out-Null
        Write-Host "=== $testName ==="
        & $compiler $test.FullName $testOutput
        if ($LASTEXITCODE -ne 0) {
            $failures += "$testName - compilation failed (exit $LASTEXITCODE)"
            continue
        }

        $program = Join-Path $testOutput ($test.BaseName + '.exe')
        if (!(Test-Path -LiteralPath $program -PathType Leaf)) {
            $failures += "$testName - compiler did not produce an executable"
            continue
        }

        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $program
        $startInfo.WorkingDirectory = $testOutput
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $process = [System.Diagnostics.Process]::Start($startInfo)
        try {
            if (!$process.WaitForExit(60000)) {
                $process.Kill()
                $process.WaitForExit()
                $failures += "$testName - timed out after 60 seconds"
            } elseif ($process.ExitCode -ne 0) {
                $failures += "$testName - program failed (exit $($process.ExitCode))"
            } else {
                Write-Host 'PASS'
            }
        } finally {
            $process.Dispose()
        }
    }
} finally {
    $resolvedOutput = (Resolve-Path -LiteralPath $output).ProviderPath
    if ((Split-Path -Parent $resolvedOutput) -eq $tempRoot -and
        (Split-Path -Leaf $resolvedOutput) -eq $outputName) {
        Remove-Item -LiteralPath $resolvedOutput -Recurse -Force
    }
}

Write-Host ("Passed: {0}/{1}. Failed: {2}." -f ($tests.Count - $failures.Count), $tests.Count, $failures.Count)
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "FAIL: $_" }
    exit 1
}
exit 0
