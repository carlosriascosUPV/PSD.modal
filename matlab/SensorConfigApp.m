classdef SensorConfigApp < handle
    %SENSORCONFIGAPP Aplicación MATLAB para configuración sensor por sensor.

    properties (Access = private)
        UIFigure matlab.ui.Figure

        LeftPanel matlab.ui.container.Panel
        RightPanel matlab.ui.container.Panel

        LogoPanel matlab.ui.container.Panel
        ConfigTitle matlab.ui.control.Label

        SamplingHzField matlab.ui.control.NumericEditField
        SerialNumberField matlab.ui.control.EditField
        SensorIDField matlab.ui.control.EditField
        FormatDropDown matlab.ui.control.DropDown
        ChannelsDropDown matlab.ui.control.DropDown
        FactorField matlab.ui.control.NumericEditField
        RangeField matlab.ui.control.EditField
        UTCStartField matlab.ui.control.EditField

        Ch1AxisDropDown matlab.ui.control.DropDown
        Ch2AxisDropDown matlab.ui.control.DropDown
        Ch3AxisDropDown matlab.ui.control.DropDown
        Ch1SignSwitch matlab.ui.control.Switch
        Ch2SignSwitch matlab.ui.control.Switch
        Ch3SignSwitch matlab.ui.control.Switch

        AddSensorButton matlab.ui.control.Button
        ClearFormButton matlab.ui.control.Button
        RemoveSelectedButton matlab.ui.control.Button
        BuildTableButton matlab.ui.control.Button
        StatusLabel matlab.ui.control.Label

        PreviewAxes matlab.ui.control.UIAxes

        SensorTable matlab.ui.control.Table
        ChannelTable matlab.ui.control.Table
        PlotTabs matlab.ui.container.TabGroup
        TimeTab matlab.ui.container.Tab
        SpectralTab matlab.ui.container.Tab
        TimeAxes matlab.ui.control.UIAxes
        FreqAxes matlab.ui.control.UIAxes

        Sensors struct = struct([])
    end

    methods
        function app = SensorConfigApp()
            createUI(app);
            resetForm(app);
            updateOrientationVisibility(app);
            updateSensorTable(app);
            updateChannelTable(app, table());
            updatePreview(app);
        end
    end

    methods (Access = private)
        function createUI(app)
            app.UIFigure = uifigure('Name', 'PSD.modal - Configuración de Sensores', ...
                'Position', [40 40 1500 860], ...
                'Color', [1 1 1]);

            app.LeftPanel = uipanel(app.UIFigure, ...
                'Position', [10 10 300 840], ...
                'BackgroundColor', [1 1 1], ...
                'BorderType', 'line', ...
                'HighlightColor', [0.85 0.85 0.85]);

            app.RightPanel = uipanel(app.UIFigure, ...
                'Position', [320 10 1170 840], ...
                'BackgroundColor', [1 1 1], ...
                'BorderType', 'none');

            app.LogoPanel = uipanel(app.LeftPanel, ...
                'Title', 'Icono / Logo empresa', ...
                'Position', [10 760 280 70], ...
                'BackgroundColor', [1 1 1]);
            uilabel(app.LogoPanel, 'Text', 'Espacio reservado para logo corporativo', ...
                'Position', [10 20 250 22], 'FontColor', [0.4 0.4 0.4]);

            app.ConfigTitle = uilabel(app.LeftPanel, ...
                'Text', 'Configuración del Sensor', ...
                'Position', [10 730 280 24], ...
                'FontWeight', 'bold', ...
                'FontSize', 16, ...
                'HorizontalAlignment', 'left');

            y = 695;
            dy = 38;

            uilabel(app.LeftPanel, 'Text', 'Frecuencia (Hz)', 'Position', [10 y 130 22]);
            app.SamplingHzField = uieditfield(app.LeftPanel, 'numeric', ...
                'Position', [150 y 140 22], 'Limits', [0 Inf], 'Value', 250, ...
                'ValueChangedFcn', @(~,~) updatePreview(app));
            y = y - dy;

            uilabel(app.LeftPanel, 'Text', 'Serial number (opcional)', 'Position', [10 y 130 22]);
            app.SerialNumberField = uieditfield(app.LeftPanel, 'text', ...
                'Position', [150 y 140 22], 'ValueChangedFcn', @(~,~) updatePreview(app));
            y = y - dy;

            uilabel(app.LeftPanel, 'Text', 'Sensor ID', 'Position', [10 y 130 22]);
            app.SensorIDField = uieditfield(app.LeftPanel, 'text', ...
                'Position', [150 y 140 22], 'Value', 'A1', ...
                'ValueChangedFcn', @(~,~) updatePreview(app));
            y = y - dy;

            uilabel(app.LeftPanel, 'Text', 'Formato', 'Position', [10 y 130 22]);
            app.FormatDropDown = uidropdown(app.LeftPanel, ...
                'Position', [150 y 140 22], ...
                'Items', {'MINISEED', 'TXT', 'MAT', 'XLS'}, ...
                'Value', 'MINISEED', ...
                'ValueChangedFcn', @(~,~) updatePreview(app));
            y = y - dy;

            uilabel(app.LeftPanel, 'Text', 'Canales', 'Position', [10 y 130 22]);
            app.ChannelsDropDown = uidropdown(app.LeftPanel, ...
                'Position', [150 y 140 22], ...
                'Items', {'1', '2', '3'}, ...
                'Value', '3', ...
                'ValueChangedFcn', @(~,~) channelsChanged(app));
            y = y - dy;

            uilabel(app.LeftPanel, 'Text', 'Factor', 'Position', [10 y 130 22]);
            app.FactorField = uieditfield(app.LeftPanel, 'numeric', ...
                'Position', [150 y 140 22], 'Limits', [0 Inf], 'Value', 1, ...
                'ValueChangedFcn', @(~,~) updatePreview(app));
            y = y - dy;

            uilabel(app.LeftPanel, 'Text', 'Rango', 'Position', [10 y 130 22]);
            app.RangeField = uieditfield(app.LeftPanel, 'text', ...
                'Position', [150 y 140 22], 'Value', '+/-2g', ...
                'ValueChangedFcn', @(~,~) updatePreview(app));
            y = y - dy;

            uilabel(app.LeftPanel, 'Text', 'UTC (yyyy-MM-ddTHH:mm:ss)', ...
                'Position', [10 y 170 22]);
            app.UTCStartField = uieditfield(app.LeftPanel, 'text', ...
                'Position', [180 y 110 22], ...
                'Value', char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss')), ...
                'ValueChangedFcn', @(~,~) updatePreview(app));
            y = y - 44;

            uilabel(app.LeftPanel, 'Text', 'Orientación por canal (eje + switch +/-)', ...
                'Position', [10 y+18 260 22], 'FontWeight', 'bold');

            axisItems = {'X', 'Y', 'Z'};

            uilabel(app.LeftPanel, 'Text', 'CH1', 'Position', [10 y-6 35 22]);
            app.Ch1SignSwitch = uiswitch(app.LeftPanel, 'slider', ...
                'Items', {'-', '+'}, 'Value', '+', ...
                'Position', [45 y-12 45 20], 'ValueChangedFcn', @(~,~) updatePreview(app));
            app.Ch1AxisDropDown = uidropdown(app.LeftPanel, 'Items', axisItems, ...
                'Value', 'X', 'Position', [105 y-6 70 22], ...
                'ValueChangedFcn', @(~,~) updatePreview(app));

            uilabel(app.LeftPanel, 'Text', 'CH2', 'Position', [180 y-6 35 22]);
            app.Ch2SignSwitch = uiswitch(app.LeftPanel, 'slider', ...
                'Items', {'-', '+'}, 'Value', '+', ...
                'Position', [215 y-12 45 20], 'ValueChangedFcn', @(~,~) updatePreview(app));
            app.Ch2AxisDropDown = uidropdown(app.LeftPanel, 'Items', axisItems, ...
                'Value', 'Y', 'Position', [255 y-6 35 22], ...
                'ValueChangedFcn', @(~,~) updatePreview(app));

            y = y - 34;

            uilabel(app.LeftPanel, 'Text', 'CH3', 'Position', [10 y-6 35 22]);
            app.Ch3SignSwitch = uiswitch(app.LeftPanel, 'slider', ...
                'Items', {'-', '+'}, 'Value', '+', ...
                'Position', [45 y-12 45 20], 'ValueChangedFcn', @(~,~) updatePreview(app));
            app.Ch3AxisDropDown = uidropdown(app.LeftPanel, 'Items', axisItems, ...
                'Value', 'Z', 'Position', [105 y-6 70 22], ...
                'ValueChangedFcn', @(~,~) updatePreview(app));

            y = y - 44;

            app.AddSensorButton = uibutton(app.LeftPanel, 'push', ...
                'Text', 'Agregar sensor', ...
                'Position', [10 y 130 26], ...
                'ButtonPushedFcn', @(~,~) addSensor(app));

            app.ClearFormButton = uibutton(app.LeftPanel, 'push', ...
                'Text', 'Limpiar', ...
                'Position', [150 y 65 26], ...
                'ButtonPushedFcn', @(~,~) resetForm(app));

            app.RemoveSelectedButton = uibutton(app.LeftPanel, 'push', ...
                'Text', 'Eliminar', ...
                'Position', [220 y 70 26], ...
                'ButtonPushedFcn', @(~,~) removeSelectedSensor(app));

            y = y - 34;

            app.BuildTableButton = uibutton(app.LeftPanel, 'push', ...
                'Text', 'Generar tabla por canal', ...
                'Position', [10 y 280 26], ...
                'ButtonPushedFcn', @(~,~) buildChannelTable(app));

            y = y - 34;

            app.StatusLabel = uilabel(app.LeftPanel, ...
                'Text', 'Listo', ...
                'Position', [10 y 280 38], ...
                'FontColor', [0.2 0.2 0.2]);

            app.PreviewAxes = uiaxes(app.LeftPanel, ...
                'Position', [10 10 280 220], ...
                'BackgroundColor', [1 1 1]);
            title(app.PreviewAxes, 'Vista gráfica del sensor (cubo)');
            axis(app.PreviewAxes, 'equal');

            % Zona de datos en la parte superior derecha
            app.SensorTable = uitable(app.RightPanel, ...
                'Position', [10 560 1148 130], ...
                'ColumnEditable', false, ...
                'ColumnName', {'#','SensorID','SerialNumber','SamplingHz','Format', ...
                               'Channels','Factor','Range','Orientation','UTCStart'});

            app.ChannelTable = uitable(app.RightPanel, ...
                'Position', [10 400 1148 150], ...
                'ColumnEditable', false, ...
                'ColumnName', {'SensorID','SerialNumber','SamplingHz','Format', ...
                               'Channel','Factor','Range','Orientation','UTCStart'});

            % Zona para Time Histories y FFT/PSD/FRF
            app.PlotTabs = uitabgroup(app.RightPanel, 'Position', [10 10 1148 380]);
            app.TimeTab = uitab(app.PlotTabs, 'Title', 'Time Histories');
            app.SpectralTab = uitab(app.PlotTabs, 'Title', 'FFT / PSD / Funciones de Transferencia');

            app.TimeAxes = uiaxes(app.TimeTab, 'Position', [20 40 1100 300], ...
                'BackgroundColor', [1 1 1]);
            title(app.TimeAxes, 'Zona para Time Histories');
            xlabel(app.TimeAxes, 'Tiempo (s)');
            ylabel(app.TimeAxes, 'Amplitud');
            grid(app.TimeAxes, 'on');

            app.FreqAxes = uiaxes(app.SpectralTab, 'Position', [20 40 1100 300], ...
                'BackgroundColor', [1 1 1]);
            title(app.FreqAxes, 'Zona para FFT / PSD / FRF');
            xlabel(app.FreqAxes, 'Frecuencia (Hz)');
            ylabel(app.FreqAxes, 'Magnitud');
            grid(app.FreqAxes, 'on');
        end

        function channelsChanged(app)
            updateOrientationVisibility(app);
            updatePreview(app);
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
                buildChannelTable(app);
                setStatus(app, sprintf('Sensor %s agregado.', sensor.SensorID), [0.1 0.45 0.1]);
            catch ME
                setStatus(app, ['Error: ' ME.message], [0.75 0.1 0.1]);
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
            orientation = composeOrientation(app, channels);

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

            % Validar estructura con utilidad existente
            buildSensorTable(sensor);
        end

        function orientation = composeOrientation(app, channels)
            orientation = cell(1, channels);
            orientation{1} = [app.Ch1SignSwitch.Value app.Ch1AxisDropDown.Value];
            if channels >= 2
                orientation{2} = [app.Ch2SignSwitch.Value app.Ch2AxisDropDown.Value];
            end
            if channels >= 3
                orientation{3} = [app.Ch3SignSwitch.Value app.Ch3AxisDropDown.Value];
            end
        end

        function removeSelectedSensor(app)
            if isempty(app.Sensors)
                setStatus(app, 'No hay sensores para eliminar.', [0.75 0.45 0.1]);
                return;
            end

            idx = app.SensorTable.Selection;
            if isempty(idx)
                setStatus(app, 'Seleccione una fila en la tabla de sensores.', [0.75 0.45 0.1]);
                return;
            end

            row = idx(1);
            if row < 1 || row > numel(app.Sensors)
                setStatus(app, 'Selección inválida.', [0.75 0.1 0.1]);
                return;
            end

            app.Sensors(row) = [];
            updateSensorTable(app);
            buildChannelTable(app);
            setStatus(app, 'Sensor eliminado.', [0.1 0.45 0.1]);
        end

        function buildChannelTable(app)
            try
                if isempty(app.Sensors)
                    updateChannelTable(app, table());
                    setStatus(app, 'No hay sensores cargados.', [0.75 0.45 0.1]);
                    return;
                end

                t = buildSensorTable(app.Sensors);
                updateChannelTable(app, t);
                setStatus(app, sprintf('Tabla por canal generada (%d filas).', height(t)), [0.1 0.45 0.1]);
            catch ME
                setStatus(app, ['Error al generar tabla: ' ME.message], [0.75 0.1 0.1]);
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
                orientationText = strjoin(string(s.Orientation), ', ');
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
            visible2 = channels >= 2;
            visible3 = channels >= 3;

            app.Ch2SignSwitch.Visible = visible2;
            app.Ch2AxisDropDown.Visible = visible2;
            app.Ch3SignSwitch.Visible = visible3;
            app.Ch3AxisDropDown.Visible = visible3;
        end

        function resetForm(app)
            app.SamplingHzField.Value = 250;
            app.SerialNumberField.Value = '';
            app.SensorIDField.Value = 'A1';
            app.FormatDropDown.Value = 'MINISEED';
            app.ChannelsDropDown.Value = '3';
            app.FactorField.Value = 1;
            app.RangeField.Value = '+/-2g';
            app.UTCStartField.Value = char(datetime('now', 'TimeZone', 'UTC', ...
                'Format', 'yyyy-MM-dd''T''HH:mm:ss'));

            app.Ch1AxisDropDown.Value = 'X';
            app.Ch2AxisDropDown.Value = 'Y';
            app.Ch3AxisDropDown.Value = 'Z';
            app.Ch1SignSwitch.Value = '+';
            app.Ch2SignSwitch.Value = '+';
            app.Ch3SignSwitch.Value = '+';

            updateOrientationVisibility(app);
            setStatus(app, 'Formulario reiniciado.', [0.2 0.2 0.2]);
            updatePreview(app);
        end

        function setStatus(app, textValue, colorValue)
            app.StatusLabel.Text = textValue;
            app.StatusLabel.FontColor = colorValue;
        end

        function updatePreview(app)
            cla(app.PreviewAxes);
            hold(app.PreviewAxes, 'on');

            v = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            f = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];

            patch(app.PreviewAxes, 'Vertices', v, 'Faces', f, ...
                'FaceColor', [0.35 0.65 0.9], 'FaceAlpha', 0.22, 'EdgeColor', [0.2 0.2 0.2], ...
                'LineWidth', 1.2);

            channels = str2double(app.ChannelsDropDown.Value);
            orientation = composeOrientation(app, channels);
            text(app.PreviewAxes, 0.05, 1.08, 0, sprintf('ID: %s', app.SensorIDField.Value), ...
                'FontSize', 9, 'FontWeight', 'bold');
            text(app.PreviewAxes, 0.05, 0.98, 0, sprintf('Hz: %.3g | Ch: %d', app.SamplingHzField.Value, channels), ...
                'FontSize', 8);
            text(app.PreviewAxes, 0.05, 0.88, 0, sprintf('Fmt: %s | F: %.3g', app.FormatDropDown.Value, app.FactorField.Value), ...
                'FontSize', 8);
            text(app.PreviewAxes, 0.05, 0.78, 0, sprintf('Rango: %s', app.RangeField.Value), 'FontSize', 8);
            text(app.PreviewAxes, 0.05, 0.68, 0, sprintf('Orientación: %s', strjoin(orientation, ', ')), 'FontSize', 8);

            quiver3(app.PreviewAxes, 0.5, 0.5, 0.5, 0.6, 0, 0, 'r', 'LineWidth', 1.4, 'MaxHeadSize', 0.5);
            quiver3(app.PreviewAxes, 0.5, 0.5, 0.5, 0, 0.6, 0, 'g', 'LineWidth', 1.4, 'MaxHeadSize', 0.5);
            quiver3(app.PreviewAxes, 0.5, 0.5, 0.5, 0, 0, 0.6, 'b', 'LineWidth', 1.4, 'MaxHeadSize', 0.5);

            text(app.PreviewAxes, 1.15, 0.5, 0.5, 'X', 'Color', 'r', 'FontWeight', 'bold');
            text(app.PreviewAxes, 0.5, 1.15, 0.5, 'Y', 'Color', 'g', 'FontWeight', 'bold');
            text(app.PreviewAxes, 0.5, 0.5, 1.15, 'Z', 'Color', 'b', 'FontWeight', 'bold');

            grid(app.PreviewAxes, 'on');
            app.PreviewAxes.XLim = [-0.15 1.35];
            app.PreviewAxes.YLim = [-0.15 1.35];
            app.PreviewAxes.ZLim = [-0.15 1.35];
            app.PreviewAxes.XTick = [];
            app.PreviewAxes.YTick = [];
            app.PreviewAxes.ZTick = [];
            app.PreviewAxes.Box = 'on';
            view(app.PreviewAxes, 135, 22);
            hold(app.PreviewAxes, 'off');
        end
    end
end
