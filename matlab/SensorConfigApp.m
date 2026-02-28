classdef SensorConfigApp < handle
    %SENSORCONFIGAPP Aplicación MATLAB para configuración sensor por sensor.

    properties (Access = private)
        UIFigure matlab.ui.Figure
        TabGroup matlab.ui.container.TabGroup
        ConfigTab matlab.ui.container.Tab

        SamplingHzField matlab.ui.control.NumericEditField
        SerialNumberField matlab.ui.control.EditField
        SensorIDField matlab.ui.control.EditField
        FormatDropDown matlab.ui.control.DropDown
        ChannelsDropDown matlab.ui.control.DropDown
        FactorField matlab.ui.control.NumericEditField
        RangeField matlab.ui.control.EditField
        Orientation1DropDown matlab.ui.control.DropDown
        Orientation2DropDown matlab.ui.control.DropDown
        Orientation3DropDown matlab.ui.control.DropDown
        UTCStartField matlab.ui.control.EditField

        AddSensorButton matlab.ui.control.Button
        ClearFormButton matlab.ui.control.Button
        RemoveSelectedButton matlab.ui.control.Button
        BuildTableButton matlab.ui.control.Button

        SensorTable matlab.ui.control.Table
        ChannelTable matlab.ui.control.Table
        StatusLabel matlab.ui.control.Label

        Sensors struct = struct([])
    end

    methods
        function app = SensorConfigApp()
            createUI(app);
            resetForm(app);
            updateOrientationVisibility(app);
            updateSensorTable(app);
            updateChannelTable(app, table());
        end
    end

    methods (Access = private)
        function createUI(app)
            app.UIFigure = uifigure('Name', 'PSD.modal - Configuración de Sensores', ...
                'Position', [80 80 1320 720]);

            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [10 10 1300 700]);
            app.ConfigTab = uitab(app.TabGroup, 'Title', 'Configuración');

            % Campos del formulario
            uilabel(app.ConfigTab, 'Text', 'Frecuencia (Hz)', 'Position', [20 650 120 22]);
            app.SamplingHzField = uieditfield(app.ConfigTab, 'numeric', ...
                'Position', [150 650 120 22], 'Limits', [0 Inf], 'Value', 250);

            uilabel(app.ConfigTab, 'Text', 'Serial number (opcional)', 'Position', [300 650 170 22]);
            app.SerialNumberField = uieditfield(app.ConfigTab, 'text', 'Position', [470 650 140 22]);

            uilabel(app.ConfigTab, 'Text', 'Sensor ID', 'Position', [640 650 70 22]);
            app.SensorIDField = uieditfield(app.ConfigTab, 'text', 'Position', [720 650 100 22], 'Value', 'A1');

            uilabel(app.ConfigTab, 'Text', 'Formato', 'Position', [850 650 60 22]);
            app.FormatDropDown = uidropdown(app.ConfigTab, ...
                'Position', [920 650 120 22], ...
                'Items', {'MINISEED', 'TXT', 'MAT', 'XLS'}, ...
                'Value', 'MINISEED');

            uilabel(app.ConfigTab, 'Text', 'Canales', 'Position', [1070 650 60 22]);
            app.ChannelsDropDown = uidropdown(app.ConfigTab, ...
                'Position', [1140 650 120 22], ...
                'Items', {'1','2','3'}, ...
                'Value', '3', ...
                'ValueChangedFcn', @(~,~) updateOrientationVisibility(app));

            uilabel(app.ConfigTab, 'Text', 'Factor', 'Position', [20 615 120 22]);
            app.FactorField = uieditfield(app.ConfigTab, 'numeric', ...
                'Position', [150 615 120 22], 'Limits', [0 Inf], 'Value', 1);

            uilabel(app.ConfigTab, 'Text', 'Rango', 'Position', [300 615 50 22]);
            app.RangeField = uieditfield(app.ConfigTab, 'text', ...
                'Position', [360 615 120 22], 'Value', '+/-2g');

            orientationItems = {'+X','-X','+Y','-Y','+Z','-Z'};
            uilabel(app.ConfigTab, 'Text', 'Orientación ch1', 'Position', [510 615 100 22]);
            app.Orientation1DropDown = uidropdown(app.ConfigTab, ...
                'Position', [620 615 80 22], 'Items', orientationItems, 'Value', '+X');

            uilabel(app.ConfigTab, 'Text', 'Orientación ch2', 'Position', [720 615 100 22]);
            app.Orientation2DropDown = uidropdown(app.ConfigTab, ...
                'Position', [830 615 80 22], 'Items', orientationItems, 'Value', '+Y');

            uilabel(app.ConfigTab, 'Text', 'Orientación ch3', 'Position', [930 615 100 22]);
            app.Orientation3DropDown = uidropdown(app.ConfigTab, ...
                'Position', [1040 615 80 22], 'Items', orientationItems, 'Value', '+Z');

            uilabel(app.ConfigTab, 'Text', 'Tiempo UTC (yyyy-MM-ddTHH:mm:ss)', ...
                'Position', [20 580 230 22]);
            app.UTCStartField = uieditfield(app.ConfigTab, 'text', ...
                'Position', [250 580 220 22], ...
                'Value', char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss')));

            app.AddSensorButton = uibutton(app.ConfigTab, 'push', ...
                'Text', 'Agregar sensor', ...
                'Position', [500 578 130 26], ...
                'ButtonPushedFcn', @(~,~) addSensor(app));

            app.ClearFormButton = uibutton(app.ConfigTab, 'push', ...
                'Text', 'Limpiar formulario', ...
                'Position', [645 578 140 26], ...
                'ButtonPushedFcn', @(~,~) resetForm(app));

            app.RemoveSelectedButton = uibutton(app.ConfigTab, 'push', ...
                'Text', 'Eliminar seleccionado', ...
                'Position', [800 578 150 26], ...
                'ButtonPushedFcn', @(~,~) removeSelectedSensor(app));

            app.BuildTableButton = uibutton(app.ConfigTab, 'push', ...
                'Text', 'Generar tabla por canal', ...
                'Position', [965 578 180 26], ...
                'ButtonPushedFcn', @(~,~) buildChannelTable(app));

            app.StatusLabel = uilabel(app.ConfigTab, 'Text', 'Listo', ...
                'Position', [20 545 1240 22], 'FontColor', [0.1 0.1 0.1]);

            app.SensorTable = uitable(app.ConfigTab, ...
                'Position', [20 300 1240 230], ...
                'ColumnEditable', false, ...
                'ColumnName', {'#','SensorID','SerialNumber','SamplingHz','Format', ...
                               'Channels','Factor','Range','Orientation','UTCStart'});

            app.ChannelTable = uitable(app.ConfigTab, ...
                'Position', [20 20 1240 260], ...
                'ColumnEditable', false, ...
                'ColumnName', {'SensorID','SerialNumber','SamplingHz','Format', ...
                               'Channel','Factor','Range','Orientation','UTCStart'});
        end

        function addSensor(app)
            try
                sensor = readForm(app);
                if isempty(app.Sensors)
                    app.Sensors = sensor;
                else
                    app.Sensors(end+1) = sensor; %#ok<AGROW>
                end

                updateSensorTable(app);
                app.StatusLabel.Text = sprintf('Sensor %s agregado.', sensor.SensorID);
                app.StatusLabel.FontColor = [0.1 0.4 0.1];
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
                app.StatusLabel.FontColor = [0.7 0.1 0.1];
            end
        end

        function sensor = readForm(app)
            samplingHz = app.SamplingHzField.Value;
            if isempty(samplingHz) || samplingHz <= 0
                error('La frecuencia (Hz) debe ser positiva.');
            end

            factor = app.FactorField.Value;
            if isempty(factor) || factor <= 0
                error('Factor debe ser positivo.');
            end

            sensorID = strtrim(app.SensorIDField.Value);
            if isempty(sensorID)
                error('Sensor ID es obligatorio.');
            end

            rangeValue = strtrim(app.RangeField.Value);
            if isempty(rangeValue)
                error('Rango es obligatorio.');
            end

            utcText = strtrim(app.UTCStartField.Value);
            if isempty(utcText)
                error('Tiempo UTC es obligatorio.');
            end

            channels = str2double(app.ChannelsDropDown.Value);
            orientation = cell(1, channels);
            orientation{1} = app.Orientation1DropDown.Value;
            if channels >= 2
                orientation{2} = app.Orientation2DropDown.Value;
            end
            if channels >= 3
                orientation{3} = app.Orientation3DropDown.Value;
            end

            sensor = struct( ...
                'SamplingHz', samplingHz, ...
                'SensorID', sensorID, ...
                'Format', app.FormatDropDown.Value, ...
                'Channels', channels, ...
                'Factor', factor, ...
                'Range', rangeValue, ...
                'Orientation', {orientation}, ...
                'UTCStart', utcText, ...
                'SerialNumber', strtrim(app.SerialNumberField.Value));

            % Validar estructura con la utilidad existente
            buildSensorTable(sensor);
        end

        function removeSelectedSensor(app)
            if isempty(app.Sensors)
                app.StatusLabel.Text = 'No hay sensores para eliminar.';
                app.StatusLabel.FontColor = [0.7 0.4 0.1];
                return;
            end

            idx = app.SensorTable.Selection;
            if isempty(idx)
                app.StatusLabel.Text = 'Seleccione una fila en la tabla de sensores.';
                app.StatusLabel.FontColor = [0.7 0.4 0.1];
                return;
            end

            row = idx(1);
            if row < 1 || row > numel(app.Sensors)
                app.StatusLabel.Text = 'Selección inválida.';
                app.StatusLabel.FontColor = [0.7 0.1 0.1];
                return;
            end

            app.Sensors(row) = [];
            updateSensorTable(app);
            buildChannelTable(app);
            app.StatusLabel.Text = 'Sensor eliminado.';
            app.StatusLabel.FontColor = [0.1 0.4 0.1];
        end

        function buildChannelTable(app)
            try
                if isempty(app.Sensors)
                    updateChannelTable(app, table());
                    app.StatusLabel.Text = 'No hay sensores cargados.';
                    app.StatusLabel.FontColor = [0.7 0.4 0.1];
                    return;
                end

                t = buildSensorTable(app.Sensors);
                updateChannelTable(app, t);
                app.StatusLabel.Text = sprintf('Tabla por canal generada (%d filas).', height(t));
                app.StatusLabel.FontColor = [0.1 0.4 0.1];
            catch ME
                app.StatusLabel.Text = ['Error al generar tabla: ' ME.message];
                app.StatusLabel.FontColor = [0.7 0.1 0.1];
            end
        end

        function updateSensorTable(app)
            if isempty(app.Sensors)
                app.SensorTable.Data = cell(0, 10);
                return;
            end

            n = numel(app.Sensors);
            data = cell(n, 10);
            for i = 1:n
                s = app.Sensors(i);
                orientationText = strjoin(string(s.Orientation), ',');
                data(i, :) = {i, s.SensorID, s.SerialNumber, s.SamplingHz, upper(string(s.Format)), ...
                              s.Channels, s.Factor, s.Range, orientationText, string(s.UTCStart)};
            end
            app.SensorTable.Data = data;
        end

        function updateChannelTable(app, t)
            if isempty(t)
                app.ChannelTable.Data = cell(0, 9);
                return;
            end

            data = cell(height(t), 9);
            for i = 1:height(t)
                data(i, :) = {char(string(t.SensorID(i))), char(string(t.SerialNumber(i))), ...
                              t.SamplingHz(i), char(string(t.Format(i))), t.Channel(i), ...
                              t.Factor(i), char(string(t.Range(i))), ...
                              char(string(t.Orientation(i))), char(string(t.UTCStart(i)))};
            end
            app.ChannelTable.Data = data;
        end

        function updateOrientationVisibility(app)
            channels = str2double(app.ChannelsDropDown.Value);
            app.Orientation2DropDown.Visible = channels >= 2;
            app.Orientation3DropDown.Visible = channels >= 3;
        end

        function resetForm(app)
            app.SamplingHzField.Value = 250;
            app.SerialNumberField.Value = '';
            app.SensorIDField.Value = 'A1';
            app.FormatDropDown.Value = 'MINISEED';
            app.ChannelsDropDown.Value = '3';
            app.FactorField.Value = 1;
            app.RangeField.Value = '+/-2g';
            app.Orientation1DropDown.Value = '+X';
            app.Orientation2DropDown.Value = '+Y';
            app.Orientation3DropDown.Value = '+Z';
            app.UTCStartField.Value = char(datetime('now', 'TimeZone', 'UTC', ...
                'Format', 'yyyy-MM-dd''T''HH:mm:ss'));
            updateOrientationVisibility(app);
            app.StatusLabel.Text = 'Formulario reiniciado.';
            app.StatusLabel.FontColor = [0.1 0.1 0.1];
        end
    end
end
