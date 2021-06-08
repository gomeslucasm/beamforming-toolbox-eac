classdef ImageToPlot 
    
   properties
       image_file
       figure_length = 1
       x_offset = 0
       y_offset = 0
       alpha = 0.5
   end
   
   methods
       %%%%%%%%% Class constructor %%%%%%%%%%%%%%
       function this = ImageToPlot(image_file,varargin) 
        default_args = containers.Map({'x_offset','y_offset',...
            'figure_length'},{0,0,0.8});
        default_inputs = parse_default_args(default_args,varargin);
        this.image_file = image_file;
        this.figure_length = default_inputs('figure_length');
        this.x_offset = default_inputs('x_offset');
        this.y_offset = default_inputs('y_offset');
       end
       %%%%%%%% Plot funtion %%%%%%%%%%%%%%%%%%%%%
       function h = plot(obj,varargin)
         default_args = containers.Map({'alpha'},{.7});
         default_inputs = parse_default_args(default_args,varargin);
         I = imread(obj.image_file); 
         Lfig = obj.figure_length/2;
         h = image('CData',flipud(I),'XData',[-Lfig Lfig], ...
                  'YData',[0 2*Lfig],...
                  'alphadata',default_inputs('alpha')) 
%          xlim([-Lfig Lfig])
%          ylim([0 2*Lfig])
         uistack(h,'top')
       end        
   end
    
end