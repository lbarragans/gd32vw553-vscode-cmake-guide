# Clase 01 — De un Windows limpio a Blink Polling

Este es el orden obligatorio para la primera clase.

## Antes de la clase

- descargue los paquetes para no depender de Internet;
- copie la guía y `00_Blink_Polling` en cada equipo;
- compruebe que los cables USB transmiten datos;
- tenga disponible un WCH-Link por puesto;
- no ejecute Zadig preventivamente.

## Fase A — preparar Windows

1. Crear `C:\gd32_tools`.
2. Extraer CMake, Ninja, Nuclei GCC, OpenOCD y Firmware Library según
   [02_INSTALLATION_WINDOWS.md](02_INSTALLATION_WINDOWS.md).
3. Agregar las cuatro carpetas al PATH.
4. Cerrar y volver a abrir las ventanas.
5. Ejecutar `check_env.bat` con doble clic.
6. No avanzar mientras exista una línea `[FALTA]`.

## Fase B — reconocer el hardware

1. Conectar el WCH-Link al computador.
2. Abrir Administrador de dispositivos.
3. Confirmar `WCH CMSIS-DAP` y normalmente `WCH-Link SERIAL (COMx)`.
4. Conectar JTAG y GND a la placa.
5. Alimentar la placa.
6. Si Windows no reconoce el probe, seguir la recuperación de
   [11_VSCODE_Y_CONEXION_PLACA.md](11_VSCODE_Y_CONEXION_PLACA.md).

## Fase C — preparar VS Code

1. Instalar C/C++, CMake Tools y Cortex-Debug.
2. Abrir exclusivamente la raíz de `00_Blink_Polling`.
3. Aceptar Workspace Trust para el repositorio conocido.
4. Copiar `tools/local_config.example.ps1` como `local_config.ps1`.
5. Conservar las rutas `C:/gd32_tools/...`.
6. Ejecutar **Verify GD32 Environment**.

## Fase D — compilar y programar Blink Polling

1. Ejecutar **Build + Flash Original** o la tarea equivalente.
2. Esperar `Programming Finished`, `Verified OK` y `Resetting Target`.
3. Comprobar que LED1 en PC13 cambia de estado.
4. La conexión validada usa CMSIS-DAP v2, USB bulk, VID/PID `1A86:8012`,
   JTAG y 50 kHz.

## Evidencia mínima

- `check_env.bat` con todos los `[OK]`;
- **Verify GD32 Environment** sin errores;
- terminal con `Verified OK`;
- demostración del LED;
- commit utilizado.

## Regla de diagnóstico

Deténgase en la primera capa que falle: archivos, PATH, driver USB, WCH-Link,
JTAG, CMake, Ninja, OpenOCD y finalmente comportamiento del firmware.
