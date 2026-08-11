# 7. Crear un proyecto nuevo

Hay dos métodos seguros. Ninguno copia `build/`, `.git`, rutas personales ni
binarios.

## Método A: usar el script

Desde la raíz de esta guía:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\create_project.ps1 `
  -Name Mi_Proyecto_GD32 `
  -DestinationRoot ..
```

El proyecto se crea como carpeta hermana. El nombre solo puede contener letras,
números, guion y guion bajo. Por seguridad, el script se detiene si el destino
ya existe; no sobrescribe trabajo.

Después:

```powershell
cd ..\Mi_Proyecto_GD32
Copy-Item .\tools\local_config.example.ps1 .\tools\local_config.ps1
notepad .\tools\local_config.ps1
code .
```

Ejecute `Verify GD32 Environment`, `Build + Flash GD32` y luego cree la
configuración de depuración.

## Método B: copiar manualmente

Copie:

- `.vscode/`;
- `cmake/`;
- `Inc/`;
- `Src/`;
- `tools/`, excepto cualquier `local_config.ps1` privado;
- `.gitignore`;
- `CMakeLists.txt`;
- `CMakePresets.json`.

Cambie únicamente el nombre dentro de:

```cmake
project(Mi_Proyecto_GD32 LANGUAGES C ASM)
```

Mantenga `TARGET_NAME GD32VW55x` si desea conservar los nombres que esperan los
scripts. Si lo cambia, debe actualizar también `flash.ps1`, `launch.json` y las
rutas de salida.

## Agregar un módulo C

Ejemplo de archivos:

```text
Inc/led.h
Src/led.c
```

Agregue el fuente al bloque `APP_SOURCES`:

```cmake
set(APP_SOURCES
    Src/main.c
    Src/led.c
    ...
)
```

Los encabezados de `Inc/` ya están en la ruta de includes.

## Agregar ensamblador RISC-V

Use `.S` cuando necesite preprocesador C:

```text
Src/funciones_riscv.S
Inc/funciones_riscv.h
```

En CMake:

```cmake
set(APP_SOURCES
    Src/main.c
    Src/funciones_riscv.S
    ...
)
```

Declare las funciones en el `.h` y respete la ABI RISC-V: argumentos y retorno
en `a0`–`a7`, temporales `t0`–`t6` y preservación de registros `s0`–`s11` si la
rutina los modifica.

## Agregar un periférico

1. Incluya el encabezado correspondiente en `Inc/gd32vw55x_libopt.h`, por
   ejemplo `gd32vw55x_usart.h`.
2. Habilite el reloj del periférico.
3. Configure GPIO y multiplexación.
4. Inicialice el periférico.
5. compile y revise el primer error, no toda la cascada.

## Lista de control antes de crear Git

```powershell
git check-ignore .\build
git check-ignore .\tools\local_config.ps1
git check-ignore .\.vscode\launch.json
```

Cada comando debe imprimir la ruta ignorada. Después:

```powershell
git init
git add --all
git status --short
```

Revise que no aparezcan el SDK, toolchain, `build/`, `local_config.ps1` ni
`launch.json` antes de hacer el primer commit.
