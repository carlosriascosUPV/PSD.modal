# PSD.modal
Esta aplicación genera el análisis modal basado en vibraciones experimentales.

## Definición sensor por sensor (MATLAB)
Se agregó un flujo para definir sensores individualmente con los campos solicitados:

- Frecuencia de muestreo en Hz (`SamplingHz`)
- Número de serie opcional (`SerialNumber`)
- Sensor ID (`SensorID`, por ejemplo `A1`)
- Formato (`MINISEED`, `TXT`, `MAT`, `XLS`)
- Canales (`Channels`, entero entre 1 y 3)
- Factor (`Factor`)
- Rango (`Range`)
- Orientación por canal (`Orientation`: `+/-X`, `+/-Y`, `+/-Z`)
- Tiempo UTC (`UTCStart`)

### Archivos
- `matlab/buildSensorTable.m`: valida y transforma la definición de sensores en una tabla por canal.
- `matlab/demo_sensor_config.m`: ejemplo de uso.

### Uso rápido
```matlab
run('matlab/demo_sensor_config.m')
```

O con tus propios datos:

```matlab
sensors(1) = struct( ...
    'SamplingHz', 250, ...
    'SensorID', 'A1', ...
    'Format', 'miniseed', ...
    'Channels', 3, ...
    'Factor', 3.815, ...
    'Range', '+/-2g', ...
    'Orientation', {'-Y','-X','+Z'}, ...
    'UTCStart', datetime('now', 'TimeZone', 'UTC'), ...
    'SerialNumber', 'W25641');

sensorTable = buildSensorTable(sensors)
```
