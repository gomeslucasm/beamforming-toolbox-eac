classdef BeamformingResult
    properties
        grid; % grid or mesh values
        data; % (BeamformingFreqResult ou BeamformingTimeResult)
        Fs; % sampling rate
    end
    
    methods
        function this = BeamformingResult(varargin)
           required_args = {'grid','data'};
           default_args = containers.Map({'Fs'},{44100});
           required_inputs = parse_required_args(required_args,varargin);
           default_inputs = parse_default_args(default_args,varargin);
           
           this.data = required_inputs('data');
           this.grid = required_inputs('grid');
           this.Fs = default_inputs('Fs');
        end
        function h = plot(obj, varargin)
            % default arguments
            default_args = containers.Map(...
                {'DR','interp','transparent','dB'},...
                {10, true, false, true});
            % parsing default args and inputs
            parsed_args = parse_default_args(default_args,varargin);
            % get data to plot
            plot_data = abs(obj.data.get_freq_data(varargin{:}));
            % dB data
            if parsed_args('dB')
                plot_data = mag2dbPa(plot_data);
            end
            max_val = max(max(plot_data));
            % putting the minimun value equal to max minus dynamic range
             plot_data(plot_data < max_val - parsed_args('DR')) = ...
                 max_val - parsed_args('DR');
            h = pcolor(obj.grid('x_mesh'),obj.grid('y_mesh'),plot_data)
             caxis([max_val-parsed_args('DR') max_val])
            if parsed_args('transparent')      
                cmap = [[1 1 1]; jet];
                colormap(cmap)
            else
                colormap(jet)
            end
            if parsed_args('interp')
               shading interp; 
            end
        end
    end

end

