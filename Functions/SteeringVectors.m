function varargot = SteeringVectors(Array,Grid,varargin)
    
    sArgs = containers.Map({'c0','Fs','Type'}...
        ,{343.3,44100,'Static'});
    %%%%%%%%%%% Microphones %%%%%%%%%%%%%
    x_mics = Array.position('x');
    y_mics = Array.position('y');
    z_mics = Array.position('z');
    %%%%%%%%%%% Focus points %%%%%%%%%%%%%
    x_focus = Grid('x');
    y_focus = Grid('y');
    z_focus = Grid('z');
    %%%%%%%%%%% Calculating %%%%%%%%%%%%%%
    for i=1:1:length(x_focus)  
        x_foc = x_focus(i); y_foc = y_focus(i); z_foc = z_focus(i);
        foc_pos = [x_foc y_foc z_foc];
        for n=1:1:Array.n_mic
            x_mic = x_mics(n); y_mic = y_mics(n); z_mic = z_mics(n);
            mic_pos = [x_mic y_mic z_mic];
            steering_vector(i,n) = -exp(2*pi*freq*norm(foc_pos-mic_pos)/sArgs('c0'));
        end
    end

    if nargout >0
       varargout{1} = steering_vector(); 
    end
end

