# 12. Ruta de ejecución de los ejercicios 00 a 12

## Procedimiento común para 00–11

1. Clone el repositorio correcto.
2. Abra su raíz exacta en VS Code.
3. Cree y complete `tools/local_config.ps1`.
4. Ejecute `Verify GD32 Environment`.
5. Lea `README.md`, `Doc/6_VARIANTES_DEL_EJERCICIO.md` y
   `Doc/7_PLAN_DE_VALIDACION.md`.
6. Ejecute primero la referencia original.
7. En `Terminal > Run Task`, seleccione **Build + Flash Assembly**.
8. En `Terminal > Run Task`, seleccione **Build + Flash FreeRTOS**; la tarea
   integra la aplicación en el MSDK V1.0.3g y usa su port GD32VW553/ECLIC.
9. Registre compilación, flash, observación física y variables GDB por separado.

## Mapa académico y evidencia esperada

| Nº | Ejercicio | Assembly puro | FreeRTOS | Evidencia principal |
| ---: | --- | --- | --- | --- |
| 00 | Blink polling | MMIO y espera activa | una tarea periódica | PC13 cambia con el periodo |
| 01 | Blink SysTimer | IRQ de 1 ms y contador | tick del kernel | contador y periodo de 1 s |
| 02 | Arreglo | suma/máximo signed | productor, procesador y Queue | suma 8, máximo 5, cinco pulsos |
| 03 | CRC-8 | CRC bit a bit | dos queues y tres tareas | `123456789 -> 0xF4` |
| 04 | FSM LED | estados no bloqueantes | productor + Queue + controlador | patrones lento, rápido y pausa |
| 05 | Event flags | AMO atómico | Event Groups | eventos 250/1000/5000 ms |
| 06 | Scheduler | tabla y despacho cooperativo | tres tareas periódicas | ejecuciones por periodo |
| 07 | Ring buffer | FIFO circular de 8 | Queue de 8 | orden, ocupación y overflows |
| 08 | Excepciones | trap y corrección de `mepc` | prueba dentro de una tarea | retorno después de `c.unimp` |
| 09 | UART parser | FIFO, FSM y CRC | Queue RX + Queue eventos | trama válida/rechazada |
| 10 | I2C virtual | mapa de registros | tarea + Queue | seis operaciones ACK/NACK |
| 11 | Secure element | SHA/HMAC fijo | autenticación + Queue | cinco pruebas y anti-replay |
| 12 | WiFi HTTP LED | banco local HTTP/LED | SDK WiFi completo | SoftAP, HTTP y LED real |

## Funcionamiento de cada ejercicio

### 00 — Blink polling

- **Assembly:** habilita el reloj de GPIOC, configura PC13, escribe BOP/BC y
  usa un retardo ocupado. Enseña MMIO, máscaras y branches.
- **FreeRTOS:** una tarea alterna PC13 y se bloquea con `vTaskDelayUntil`.
- **Prueba:** mida tres ciclos y confirme el periodo configurado. Mientras el
  Assembly espera, la CPU no puede hacer trabajo útil; la tarea FreeRTOS sí se
  bloquea.

### 01 — Blink con SysTimer

- **Assembly:** configura SysTimer/ECLIC, incrementa milisegundos en IRQ 7 y el
  `main` actúa cuando transcurre el intervalo.
- **FreeRTOS:** el port posee el tick y libera periódicamente la tarea.
- **Prueba:** observe el contador, el handler y el LED de 1 s. No instale dos
  handlers diferentes sobre la misma fuente de tick.

### 02 — Arreglo

- **Assembly:** recorre `{2,-1,5,3,-2,1}` con `lw`, suma y comparación signed.
- **FreeRTOS:** productor envía un trabajo, procesador calcula y una tercera
  tarea recibe el resultado mediante queues.
- **Prueba:** `suma=8`, `máximo=5` y patrón de cinco pulsos.

### 03 — CRC-8/ATM

- **Assembly:** aplica XOR y ocho shifts por byte con polinomio `0x07`.
- **FreeRTOS:** productor, procesador y validador se desacoplan mediante dos
  queues.
- **Prueba:** el vector estándar `123456789` debe resultar `0xF4`; el vector
  alterado debe ser diferente.

### 04 — Máquina de estados LED

- **Assembly:** conserva estado, fase, pulsos y próximo vencimiento sin espera
  activa.
- **FreeRTOS:** una tarea genera eventos y otra ejecuta la FSM al recibirlos.
- **Prueba:** tres pulsos lentos, cinco rápidos y pausa de 2 s; el contador de
  trabajo de fondo debe continuar creciendo.

### 05 — Banderas de eventos

- **Assembly:** la ISR publica bits mediante `amoor.w.aqrl`; el bucle los toma
  y limpia con `amoswap.w.aqrl` sin perder actualizaciones concurrentes.
