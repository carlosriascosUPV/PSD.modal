# PSD.modal
Esta aplicación genera el análisis modal basado en vibraciones experimentales.

## Aplicación MATLAB (pestaña **Configuración**)
Se agregó una app MATLAB con estilo visual de página web (fondo blanco), organizada en dos zonas:

- **Panel izquierdo (≈20% ancho, vertical completo):** sección de datos de configuración del sensor.
- **Panel derecho (≈80% ancho):** tablas y área para visualizaciones (`Time Histories` y `FFT/PSD/Funciones de Transferencia`).

### Lo que incluye la UI
- Espacio reservado para **icono/logo de empresa** en la parte superior izquierda.
- Definición sensor por sensor con:
  - Frecuencia en Hz (`SamplingHz`)
  - Serial opcional (`SerialNumber`)
  - Sensor ID (`SensorID`, por ejemplo `A1`)
  - Formato (`MINISEED`, `TXT`, `MAT`, `XLS`)
  - Canales (`1` a `3`)
  - Factor (`Factor`)
  - Rango (`Range`)
  - Tiempo UTC (`UTCStart`)
- Orientación por canal usando:
  - Selección de eje (`X`, `Y`, `Z`)
  - Switch de signo (`+` / `-`)
  - Resultado final en formato `+X`, `-Y`, etc.
- Ilustración gráfica de un **cubo 3D** que refleja los datos actuales del sensor.

### Archivos
- `matlab/SensorConfigApp.m`: app con layout completo, pestaña/sección de configuración y zonas de visualización.
- `matlab/runSensorConfigApp.m`: función para iniciar la app.
- `matlab/buildSensorTable.m`: valida y transforma sensores a tabla por canal.
- `matlab/demo_sensor_config.m`: ejemplo por script (sin UI).

## Uso
### Opción 1: App (recomendado)
```matlab
run('matlab/runSensorConfigApp.m')
```

Desde la app puedes:
- Agregar sensores.
- Eliminar sensores seleccionados.
- Generar tabla canal por canal.
- Ver vista previa del sensor en cubo 3D.

### Opción 2: Script directo
```matlab
run('matlab/demo_sensor_config.m')
```
