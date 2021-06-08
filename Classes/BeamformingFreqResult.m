classdef BeamformingFreqResult
    
    properties
       freq_vector
       freq_data
    end
    
    methods
        %%% class constructor
        function this = BeamformingFreqResult(varargin)
           required_args = ["data","vector"];
           required_inputs = parse_required_args(required_args,varargin);
           this.freq_data = required_inputs('data');
           this.freq_vector = required_inputs('vector');
        end
        %%% get freq data
        function data = get_freq_data(obj,varargin)
           required_args = ["freq",];
           required_inputs = parse_required_args(required_args,varargin);
           [~, idx] = min(abs(required_inputs('freq')-obj.freq_vector));
           data = obj.freq_data(:,:,idx);
        end
    end
    
end