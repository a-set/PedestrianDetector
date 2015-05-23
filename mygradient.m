function [mag,ori] = mygradient(I)

%Set filter values
Dx = [-1 0 1]; Dy = [-1;0;1];
%Compute Gradient images
Gx = conv2(im2double(I),Dx,'same');
Gy = conv2(im2double(I),Dy,'same');
%Compute Gradient intensity images
%magnitude
mag = sqrt(Gx.^2 + Gy.^2);
%direction
ori = atan2(Gy,Gx);
end
