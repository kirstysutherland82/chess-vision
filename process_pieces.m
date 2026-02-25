close all; clear all; clc;

data = load('board_calibration.mat');
board_dictionary = data.board_dictionary;

% read in image
raw_img = imread('images\week7\e4.jpg');
%rotate
img=imrotate(raw_img,-90);
%use pink mask
masked_img = pink_mask_function(img);


piece_centre_coords = [];

%show boundaries labeled in green
[B,L] = bwboundaries(masked_img,'noholes');
stats = regionprops(L, 'Centroid', 'Area');
figure,imshow(img);imshow(masked_img);
minArea = 500;
hold on;
for k = 1:length(B)
      if stats(k).Area>minArea
            boundary = B{k};
            plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
            centroid = stats(k).Centroid;
            plot(centroid(1), centroid(2), 'r*', 'MarkerSize', 10, 'LineWidth', 2);
            %fill in square coords
            piece_centre_coords = [piece_centre_coords; centroid];
      end
end

%list of square names
pos_list = board_dictionary.keys;

%occupancy grid - 8x8 1s and 0s
occupancy_grid = zeros(8,8);

%radius of sticker
radius = 120;

for i=1:64
    number_row = mod(i-1, 8) + 1;
    letter_col = floor((i-1)/8) + 1;


    current_pos = pos_list(i);
    square_coord = board_dictionary(current_pos);
    square_xy = square_coord{1}; % unpacks xy coords

    if ~isempty(piece_centre_coords)
      euc_distances = sqrt((piece_centre_coords(:,1) - square_xy(1)).^2 + (piece_centre_coords(:,2) - square_xy(2)).^2);

      if any (euc_distances <=radius)
            occupancy_grid(number_row,letter_col) = 1;
      end

    end 

end      


figure, imshow(img); hold on;
for i = 1:64
    center = board_dictionary(pos_list(i));
    xy = center{1};
    % Draw a circle for the radius
    viscircles(xy, radius, 'Color', 'b', 'LineWidth', 1);
end
plot(piece_centre_coords(:,1), piece_centre_coords(:,2), 'r*', 'MarkerSize', 10);

disp(occupancy_grid);