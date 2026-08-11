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

## launch.json reproducible

`.vscode/launch.example.json` solo muestra la estructura. No debe editarse con
rutas personales. Ejecute:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\create_debug_config.ps1
```

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
