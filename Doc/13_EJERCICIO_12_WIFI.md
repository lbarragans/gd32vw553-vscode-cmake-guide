# 13. Ejercicio 12: FreeRTOS, WiFi y HTTP

## 13.1 Por qué usa otro flujo

WiFi requiere firmware de radio, calibración RF, controladores, FreeRTOS,
lwIP, DHCP, TCP y bibliotecas del fabricante. Use el SDK
`GD32VW55x_RELEASE_V1.0.3g` validado por el ejercicio; no el CMake bare-metal de
00–11 ni un kernel FreeRTOS descargado por separado.

## 13.2 Estado realmente comprobado

| Variante | Estado |
| --- | --- |
| Original WiFi | compila, programa, crea SoftAP, responde HTTP y controla LED |
| Assembly | compila, programa y ejecuta su patrón LED; no contiene WiFi |
| FreeRTOS | compila completamente; prueba física pendiente |

Nunca use “compiló” como sinónimo de “funcionó en la placa”.

## 13.3 Componentes

- GD32 Embedded Builder y su toolchain;
- `GD32VW55x_RELEASE_V1.0.3g`;
- WCH-Link con interfaz `WCH CMSIS-DAP` reconocida por Windows;
- OpenOCD incluido con GD32 Embedded Builder;
- carpeta `FreeRTOS_Puro/` o `VendorApp/` del ejercicio;
- panel `Web/GD32_LED_CONTROL_LOCAL.html`.

## 13.4 Integrar la aplicación

1. Extraiga el SDK en una ruta corta:

```text
C:\GD32\GD32VW55x_RELEASE_V1.0.3g
```

2. Cree:

```text
C:\GD32\GD32VW55x_RELEASE_V1.0.3g\MSDK\app_http_led
```

3. Copie desde `FreeRTOS_Puro/`:

```text
main.c
app_cfg.h
CMakeLists.txt
```

4. No copie `main.S` en esta aplicación WiFi: esa fuente es un banco local de
la capa HTTP/LED, no una pila de radio.
5. Compile primero MBL y después MSDK usando la configuración del SDK.
6. Construya `image-all.bin` con MBL en offset 0 y MSDK en `0xA000`.

## 13.5 Reconocer el depurador

Abra el Administrador de dispositivos. Deben aparecer:

```text
WCH CMSIS-DAP
WCH-Link SERIAL (COMx)
```

La programación JTAG utiliza **WCH CMSIS-DAP**. El puerto COM no programa esta
imagen. Si la interfaz CMSIS-DAP no aparece, OpenOCD terminará con
`unable to find a matching CMSIS-DAP device`.

## 13.6 Programar manualmente desde VS Code

1. Conecte la placa y el WCH-Link.
2. Abra solamente la carpeta raíz del ejercicio 12 en VS Code.
3. Abra **Terminal > Run Task**.
4. Elija **Verify GD32 Environment**.
5. Elija **Build + Flash Original WiFi**.
6. Observe la terminal integrada hasta encontrar `Programming Finished`,
   `Verified OK` y `Resetting Target`.
7. Desconecte el WCH-Link de la placa, conserve la alimentación USB y pulse
   RESET para ejecutar normalmente.

La tarea usa CMSIS-DAP v2 por USB bulk, JTAG y 50 kHz. Si el núcleo queda
bloqueado o pide autenticación, mantenga BOOT pulsado, pulse y suelte RESET,
espere dos segundos, suelte BOOT y repita la tarea.

El mensaje `checksum mismatch - attempting binary compare` no representa un
fallo si inmediatamente después aparece `Verified OK`.

## 13.7 Probar

1. Busque la red abierta `GD32_LED_LAB`.
2. Conecte el computador o teléfono.
3. Aunque Windows indique “sin Internet”, permanezca conectado a esa red.
4. En VS Code seleccione **Terminal > Run Task > Open local HTTP panel**.
5. Pulse **Conectar** en el panel y pruebe Encender, Apagar, Alternar,
   Parpadeo lento y Parpadeo rápido.
6. Confirme cambio físico de PC13 y respuestas HTTP 200.

Algunos navegadores muestran en blanco la raíz embebida. Esto no implica que
HTTP haya fallado. El panel local es el método de uso recomendado y consulta
la API real de la placa en `http://192.168.237.1`.

## 13.8 Assembly del ejercicio 12

`Ensamblador_RISCV_Puro/main.S` ejecuta seis solicitudes simuladas, parser,
modos y LED. Se integra como una prueba bare-metal de lógica. No crea el
SoftAP; por tanto no debe usarse como evidencia de WiFi real.

Para ejecutarlo desde VS Code use **Terminal > Run Task > Build + Flash
Assembly**. La evidencia esperada es el patrón del LED descrito en el README de
la variante, no la aparición de `GD32_LED_LAB`.

## 13.9 FreeRTOS

Use **Build + Flash FreeRTOS WiFi**. La compilación está comprobada, pero la
guía conserva el estado “prueba física pendiente” hasta observar la misma
evidencia completa de la variante Original. Si OpenOCD no encuentra
CMSIS-DAP, reconecte el WCH-Link; no recompile innecesariamente.

## 13.10 Diagnóstico

| Síntoma | Revisión |
| --- | --- |
| no aparece CMSIS-DAP | reconectar WCH-Link, cambiar cable/USB y cerrar depuración |
| OpenOCD no encuentra dispositivo | verificar `WCH CMSIS-DAP`, no solo el COM |
| programa pero no arranca | BOOT0, reset e imagen completa |
| no aparece WiFi | esperar, revisar MBL+MSDK y offset `0xA000` |
| hay WiFi sin HTTP | IP, tarea servidor, lwIP y aplicación copiada |
| HTTP responde sin LED | polaridad y PC13 |
| navegador queda en blanco | abrir el panel HTML local desde la tarea de VS Code |
