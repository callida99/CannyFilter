close all;
sigma = 1 ; % sigma for Gaussian filter

%Load and display original image
im = imread('sample.png');

%Step 1: Apply Gaussian Filter to reduce noise
im = rgb2gray(im)
im = double(imgaussfilt(im,sigma));

%Step 2: Determine the intensity Gradients using Sobel filter and find
%magnitude of an Image
Gx = SobelFilter(im, 'x'); %intensity gradient x
Gy = SobelFilter(im, 'y'); %intensity gradient y
title('intensity gradient x');
title('intensity gradient y');

Gmag = sqrt(Gx.^2 + Gy.^2); %magnitude
angle = atan2(Gy,Gx)*180/pi;% angle

%Step 3: Make all angles directions positive and adjust them to 0 45 90 135
angle = AdjustAngleDirections(angle);

%Step 4: Non-Maximum Supression
[height,width] = size(angle);
CannyMatrix = zeros(height,width); %create empty matrix to fill it with proper parameters

for y = 2:height-1
    for x = 2:width-1
        if (angle(y,x)==0) 
            if (Gmag(y,x) >= Gmag(y,x+1)) && ...
                   (Gmag(y,x) >= Gmag(y,x-1))
                    CannyMatrix(y,x)= Gmag(y,x);
                else
                    CannyMatrix(y,x)=0;
            end
        elseif(angle(y,x)==90)
              if (Gmag(y,x) >= Gmag(y+1,x)) && ...
                   (Gmag(y,x) >= Gmag(y-1,x))
                    CannyMatrix(y,x)= Gmag(y,x);
                else
                    CannyMatrix(y,x)=0;
              end 
             
        elseif(angle(y,x)==45)
              if (Gmag(y,x) >= Gmag(y+1,x+1)) && ...
                   (Gmag(y,x) >= Gmag(y-1,x-1))
                    CannyMatrix(y,x)= Gmag(y,x);
                else
                    CannyMatrix(y,x)=0;
              end 
             
        elseif(angle(y,x)==135)
              if (Gmag(y,x) >= Gmag(y+1,x-1)) && ...
                   (Gmag(y,x) >= Gmag(y-1,x+1))
                    CannyMatrix(y,x)= Gmag(y,x);
                else
                    CannyMatrix(y,x)=0;
              end 
       
        end
    end
end

CannyMatrix = Normalize(CannyMatrix);
imshow(CannyMatrix)

%Step 5 : Hysterics thresholding
lowThreshold = 0.01  ;
highThreshold = 0.06;

lowThreshold = lowThreshold * max(max(CannyMatrix));
highThreshold = highThreshold * max(max(CannyMatrix));
CannyFinal = zeros (height, width);

for i = 1  : height
    for j = 1 : width
        if (CannyMatrix(i, j) < lowThreshold)
            CannyFinal(i, j) = 0;
        elseif (CannyMatrix(i, j) > highThreshold)
            CannyFinal(i, j) = 1;
              elseif ( CannyMatrix(i+1,j)>highThreshold || CannyMatrix(i-1,j)>highThreshold ||...
                  CannyMatrix(i,j+1)>highThreshold|| CannyMatrix(i,j-1)>highThreshold || ...
              CannyMatrix(i-1, j-1)>highThreshold || CannyMatrix(i-1, j+1)>highThreshold|| ...
          CannyMatrix(i+1, j+1)>highThreshold || CannyMatrix(i+1, j-1)>highThreshold)
      
           CannyFinal(i,j) = 1;
        end
    end
end

figure, imshow(CannyFinal);

im2 = imread('598644.jpg');
im2 = rgb2gray(im2)
canny2 = edge(im2,'Canny');
imshow(canny2);

imshow(CannyFinal);
title("My method");











function[angle] = AdjustAngleDirections(angle) %change here to one for loop
[height,width] = size(angle);

 for i = 1:height
    for j = 1:width
        if(angle(i,j)<0)
            angle(i,j) = 360 + angle(i,j);
        end
    end
 end   
    
    for i = 1:height
        for j = 1:width
              if ((angle(i, j) >= 0 ) && (angle(i, j) < 22.5) || (angle(i, j) >= 157.5) && (angle(i, j) < 202.5)...
                      || (angle(i, j) >= 337.5) && (angle(i, j) <= 360))
                   angle(i,j)=0;
             elseif ((angle(i, j) >= 22.5) && (angle(i, j) < 67.5) || (angle(i, j) >= 202.5) && (angle(i, j) < 247.5))
                   angle(i, j) = 45;
             elseif ((angle(i, j) >= 67.5 && angle(i, j) < 112.5) || (angle(i, j) >= 247.5 && angle(i, j) < 292.5))
                   angle(i, j) = 90;
                    
             elseif ((angle(i, j) >= 112.5 && angle(i, j) < 157.5) || (angle(i, j) >= 292.5 && angle(i, j) < 337.5))
                      angle(i, j) = 135;
                      
              end
         end
    end
 end


% change Sobel filter function
function[A] = SobelFilter(A, filterDirection)
    switch filterDirection
        case 'x' 
            Gx = [-1 0 +1; -2 0 +2; -1 0 +1];
            A = imfilter(A, double(Gx), 'conv', 'replicate'); %filter the image in x direction
        case 'y'
            Gy = [-1 -2 -1; 0 0 0; +1 +2 +1];
            A = imfilter(A, double(Gy), 'conv', 'replicate'); %filter the image in y direction
        otherwise
            error('Bad filter direction - try inputs ''x'' or ''y''');
    end
end

%Normalisation
% Normalize matrix
function[A] = Normalize(A)
    A = A/max(A(:));
end

