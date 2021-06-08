function varargout = MakeSource(position,amp,f,varargin)
    % Constructor of the MVSource class

    output = MVSource;
    % Positions
    label_pos = {'x','y','z'};
    for i=1:1:length(position)
        output.position(label_pos{i}) = position(i);
    end
    for i=length(position):1:length(label_pos)
        output.position(label_pos{i}) = 0;
    end
    % Spectrum
    output.spec_data('amp') = real(amp);
    output.spec_data('freq') = f;
    % Add noise variable
    if nargin>3 && nargin<6
        output.spec_data(varargin{1}) = varargin{2};
    else
        output.spec_data('noise') = 0;
    end
    varargout{1} = output;
end

