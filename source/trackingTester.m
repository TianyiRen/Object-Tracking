function trackingTester(data_params, tracking_params)
countBin = tracking_params.bin_n; 
Rectangle = tracking_params.rect;
x_1 = Rectangle(2); y_1 = Rectangle(1);
x_2 = Rectangle(4) + x_1 - 1; y_2 = Rectangle(3) + y_1 -1;
mkdir(data_params.out_dir);
f_max = max(data_params.frame_ids);
f_min = min(data_params.frame_ids);

FName = data_params.genFname(data_params.frame_ids(f_min));
img = imread(fullfile(data_params.data_dir, FName));
[M, map]=rgb2ind(img(x_1:x_2,y_1:y_2,:), countBin);
% [M,map] = rgb2ind(countBin);
MM = histc(M(:), 0:countBin-1);
MM = MM - mean(MM);
c_x = round((x_1+x_2)/2);
c_y = round((y_1+y_2)/2);


for i = f_min:f_max
    F_i = data_params.genFname(data_params.frame_ids(i));
    img = imread(fullfile(data_params.data_dir,F_i));
    [m,n] = size(img);
    boundary_1 = c_x - tracking_params.search_half_window_size;
    boundary_2 = c_x + tracking_params.search_half_window_size;
    boundary_3 = c_y - tracking_params.search_half_window_size;
    boundary_4 = c_y + tracking_params.search_half_window_size;
    
    for p = boundary_1:boundary_2
        
        for q = boundary_3:boundary_4
            R4 = round((Rectangle(4)-1)/2);
            R3 = round((Rectangle(3)-1)/2);
            c_1 = p - R4;
            c_2 = q - R3;
            NN = rgb2ind(img(c_1:Rectangle(4)+c_1-1, c_2:Rectangle(3)+c_2-1, :), map);
            NN = histc(NN(:),0:countBin-1);
            NN = NN - mean(NN);
            temp = sqrt((MM'*MM)*(NN'*NN));
            temp = (MM'*NN) / temp;
            C(p - boundary_1 + 1, q - boundary_3 + 1) = temp;
        end
    end
    
    [index_x, index_y] = find(C == max(C(:)));
    c_x = c_x + index_x(ceil(size(index_x,1)/2)) - tracking_params.search_half_window_size - 1;
    c_y = c_y + index_y(ceil(size(index_x,1)/2)) - tracking_params.search_half_window_size - 1;
    c_1 = c_x - R4;
    c_3 = c_y - R3;
    
    img = drawBox(img, [c_3 c_1 Rectangle(3) Rectangle(4)], [0 0 255], 1);
    imwrite(img,fullfile(data_params.out_dir, F_i));
end


