data=imread("dardo5.jpg");
       
    diff_im = imsubtract(data(:,:,3), rgb2gray(data));   % blue color
    diff_im = medfilt2(diff_im, [3 3]); 
    diff_im = im2bw(diff_im,0.18); 
    diff_im = bwareaopen(diff_im,300);     
    bw = bwlabel(diff_im, 8);
    stats = regionprops(bw, 'BoundingBox', 'Centroid','Extrema');     
    figure,imshow(data);
    hold on        
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        xhit= stats(object).Extrema(7,1);
        yhit= stats(object).Extrema(7,2);
        rectangle('Position',bb,'EdgeColor','r','LineWidth',1)       
        plot(bc(1),bc(2), '-m+')   
        plot(xhit,yhit,'-m+')
        a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        b=text(xhit+15,yhit, strcat('X: ', num2str(round(xhit)), '    Y: ', num2str(round(yhit))));
        set(b, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end 