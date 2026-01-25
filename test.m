close all; clear all; clc;

%read in image
img = imread('images\faces2.jpg');

%initialise face detector
faceDetector = vision.CascadeObjectDetector(); 

%apply facedetector
bboxes = faceDetector(img);

%annotate detected faces
detectedImage = insertObjectAnnotation(img,'rectangle',bboxes,'Face'); 

%show detected image
figure;
imshow(detectedImage);
title('Face Detection Complete');

