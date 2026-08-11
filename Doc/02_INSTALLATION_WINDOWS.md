# 2. Instalación en Windows

## 2.1 Componentes

Instale:

1. Visual Studio Code.
2. Git para Windows.
3. CMake 3.20 o posterior.
4. Ninja.
5. GD32 Embedded Builder, que contiene Nuclei RISC-V GCC, GDB y OpenOCD.
6. `GD32VW55x_Firmware_Library_V1.6.0`.

En VS Code instale las extensiones recomendadas cuando aparezca la
notificación del repositorio:

- C/C++ de Microsoft;
- CMake Tools de Microsoft;
- Cortex-Debug.

## 2.2 Comprobar programas globales

Abra PowerShell y ejecute únicamente estas líneas, sin copiar el texto `PS C:\...>`:

```powershell
cmake --version
ninja --version
git --version
```

Si PowerShell dice que un comando no se reconoce, instale el programa o agregue
su directorio al `PATH`, cierre VS Code y vuelva a abrirlo.

## 2.3 Localizar las tres rutas

### SDK

La raíz correcta contiene `Firmware`, `Utilities` y `Template`. Ejemplo:

```text
C:/Users/usuario/OneDrive/Escritorio/GD32VW55x_Firmware_Library_V1.6.0
```

Prueba:

```powershell
Test-Path "C:\ruta\al\SDK\Firmware\GD32VW55x_standard_peripheral\system_gd32vw55x.c"
```

### Toolchain Nuclei

Debe ser la carpeta `bin` que contiene `riscv-nuclei-elf-gcc.exe`:

```powershell
Get-ChildItem "C:\ruta\a\GD32EmbeddedBuilder" `
  -Filter "riscv-nuclei-elf-gcc.exe" -Recurse |
  Select-Object -ExpandProperty FullName
```

En `local_config.ps1` se guarda la carpeta, no el nombre del ejecutable.

### OpenOCD

Localice `openocd.exe`:

```powershell
Get-ChildItem "C:\ruta\a\GD32EmbeddedBuilder" `
  -Filter "openocd.exe" -Recurse |
  Select-Object -ExpandProperty FullName
```

`OPENOCD_ROOT` debe ser el directorio padre que contiene simultáneamente
`bin/` y `scripts/`.

## 2.4 Crear la configuración privada

Desde la raíz del repositorio:

```powershell
Copy-Item .\tools\local_config.example.ps1 .\tools\local_config.ps1
notepad .\tools\local_config.ps1
```

Ejemplo de forma, reemplazando todas las rutas:

```powershell
$GD32_SDK_ROOT = "C:/ruta/GD32VW55x_Firmware_Library_V1.6.0"
$NUCLEI_TOOLCHAIN_DIR = "C:/ruta/NucleiRISCVGCC/bin"
$OPENOCD_ROOT = "C:/ruta/OpenOCD/xpack-openocd-0.11.0-3"
```

Se recomiendan barras `/` dentro de las cadenas. No publique este archivo.

## 2.5 Verificar todo de una vez

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\verify_environment.ps1
```

Todas las líneas deben comenzar por `[OK]`. La opción
`-ExecutionPolicy Bypass` solo se aplica a ese proceso de PowerShell; no cambia
permanentemente la política del sistema.
