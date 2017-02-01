function H = ransac1(im1,im2)
[img1_corresp,img2_corresp] = sift_corresp(im1,im2);
sample_length = size(img1_corresp,1);
data_samples = 1:sample_length;
while 1
    rand_four = datasample(data_samples,4,'Replace',false);
    rem_ele = setdiff(data_samples,rand_four);
    % 1 and 2 features map
    A = [];
    for i=1:4
        rand_row = rand_four(i);
        x1 = img1_corresp(rand_row,2);
        y1 = img1_corresp(rand_row,1);
        x2 = img2_corresp(rand_row,2);
        y2 = img2_corresp(rand_row,1);
        equat = [x1 y1 1 0 0 0 -x1*x2 -x2*y1 -x2;0 0 0 x1 y1 1 -y2*x1 -y1*y2 -y2];
        A = [A;equat];
    end
    H_temp1 = null(A);
%     size(H_temp1,2)
    if size(H_temp1,2)~=1
        continue;
    end
    
    H_temp = (reshape(H_temp1,3,3))';
    consen_set = [];
    delta1 = 20;
    delta2 = 0.7*size(rem_ele,2);
    
    for i = 1:size(rem_ele,2)
        sel_row = rem_ele(i);
        x1 = img1_corresp(sel_row,2);
        y1 = img1_corresp(sel_row,1);
        x2 = img2_corresp(sel_row,2);
        y2 = img2_corresp(sel_row,1);
        h_map = H_temp*[x1;y1;1]; 
        x3 = h_map(1)/h_map(3);
        y3 = h_map(2)/h_map(3);
        if sqrt((x2 - x3)^2 + (y2 - y3)^2) < delta1
            consen_set = [consen_set sel_row];
        end
    end
% disp(size(consen_set,2));
    if size(consen_set,2) > delta2
        H = H_temp;
        break;
    end
end
end