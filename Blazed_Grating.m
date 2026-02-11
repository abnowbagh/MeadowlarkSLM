function LoadImageSequence()
%This function will loop through a series of images and load them to the
%SLM

% This loads the image generation functions
if ~libisloaded('ImageGen')
    loadlibrary('ImageGen.dll', 'ImageGen.h');
end

%allocate arrays for our images
width = calllib('Blink_C_wrapper', 'Get_Width');
height = calllib('Blink_C_wrapper', 'Get_Height');
depth = calllib('Blink_C_wrapper', 'Get_Depth');
ImageOne = libpointer('uint8Ptr', zeros(width*height*3,1));
ImageTwo = libpointer('uint8Ptr', zeros(width*height*3,1));
%leave the wavefront correction blank. You should load your custom 
%WFC that was shipped with your SLM
WFC = libpointer('uint8Ptr', zeros(width*height*3,1));

%%
RGB = true;
% itr=10;
% x=[100,100,50,-50,-50,-50];
% y=[0,50,50,-50,-0,50,-50];
% z=[0,0,0,0,0,0,0];
% Number=4;
% Intensity=[10000,10000,10000,10000,10000,10000,10000];
% Affine=false;
% %generating hologram
% calllib('ImageGen','Initialize_HologramGenerator', width, height, depth, itr, RGB);
% calllib('ImageGen','Generate_Hologram', ImageOne, WFC, x,y,z,Intensity,Number, Affine);


% 
% Generate a horizontal blazed grating
Period = 8;
Increasing = 10;
horizontal = true;
calllib('ImageGen', 'Generate_Grating', ImageTwo, WFC, width, height, depth, Period, Increasing, horizontal, RGB);
% % 
% % 
% % 
% % 
% % 
% % % % Generate a vertical blazed grating
Period = 8;
Increasing = 1;
horizontal = true;
calllib('ImageGen', 'Generate_Grating', ImageOne, WFC, width, height, depth, Period, Increasing, horizontal, RGB);
% % 
% % % indicate that our images are RGB images
isEightBit = false;
% % 
% % % Loop between our images
for n = 1:10
	calllib('Blink_C_wrapper', 'Write_image', ImageOne, isEightBit);
	pause(1.0) % This is in seconds
 	calllib('Blink_C_wrapper', 'Write_image', ImageTwo, isEightBit);
 	pause(1.0) % This is in seconds
end
% % 
% calllib('ImageGen','Destruct_HologramGenerator');
%%

%%
% 
% [X, Y] = meshgrid(1:width, 1:height);
% 
% % Initialize grating phase map
% blazed_grating = zeros(height, width);
% 
% % Create varying grating period across X
% for col = 1:height
%     period = 2 + 10 * (col / height);  % Period increases from 2 to 12
%     k = 2 * pi / period;                  % Spatial frequency
%     blazed_grating(col,:) = mod(k * (col - 1), 2*pi);  % Phase ramp at that column
% end
% 
% % Create two spot holograms using linear phase ramps
% % Define spatial frequencies for each spot
% fx1 = 0.03;  fy1 = 0.02;   % First spot
% fx2 = -0.03; fy2 = -0.02;  % Second spot
% 
% % Linear phase ramps
% phi1 = 2 * pi * (fx1 * X + fy1 * Y);
% phi2 = 2 * pi * (fx2 * X + fy2 * Y);
% 
% % Combine both spots
% traps_phase = angle(exp(1i * phi1) + exp(1i * phi2));  % Phase-only hologram
% 
% % Combine traps and blazed grating
% combined_phase = mod(blazed_grating, 2*pi);
% 
% % Convert to 8-bit image for SLM
% slm_image = uint8(255 * combined_phase / (2*pi));
% % send to SLM
% isEightBit = true;
% calllib('Blink_C_wrapper', 'Write_image', slm_image, isEightBit);
% % pause(5)
% % % 
% % 
% % imshow(slm_image, []);
%%

if libisloaded('ImageGen')
    unloadlibrary('ImageGen');
end

end 