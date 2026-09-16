# 9. Ensamblador RISC-V: preparación y ejecución paso a paso

## 9.1 Qué se ejecuta realmente

Los archivos `Ensamblador_RISCV_Puro/main.S` contienen la lógica de aplicación
en Assembly RV32. El archivo `.S` no reemplaza el arranque del microcontrolador,
el mapa de memoria ni el programador. El firmware final todavía necesita:

- `startup_gd32vw55x.S`, que prepara pila, datos, BSS y tabla de vectores;
- `GD32VW553xM.lds`, que distribuye el programa en Flash y SRAM;
- `system_gd32vw55x.c`, que configura reloj y plataforma;
- el compilador, ensamblador, enlazador y GDB de Nuclei;
- OpenOCD y un probe CMSIS-DAP/JTAG para grabar y depurar.

Por eso «Assembly puro» significa **sin C en la lógica del ejercicio**, no
«un único archivo que funciona sin infraestructura de arranque».

## 9.2 Extensiones `.S` y `.s`

Use `.S` mayúscula. GCC aplica primero el preprocesador y después el
ensamblador. Esto permite `#include`, símbolos y opciones comunes del proyecto.
Un `.s` minúsculo se envía directamente al ensamblador.

## 9.3 Preparar una copia de trabajo

No sustituya la referencia original. Desde la raíz de un ejercicio 00–11:

```powershell
New-Item -ItemType Directory -Force .\Trabajo_Assembly | Out-Null
Copy-Item .\Ensamblador_RISCV_Puro\main.S .\Trabajo_Assembly\main.S -Force
```

La forma recomendada es crear una rama antes de integrar:

```powershell
git switch -c laboratorio/assembly
```

## 9.4 Añadir el archivo al proyecto CMake

Abra `CMakeLists.txt`, localice `APP_SOURCES` y sustituya únicamente el fuente
de aplicación `Src/main.c` por:

```cmake
Ensamblador_RISCV_Puro/main.S
```

Conserve startup, sistema, drivers y linker script. El bloque debe mantener
`ASM` en la declaración del proyecto:

```cmake
project(NombreDelEjercicio LANGUAGES C ASM)
```

No compile simultáneamente dos archivos que definan `main`, porque el linker
informará `multiple definition of main`.

Algunos ejercicios necesitan símbolos de infraestructura del SDK:

- SysTimer/ECLIC: startup y wrapper de interrupción;
- excepciones: `Exception_Register_EXC` y `entry.S` del SDK;
- SHA-256 fijo: incluya también `sha256_fixed.S`;
- ejercicio 12: siga su flujo especial; el Assembly solo prueba la capa HTTP/LED.

## 9.5 Configurar y compilar

Desde la raíz del ejercicio:

```powershell
Copy-Item .\tools\local_config.example.ps1 .\tools\local_config.ps1 -ErrorAction SilentlyContinue
notepad .\tools\local_config.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\verify_environment.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\configure.ps1 -BuildType Debug
cmake --build --preset build-debug
```

Compruebe que el listado contiene las instrucciones esperadas:

```powershell
Select-String -Path .\build\debug\*.lst -Pattern "main:|eclic_mtip_handler:"
```

Si cambió fuentes o toolchain y CMake conserva una configuración vieja:

```powershell
Remove-Item .\build -Recurse -Force
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\configure.ps1 -BuildType Debug
cmake --build --preset build-debug
```

## 9.6 Programar y ejecutar

1. Desconecte la alimentación.
2. Una GND del probe con GND de la placa.
3. Conecte las señales JTAG indicadas por el esquema de la placa.
4. Use niveles de 3,3 V; no inyecte 5 V en JTAG.
5. Conecte el probe al PC y alimente la placa.
6. Ejecute:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\flash.ps1 -BuildType Debug
```

El éxito requiere las tres ideas siguientes en la salida:

```text
Programming Finished
Verified OK
Resetting Target
```

## 9.7 Depurar Assembly en VS Code

Genere la configuración una sola vez:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\create_debug_config.ps1
```

Después:

1. abra `Ensamblador_RISCV_Puro/main.S`;
2. coloque un breakpoint en una instrucción real, no en un comentario o label;
3. presione `F5`;
4. use Step Into para avanzar instrucción por instrucción;
5. abra Registers y observe `pc`, `sp`, `ra`, `a0-a7`, `s0-s11` y `t0-t6`;
6. agregue a Watch los símbolos `g_*` descritos en `DEPURACION.md`;
7. abra el `.lst` para relacionar dirección, instrucción y fuente.

## 9.8 Convención ABI mínima

| Registros | Responsabilidad |
| --- | --- |
| `a0-a7` | argumentos y valores de retorno |
| `t0-t6` | temporales; una función llamada puede cambiarlos |
| `s0-s11` | deben preservarse si la función los modifica |
| `ra` | dirección de retorno; guárdela si la función llama otra función |
| `sp` | pila, alineada según la ABI |

Una rutina que usa `s1` y llama otra función debe salvar ambos:

```asm
addi sp, sp, -16
sw   s1, 8(sp)
sw   ra, 12(sp)
/* cuerpo */
lw   s1, 8(sp)
lw   ra, 12(sp)
addi sp, sp, 16
ret
```

## 9.9 Cuándo considerar validada la variante

Marque por separado:

1. sintaxis revisada;
2. compilación y enlace correctos;
3. flash verificada;
4. comportamiento físico observado;
5. variables y contadores comprobados con GDB.

Que `main.S` exista no demuestra los puntos 2–5.
