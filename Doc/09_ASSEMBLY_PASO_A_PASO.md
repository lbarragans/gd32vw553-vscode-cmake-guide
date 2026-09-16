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

## 9.3 Abrir la variante sin alterar la referencia

No sustituya la referencia original. En el explorador de VS Code abra
`Ensamblador_RISCV_Puro/main.S`; el CMake del repositorio selecciona esta
fuente mediante la tarea Assembly y mantiene intactos los archivos de `Src/`.

## 9.4 Seleccionar el archivo en CMake

Los ejercicios 00–11 incorporan `APP_VARIANT=original|assembly`. El CMake
selecciona solo una lógica de aplicación y conserva startup, sistema, drivers y
linker script. Así se evita compilar simultáneamente dos definiciones de `main`.

Para construir Assembly abra `Terminal > Run Task` y seleccione
**Build + Flash Assembly**.

Algunos ejercicios necesitan símbolos de infraestructura del SDK:

- SysTimer/ECLIC: startup y wrapper de interrupción;
- excepciones: `Exception_Register_EXC` y `entry.S` del SDK;
- SHA-256 fijo: incluya también `sha256_fixed.S`;
- ejercicio 12: siga su flujo especial; el Assembly solo prueba la capa HTTP/LED.

## 9.5 Configurar y compilar

1. Prepare `local_config.ps1` desde el explorador según el capítulo 11.
2. Abra `Terminal > Run Task`.
3. Seleccione **Verify GD32 Environment**.
4. Seleccione **Build + Flash Assembly**.
5. Abra `build/debug/GD32VW55x.lst` desde el explorador para comprobar las
   instrucciones y símbolos esperados.

## 9.6 Programar y ejecutar

1. Desconecte la alimentación.
2. Una GND del probe con GND de la placa.
3. Conecte las señales JTAG indicadas por el esquema de la placa.
4. Use niveles de 3,3 V; no inyecte 5 V en JTAG.
5. Conecte el probe al PC y alimente la placa.
6. En `Terminal > Run Task`, seleccione **Build + Flash Assembly**.

El éxito requiere las tres ideas siguientes en la salida:

```text
Programming Finished
Verified OK
Resetting Target
```

## 9.7 Depurar Assembly en VS Code

Genere la configuración una sola vez seleccionando **Create Debug
Configuration** en `Terminal > Run Task`. Después:

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
