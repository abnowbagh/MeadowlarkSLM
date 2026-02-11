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

% The number of data points we will use in the calibration is 256 (8 bit's)
NumDataPoints = 256;

% If you are generating a global calibration (recommended) the number of regions is 1, 
% if you are generating a regional calibration (typically not necessary) the number of regions is 64
NumRegions = 1;

%allocate an array for our image, and set the wavefront correction to 0 for the LUT calibration process
Image = libpointer('uint8Ptr', zeros(width*height*3,1));
WFC = libpointer('uint8Ptr', zeros(width*height*3,1));

isEightBit = false;
RGB = true;

% PixelsPerStripe = 5;%initially 8
% 
% PixelValueOne=0;
% PixelValueTwo=128;
% 
% calllib('ImageGen', 'Generate_Stripe', Image, WFC, width, height, depth, PixelValueOne, PixelValueTwo, PixelsPerStripe, RGB);



% % Generate a blazed grating
% Period = 5;
% Increasing = 10;
% horizontal = true;
% calllib('ImageGen', 'Generate_Grating', Image, WFC, width, height, depth, Period, Increasing, horizontal, RGB);
% 
% calllib('Blink_C_wrapper', 'Write_image', Image, isEightBit);

%
%%
%create two spots
isEightBit = true;
[x, y] = meshgrid(linspace(-0.5, 0.5, width), linspace(-0.5, 0.5, height));
% Define spatial frequencies for two spots
% Increase fx/fy to move spots farther out
fx1 = -200; fy1 =70 ; a1=1;
fx2 = -160; fy2 = 200; a2=1;


% Sum two plane waves (complex field)
H = a1*exp(1i * 2 * pi * (fx1 * x + fy1 * y)) + ...
    a2*exp(1i * 2 * pi * (fx2 * x + fy2 * y));

% carrier
fcx=50; fcy=50;
carrier= 2*pi*(fcx*x+fcy*y);

% Extract phase from combined field
raw_phase = angle(H)+carrier;  % Phase from -pi to pi

% Normalize phase to [0,1] for LUT indexing
normalized_phase = mod(raw_phase + pi, 2*pi) / (2*pi);

% Convert to 8-bit (0–255), assuming LUT expects 8-bit index
slm_phase = uint8(normalized_phase * 255);

% Send to SLM
calllib('Blink_C_wrapper', 'Write_image', slm_phase, isEightBit);% this function applies your LUT

%%

%while true
    
% RGB = true;
% itr=10;
% x=[100,-100,100,50,50,-50,-50];
% y=[0,0,100,0,-0,50,-50];
% z=[0,0,0,0,0,0,0];
% Number=3;
% Intensity=[1,1,1,10000,10000,10000,10000];
% Affine=false;
% %generating hologram
% calllib('ImageGen','Initialize_HologramGenerator', width, height, depth, itr, RGB);
% calllib('ImageGen','Generate_Hologram', Image, WFC, x,y,z,Intensity,Number, Affine);
% isEightBit = false;
% calllib('Blink_C_wrapper', 'Write_image', Image, isEightBit);
    
%     
%Curve=interactive_poly_curve();


% lut=[Curve.curve.XData.' int32(Curve.curve.YData.')];
% 
% 
% %lut_file='blazed_lut.csv';
% lut_file='C:\Users\Optical Tweezers\Blink 1920 HDMI\LUT Files\blazed_lut.lut';
% 
% fid = fopen(lut_file, 'w');
% for i = 1:size(lut,1)
%     fprintf(fid, '%g %g\n', lut(i,:));  % Adjust format string as needed
% end
% fclose(fid);
% 
% 
% % 




