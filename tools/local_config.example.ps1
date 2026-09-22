# Copie este archivo como tools/local_config.ps1.
# Si siguio la instalacion estandar, no necesita cambiar estas rutas.
# tools/local_config.ps1 contiene rutas personales y esta excluido de Git.

$GD32_SDK_ROOT = "C:/gd32_tools/GD32VW55x_Firmware_Library_V1.6.0"

$NUCLEI_TOOLCHAIN_DIR = `
    "C:/gd32_tools/nuclei/bin"

# Debe apuntar al directorio que contiene bin/ y scripts/.
$OPENOCD_ROOT = `
    "C:/gd32_tools/openocd"
