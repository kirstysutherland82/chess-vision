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



%show boundaries labeled in green
[B,L] = bwboundaries(squares_only,'noholes');
stats = regionprops(L, 'Centroid', 'Area');
minArea = 10000;
maxArea = 1000000
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
   if stats(k).Area>minArea && stats(k).Area<maxArea
      boundary = B{k};
      plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
      centroid = stats(k).Centroid;
      plot(centroid(1), centroid(2), 'r*', 'MarkerSize', 10, 'LineWidth', 2);
   end
end


figure;
imshow(gauss_img);

%%%%%%%%%%%%%%%%%%% Board mask method (doesnt work) %%%%%%%%%%%%%%%%%%%
%% Join nearby edges to form solid shapes
%se = strel('square', 5);
%closed_edges = imclose(canny_img, se);
%filled_board = imfill(closed_edges, 'holes');
%stats = regionprops(filled_board, 'Area', 'BoundingBox', 'PixelIdxList');
%[~, idx] = max([stats.Area]); % Find index of the largest area

%% Create a mask for ONLY the board
%board_mask = false(size(filled_board));
%board_mask(stats(idx).PixelIdxList) = true;
%Isolate the board edges by removing background clutter
%isolated_canny = canny_img .* board_mask;

%% Crop the image to just the board's bounding box
%board_box = stats(idx).BoundingBox;
%cropped_board = imcrop(isolated_canny, board_box);

%% show image
%figure;
%imshow(cropped_board);