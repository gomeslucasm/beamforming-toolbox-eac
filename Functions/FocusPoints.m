function Output = FocusPoints(Size,FrameSize,varargin)
    % Default inputs
    sArgs = containers.Map({'z'},{1});
    % Optional inputs
    for i=1:2:length(varargin)
        sArgs(varargin{i}) = varargin{i+1};
    end
    x_grid = -(Size/2):FrameSize:(Size/2);
    y_grid = 0:FrameSize:Size;
    [X,Y] = meshgrid(x_grid,y_grid);   
    X = X(:);
    Y = Y(:);
    Z(1:length(X)) = sArgs('z');
    Output = containers.Map({'x_mesh','y_mesh','z','x','y'},{x_grid,y_grid,Z,X,Y});
end