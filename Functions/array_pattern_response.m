function varargout = array_pattern_response(array, frequency, distance, size, frame_size)
%%%%%%%%%%
if isscalar(frequency)
   frequency = [frequency];
end
c0 = 343;
%%%%%%%%%% Focus points
    out_focus_data = FocusPoints(size, frame_size);
    out_focus = struct();
    out_focus.x = out_focus_data('x');
    out_focus.y = out_focus_data('y');
    out_focus.x_mesh = out_focus_data('x_mesh');
    out_focus.y_mesh = out_focus_data('y_mesh');
%%%%%%%%%%%

out_data = [];
mic_pos = struct();
mic_pos_x = array.position('x');
mic_pos_y = array.position('y');
mic_pos_z = array.position('z');

origin_array = array.Origin();
source_pos_x = origin_array('x');
source_pos_y = origin_array('y');
source_pos_z = distance;


out_beam_func = zeros(length(out_focus.x),length(frequency));
%%%%%%%%%%% 
for n_f=1:1:length(out_focus.x)
    focus_point_array_origin_distance = sqrt(( origin_array('x') - out_focus.x(n_f) ).^2 + ...
                                             ( origin_array('y') - out_focus.y(n_f) ).^2 + ...
                                             ( distance ).^2 );
                                         
    focus_point_mic_distances = sqrt(( mic_pos_x(:) - out_focus.x(n_f) ).^2 + ...
                                     ( mic_pos_y(:) - out_focus.y(n_f) ).^2 + ...
                                     ( distance ).^2 );
    source_array_origin_distance = distance;
    source_mic_distances = sqrt( (mic_pos_x(:) - source_pos_x).^2 + ...
                                 (mic_pos_y(:) - source_pos_y).^2 + ...
                                 (mic_pos_z(:) - source_pos_z).^2 );
    
    for n_freq = 1:1:length(frequency)     
        out_data(n_f,n_freq) = 1;
        G = exp(1i.*(2*pi*frequency(n_freq)).*...
            ((source_array_origin_distance - focus_point_array_origin_distance) - ...
            (source_mic_distances - focus_point_mic_distances))./c0);
        
        G = G.*((focus_point_mic_distances.*source_array_origin_distance)./...
            (focus_point_array_origin_distance.*source_mic_distances));
        out_beam_func(n_f,n_freq) = sum(G);
    end
end

k=0;
for n_x =1:1:length(out_focus.x_mesh)
    for n_y = 1:1:length(out_focus.y_mesh)
        k=k+1;
        f_conc(n_y,n_x,:) = out_beam_func(k,:);
    end
end 


if nargout>0
    infos = struct();
    infos.array_type = array.info.type;
    data = BeamformingFreqResult('data',f_conc,'vector',frequency);
    grid  = containers.Map({'x','y', 'x_mesh', 'y_mesh'},...
        {out_focus.x, out_focus.y, out_focus.x_mesh,out_focus.y_mesh});
    out = BeamformingResult('data',data,'grid',grid,'info', infos);
    varargout{1} = out;
end
    
end