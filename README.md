# PSD.modal
Esta aplicación genera el análisis modal basado en vibraciones experimentales.

## Aplicación MATLAB (pestaña **Configuración**)
Se agregó una app MATLAB funcional para definir sensores uno por uno en la pestaña **Configuración**.

### Campos soportados por sensor
- Frecuencia de muestreo en Hz (`SamplingHz`)
- Número de serie opcional (`SerialNumber`)
- Sensor ID (`SensorID`, por ejemplo `A1`)
- Formato (`MINISEED`, `TXT`, `MAT`, `XLS`)
- Canales (`Channels`, entero entre 1 y 3)
- Factor (`Factor`)
- Rango (`Range`)
- Orientación por canal (`Orientation`: `+/-X`, `+/-Y`, `+/-Z`)
- Tiempo UTC (`UTCStart`, formato `yyyy-MM-ddTHH:mm:ss`)

### Archivos
- `matlab/SensorConfigApp.m`: app con UI y pestaña **Configuración**.
- `matlab/runSensorConfigApp.m`: función para iniciar la app.
- `matlab/buildSensorTable.m`: valida y transforma sensores a tabla por canal.
- `matlab/demo_sensor_config.m`: ejemplo por script (sin UI).

## Uso
### Opción 1: App (recomendado)
```matlab
run('matlab/runSensorConfigApp.m')
```

En la pestaña **Configuración** puedes:
- Agregar sensores.
- Eliminar sensores seleccionados.
- Generar la tabla canal por canal.

### Opción 2: Script directo
```matlab
run('matlab/demo_sensor_config.m')
```

## Ejemplo de definición por script
```matlab
sensors(1) = struct( ...
    'SamplingHz', 250, ...
    'SensorID', 'A1', ...
    'Format', 'miniseed', ...
    'Channels', 3, ...
    'Factor', 3.815, ...
    'Range', '+/-2g', ...
    'Orientation', {{'-Y','-X','+Z'}}, ...
    'UTCStart', datetime('now', 'TimeZone', 'UTC'), ...
    'SerialNumber', 'W25641');

% Nota: para listas de orientación en un solo sensor,
% use doble llaves: {{...}}.

sensorTable = buildSensorTable(sensors)
```
