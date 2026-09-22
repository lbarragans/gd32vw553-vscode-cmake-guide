@echo off
setlocal EnableExtensions
title Verificacion GD32VW553

echo ============================================================
echo  GD32VW553 - VERIFICACION PREVIA DEL ENTORNO
echo ============================================================
echo.

set "ERRORS=0"

call :check_command cmake "CMake"
call :check_command ninja "Ninja"
call :check_command git "Git"
call :check_command riscv-nuclei-elf-gcc "Nuclei RISC-V GCC"
call :check_command riscv-nuclei-elf-gdb "Nuclei RISC-V GDB"
call :check_command openocd "OpenOCD"

echo.
echo Verificando estructura estandar C:\gd32_tools ...
call :check_file "C:\gd32_tools\GD32VW55x_Firmware_Library_V1.6.0\Firmware\GD32VW55x_standard_peripheral\system_gd32vw55x.c" "SDK bare-metal V1.6.0"
call :check_file "C:\gd32_tools\openocd\scripts\target\gd32vw55x.cfg" "Target OpenOCD GD32VW55x"

echo.
if "%ERRORS%"=="0" (
    echo [OK] Entorno base listo. Ya puede abrir VS Code.
    echo Siguiente paso: Terminal ^> Run Task ^> Verify GD32 Environment
) else (
    echo [ERROR] Se encontraron %ERRORS% problema(s).
    echo Corrija el PATH o la estructura C:\gd32_tools y vuelva a ejecutar.
)
echo.
pause
exit /b %ERRORS%

:check_command
where %~1 >nul 2>&1
if errorlevel 1 (
    echo [FALTA] %~2: %~1 no esta en PATH
    set /a ERRORS+=1
) else (
    for /f "delims=" %%I in ('where %~1') do (
        echo [OK] %~2: %%I
        %~1 --version
        echo.
        goto :command_done
    )
)
:command_done
exit /b 0

:check_file
if exist "%~1" (
    echo [OK] %~2: %~1
) else (
    echo [FALTA] %~2: %~1
    set /a ERRORS+=1
)
exit /b 0
