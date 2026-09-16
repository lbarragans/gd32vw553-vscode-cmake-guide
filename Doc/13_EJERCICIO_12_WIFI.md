# 13. Ejercicio 12: FreeRTOS, WiFi y HTTP

## 13.1 Por qué usa otro flujo

WiFi requiere firmware de radio, calibración RF, controladores, FreeRTOS,
lwIP, DHCP, TCP y bibliotecas del fabricante. Use el SDK
`GD32VW55x_RELEASE_V1.0.3g` validado por el ejercicio; no el CMake bare-metal de
00–11 ni un kernel FreeRTOS descargado por separado.

## 13.2 Componentes

- GD32 Embedded Builder y su toolchain;
- `GD32VW55x_RELEASE_V1.0.3g`;
- GD32 ISP CLI para Windows;
- driver CH340 cuando Windows no reconoce el USB-UART;
- carpeta `FreeRTOS_Puro/` o `VendorApp/` del ejercicio;
- panel `Web/GD32_LED_CONTROL_LOCAL.html`.

## 13.3 Integrar la aplicación

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

## 13.4 Reconocer el puerto UART

Abra Administrador de dispositivos y ubique:

```text
USB-SERIAL CH340 (COMx)
```

Confirme desde PowerShell:

```powershell
Get-CimInstance Win32_SerialPort |
    Select-Object DeviceID, Name, PNPDeviceID
```

No elija `WCH-Link SERIAL` salvo que el cableado físico lleve esa UART al
bootloader. En la placa validada se utiliza el CH340.

## 13.5 Programar

1. Cierre monitores seriales que estén usando el COM.
2. Lleve la placa al modo bootloader indicado por su manual.
3. Seleccione en GD32 ISP CLI el COM del CH340.
4. Cargue `image-all.bin`.
5. Use dirección `0x08000000`.
6. Programe y verifique.
7. Libere BOOT0 y reinicie.
8. Espere hasta 30 segundos para inicialización de radio.

## 13.6 Probar

1. Busque la red abierta `GD32_LED_LAB`.
2. Conecte el computador o teléfono.
3. Abra `http://192.168.237.1/status`.
4. Pruebe `/on`, `/off`, `/toggle`, `/blink/slow` y `/blink/fast`.
5. Abra el HTML local del panel.
6. Confirme cambio físico de PC13 y respuestas HTTP 200.

## 13.7 Assembly del ejercicio 12

`Ensamblador_RISCV_Puro/main.S` ejecuta seis solicitudes simuladas, parser,
modos y LED. Se integra como una prueba bare-metal de lógica. No crea el
SoftAP; por tanto no debe usarse como evidencia de WiFi real.

## 13.8 Diagnóstico

| Síntoma | Revisión |
| --- | --- |
| no aparece COM | cable, driver CH340, Administrador de dispositivos |
| ISP no abre COM | cerrar monitor/terminal y seleccionar puerto correcto |
| programa pero no arranca | BOOT0, reset e imagen completa |
| no aparece WiFi | esperar, revisar MBL+MSDK y offset `0xA000` |
| hay WiFi sin HTTP | IP, tarea servidor, lwIP y aplicación copiada |
| HTTP responde sin LED | polaridad y PC13 |
