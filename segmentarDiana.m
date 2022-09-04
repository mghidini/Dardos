function [ masks ] = segmentarDiana(image)
% funcion para dividir la diana entre las zonas de puntuacion

% convertir en escala de grises
gray_image = rgb2gray(image);

% extraer red channel, calcular umbral con otsu y binarizar
red = image(:,:,1)-gray_image;
u_red = graythresh(red);
masks.red = imbinarize(red, u_red);

% extraer green channel, calcular umbral con otsu y binarizar
green = image(:,:,2)-gray_image;
u_green = graythresh(green);
masks.green = imbinarize(green, u_green);

% masara para extraer las zonas verdes y rojas
masks.red_and_green = masks.red + masks.green;


% elemento estructural 
es = strel('disk', round(numel(image(:,1,1))/100));

% clausura
mult_circles = imclose(masks.red_and_green, es);
masks.board = imfill(mult_circles,'holes');
masks.miss = ~masks.board;



% Subtraccion entre mascaras para encontrar las regiones de puntuacion
masks.single = masks.board - mult_circles;
masks.double = masks.board - imfill(masks.single,'holes');

inner_ring = imfill((masks.board - masks.double - masks.single),'holes') - ...
    (masks.board - masks.double - masks.single);

masks.triple = masks.board - masks.double - masks.single - imfill(inner_ring,'holes');
masks.triple(masks.triple < 0) = 0;

masks.outer_bull = (mult_circles - masks.double - masks.triple) .* masks.green;
masks.inner_bull = (mult_circles - masks.double - masks.triple) .* masks.red;

figure(2);
subplot(1, 3, 1); imshow(masks.red); title("red mask");
subplot(1, 3, 2); imshow(masks.red_and_green); title("green and red mask");
subplot(1, 3, 3); imshow(masks.green); title("green mask");

figure(3);
subplot(3, 3, 1); imshow(masks.board); title("entire board");
subplot(3, 3, 2); imshow(masks.miss); title("miss (0 puntos)");
subplot(3, 3, 4); imshow(masks.single); title("puntos X1");
subplot(3, 3, 5); imshow(masks.double); title("puntos X2");
subplot(3, 3, 6); imshow(masks.triple); title("puntos X3");
subplot(3, 3, 8); imshow(masks.inner_bull); title("inner bull");
subplot(3, 3, 9); imshow(masks.outer_bull); title("outer bull");

end