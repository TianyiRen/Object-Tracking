function result = computeFlow(img1, img2, win_radius, template_radius, grid_MN)
window_tpl = template_radius;
window_search = win_radius;

[m,n] = size(img1);
img3 = zeros(2*window_tpl+m, 2*window_tpl+n);
img4 = zeros(2*window_tpl+m, 2*window_tpl+n);
for i = 1:m
    for j = 1:n
        img3(window_tpl+i,window_tpl+j) = img1(i,j);
        img4(window_tpl+i,window_tpl+j) = img2(i,j);
    end
end
for i = 1:m
    for j = 1:n
        for r = 1:1+2*window_tpl
            for t = 1:1+2*window_tpl
                blk1(r,t) = img4(i+r-1,j+t-1);
            end
        end
        tpl(i,j,:) = reshape(blk1,1,(2*window_tpl+1)^2);
    end
end

window_m = grid_MN(1);
window_n = grid_MN(2);
p_x = zeros(m,n);
p_y = zeros(m,n);

for i = 1:window_m:m
    for j = 1:window_n:n
        for r = 1:2*window_tpl+1
            for t = 1:1+2*window_tpl
                blk2(r,t) = img3(i+r-1,j+t-1);
            end
        end
        
        B1 = max(1,i - window_search);
        B3 = max(1,j - window_search);
        B2 = min(m,i + window_search);
        B4 = min(n,j + window_search);
        Li = reshape(blk2,1,(2*window_tpl+1)^2);    
        Li = Li(:);
        blk = tpl(B1:B2,B3:B4,:);
        S = blk.*blk;
        S = sqrt(sum(S,3));
        blk = reshape(blk,(B2-B1+1)*(B4-B3+1),(2*window_tpl+1)^2);
        SS = sqrt(Li'*Li);
        R = reshape(blk*Li, B2-B1+1, B4-B3+1);
        R = R./S/SS;
        max_temp = max(R(:));
        [r2m, r2n] = size(R);
        [i1,i2] = find(R == max_temp);
        p_x(i,j) = B1 + i1(ceil(size(i1,1)/2)) - i - 1;
        p_y(i,j) = B3 + i2(ceil(size(i1,1)/2)) - j - 1;
    end
end

fh1 = figure;
imshow(img1);

for i = 1:window_m:m
    for j = 1:window_n:n
        hold on;
        quiver(j+(window_n-1)/2, i+(window_m-1)/2, p_y(i,j), p_x(i,j),'filed','y');
    end
end

img = getimage(fh1);
truesize(fh1, [size(img1, 1), size(img1, 2)]);
frame = getframe(fh1); 
result = frame.cdata;
