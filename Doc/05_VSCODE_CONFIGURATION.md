# 5. Configuración de Visual Studio Code

## Abrir la raíz correcta

Use `File > Open Folder` y seleccione la carpeta que contiene simultáneamente
`CMakeLists.txt`, `CMakePresets.json`, `Src`, `tools` y `.vscode`.

Si abre la carpeta superior, `${workspaceFolder}` apuntará al lugar equivocado
y las tareas no encontrarán los scripts.

## Workspace Trust

VS Code puede abrir un proyecto descargado en Restricted Mode. Revise el origen
y, para este repositorio conocido, seleccione **Trust this folder**. Las tareas
y la depuración no se habilitan completamente en modo restringido.

## Extensiones

`.vscode/extensions.json` recomienda:

- `ms-vscode.cpptools`;
- `ms-vscode.cmake-tools`;
- `marus25.cortex-debug`.

Abra Extensions con `Ctrl+Shift+X` y compruebe que estén instaladas y activas.

Para comprobarlas desde la terminal integrada:

```powershell
code --list-extensions | Select-String "ms-vscode.cpptools|ms-vscode.cmake-tools|marus25.cortex-debug"
```

La conexión USB, el Administrador de dispositivos, JTAG, CH340 y el diagnóstico
por capas se explican en
[11_VSCODE_Y_CONEXION_PLACA.md](11_VSCODE_Y_CONEXION_PLACA.md).

## Tareas incluidas

Abra `Terminal > Run Task`:

| Tarea | Acción |
| --- | --- |
| `Verify GD32 Environment` | Comprueba programas y rutas. |
| `Create Debug Configuration` | Genera `launch.json` con rutas locales. |
| `Configure GD32 Debug` | Ejecuta el preset de configuración. |
| `Build GD32 Debug` | Configura y compila. Es la tarea de build por defecto. |
| `Flash GD32 Debug` | Programa el ELF ya generado. |
| `Build + Flash GD32` | Compila y programa en secuencia. |

`Ctrl+Shift+B` ejecuta la tarea de compilación predeterminada. Para programar la
placa use explícitamente `Build + Flash GD32`, porque compilar no modifica la
flash.

## CMake Presets y rutas reproducibles

La selección de generador, carpeta de salida, modo Debug/Release, toolchain y
SDK se encuentra en `CMakePresets.json`. No se guardan rutas de compilación en
`.vscode/settings.json`.

Los presets compartidos usan la estructura docente:

```text
C:/gd32_tools/GD32VW55x_Firmware_Library_V1.6.0
C:/gd32_tools/nuclei/bin
```

Por eso **CMake: Select Configure Preset** debe mostrar `GD32VW553 Debug` y
`GD32VW553 Release` en cualquier computador preparado según la guía. El preset
Debug genera exclusivamente `build/debug`; Release usa `build/release`.

`tools/local_config.ps1` conserva OpenOCD y permite reemplazar rutas en un
equipo administrativo que no pueda usar `C:\gd32_tools`. La línea de comandos
de `tools/configure.ps1` tiene prioridad sobre los valores predeterminados del
preset. Así se obtiene un camino uniforme para estudiantes sin impedir una
configuración local excepcional.

## launch.json reproducible

`.vscode/launch.example.json` solo muestra la estructura. No debe editarse con
rutas personales. Abra `Terminal > Run Task` y seleccione **Create Debug
Configuration**.

El script lee `tools/local_config.ps1` y crea `.vscode/launch.json`. Este último
queda excluido de Git.

## IntelliSense frente a compilación

Los subrayados de IntelliSense no determinan si CMake puede compilar. CMake
controla la compilación real. Si IntelliSense todavía no descubre los includes:

1. asegúrese de haber configurado el proyecto;
2. en la paleta de comandos ejecute `CMake: Configure` o la tarea propia;
3. ejecute `C/C++: Reset IntelliSense Database`;
4. vuelva a cargar la ventana.

No duplique manualmente todas las rutas del SDK en `c_cpp_properties.json` si
CMake Tools ya puede aportar la información de compilación.

## Vista previa de Markdown

Abra un `.md` y use `Ctrl+Shift+V`. Si el atajo está ocupado, abra la paleta con
`Ctrl+Shift+P` y elija `Markdown: Open Preview`.