- **FreeRTOS:** Event Groups expresan la misma publicación/espera.
- **Prueba:** confirme cinco segundos de conmutacion lenta (cada 500 ms),
  seguidos por cinco segundos de conmutacion rapida (cada 250 ms). El ciclo se
  repite; las banderas internas conservan periodos de 250, 1000 y 5000 ms.

### 06 — Planificador cooperativo

- **Assembly:** una tabla guarda periodo, próxima liberación y ejecuciones; el
  dispatcher invoca tareas vencidas.
- **FreeRTOS:** tres tareas independientes usan `vTaskDelayUntil`.
- **Prueba:** observe dos pulsos por segundo durante 5 segundos y luego tres
  pulsos por segundo durante 5 segundos. Confirme al menos dos cambios:
  `2 -> 3 -> 2 -> 3`.

### 07 — Ring buffer productor/consumidor

- **Assembly:** FIFO de ocho elementos, índices circulares con `& 7`,
  watermark, overflow, underflow y latencia.
- **FreeRTOS:** una Queue de ocho reemplaza el buffer manual; tareas separan
  producción, consumo, fases e indicador.
- **Prueba:** orden monotónico y comportamiento distinto en equilibrio,
  sobrecarga y drenaje. En la placa validada PC13 es activo en alto: queda
  apagado con la cola vacia, encendido con ocupacion parcial y parpadea cuando
  la cola esta llena.

### 08 — Recuperación de excepción

- **Referencia:** provoca deliberadamente `c.unimp` (`0x0000`), entra por la
  infraestructura de excepciones del SDK, comprueba causa 2 y corrige el
  `mepc` guardado antes de regresar.
- **Assembly:** captura `mcause`, `mepc` y `mtval`, reconoce que la instrucción
  mide 16 bits y suma dos al `mepc` de la trama oficial.
- **FreeRTOS:** `test_task` arma la prueba y ejecuta `c.unimp`. Una entrada
  mínima `exc_entry`, escrita con Assembly embebido, conserva sus registros
  temporales, comprueba causa 2, avanza el CSR `mepc` dos bytes y retorna con
  `mret`. Solo después del retorno normal se notifica a `indicator_task`.
- **Prueba:** en las tres variantes deben aparecer tres destellos cortos,
  seguidos por una pausa larga; el patrón se repite.

#### Ejecución manual en VS Code

1. Abra exclusivamente la carpeta `08_RISCV_Exception_Recovery` mediante
   **File > Open Folder**.
2. Abra `tools/local_config.ps1` y confirme las rutas del SDK V1.0.3g,
   toolchain Nuclei y OpenOCD.
3. Seleccione **Terminal > Run Task > Verify GD32 Environment**.
4. Seleccione **Terminal > Run Task > Build + Flash Original** y confirme los
   tres destellos con pausa.
5. Seleccione **Terminal > Run Task > Build + Flash Assembly** y repita la
   observación.
6. Seleccione **Terminal > Run Task > Build + Flash FreeRTOS**. Esta tarea
   limpia el MSDK compartido, copia `main.c` y `app_cfg.h`, compila MBL/MSDK,
   crea `image-all.bin` y lo programa desde `0x08000000`.
7. Compruebe en la salida `Programming Finished`, `Verified OK` y
   `Resetting Target`; después confirme el mismo patrón físico.

#### Qué debe observarse al depurar

| Símbolo | Valor correcto |
| --- | ---: |
| `g_exception_count` | `1` |
| `g_last_mcause & 0xFFF` | `2` |
| `g_last_instruction` | `0x0000` |
| `g_instruction_length` | `2` |
| `g_recovery_count` | `1` |
| `g_test_armed` | `0` |
| `g_test_completed` | `1` |
| `g_unexpected_exception` | `0` |

No llame APIs de FreeRTOS dentro de `exc_entry`. La notificación pertenece al
contexto normal de la tarea, después de ejecutar `mret`.

### 09 — Parser UART con CRC-8

- **Referencia:** una FIFO circular recibe el flujo simulado y alimenta una FSM
  con estados `WAIT_SOF`, `READ_LENGTH`, `READ_COMMAND`, `READ_PAYLOAD` y
  `READ_CRC`.
- **Assembly:** implementa FIFO, FSM y CRC-8/ATM con polinomio `0x07`; conserva
  la última trama válida y contabiliza ruido, overflow y rechazos.
- **FreeRTOS:** `producer_task` envía bytes a una Queue RX, `parser_task`
  ejecuta la FSM y una Queue de eventos desacopla `indicator_task`.
- **Prueba:** el flujo contiene dos bytes de ruido, dos tramas válidas, una
  trama con CRC alterado y una longitud inválida.

#### Formato y resultados

```text
SOF(0xA5) | LEN(0..8) | CMD | PAYLOAD | CRC-8
```

El CRC cubre `LEN + CMD + PAYLOAD`; no incluye `SOF`. Usa valor inicial
`0x00`, polinomio `0x07`, sin reflexión y sin XOR final.

