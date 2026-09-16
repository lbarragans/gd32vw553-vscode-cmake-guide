# GD32VW553 con Visual Studio Code y CMake

**Autora:** Laura Daniela Barragán Silva  
**Plataforma validada:** GD32VW553HMQ6/HMQ7  
**Arquitectura:** Nuclei RISC-V RV32  
**Sistema anfitrión:** Windows 10/11  
**Entorno:** VS Code, CMake, Ninja, Nuclei RISC-V GCC y OpenOCD

## Propósito

Este repositorio es una guía reproducible y una plantilla mínima para crear,
compilar, programar y depurar proyectos del GD32VW553 desde Visual Studio Code.
No sustituye el SDK oficial: lo referencia desde una ruta local que nunca se
publica en GitHub.

Al terminar la configuración podrá:

- compilar fuentes C y ensamblador RISC-V;
- generar `ELF`, `HEX`, `BIN`, `MAP` y `LST` con CMake;
- programar la placa con OpenOCD y un depurador CMSIS-DAP/WCH-Link;
- usar breakpoints, ejecución paso a paso, registros y variables en VS Code;
- crear proyectos nuevos a partir de esta plantilla.

## Cadena de herramientas

```mermaid
flowchart TD
    A["Fuentes C y ASM"] --> B["CMake: configura el proyecto"]
    B --> C["Ninja: ejecuta la compilación"]
    C --> D["Nuclei GCC: compila y enlaza"]
    D --> E["ELF + HEX + BIN + MAP + LST"]
    E --> F["OpenOCD + CMSIS-DAP"]
    F --> G["Flash y depuración del GD32VW553"]
```

## Ruta rápida

1. Instale los componentes descritos en [Doc/02_INSTALLATION_WINDOWS.md](Doc/02_INSTALLATION_WINDOWS.md).
2. Duplique `tools/local_config.example.ps1` desde el explorador de VS Code y
   cambie el nombre de la copia a `local_config.ps1`.
3. Edite en esa copia las cuatro rutas locales.
4. Abra **esta carpeta**, no su carpeta superior, en VS Code.
5. Acepte **Trust this folder** si confía en el contenido descargado.
6. Ejecute `Terminal > Run Task > Verify GD32 Environment`.
7. Ejecute `Terminal > Run Task > Build + Flash GD32`.
8. Compruebe que el LED de PC13 cambia de estado.
9. Ejecute `Create Debug Configuration` y después presione `F5` para depurar.

## Ruta completa para los ejercicios 00–12

Si este repositorio se usa como manual del curso, siga en orden:

1. [hardware y herramientas](Doc/01_HARDWARE_AND_TOOLS.md);
2. [instalación en Windows](Doc/02_INSTALLATION_WINDOWS.md);
3. [VS Code y reconocimiento de la placa](Doc/11_VSCODE_Y_CONEXION_PLACA.md);
4. [compilar, programar y depurar](Doc/06_BUILD_FLASH_DEBUG.md);
5. [Assembly paso a paso](Doc/09_ASSEMBLY_PASO_A_PASO.md);
6. [FreeRTOS paso a paso](Doc/10_FREERTOS_PASO_A_PASO.md);
7. [ejecución de los ejercicios 00–12](Doc/12_EJERCICIOS_00_A_12.md);
8. [flujo especial WiFi del ejercicio 12](Doc/13_EJERCICIO_12_WIFI.md).

La guía distingue deliberadamente entre **fuente preparada**, **firmware que
compila** y **variante validada en placa**. Las carpetas FreeRTOS de 00–12 se
integran como aplicaciones del MSDK V1.0.3g para reutilizar el port
GD32VW553/ECLIC oficial. La validación física final se registra por ejercicio.

## Operación sin escribir comandos

El procedimiento docente se realiza desde los menús de VS Code. Los scripts
PowerShell son infraestructura interna de las tareas y el estudiante no tiene
que invocarlos manualmente. Use `Terminal > Run Task`, seleccione la tarea y
lea su salida en el panel integrado.

## Resultado de la prueba mínima

El archivo `Src/main.c` configura PC13 como salida y alterna su nivel
aproximadamente cada 500 ms. La espera activa solo se utiliza para comprobar la
cadena completa. No pretende ser una arquitectura recomendada para aplicaciones
reales.

## Archivos generados

