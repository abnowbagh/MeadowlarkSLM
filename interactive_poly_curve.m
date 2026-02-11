% Interactive generation of optimised SLM LUT.
% - Drag the green cursors in y
% - FORMAT TO MEADOWLARK LUT STRUCTURE
% - Save the array to our LUT file
% - Read in the LUT file and write to the SLM
% - Observe camera for changes in 0, +1 and +2 orders.

function data= interactive_poly_curve()
    % Define figure
    f = figure('Name', 'Draggable Polynomial Curve', ...
               'NumberTitle', 'off', ...
               'WindowButtonUpFcn', @stopDragFcn);

    % X domain
    x = linspace(0, 255, 256);
    %x = linspace(0, 255, 1000);
    
    % Fixed anchor points
    anchors_x = [0, 85, 170, 255];
    anchors_y= [2153,2584 ,3214, 4095];
    %anchors_y = [-pi, -1, 1, pi];  % middle two are adjustable

    % Plot initial curve
    curve = plot(x, interp1(anchors_x, anchors_y, x, 'pchip'), 'b-', 'LineWidth', 2); hold on;

    % Plot anchor points
    h_fixed1 = plot(anchors_x(1), anchors_y(1), 'ro', 'MarkerFaceColor', 'r');
    h_fixed2 = plot(anchors_x(4), anchors_y(4), 'ro', 'MarkerFaceColor', 'r');

    h_drag1 = plot(anchors_x(2), anchors_y(2), 'go', 'MarkerFaceColor', 'g', ...
                   'ButtonDownFcn', {@startDragFcn, 2});
    h_drag2 = plot(anchors_x(3), anchors_y(3), 'go', 'MarkerFaceColor', 'g', ...
                   'ButtonDownFcn', {@startDragFcn, 3});

    % Store state
    data.anchors_x = anchors_x;
    data.anchors_y = anchors_y;
    data.curve = curve;
    data.dragging = false;
    data.dragIndex = [];
    data.dragPoints = [h_drag1, h_drag2];
    guidata(f, data);
    

    % Set axes
    axis([0 255 2100 4200]);
    %axis([0 255 -pi-1 pi+1]);
    xlabel('X');
    ylabel('Y');
    title('Drag the green points to reshape the curve');

   
    % Mouse move callback
    set(f, 'WindowButtonMotionFcn', @draggingFcn);
    global c;
    c=0;
%     lut=[curve.XData.' int32(curve.YData.')];
%     lut_file='C:\Users\Optical Tweezers\Blink 1920 HDMI\LUT Files\blazed_lut.lut';
%     calllib('Blink_C_wrapper', 'Load_lut', lut_file);
%     disp('lut updated')


%     %lut_file='blazed_lut.csv';
%     lut_file='C:\Users\Optical Tweezers\Blink 1920 HDMI\LUT Files\blazed_lut.lut';
% 
%     fid = fopen(lut_file, 'w');
%     for i = 1:size(lut,1)
%         fprintf(fid, '%g %g\n', lut(i,:));  % Adjust format string as needed
%     end
%     fclose(fid);
%     %pause(2);
    end

function startDragFcn(src, ~, index)
    f = ancestor(src, 'figure');
    data = guidata(f);
    data.dragging = true;
    data.dragIndex = index;
    guidata(f, data);
end

function stopDragFcn(~, ~)
    f = gcf;
    data = guidata(f);
    data.dragging = false;
    data.dragIndex = [];
    guidata(f, data);
    
    lut=[data.curve.XData.' int32(data.curve.YData.')];


        %lut_file='blazed_lut.csv';
        lut_file='C:\Users\Optical Tweezers\Blink 1920 HDMI\LUT Files\blazed_lut.lut';

        fid = fopen(lut_file, 'w');
        for i = 1:size(lut,1)
            fprintf(fid, '%g %g\n', lut(i,:));  % Adjust format string as needed
        end
        fclose(fid);
        disp('change')
        pause(0.05)

   
            calllib('Blink_C_wrapper', 'Load_lut', lut_file);
            disp('lut updated');
end

function draggingFcn(src, ~)
    data = guidata(src);

    if data.dragging
        cp = get(gca, 'CurrentPoint');
        newY = cp(1,2);  % get new y position from mouse
        index = data.dragIndex;

        % Clamp y to visible range
        newY= max(min(newY, 4200), 2100);
        %newY = max(min(newY, pi+1), -pi-1);

        % Update data
        data.anchors_y(index) = newY;

        % Update point position
        set(data.dragPoints(index-1), 'YData', newY);

        % Recalculate and update curve
        x = linspace(0, 255, 256);
        %x = linspace(0, 255, 1000);
        y = interp1(data.anchors_x, data.anchors_y, x, 'pchip');
        set(data.curve, 'YData', y);

        % Save state
        guidata(src, data);
        
%         lut=[data.curve.XData.' int32(data.curve.YData.')];
% 
% 
%         %lut_file='blazed_lut.csv';
%         lut_file='C:\Users\Optical Tweezers\Blink 1920 HDMI\LUT Files\blazed_lut.lut';
% 
%         fid = fopen(lut_file, 'w');
%         for i = 1:size(lut,1)
%             fprintf(fid, '%g %g\n', lut(i,:));  % Adjust format string as needed
%         end
%         fclose(fid);
%         disp('change')
%         pause(0.1)
% 
%         
%         %if(mod(c,10)==0)
%             calllib('Blink_C_wrapper', 'Load_lut', lut_file);
%             disp('lut updated');
%          %   c=0;
        %end
    end
end