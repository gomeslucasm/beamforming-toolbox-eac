function dynamic_range = array_dynamic_range(array_response, varargin)


%% Inputs
default_args = containers.Map({'freq','plot_peaks'},...
    {array_response.data.freq_vector(1), false});
default_inputs = parse_default_args(default_args,varargin);
frequency = default_inputs('freq');
%% Pre processing

normalized_data = abs(array_response.get_freq_data('freq',frequency));
normalized_data = normalized_data/max(max(normalized_data));
array_response.data.freq_data = normalized_data;
array_response_data = mag2dbPa(normalized_data);

%% Find regional max (peaks)
TF = imregionalmax(array_response_data);
l_data = size(array_response_data);
%% Reshaping position data to the same size of response
pos_x = reshape(array_response.grid('x'),l_data);
pos_y = reshape(array_response.grid('y'),l_data);
%% Getting position and data from peaks values
pos_x_max = pos_x(TF(:));
pos_y_max = pos_y(TF(:));
array_response_data_max = array_response_data(TF(:));
%% Order ascending peak values
[ordered_data, idxs] = sort(array_response_data_max);
ordered_pos_x = pos_x_max(idxs);
ordered_pos_y = pos_y_max(idxs);
%% Dynamic range (max - second_max)
dynamic_range = ordered_data(end) - ordered_data(end-1);
%% Optional plot

if default_args('plot_peaks')
    figure()
    array_response.plot_3D('freq',frequency)
    hold on 
    plot3(ordered_pos_x(end), ordered_pos_y(end),ordered_data(end),'gs',...
        'LineWidth',2,...
        'MarkerSize',10,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor','	magenta')
    hold on 
    plot3(ordered_pos_x(end-1), ordered_pos_y(end-1),ordered_data(end-1),'gs',...
        'LineWidth',2,...
        'MarkerSize',10,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor','green')
    legend('Resposta do array', 'Maior pico', 'Segundo maior pico')
    colorbar
    xlabel('x (m)')
    ylabel('y (m)')
    a = colorbar;
    a.Label.String = 'Amplitude (dB ref.:1e-5)';
    title(['Reposta do array - ' array_response.info.array_type '  - F = ' ... 
        num2str(frequency)  'Hz - Faixa dinâmica = ' num2str(dynamic_range) ' dB'])
end
%%
end