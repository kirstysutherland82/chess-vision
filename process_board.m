close all; clear all; clc;

% read in image
img = imread('images\board_with_white_bg.jpg');
% convert to greyscale
grey_img = rgb2gray(img);
% gaussian blurring filter
gauss_img = imgaussfilt(grey_img,20);
% canny edge detection
canny_img = edge(gauss_img,'Canny');
%dialate edges
se = strel('square', 15); 
dialated_edges = imdilate(canny_img, se);
% fill holes
holes_filled = imfill(dialated_edges,"holes");
%disregard big board
squares_only = holes_filled & ~dialated_edges;
double = im2double(canny_img);
%initialise square coords array
square_coords = [];


%show boundaries labeled in green
[B,L] = bwboundaries(squares_only,'noholes');
stats = regionprops(L, 'Centroid', 'Area');
minArea = 10000;
maxArea = 1000000;
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
   if stats(k).Area>minArea && stats(k).Area<maxArea
      boundary = B{k};
      plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
      centroid = stats(k).Centroid;
      plot(centroid(1), centroid(2), 'r*', 'MarkerSize', 10, 'LineWidth', 2);
      %fill in square coords
      square_coords = [square_coords; centroid];
   end
end

%sort coords into a1-h8 order
y_sorted = sortrows(square_coords,2);
%initialise final array
coords_sorted = zeros(64,2);
%loops through every 8 rows
for i = 0:7
   rows = ((8*i +1):(8*i) +8);
   currentRow = y_sorted(rows, :);

   %sort left to right by x coord
   coords_sorted(rows,:) = sortrows(currentRow,1);
end