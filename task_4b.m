%% most code taken from deblur.m (provided for assigment, not written by me)
%% lines 29, 39 and 55-63 are my implementation of the ISRA algorithm
close all; clear; clc;

 h = double(imread('images/testkernel.png')); % motion blur
% h = fspecial('gaussian', [15 15], 5); % Gaussian blur
% h = fspecial('gaussian', [9 9], 4); % Beck-Teboulle SIAM 2009
h = h./sum(h(:));

blur = @(im) imfilter(im,h,'conv','circular');


% Gaussian noise
noise_mean = 0;
% noise_var = 0.00001; % 10^{-5}
noise_var = 0.000001; % 10^{-6} Beck-Teboulle SIAM 2009 

% f = im2double(imread('barbara_face.png'));
f = im2double(imread('cameraman.tif'));
g = imfilter(f,h,'conv','circular'); % blur
g = imnoise(g,'gaussian',noise_mean,noise_var); % ading noise

H = psf2otf(h,size(g));

psnr0 = psnr(f,g);
psnrRL = [psnr0];
psnrLw = [psnr0];
%initialise psnr for ISRA
psnrISRA = [psnr0];

% Wiener deblurring
W = deconvwnr(g,h,0.0001);


RL = g;
Lw = g;
G = fft2(g);
%intialise ISRA variable 
ISRA = g;
%initialise ISRA equation numerator - h(-x,-y)*g(x,y)
numerator = ifft2(conj(H) .* fft2(g));
maxiter = 3000; 
for i = 1:maxiter
 %
 % Richardson-Lucy iterations: RL = RL.*[h(-x)*(g./(RL*h(x)))]
 RL = RL.*ifft2(fft2(g./blur(RL)).*conj(H));
 psnr_RL = psnr(RL,f);
 psnrRL = [psnrRL; psnr_RL];
 %
 % Landweber iterations: Lw = Lw + h(-x)*(Lw-Lw*h(x))
 Lw = Lw + ifft2(conj(H).*(fft2(g-blur(Lw))));
 psnr_Lw = psnr(Lw,f);
 psnrLw = [psnrLw; psnr_Lw];
 %
 %ISRA iterations
 %denominator of ISRA equation - h(-x,-y)*h(x,y)*In(x,y)
 denominator_freqdomain = (conj(H)) .* fft2(blur(ISRA));
 denominator = ifft2(denominator_freqdomain);
 %iteration update step
 ISRA = real(ISRA .* (numerator./denominator));
 %track PSNR as it changes
 psnr_ISRA = psnr(ISRA,f);
 psnrISRA = [psnrISRA; psnr_ISRA];


 %
end

psnrW = psnr(W,f)*ones(maxiter,1);

%compare deblurring
figure,imshow([Lw,RL,ISRA]);title('Landweber, Richardson-Lucy and ISRA on MOTION BLUR');

figure();
semilogy(psnrW,'LineWidth',1.5,'Color',[0,0,1]),axis([1 maxiter 0 30]); 
hold
semilogy(psnrLw,'LineWidth',1.5,'Color',[0,1,0]),axis([1 maxiter 0 35]);
semilogy(psnrRL,'LineWidth',1.5,'Color',[1,0,0]),axis([1 maxiter 0 30]);
semilogy(psnrISRA,'LineWidth',1.5,'Color',[1,0.5,0]),axis([1 maxiter 0 30]);
legend('Wiener', 'Landweber','Richardson-Lucy', 'ISRA');