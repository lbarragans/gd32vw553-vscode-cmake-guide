[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9_-]+$')]
    [string]$Name,

    [string]$DestinationRoot = ".."
)

$ErrorActionPreference = "Stop"
$TemplateRoot = Split-Path -Parent $PSScriptRoot
$DestinationRoot = [System.IO.Path]::GetFullPath(
    (Join-Path $TemplateRoot $DestinationRoot)
)
$Destination = Join-Path $DestinationRoot $Name

if (Test-Path $Destination) {
    throw "El destino ya existe: $Destination. El script no sobrescribe proyectos."
}

New-Item -ItemType Directory -Path $Destination | Out-Null

foreach ($Folder in @(".vscode", "cmake", "Inc", "Src", "tools")) {
    New-Item -ItemType Directory -Path (Join-Path $Destination $Folder) |
        Out-Null
}

$Files = @(
    ".gitignore",
    "CMakeLists.txt",
    "CMakePresets.json",
    ".vscode/extensions.json",
    ".vscode/launch.example.json",
    ".vscode/tasks.json",
    "cmake/generate_listing.cmake",
    "cmake/toolchain-riscv.cmake",
    "Inc/gd32vw55x_libopt.h",
    "Src/main.c",
    "tools/configure.ps1",
    "tools/create_debug_config.ps1",
    "tools/flash.ps1",
    "tools/verify_environment.ps1",
    "tools/local_config.example.ps1"
)

foreach ($RelativePath in $Files) {
    Copy-Item `
        (Join-Path $TemplateRoot $RelativePath) `
        (Join-Path $Destination $RelativePath)
}

$CMakeFile = Join-Path $Destination "CMakeLists.txt"
$CMakeText = Get-Content $CMakeFile -Raw
$CMakeText = $CMakeText.Replace(
    "project(GD32VW553_VSCode_CMake_Starter LANGUAGES C ASM)",
    "project($Name LANGUAGES C ASM)"
)
[System.IO.File]::WriteAllText(
    $CMakeFile,
    $CMakeText,
    (New-Object System.Text.UTF8Encoding($false))
)

$Readme = @"
# $Name

Proyecto GD32VW553 creado desde la plantilla VS Code + CMake.

1. Copie tools/local_config.example.ps1 como tools/local_config.ps1.
2. Edite las tres rutas locales.
3. Abra esta carpeta en VS Code.
4. Ejecute Verify GD32 Environment y despues Build + Flash GD32.
"@
[System.IO.File]::WriteAllText(
    (Join-Path $Destination "README.md"),
    $Readme,
    (New-Object System.Text.UTF8Encoding($false))
)

Write-Host "Proyecto creado en: $Destination" -ForegroundColor Green
