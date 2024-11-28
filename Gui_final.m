clc;
close all;
clear puerto;

puerto = serialport("COM4", 9600);
configureTerminator(puerto, "CR/LF"); 
pause(2);
disp('Conexión serial iniciada');

global contadorRojo contadorVerde contadorAzul contadorTotal lblRojo lblVerde lblAzul lblTotal axImagenCapturada axImagenProcesada;

contadorRojo = 0;
contadorVerde = 0;
contadorAzul = 0;
contadorTotal = 0;

app = uifigure('Name', 'Sistema de Clasificación de Botellas', 'Position', [100, 100, 800, 500]);

panelRojo = uipanel(app, 'Title', 'Botellas ROJAS', 'Position', [50, 350, 200, 80], 'BackgroundColor', 'red', 'FontSize', 14, 'FontWeight', 'bold');
panelVerde = uipanel(app, 'Title', 'Botellas VERDES', 'Position', [50, 250, 200, 80], 'BackgroundColor', 'green', 'FontSize', 14, 'FontWeight', 'bold');
panelAzul = uipanel(app, 'Title', 'Botellas AZULES', 'Position', [50, 150, 200, 80], 'BackgroundColor', 'blue', 'FontSize', 14, 'FontWeight', 'bold');
panelTotal = uipanel(app, 'Title', 'TOTAL', 'Position', [50, 50, 200, 80], 'BackgroundColor', 'yellow', 'FontSize', 14, 'FontWeight', 'bold');

lblRojo = uilabel(panelRojo, 'Text', '0', 'Position', [50, 10, 100, 40], 'BackgroundColor', 'white', 'HorizontalAlignment', 'center', 'FontSize', 20, 'FontWeight', 'bold');
lblVerde = uilabel(panelVerde, 'Text', '0', 'Position', [50, 10, 100, 40], 'BackgroundColor', 'white', 'HorizontalAlignment', 'center', 'FontSize', 20, 'FontWeight', 'bold');
lblAzul = uilabel(panelAzul, 'Text', '0', 'Position', [50, 10, 100, 40], 'BackgroundColor', 'white', 'HorizontalAlignment', 'center', 'FontSize', 20, 'FontWeight', 'bold');
lblTotal = uilabel(panelTotal, 'Text', '0', 'Position', [50, 10, 100, 40], 'BackgroundColor', 'white', 'HorizontalAlignment', 'center', 'FontSize', 20, 'FontWeight', 'bold');

axImagenCapturada = uiaxes(app, 'Position', [300, 250, 300, 200]);
title(axImagenCapturada, 'Imagen Capturada');

axImagenProcesada = uiaxes(app, 'Position', [300, 30, 300, 200]);
title(axImagenProcesada, 'Imagen Procesada');

btnReset = uibutton(app, 'Text', 'Reiniciar Contadores', 'Position', [630, 250, 150, 40],'ButtonPushedFcn', @(btnReset, event) reset(), 'BackgroundColor', [0.6, 0.8, 1]);
btnStop = uibutton(app, 'Text', 'Detener', 'Position', [630, 200, 150, 40], 'ButtonPushedFcn', @(btnStop, event) stopProcess(app), 'BackgroundColor', [0.6, 0.8, 1]);

isProcessing = false;

app.CloseRequestFcn = @(src, event) closeApp(src);

proceso = imread('proceso.png');
iniciado = imread('iniciado.png');
imshow(proceso, 'Parent', axImagenCapturada);
imshow(iniciado, 'Parent', axImagenProcesada);
disp('Proceso iniciado');

%[audio, sampleRate] = audioread('iniciando_proceso.m4a');
%sound(audio, sampleRate);

