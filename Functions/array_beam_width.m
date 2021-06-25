function beam_width = array_beam_width(array_response, varargin)

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
%% Procurando valor menor que 3dB
beam_value = ordered_data(end) - 3;
minor_than_beam = array_response_data(array_response_data<beam_value);
pos_x_minor_than_beam = pos_x(array_response_data<beam_value);
pos_y_minor_than_beam = pos_y(array_response_data<beam_value);
[val, idx] = min(abs(sqrt((ordered_pos_x(end)-pos_x_minor_than_beam).^2 + (ordered_pos_y(end)-pos_y_minor_than_beam).^2)));
%%
beam_width = sqrt((pos_x_minor_than_beam(idx) - ordered_pos_x(end)).^2 + ...
    (pos_x_minor_than_beam(idx) - ordered_pos_x(end)).^2);
%%
end