% Mosaicing of three images. 
function mosaic()

I1 = imread('img1.pgm');
I2 = imread('img2.pgm');
I3 = imread('img3.pgm');
% Set the canvas_row and column size
canvas_rows = 600;
canvas_columns = 1500;
canvas = zeros(canvas_rows,canvas_columns);
% Offset to bring the image to center. 
offsetRow = 350;
offsetColumn = 100;
[H21,H23] = get_homography();
% H21 = inv ([ 1.3821   -0.0057 -251.4812; 0.1116    1.2489  -63.8704 ; 0.0006    0.0000    1.0000]);
% H23 = inv([0.6120   -0.0079  258.5028;-0.1158    0.8641   36.9060;-0.0006   -0.0000    1.0000]);
for jj = 1:canvas_rows
    for ii = 1:canvas_columns
        i = ii - offsetRow;
        j = jj - offsetColumn;
        
        tmp = H21 * [i;j;1];
        i1  = tmp(1) / tmp(3);
        j1  = tmp(2) / tmp(3);
       
        tmp = H23 * [i;j;1];
        i3  = tmp(1) / tmp(3);
        j3  = tmp(2) / tmp(3);
        
        v1  = BilinearInterp(i1,j1,I1);
        v2  = BilinearInterp(i,j,I2);
        v3  = BilinearInterp(i3,j3,I3);
%         canvas(jj,ii) = (v1 + v2) /2 ;
        canvas(jj,ii) = BlendValues(v1,v2,v3);
    end
end
canvas = uint8(canvas);
imshow(canvas);
end

function [intrep] = BilinearInterp(i,j,I)
    del_x = i - floor(i);
    del_y = j - floor(j);
    i = floor(i);
    j = floor(j);
    [m,n] = size(I);
    if i <= 0 || j <= 0 || i >= n || j >=m
        intrep = 0;
        return
    end
    intrep = (1-del_x)*(1-del_y)*I(j,i) + (1-del_x)*(del_y)*I(j,i+1) + (del_x)*(1-del_y)*I(j+1,i) + (del_x)*(del_y)*I(j+1,i+1);
end

function [H21,H23] = get_homography()
    % Finding best homography using ransac
    H21  = inv(ransac1('img1.pgm','img2.jpg'));
    H23  = inv(ransac1('img3.pgm','img2.jpg'));
end

function [blend] = BlendValues(v1,v2,v3)
    blen_temp = [];
    if v1 ~= 0
        blen_temp = [blen_temp v1];
    end
    if v2 ~= 0
        blen_temp = [blen_temp v2];
    end
    if v3 ~= 0 
        blen_temp = [blen_temp v3];
    end
    blend = mean(blen_temp);
end


