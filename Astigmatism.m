clear all
close all
clc
% This loads the image generation functions
if ~libisloaded('ImageGen')
    loadlibrary('ImageGen.dll', 'ImageGen.h');
end
loadlibrary('Blink_C_Wrapper.dll', 'Blink_C_Wrapper.h');
% read the SLM height and width. 
width = calllib('Blink_C_wrapper', 'Get_Width');
height = calllib('Blink_C_wrapper', 'Get_Height');
depth = calllib('Blink_C_wrapper', 'Get_Depth');

%
%% Astigmatism

Ax=0.5;
Ay=0.1;

[x, y] = meshgrid(linspace(-0.5, 0.5, width), linspace(-0.5, 0.5, height));

phi_ast= Ax*x.^2+ Ay*y.^2;



% Normalize phase to [0,1] for LUT indexing
normalized_phase = mod(phi_ast, 2*pi);

% Convert to 8-bit (0–255), assuming LUT expects 8-bit index
slm_phase = uint8(normalized_phase * 255);

% Send to SLM
calllib('Blink_C_wrapper', 'Write_image', slm_phase, isEightBit);% this function applies your LUT

imagesc(normalized_phase)
axis image
colormap gray
colorbar
title('Astigmatic Phase Mask')



