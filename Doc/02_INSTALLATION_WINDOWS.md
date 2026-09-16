# 2. Instalación en Windows

## 2.1 Componentes

Instale:

1. Visual Studio Code.
2. Git para Windows.
3. CMake 3.20 o posterior.
4. Ninja.
5. GD32 Embedded Builder, que contiene Nuclei RISC-V GCC, GDB y OpenOCD.
6. `GD32VW55x_Firmware_Library_V1.6.0`.

## 2.1.1 Descargas y función de cada paquete

| Componente | Sitio oficial | Para qué se necesita |
| --- | --- | --- |
| VS Code | <https://code.visualstudio.com/Download> | editor, tareas y depuración |
| Git for Windows | <https://git-scm.com/download/win> | clonar y actualizar repositorios |
| CMake | <https://cmake.org/download/> | generar el sistema de construcción |
| Ninja | <https://github.com/ninja-build/ninja/releases> | ejecutar las reglas de compilación |
| GD32VW553 y recursos | <https://www.gigadevice.com/product/mcu/wireless-mcus/gd32vw553-series> | ficha, SDK, firmware y herramientas GD32 |
| MSDK oficial GD32VW553 | <https://www.gigadevice.com/product/mcu/mcus-product-selector/gd32vw553hmq6> | FreeRTOS, port Nuclei/ECLIC, MBL, WiFi y lwIP para las variantes FreeRTOS 00–12 |

Descargue herramientas de fabricante únicamente desde GigaDevice. Los nombres
y versiones visibles en el portal pueden cambiar; para reproducir los
laboratorios conserve localmente las versiones validadas que se indican aquí.

Hay dos paquetes GD32 diferentes:

| Paquete | Ejercicios | Contenido |
| --- | --- | --- |
| `GD32VW55x_Firmware_Library_V1.6.0` | 00–11 | startup, linker, drivers y ejemplos bare-metal |
| `GD32VW55x_RELEASE_V1.0.3g` | FreeRTOS 00–12 | MBL/MSDK, FreeRTOS, port Nuclei/ECLIC, WiFi, lwIP y firmware de radio |

No reemplace uno por el otro solo porque ambos contienen `GD32VW55x`.
Para ejecutar estos laboratorios no descargue ni mezcle un kernel FreeRTOS
genérico: use el que viene integrado en `GD32VW55x_RELEASE_V1.0.3g`.

En la página oficial del dispositivo, localice exactamente
`GD32VW55x_RELEASE_V1.0.3g`, descárguelo y compruebe el archivo con:

```powershell
Get-ChildItem "$HOME\Downloads" |
  Where-Object Name -Match "GD32VW55x.*RELEASE" |
  Sort-Object LastWriteTime -Descending |
  Format-Table Name,Length,LastWriteTime
```

En VS Code instale las extensiones recomendadas cuando aparezca la
notificación del repositorio:

- C/C++ de Microsoft;
- CMake Tools de Microsoft;
- Cortex-Debug.

Después de instalar, continúe con
[11_VSCODE_Y_CONEXION_PLACA.md](11_VSCODE_Y_CONEXION_PLACA.md) para reconocer
el probe, el CH340 y configurar F5.

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
