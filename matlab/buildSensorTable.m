function sensorTable = buildSensorTable(sensors)
%BUILDSENSORTABLE Creates a channel-by-channel sensor configuration table.
%   sensorTable = buildSensorTable(sensors)
%   sensors: struct array with fields:
%     - SamplingHz (positive scalar)
%     - SensorID (char/string, e.g., "A1")
%     - Format ("miniseed"|"txt"|"mat"|"xls")
%     - Channels (integer 1..3)
%     - Factor (positive scalar)
%     - Range (char/string)
%     - Orientation (string/cellstr with channel orientations: +/-X, +/-Y, +/-Z)
%     - UTCStart (datetime in UTC or parsable text)
%     - SerialNumber (optional char/string)

    if nargin == 0 || isempty(sensors)
        sensorTable = table();
        return;
    end

    required = ["SamplingHz","SensorID","Format","Channels", ...
                "Factor","Range","Orientation","UTCStart"];

    rows = {};
    rowIdx = 0;

    for i = 1:numel(sensors)
        sensor = sensors(i);
        validateSensor(sensor, required);

        fmt = upper(string(sensor.Format));
        allowedFormats = ["MINISEED","TXT","MAT","XLS"];
        if ~any(fmt == allowedFormats)
            error('Formato no válido para SensorID %s. Use: %s', ...
                  string(sensor.SensorID), strjoin(allowedFormats, ', '));
        end

        nCh = sensor.Channels;
        if nCh < 1 || nCh > 3 || floor(nCh) ~= nCh
            error('Channels para SensorID %s debe ser entero entre 1 y 3.', string(sensor.SensorID));
        end

        orientation = normalizeOrientation(sensor.Orientation, nCh, string(sensor.SensorID));
        utc = normalizeUtc(sensor.UTCStart);

        serial = "";
        if isfield(sensor, 'SerialNumber') && ~isempty(sensor.SerialNumber)
            serial = string(sensor.SerialNumber);
        end

        for ch = 1:nCh
            rowIdx = rowIdx + 1;
            rows(rowIdx, :) = { ...
                string(sensor.SensorID), ...
                serial, ...
                sensor.SamplingHz, ...
                fmt, ...
                ch, ...
                sensor.Factor, ...
                string(sensor.Range), ...
                orientation(ch), ...
                utc ...
            };
        end
    end

    sensorTable = cell2table(rows, 'VariableNames', { ...
        'SensorID','SerialNumber','SamplingHz','Format', ...
        'Channel','Factor','Range','Orientation','UTCStart'});
end

function validateSensor(sensor, required)
    fields = string(fieldnames(sensor));
    missing = required(~ismember(required, fields));
    if ~isempty(missing)
        error('Sensor con campos faltantes: %s', strjoin(missing, ', '));
    end

    if ~isscalar(sensor.SamplingHz) || sensor.SamplingHz <= 0
        error('SamplingHz debe ser un número positivo.');
    end

    if ~isscalar(sensor.Factor) || sensor.Factor <= 0
        error('Factor debe ser un número positivo.');
    end
end

function orientation = normalizeOrientation(rawOrientation, nCh, sensorID)
    allowed = ["+X","-X","+Y","-Y","+Z","-Z"];

    if ischar(rawOrientation) || isstring(rawOrientation)
        orientation = string(rawOrientation);
    elseif iscell(rawOrientation)
        orientation = string(rawOrientation);
    else
        error('Orientation para SensorID %s debe ser string o celda de strings.', sensorID);
    end

    if numel(orientation) == 1 && nCh > 1
        error('Orientation para SensorID %s requiere %d valores (uno por canal).', sensorID, nCh);
    end

    if numel(orientation) ~= nCh
        error('Orientation para SensorID %s debe tener exactamente %d elementos.', sensorID, nCh);
    end

    orientation = upper(strtrim(orientation));
    if ~all(ismember(orientation, allowed))
        error('Orientation inválida en SensorID %s. Permitidas: %s', ...
              sensorID, strjoin(allowed, ', '));
    end
end

function utc = normalizeUtc(rawUtc)
    if isdatetime(rawUtc)
        utc = rawUtc;
    else
        utc = datetime(rawUtc, 'TimeZone', 'UTC', 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    end

    if isempty(utc.TimeZone)
        utc.TimeZone = 'UTC';
    end

    utc.TimeZone = 'UTC';
end
