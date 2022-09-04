%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Procesamiento de Imagenes Digitales                               %%%
%%% Trabajo Dirigido                                                  %%%
%%% Método para identificar la puntuación                             %%%
%%% de dardos lanzados en una diana                                   %%%
%%%                                                                   %%%
%%% Autores: M. Ghidini, P. Quindos de la Riva                        %%%
%%% Mayo 2022                                                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc;
warning off;

scale = 1;
showImages = 0;  
imageAlign = 1; 

%% Seleccion de las imagenes por parte del usuario
fprintf('Select Background Image.\n');
[backgroundFile, backgroundPath] = uigetfile({'*.jpg','*.png'});
backgroundImage = imresize(im2double(imread([backgroundPath,backgroundFile])), scale);

fprintf('Select Dart Image..\n');
[dartFile, dartPath] = uigetfile({'*.jpg','*.png'});
dartImage = imresize(im2double(imread([dartPath,dartFile])), scale);

%% Segmentacion de la diana para determinar la tabla de puntos
fprintf('Creating Pointmap.....\n');

% Division de la diana en las diferentes areas
masks = segmentarDiana(backgroundImage); %-------------------------------------------------------------------------------

center = regionprops(masks.inner_bull, "Centroid");

% Deteccion de los bordes de la diana
grayBackgroundImage = rgb2gray(backgroundImage);
edge = edge(grayBackgroundImage,"canny",0.25); %Canny
[H,theta,rho] = hough(edge,'ThetaResolution',0.05); % Transformada de Hough

P = houghpeaks(H,10,'threshold',ceil(0.05*max(H(:))));
lines = houghlines(grayBackgroundImage .* masks.board,theta,rho,P);

%angles - Zero degrees = North
angles = theta(P(:,2))-90; 
angles = sort(mod([angles angles+180]+360,360)); 

%values = [18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5, 20, 1];
%values = [3, 19, 7, 16, 8, 11, 14, 9, 12, 5, 20, 1, 18, 4, 13, 6, 10, 15, 2, 17]

%original
values = [10, 15, 2, 17, ...
    3, 19, 7, 16, 8, 11, 14, 9, 12, 5, 20, 1, 18, 4, 13, 6];

region(1:20) = struct('minAngle','%f','maxAngle','%f','value','%d');
for i = 1:numel(region)
    region(i).minAngle = angles(i);
    region(i).maxAngle = angles(mod(i,numel(angles))+1);
    region(i).value = values(i);
end

[rows, columns] = size(masks.board);


%% Encontrar el dardo en la diana

diff_im = imsubtract(dartImage(:,:,3), rgb2gray(dartImage));

diff_im = medfilt2(diff_im, [3 3]);
diff_im = im2bw(diff_im,0.18); 
diff_im = bwareaopen(diff_im,300);     
bw = bwlabel(diff_im, 8);
stats = regionprops(bw, 'BoundingBox', 'Centroid','Extrema','Orientation');     
figure,imshow(dartImage);
hold on   

object =1:length(stats);
bb = stats(object).BoundingBox;
bc = stats(object).Centroid;
orie=stats(object).Orientation;
if orie>0 
xhit= stats(object).Extrema(7,1);
yhit= stats(object).Extrema(7,2);
rectangle('Position',bb,'EdgeColor','r','LineWidth',1)       
plot(bc(1),bc(2), '-m+')   
plot(xhit,yhit,'-m+')
a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
b=text(xhit+15,yhit, strcat('X: ', num2str(round(xhit)), '    Y: ', num2str(round(yhit))));
set(b, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
else 
xhit= stats(object).Extrema(3,1);
yhit= stats(object).Extrema(3,2);
rectangle('Position',bb,'EdgeColor','r','LineWidth',1)       
plot(bc(1),bc(2), '-m+')   
plot(xhit,yhit,'-m+')
a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
b=text(xhit+15,yhit, strcat('X: ', num2str(round(xhit)), '    Y: ', num2str(round(yhit))));
set(b, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
end

[points, masks.hit] = getScore(xhit, yhit, center, region, masks); %---------------------------------------------

%% Resaltar la seccion en la que cae el dardo
fprintf('Displaying Results........\n');
figure, imshow(dartImage), hold on;

boundary = bwboundaries(masks.hit);
for numRegion = 1:numel(boundary)
    plot(boundary{numRegion,1}(:,2), boundary{numRegion,1}(:,1), ...
        'y','LineWidth',2)
end
text(columns/2,rows,sprintf('%d Points',points), ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 28, ...
    'FontWeight', 'bold', ...
    'Color', 'b', ...
    'BackgroundColor', 'w');
pause(2);
hold off; 

warning on;
fprintf('Program Complete!\n');
