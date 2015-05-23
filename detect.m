
function [x,y,score] = detect(I,template,ndet)
%
% return top ndet detections found by applying template to the given image.
%   x,y should contain the coordinates of the detections in the image
%   score should contain the scores of the detections
%


% compute the feature map for the image
f = hog(I);

nori = size(f,3);

% cross-correlate template with feature map to get a total response
R = zeros(size(f,1),size(f,2));
for i = 1:nori
  R = R + filter2(template(:,:,i),f(:,:,i));
end

% now return locations of the top ndet detections

% sort response from high to low
[val,ind] = sort(R(:),'descend');

% work down the list of responses, removing overlapping detections as we go
i = 1;
detcount = 1;
h = size(f,1);
x = zeros(1,ndet);
y = zeros(1,ndet);
score = zeros(1,ndet);
while ((detcount <= ndet) && (i < length(ind)))
  % convert ind(i) back to (i,j) values to get coordinates of the block
  xblock = ceil(ind(i)/h);
  yblock = ind(i) - (h*(xblock-1)+1)+1;
  assert(val(i)==R(yblock,xblock)); %make sure we did the indexing correctly

  % now convert yblock,xblock to pixel coordinates 
  ypixel = 8*yblock;
  xpixel = 8*xblock;
  overlap = 0;
  % check if this detection overlaps any detections which we've already added to the list
  
  if(find(x == xpixel))
      if(find(y==ypixel<8))  
        overlap = 1;
      end
  end 
  % if not, then add this detection location and score to the list we return
 
  if (~overlap)
    x(detcount) = xpixel;
    y(detcount) = ypixel;
    score(detcount) = R(yblock,xblock);
    detcount = detcount+1;
  end
  i = i + 1;
end
end


