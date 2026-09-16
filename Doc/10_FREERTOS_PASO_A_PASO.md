# 10. FreeRTOS: funcionamiento e integración paso a paso

## 10.1 Qué es y qué no es FreeRTOS

FreeRTOS es un kernel de tiempo real escrito principalmente en C. No es un
lenguaje ni sustituye el SDK del microcontrolador. El código de cada ejercicio
crea tareas, colas, notificaciones o grupos de eventos; el kernel decide cuál
tarea se ejecuta y el port RISC-V realiza los cambios de contexto.

## 10.2 Piezas obligatorias

| Pieza | Función |
| --- | --- |
| `tasks.c` | scheduler, estados y listas de tareas |
| `queue.c` | queues, semáforos y mutexes |
| `list.c` | listas internas del kernel |
| `event_groups.c` | Event Groups cuando el ejercicio los usa |
| `timers.c` | software timers, solo si se habilitan |
| `portable/.../port.c` | cambio de contexto y tick para RISC-V |
| `portASM.S` | entrada/salida de contexto en Assembly |
| `heap_4.c` | asignador recomendado para estos laboratorios |
| `FreeRTOSConfig.h` | reloj, tick, prioridades, heap y hooks |

No mezcle un `port.c` genérico al azar con startup, ABI o control de
interrupciones diferentes. Para GD32VW553 debe usarse un port compatible con el
nucleo Nuclei/ECLIC y con el SDK seleccionado.

## 10.3 Dos rutas diferentes del curso

### Ejercicios 00–11

La biblioteca bare-metal `GD32VW55x_Firmware_Library_V1.6.0` aporta drivers y
startup, pero las carpetas `FreeRTOS_Puro/` del curso contienen principalmente
la **aplicación**. Antes de ejecutarlas todavía hay que integrar kernel, port,
heap, configuración y tick. No deben anunciarse como validadas hasta compilar y
probar esa integración.

### Ejercicio 12

Use `GD32VW55x_RELEASE_V1.0.3g`. Este SDK ya incorpora el FreeRTOS y las capas
WiFi/lwIP compatibles. No descargue otro kernel ni sustituya su port. Copie la
aplicación en `MSDK/app_http_led` siguiendo el capítulo 13.

## 10.4 Obtener el kernel

La fuente oficial está en:

```text
https://github.com/FreeRTOS/FreeRTOS-Kernel
```

Para una integración reproducible, clone una versión conocida en una carpeta
externa al repositorio del ejercicio:

```powershell
Set-Location C:\GD32
git clone https://github.com/FreeRTOS/FreeRTOS-Kernel.git
Set-Location .\FreeRTOS-Kernel
git tag --list
```

No copie automáticamente el port RISC-V hasta confirmar que soporta el modelo
de interrupciones usado por GD32VW553. La opción más segura es partir del port
que acompañe un ejemplo oficial de GD32VW55x o del SDK WiFi validado.

## 10.5 Configuración mínima que debe decidirse

Ejemplo conceptual de `FreeRTOSConfig.h`:

```c
#define configCPU_CLOCK_HZ             160000000UL
#define configTICK_RATE_HZ             1000U
#define configMAX_PRIORITIES            8U
#define configMINIMAL_STACK_SIZE       256U
#define configTOTAL_HEAP_SIZE          (24U * 1024U)
#define configUSE_PREEMPTION             1
#define configUSE_TIME_SLICING           1
#define configUSE_16_BIT_TICKS            0
#define configSUPPORT_DYNAMIC_ALLOCATION  1
#define configCHECK_FOR_STACK_OVERFLOW    2
#define configUSE_MALLOC_FAILED_HOOK      1
```

Estos valores son una base docente, no una garantía universal. El reloj debe
coincidir con `SystemCoreClock`, el heap debe caber en SRAM y los nombres de
handlers deben coincidir con el port.

## 10.6 Integración CMake de referencia

Defina la raíz externamente, no con una ruta personal publicada:

```cmake
set(FREERTOS_KERNEL_ROOT "" CACHE PATH "Raiz de FreeRTOS-Kernel")
```

La lista típica incluye:

```cmake
set(FREERTOS_SOURCES
    "${FREERTOS_KERNEL_ROOT}/tasks.c"
    "${FREERTOS_KERNEL_ROOT}/queue.c"
    "${FREERTOS_KERNEL_ROOT}/list.c"
    "${FREERTOS_KERNEL_ROOT}/event_groups.c"
    "${FREERTOS_KERNEL_ROOT}/portable/MemMang/heap_4.c"
    # port.c y portASM.S compatibles con GD32VW553/ECLIC
)
```

Añada includes para la raíz del kernel, la carpeta del port y la carpeta que
contiene `FreeRTOSConfig.h`. Sustituya `Src/main.c` por
`FreeRTOS_Puro/main.c`; conserve los módulos adicionales que cada ejercicio
requiera, por ejemplo `Src/sha256.c` en el ejercicio 11.

## 10.7 Qué hace cada API usada en los laboratorios

| API | Significado |
| --- | --- |
| `xTaskCreate` | crea una tarea, pila, prioridad y contexto inicial |
| `vTaskStartScheduler` | inicia tick y planificación; normalmente no retorna |
| `vTaskDelay` | bloquea durante una cantidad relativa de ticks |
| `vTaskDelayUntil` | mantiene un periodo respecto de una referencia temporal |
| `xQueueCreate` | reserva una cola de longitud y tamaño de elemento definidos |
| `xQueueSend` | copia un elemento a la cola; puede bloquear si está llena |
| `xQueueReceive` | obtiene un elemento; puede bloquear sin consumir CPU |
| `xTaskNotifyGive` | envía una notificación ligera a una tarea |
| `ulTaskNotifyTake` | espera/consume esa notificación |
| `xEventGroupSetBits` | publica varios eventos como bits |
| `xEventGroupWaitBits` | espera una combinación de bits |

Desde una ISR use exclusivamente las variantes `...FromISR` y solicite el
cambio de contexto con la macro definida por el port cuando corresponda.

## 10.8 Compilar y depurar

Una vez integrada la plataforma:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\verify_environment.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\configure.ps1 -BuildType Debug
cmake --build --preset build-debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\flash.ps1 -BuildType Debug
```

Coloque breakpoints en la primera línea de cada tarea y observe:

- que `vTaskStartScheduler()` no retorna;
- que una tarea bloqueada no ejecuta un bucle de espera;
- profundidad máxima de las queues;
- stack disponible mediante `uxTaskGetStackHighWaterMark` si está habilitado;
- hooks de overflow y malloc fallido.

## 10.9 Errores frecuentes

| Síntoma | Causa probable |
| --- | --- |
| `FreeRTOS.h: No such file` | faltan include directories del kernel/configuración |
| símbolos `vTask*` indefinidos | faltan fuentes del kernel en el target |
| símbolos `xPort*` indefinidos | falta port RISC-V o `portASM.S` |
| queda en `vTaskStartScheduler` | tick/IRQ/heap/port incorrectos |
| HardFault/trap al cambiar tarea | ABI, pila, port o alineación incompatibles |
| LED funciona pero ninguna otra tarea | prioridad, bloqueo o starvación |
| tick dos o cuatro veces rápido | `configCPU_CLOCK_HZ` o divisor incorrecto |

## 10.10 Criterio de validación

La variante FreeRTOS solo está cerrada cuando se verifican kernel/port usados,
compilación, enlace, scheduler activo, patrón físico, contadores y ausencia de
overflow de pila. «Fuente lista» no equivale a «firmware validado».
