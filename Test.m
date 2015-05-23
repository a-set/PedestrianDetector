%Test %read an image
I = imread('test0.jpg');
%convert to gray scale
I = rgb2gray(I);
result = hog(I);