| Caso | Resultado visible |
| --- | --- |
| trama válida `CMD=0x10` | dos destellos cortos |
| CRC alterado en `CMD=0x20` | un destello largo |
| longitud `0xFF` | un destello largo |
| trama válida `CMD=0x30` | dos destellos cortos |
| fin del ciclo | pausa y repetición |

#### Ejecución manual en VS Code

1. Abra únicamente `09_UART_Frame_Parser_CRC8` mediante **File > Open
   Folder**.
2. Revise `tools/local_config.ps1` y confirme las rutas del SDK bare-metal,
   MSDK V1.0.3g, toolchain Nuclei y OpenOCD.
3. Seleccione **Terminal > Run Task > Verify GD32 Environment**.
4. Ejecute **Build + Flash Original** y observe un ciclo completo.
5. Ejecute **Build + Flash Assembly** y confirme la misma secuencia.
6. Ejecute **Build + Flash FreeRTOS**. La tarea limpia el MSDK compartido,
   copia la aplicación, compila MBL/MSDK y programa `image-all.bin`.
7. Confirme `Programming Finished`, `Verified OK` y `Resetting Target` en la
   terminal integrada.

#### Variables de comprobación

| Variable | Incremento esperado por ciclo |
| --- | ---: |
| `g_frames_accepted` | `2` |
| `g_frames_rejected` | `2` |
| `g_crc_errors` | `1` |
| `g_length_errors` | `1` |
| `g_noise_bytes` | `2` |
| `g_rx_overflows` | `0` |

La última trama válida debe conservar `CMD=0x30`, `LEN=3` y payload
`01 02 03`. Esta comprobación valida el parser con productor simulado. Para
usar UART física, reemplace el productor por una ISR que publique con
`xQueueSendFromISR`; esa ruta requiere una validación independiente.

### 10 — Mapa de registros I2C virtual

- **Assembly:** implementa direcciones, registro seleccionado, datos
  big-endian, repeated START, ACK y causas NACK.
- **FreeRTOS:** una tarea ejecuta el guion y envía resultados a la indicadora.
- **Prueba:** seis transacciones y coherencia de siete registros. Es una
  simulación de protocolo, no señales eléctricas SDA/SCL.

### 11 — Secure element simulado

- **Assembly:** challenges, anti-replay, comparación acumulativa y HMAC-SHA256
  fijo de clave/mensaje de 32 bytes.
- **FreeRTOS:** tarea de autenticación y Queue de resultados; reutiliza
  `Src/sha256.c` como primitiva auditada.
- **Prueba:** cinco casos, rechazo de replay y patrón visual. No presente el
  HMAC Assembly pedagógico como biblioteca criptográfica general.

### 12 — Control HTTP por WiFi

- **Assembly:** seis solicitudes locales verifican parser, modos y PC13; no
  implementa radio ni red.
- **FreeRTOS:** el MSDK oficial ejecuta tareas WiFi/HTTP y LED sobre lwIP.
- **Prueba:** SoftAP `GD32_LED_LAB`, IP `192.168.237.1`, seis endpoints,
  respuestas HTTP 200 y cambio físico del LED.

## Orden recomendado dentro de cada ejercicio

### A. Referencia

Compile y ejecute sin cambiar archivos. Esto confirma hardware, toolchain y
OpenOCD antes de introducir otra variante.

### B. Assembly

Lea primero `Ensamblador_RISCV_Puro/README.md` y `DEPURACION.md`. Integre el o
los `.S`, compile Debug, inspeccione `.lst`, programe y observe los `g_*`.

### C. FreeRTOS

Lea `FreeRTOS_Puro/README.md` e `INTEGRACION.md`. Identifique APIs, número de
tareas, prioridades, stacks, objetos y módulos extra. No programe una imagen
que solo compiló parcialmente ni sustituya un port sin verificar.

## Estado honesto de ejecución

- Los ejercicios 00, 01, 02, 03, 04, 05, 06, 07, 08 y 09 fueron compilados,
  programados y comprobados físicamente en las tres variantes desde VS Code
  con WCH-Link.
- Las referencias bare-metal de 00–11 poseen infraestructura de compilación.
- Los Assembly de 00–11 se seleccionan con `APP_VARIANT=assembly` y se
  construyen con `tools/build_variant.ps1`.
- Los FreeRTOS de 00–12 son aplicaciones del MSDK oficial V1.0.3g.
- La prueba física de cada variante debe registrarse sobre la placa real.
- El Assembly de 12 no implementa radio ni TCP; valida la capa de aplicación.

## Hoja de registro sugerida

| Campo | Valor |
| --- | --- |
| ejercicio y variante | |
| commit probado | |
| placa exacta | |
| SDK/toolchain | |
| compilación | pasa/falla |
| flash verify | pasa/falla |
| evidencia física | |
| símbolos observados | |
| limitaciones | |