Después de compilar aparecen en `build/debug/`:

| Archivo | Finalidad |
| --- | --- |
| `GD32VW55x.elf` | Ejecutable con símbolos; se programa y se depura. |
| `GD32VW55x.hex` | Imagen Intel HEX para programadores compatibles. |
| `GD32VW55x.bin` | Imagen binaria sin metadatos ni direcciones. |
| `GD32VW55x.map` | Mapa del enlace: símbolos, secciones y memoria. |
| `GD32VW55x.lst` | Código fuente mezclado con desensamblado. |

## Documentación

| Documento | Contenido |
| --- | --- |
| [01_HARDWARE_AND_TOOLS](Doc/01_HARDWARE_AND_TOOLS.md) | Placa, depurador y función de cada herramienta. |
| [02_INSTALLATION_WINDOWS](Doc/02_INSTALLATION_WINDOWS.md) | Instalación y localización de rutas. |
| [03_PROJECT_STRUCTURE](Doc/03_PROJECT_STRUCTURE.md) | Estructura del repositorio y archivos locales. |
| [04_CMAKE_EXPLAINED](Doc/04_CMAKE_EXPLAINED.md) | Toolchain, presets, fuentes, enlace y artefactos. |
| [05_VSCODE_CONFIGURATION](Doc/05_VSCODE_CONFIGURATION.md) | Extensiones, tareas e IntelliSense. |
| [06_BUILD_FLASH_DEBUG](Doc/06_BUILD_FLASH_DEBUG.md) | Compilar, programar y depurar paso a paso. |
| [07_CREATE_NEW_PROJECT](Doc/07_CREATE_NEW_PROJECT.md) | Crear un proyecto nuevo desde la plantilla. |
| [08_TROUBLESHOOTING](Doc/08_TROUBLESHOOTING.md) | Diagnóstico de errores frecuentes. |
| [09_ASSEMBLY_PASO_A_PASO](Doc/09_ASSEMBLY_PASO_A_PASO.md) | Integrar, compilar, grabar y depurar las variantes Assembly. |
| [10_FREERTOS_PASO_A_PASO](Doc/10_FREERTOS_PASO_A_PASO.md) | Kernel, port, heap, configuración, APIs y validación. |
| [11_VSCODE_Y_CONEXION_PLACA](Doc/11_VSCODE_Y_CONEXION_PLACA.md) | Drivers, USB, JTAG, puertos, extensiones y F5. |
| [12_EJERCICIOS_00_A_12](Doc/12_EJERCICIOS_00_A_12.md) | Orden de ejecución y evidencia esperada para cada ejercicio. |
| [13_EJERCICIO_12_WIFI](Doc/13_EJERCICIO_12_WIFI.md) | SDK WiFi, MBL/MSDK, UART/CH340, HTTP y alcance Assembly. |

## Estructura principal

```text
GD32VW553_VSCode_CMake_Guide/
├── .vscode/              # tareas, extensiones y ejemplo de depuración
├── Doc/                  # guía detallada
├── Inc/                  # encabezados propios
├── Src/                  # aplicación mínima
├── cmake/                # toolchain y generación del listado
├── tools/                # scripts de configuración, flash y diagnóstico
├── CMakeLists.txt        # descripción del firmware
├── CMakePresets.json     # configuraciones Debug y Release
└── README.md
```

## Dependencias externas y privacidad

El SDK, el compilador y OpenOCD no se copian en este repositorio. Cada persona
configura sus rutas en `tools/local_config.ps1`; ese archivo está ignorado por
Git. También se excluyen `build/` y `.vscode/launch.json`, porque contienen
resultados generados o rutas locales.

## Referencias oficiales

- [GigaDevice: familia GD32VW553](https://www.gigadevice.com/product/mcu/wireless-mcus/gd32vw553-series)
- [Nuclei SDK: placa GD32VW553H-EVAL](https://doc.nucleisys.com/nuclei_sdk/design/board/gd32vw553h_eval.html)
- [CMake: cmake-presets(7)](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)
- [Visual Studio Code: depuración](https://code.visualstudio.com/docs/debugtest/debugging)

## Licencia y alcance

La documentación y los archivos de configuración propios pueden reutilizarse
como material académico. Los componentes externos conservan sus respectivas
licencias. Verifique siempre el modelo exacto de la placa y su conexión antes
de programar la memoria.
