clear all
close all
clc
% This loads the image generation functions
if ~libisloaded('ImageGen')
    loadlibrary('ImageGen.dll', 'ImageGen.h');
end

% read the SLM height and width. 
width = calllib('Blink_C_wrapper', 'Get_Width');
height = calllib('Blink_C_wrapper', 'Get_Height');
depth = calllib('Blink_C_wrapper', 'Get_Depth');
pixel=8e-6;
Ncycles=20;
%
%% Astigmatism
for i=1


[x, y] = meshgrid(linspace(-0.5, 0.5, width), linspace(-0.5, 0.5, height));
alpha=i*pi

k = Ncycles/(width*pixel);
% %l = Ncycles/(Ny.*pixel);% cycles per metre
phiTiltX = 2*pi*k .* X;           % linear phase in x
phiTiltY = 0; %2*pi*l .* Y;
 phiTilt=phiTiltX;
%phi_ast= alpha*(x.^2-y.^2);


isEightBit = true;
RGB = true;

% Normalize phase to [0,1] for LUT indexing
normalized_phase = mod(phi_tilt+pi, 2*pi)/(2*pi);

% Convert to 8-bit (0–255), assuming LUT expects 8-bit index
slm_phase = uint8(normalized_phase * 255);

% Send to SLM
calllib('Blink_C_wrapper', 'Write_image', slm_phase, isEightBit);% this function applies your LUT

imagesc(normalized_phase)
axis image
colormap hsv
caxis([0 1]) 
colorbar
title('Astigmatic Phase Mask')
%pause(1.0)
end