disp('Esperando comando...');
while isvalid(app)
    if puerto.NumBytesAvailable > 0
        data = readline(puerto);

        if strcmp(data, '5') && ~isProcessing
            isProcessing = true;
            disp('Comando "5" recibido. Iniciando captura y procesamiento...');
            
            try
                flush(puerto);
                
                v = videoinput("winvideo", 2, "RGB24_1280x720");
                v.ReturnedColorspace = "rgb";
                imgCapturada = getsnapshot(v);
                
                imshow(imgCapturada, 'Parent', axImagenCapturada);

                filelocation = "D:\CICLO V\PROCESAMIENTO DIGITAL DE SEÑALES\PROYECTO FAJA\PROYECTO";
                filename = "prueba.png";
                fullFilename = fullfile(filelocation, filename);
                imwrite(imgCapturada, fullFilename, "png");
                disp(['Imagen guardada en: ', fullFilename]);

                imagen = imread(fullFilename);
                
                roi = [600, 500, 400, 300];
                imagenRecortada = imcrop(imagen, roi);

                imagenHSV = rgb2hsv(imagenRecortada);

                rangoRojo = (imagenHSV(:,:,1) < 0.05 | imagenHSV(:,:,1) > 0.95) & ...
                            imagenHSV(:,:,2) > 0.3 & imagenHSV(:,:,3) > 0.3;

                rangoVerde = (imagenHSV(:,:,1) > 0.25 & imagenHSV(:,:,1) < 0.45) & ...
                             imagenHSV(:,:,2) > 0.3 & imagenHSV(:,:,3) > 0.3;

                rangoAzul = (imagenHSV(:,:,1) > 0.55 & imagenHSV(:,:,1) < 0.75) & ...
                            imagenHSV(:,:,2) > 0.2 & imagenHSV(:,:,3) > 0.15;

                pixelesRojos = sum(rangoRojo(:));
                pixelesVerdes = sum(rangoVerde(:));
                pixelesAzules = sum(rangoAzul(:));

                if pixelesRojos > pixelesVerdes && pixelesRojos > pixelesAzules
                    [audio2, sampleRate] = audioread('botella_roja.m4a');
                    sound(audio2, sampleRate);
                    disp('El color predominante es ROJO.');
                    write(puerto, '2', "char");
                    contadorRojo = contadorRojo + 1;    
                elseif pixelesVerdes > pixelesRojos && pixelesVerdes > pixelesAzules
                    [audio3, sampleRate] = audioread('botella_verde.m4a');
                    sound(audio3, sampleRate);
                    disp('El color predominante es VERDE.');
                    write(puerto, '1', "char");
                    contadorVerde = contadorVerde + 1;
                elseif pixelesAzules > pixelesRojos && pixelesAzules > pixelesVerdes
                    [audio4, sampleRate] = audioread('botella_azul.m4a');
                    sound(audio4, sampleRate);
                    disp('El color predominante es AZUL.');
                    write(puerto, '0', "char");
                    contadorAzul = contadorAzul + 1;
                else
                    disp('No hay un color predominante claro.');
                end

                contadorTotal = contadorRojo + contadorVerde + contadorAzul;

                lblRojo.Text = num2str(contadorRojo);
                lblVerde.Text = num2str(contadorVerde);
                lblAzul.Text = num2str(contadorAzul);
                lblTotal.Text = num2str(contadorTotal);

                imshow(imagenRecortada, 'Parent', axImagenProcesada);

            catch e
                disp(['Ocurrió un error: ', e.message]);
            end

            flush(puerto);
            disp('Esperando 4 segundos antes de aceptar un nuevo comando...');
            pause(4);
            disp('Listo para recibir un nuevo comando.');
            isProcessing = false;
        end
    end
    pause(0.1);
end

function reset()
    global contadorRojo contadorVerde contadorAzul contadorTotal lblRojo lblVerde lblAzul lblTotal axImagenCapturada axImagenProcesada;
    contadorRojo = 0;
    contadorVerde = 0;
    contadorAzul = 0;
    contadorTotal = 0;
    lblRojo.Text = num2str(contadorRojo);
    lblVerde.Text = num2str(contadorVerde);
    lblAzul.Text = num2str(contadorAzul);
    lblTotal.Text = num2str(contadorTotal);
    banner = imread('banner.png');
    reseteo = imread('reseteo.png');
    imshow(banner, 'Parent', axImagenCapturada);
    imshow(reseteo, 'Parent', axImagenProcesada);
    disp('Contadores reiniciados.');
    disp('Imágenes reiniciadas.');
    [audio1, sampleRate] = audioread('reseteo_completado.m4a');
    sound(audio1, sampleRate);
end

function stopProcess(app)
    global puerto;
    disp('Deteniendo la ejecución y cerrando conexión serial...');
    clear puerto;
    delete(app);
end

function closeApp(src)
    global puerto;
    disp('Cerrando la GUI y desconectando la conexión serial...');
    clear puerto;
    delete(src);
end
