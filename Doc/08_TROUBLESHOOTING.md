# 8. Solución de problemas

## Método de diagnóstico

1. lea el **primer** error real;
2. identifique la fase: configurar, compilar, enlazar, flash o depurar;
3. ejecute `Verify GD32 Environment`;
4. corrija una causa y repita esa misma fase;
5. elimine `build/` solo cuando cambie toolchain, SDK o configuración estructural.

Antes de tocar el código, ubique la capa que falla: Windows/USB, OpenOCD/JTAG,
GDB/VS Code, compilación o lógica. Consulte también
[11_VSCODE_Y_CONEXION_PLACA.md](11_VSCODE_Y_CONEXION_PLACA.md).

## Tabla rápida

| Mensaje o síntoma | Causa probable | Corrección |
| --- | --- | --- |
| `riscv-nuclei-elf-gcc was not found` | Ruta incorrecta o no exportada a `try_compile`. | Revise `NUCLEI_TOOLCHAIN_DIR` y use `tools/configure.ps1`. |
| `CMAKE_C_COMPILER not set` | Consecuencia del error anterior. | Corrija primero la ruta del compilador. |
| `No se encontro ... system_gd32vw55x.c` | `GD32_SDK_ROOT` no apunta a la raíz. | Seleccione la carpeta que contiene `Firmware/`. |
| `ninja: no work to do` | No hay archivos guardados más recientes. | Es normal; guarde el cambio si esperaba recompilación. |
| OpenOCD no abre el ELF | Ruta perdió `\` o contiene espacios sin proteger. | Use `tools/flash.ps1`, que convierte a `/` y encierra la ruta entre llaves. |
| `Unable to start debugging` con `a.exe` | VS Code creó un launch genérico de escritorio. | Elimínelo y ejecute `Create Debug Configuration`. |
| `monitor reset halt not supported` | Comando enviado como consola GDB genérica. | Use la configuración Cortex-Debug incluida. |
| `Specified argument ... arch` | Adaptador de depuración no compatible/configurado. | Instale Cortex-Debug y regenere `launch.json`. |
| Breakpoint gris o no alcanzado | ELF incorrecto, optimización o línea sin instrucción. | Use Debug, recompilar, flash y un punto en una sentencia ejecutable. |
| LED no cambia | Solo se compiló; no se programó. | Ejecute `Build + Flash GD32`. |
| OpenOCD no encuentra el probe | Cable, driver, puerto ocupado o conexión JTAG. | Reconecte, cierre otras sesiones y revise el Administrador de dispositivos. |

## Limpiar una configuración antigua

PowerShell, desde la raíz exacta del proyecto:

```powershell
Remove-Item .\build -Recurse -Force -ErrorAction SilentlyContinue
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\configure.ps1 -BuildType Debug
cmake --build --preset build-debug
```

No use comandos de borrado sobre una variable o ruta que no haya comprobado.

## PowerShell muestra errores con `PS C:\...>` o `??`

El indicador `PS C:\...>` y la salida de un comando no son instrucciones. Copie
solo las líneas de código dentro de los bloques. Por ejemplo:

```powershell
git status --short
```

Las líneas `?? archivo` son la respuesta de Git e indican archivos no seguidos.

## Ejecución de scripts deshabilitada

Use el proceso temporal incluido en las tareas:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\configure.ps1
```

No es necesario cambiar permanentemente la política del computador.

## Conflicto en el puerto 3333

Una sesión anterior de OpenOCD puede seguir abierta. Detenga la depuración en
VS Code. Si el problema continúa, cierre únicamente procesos OpenOCD que usted
haya iniciado:

```powershell
Get-Process openocd -ErrorAction SilentlyContinue
```

Luego vuelva a iniciar la sesión.

## IntelliSense marca errores, pero CMake compila

El resultado de CMake es la referencia para la compilación. Reconfigure y
reinicie la base de IntelliSense. No cambie opciones de arquitectura solo para
eliminar subrayados del editor.

## El programa compiló, pero la placa conserva el comportamiento anterior

Revise en orden:

1. guardó `Src/main.c`;
2. la terminal mostró compilación y enlace;
3. OpenOCD mostró `Programming Finished` y `Verified OK`;
4. el ELF usado pertenece a `build/debug` del proyecto abierto;
5. no está ejecutándose un `launch.json` de otra carpeta.

## Datos que conviene adjuntar al pedir ayuda

- primer error completo;
- salida de `tools/verify_environment.ps1` sin publicar rutas sensibles si no
  desea compartirlas;
- salida de `cmake --build --preset build-debug`;
- versión de CMake y Ninja;
- modelo exacto de la placa y del depurador;
- tarea seleccionada en VS Code.
