param (
    [string]$Source = "ccl/save_data.ccl",
    [string]$Output = "src/generated"
)

if (Test-Path -LiteralPath $Output) {
    Remove-Item -LiteralPath $Output -Recurse -Force
}

New-Item -ItemType Directory -Path $Output | Out-Null
ccl generate --source $Source --output $Output --language gd
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
