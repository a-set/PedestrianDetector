function ohist = hog(I)
%
% compute orientation histograms over 8x8 blocks of pixels
% orientations are binned into 9 possible bins
%
% I : grayscale image of dimension HxW
% ohist : orinetation histograms for each block. ohist is of dimension (H/8)x(W/8)x9
%

[h,w] = size(I); %size of the input
h2 = ceil(h/8); %the size of the output
w2 = ceil(w/8);
nori = 9;       %number of orientation bins

[mag,ori] = mygradient(I);

%Threshold
thresh = 0.1*max(mag(:));

ohist= zeros(h2,w2,nori);
for i= 1:nori
    B =  mag<thresh & ori>=(-pi/2 + ((i-1)*pi)/9) & ori<(-pi/2+(i*pi)/9);
    % sum up the values over 8x8 pixel blocks.
    chblock  = im2col(B,[8 8],'distinct');  %useful function for grabbing blocks
    ohist(:,:,i) = reshape(sum(chblock),[h2 w2]);
end
%sum over each block for all bins
sum1 = sum(ohist,3);
%Convert all zeros to ones in the sum matrix
sum2 = sum1==0;
sum1 = sum1 + sum2;
%now all zeros in sum1 have been converted to ones.
%Division can be performed on all bins now
for i=1:nori
   ohist(:,:,i) = ohist(:,:,i)./sum1; 
end
end



