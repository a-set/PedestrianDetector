% load a training example image
Itrain = im2double(rgb2gray(imread('train.jpg')));
%for 100 negative examples
i =1;
Itrain2 = im2double(rgb2gray(imread('test3.jpg')));
nSamples = cell(1,100);
%Built negative samples
xnmin =1;
ynmin =1;
[hn,wn] = size(Itrain2);
while (xnmin +150 < wn && ynmin +600 < hn)
    nSamples{i} = Itrain2(ynmin:ynmin+600,xnmin:xnmin+150);
    ynmin = ynmin + 1;
    xnmin = xnmin + 1;
    i = i+1;
end


%have the user select 5 positive examples in the image
n = 5;
imshow(Itrain);
Rect = cell(1,n);
ar = zeros(1,n);
w = zeros(1,n);
h = zeros(1,n);
for i=1:n
    Rect{i} = getrect();
    ar(1,i) = Rect{i}(1,4)/Rect{i}(1,3);
    h(1,i) = Rect{i}(1,4);
    w(1,i) = Rect{i}(1,3);
end
meanH = mean(h);
meanW = mean(w);
meanAr = mean(ar);
%Computing the perfect size of the image using gradient descent like
%procedure
aspectratio = meanH/meanW;
if aspectratio > meanAr
    while (aspectratio > meanAr)
        meanH = meanH - rem(meanH,8);
        meanW = meanW + (8-rem(meanW,8));
        aspectratio = meanH/meanW;
    end
else
    if aspectratio < meanAr
        while aspectratio < meanAr
            meanH = meanH + (8 - rem(meanH,8));
            meanW = meanW - rem(meanW,8);
            aspectratio = meanH/meanW;
        end
    end
end
%Compute the distance of apsectratio from meanAr
d1 = abs(aspectratio - meanAr);
%Compute the distance of previous sample from meanAr
d2 = abs((meanH - rem(meanH,8))/meanW + (8-rem(meanW,8)));
%Compute the distance of the next sample from the meanAr
d3 = abs( (meanH + (8 - rem(meanH,8)))/(meanW - rem(meanW,8)));
%the minimum of the three distances should be the final size of the
%template 
if d1 < d2 && d1 < d3
    finalH = meanH;
    finalW = meanW;
else
    if (d2<d1 && d2 < d3)
        finalH = meanH - rem(meanH,8);
        finalW = meanW + (8-rem(meanW,8));
    else
        finalH = meanH + (8 - rem(meanH,8));
        finalW = meanW - rem(meanW,8);
    end
end
%Resize all samples to finalH and finalW
Samples = cell(1,n);
for i=1:n
    xmin = Rect{i}(1,1);
    ymin = Rect{i}(1,2);
    w = Rect{i}(1,3);
    h = Rect{i}(1,4);
    Samples{i} = Itrain(ymin:ymin+h,xmin:xmin+w);
    imshow(Samples{i});
end

%Compute the template from the hog feature set of training samples
Features = cell(1,n+100);
Template = zeros(finalH,finalW);
Template = hog(Template);
h1 = size(Template,1);
w1 = size(Template,2);
b1 = size(Template,3);
Template = reshape(Template, [1 h1*w1*b1]);
for i=1:n
    Features{i} = hog(imresize(Samples{i},[finalH,finalW]));
    Features{i} = reshape(Features{i},[1 h1*w1*b1]);
    Template = Template + Features{i};
end
%add negative samples
for i=1:100
    Features{n+i} = hog(imresize(nSamples{i},[finalH,finalW]));
    Features{n+i} = reshape(Features{n+i},[1 h1*w1*b1]);
    Template = Template + Features{n+i};
end
Template = Template./(n+100);
%resize back to 3D template
Template = reshape(Template,[h1 w1 b1]);

%
% load a test image
%
Itest= im2double(rgb2gray(imread('test0.jpg')));


% find top 5 detections in Itest
ndet = 5;
[x,y,score] = detect(Itest,Template,ndet);

%display top ndet detections
figure(3); clf; imshow(Itest);
for i = 1:ndet
  % draw a rectangle.  use color to encode confidence of detection
  %  top scoring are green, fading to red
  hold on; 
  h = rectangle('Position',[x(i)-64 y(i)-64 finalW finalH],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]); 
  hold off;
end

