# 2. Preparación completa de Windows desde cero

Este capítulo se realiza **antes de abrir VS Code**. Al terminar, el archivo
`check_env.bat` debe indicar que el entorno base está listo.

## 2.1 Ruta única para toda la clase

Todos los estudiantes deben usar:

```text
C:\gd32_tools
```

No use Escritorio, Descargas, OneDrive, tildes ni carpetas con espacios. La
ruta común evita que CMake, Ninja, OpenOCD y los scripts reciban nombres
distintos en cada computador.

Cree estas carpetas desde el Explorador de Windows:

```text
C:\gd32_tools\cmake
C:\gd32_tools\ninja
C:\gd32_tools\nuclei
C:\gd32_tools\openocd
C:\gd32_tools\GD32VW55x_Firmware_Library_V1.6.0
C:\gd32_tools\GD32VW55x_RELEASE_V1.0.3g
```

La última carpeta solo será necesaria al llegar a FreeRTOS o WiFi.

## 2.2 Qué debe descargar

| Paquete | Contenido esperado | Uso |
| --- | --- | --- |
| Nuclei RISC-V GCC | `riscv-nuclei-elf-gcc.exe`, GDB, objcopy y size | compilar y depurar |
| CMake para Windows x64 | `cmake.exe` | generar el sistema de construcción |
| Ninja para Windows | `ninja.exe` | ejecutar la compilación |
| OpenOCD validado para GD32 | `bin/openocd.exe` y `scripts/target/gd32vw55x.cfg` | comunicar WCH-Link y placa |
| Firmware Library V1.6.0 | carpetas `Firmware` y `Utilities` | Original y Assembly 00–11 |
| VS Code y Git | instaladores Windows | editor, tareas y repositorios |

El compilador correcto de este curso es `riscv-nuclei-elf-gcc`. No use
`riscv-none-elf-gcc`: es otro prefijo y estos proyectos no lo buscan.

El toolchain Nuclei y el OpenOCD compatible pueden extraerse del paquete
validado de GD32 Embedded Builder. Aunque provengan del mismo instalador, se
organizan en las carpetas normalizadas para que todos tengan las mismas rutas.

Descargas oficiales:

- VS Code: <https://code.visualstudio.com/Download>
- Git: <https://git-scm.com/download/win>
- CMake: <https://cmake.org/download/>
- Ninja: <https://github.com/ninja-build/ninja/releases>
- GD32VW553: <https://www.gigadevice.com/product/mcu/wireless-mcus/gd32vw553-series>

No use un OpenOCD que no contenga `scripts/target/gd32vw55x.cfg`.

## 2.3 Cómo extraer cada paquete

### CMake

1. Descargue el ZIP de Windows x64.
2. Localice la carpeta que contiene `bin`, `doc` y `share`.
3. Copie su contenido dentro de `C:\gd32_tools\cmake`.
4. Compruebe `C:\gd32_tools\cmake\bin\cmake.exe`.

### Ninja

Extraiga `ninja.exe` desde `ninja-win.zip` directamente en
`C:\gd32_tools\ninja`.

### Nuclei GCC

1. Localice la carpeta cuyo `bin` contiene `riscv-nuclei-elf-gcc.exe`.
2. Copie el toolchain dentro de `C:\gd32_tools\nuclei`.
3. Compruebe `C:\gd32_tools\nuclei\bin\riscv-nuclei-elf-gcc.exe`.

### OpenOCD

1. Copie juntas las carpetas `bin` y `scripts` de la distribución GD32 dentro
   de `C:\gd32_tools\openocd`.
2. Compruebe:

```text
C:\gd32_tools\openocd\bin\openocd.exe
C:\gd32_tools\openocd\scripts\target\gd32vw55x.cfg
```

### Firmware Library

Extraiga `GD32VW55x_Firmware_Library_V1.6.0` bajo `C:\gd32_tools`. Evite una
carpeta duplicada como `...\V1.6.0\V1.6.0\Firmware`.

Debe existir:

```text
C:\gd32_tools\GD32VW55x_Firmware_Library_V1.6.0\Firmware\GD32VW55x_standard_peripheral\system_gd32vw55x.c
```

## 2.4 Agregar cuatro carpetas al PATH

1. Busque **variables de entorno** desde Inicio.
2. Abra **Editar las variables de entorno del sistema**.
3. Pulse **Variables de entorno...**.
4. En **Variables de usuario**, seleccione `Path` y pulse **Editar**.
5. Pulse **Nuevo** y agregue una por una:

```text
C:\gd32_tools\cmake\bin
C:\gd32_tools\ninja
C:\gd32_tools\nuclei\bin
C:\gd32_tools\openocd\bin
```

6. Confirme todas las ventanas con **Aceptar**.
7. Cierre terminales y VS Code. El PATH nuevo solo aparece en procesos que se
   abren después.

Agregue carpetas, no nombres de archivos `.exe`, y no borre entradas previas.

## 2.5 Verificación antes de abrir VS Code

Haga doble clic en `check_env.bat`, ubicado en la raíz de esta guía. Comprueba
CMake, Ninja, Git, GCC, GDB, OpenOCD, el SDK y el target del GD32.

Todas las líneas deben empezar por `[OK]`. Si aparece `[FALTA]`, compruebe el
archivo, revise la entrada del PATH, cierre la ventana y repita.

## 2.6 Configuración privada del repositorio

1. Abra el repositorio en VS Code.
2. Copie `tools/local_config.example.ps1`.
3. Renombre la copia como `tools/local_config.ps1`.
4. Si usó `C:\gd32_tools`, conserve sus valores propuestos.
5. No publique `local_config.ps1` en Git.

## 2.7 Verificación dentro de VS Code

Ejecute **Terminal > Run Task > Verify GD32 Environment**. Esta segunda prueba
revisa startup, linker, board support, GDB y scripts de OpenOCD.

Solo continúe a Blink Polling cuando ambas verificaciones terminen sin errores.
