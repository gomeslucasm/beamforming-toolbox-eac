classdef Source < master_mvs
    properties
        position     
        spec_data 
    end
    methods
        %%%%%%%%%% Create Audio %%%%%%%%%%%%%%%%%%%%%
        function varargout = CreateAudio(obj,varargin)
            % Default Inputs
            sArgs = containers.Map({'T','Fs'},{0,obj.Fs});
            % Optional Inputs
            for i=1:2:length(varargin)
               sArgs(varargin{i}) = varargin{i+1};
            end
            %
            time_total = sArgs('T');
            n_bins = round(time_total*sArgs('Fs'));
            % time vector
            t = linspace(0,time_total-(1/sArgs('Fs')),n_bins);
            % creating zeros array to source audio
            s = zeros(1,n_bins);
            %%%%%%%% Audio data %%%%%%%%%%%%%%%%%%
            if isempty(obj.time_data)==0
                s = obj.time_data(1,1:n_bins);
            %%%%%%%% Generating Audio %%%%%%%%%%%%
            else
                %%%%%%%% Noise source %%%%%%%%%%%%
                if obj.spec_data('freq')==0
                    s = wgn(1,length(t),obj.spec_data('amp') - 10*log10(1/((2e-5)^2)));
                    %%%%%%%%%% Filtering noise %%%
                    if obj.spec_data('filter')
                        ita_noise = itaAudio(s',obj.Fs,'time');
                        filter_f = obj.spec_data('filter');
                        filter_ita = ita_mpb_filter(ita_noise,[filter_f(1) filter_f(end)],...
                            'zerophase','class',1);
                        val_aj = rms(s,'dim',2)/rms(filter_ita.time(:,1).','dim',2);
                        s = val_aj.*filter_ita.time(:,1).';
                    end
                %%%%%%%% Tonal source %%%%%%%%%%%%%
                else
                    f = obj.spec_data('freq');
                    amp = dbPa2mag(obj.spec_data('amp'));
                    % generating the source
                    for i=1:1:length(amp)
                        s = s + amp(i)*sin(2*pi*f(i).*t);
                    end
                end
            end
            %%%%%%%%% Adding noise %%%%%%%%%%%%%%%%%
            if obj.spec_data('noise')>0
                s = awgn(s,obj.spec_data('noise'),'measured');
            end
            out = SAudio;
            out.time_data = s;
            varargout{1} = out; 
        end
        %%%%%%%%%% Class Constructor %%%%%%%%%%%%%%%%
        function this = Source(varargin)
            sArgs = containers.Map({'x','y','z','Amp','Freq','Noise','AudioInput','LoadAudio','Fs','FilterNoise'},...
                {0,0,0,10,0,0,[],[],44100,[]});
            %%%%%%%%%%%%%%%%%%%%%%%%
            for i =1:2:length(varargin)
                sArgs(varargin{i}) = varargin{i+1};
            end
            %%%%%% samp freq %%%%%%%
            this.Fs = sArgs('Fs');
            %%%%%%% Positions %%%%%%
            this.position = containers.Map({'x','y','z'}...
                ,{sArgs('x'),sArgs('y'),sArgs('z')});
            %%%%%%% Spec Data %%%%%%
            this.spec_data = containers.Map({'amp','freq','noise','filter'}...
                ,{sArgs('Amp'),sArgs('Freq'),sArgs('Noise'),sArgs('FilterNoise')});
            %%%%%%% Audio input %%%%
            this.time_data = sArgs('AudioInput');
            %%%%%%% Load Audio %%%%%
            if isempty(sArgs('LoadAudio'))==0
                [loadaudio, Fs] = audioread(sArgs('LoadAudio'));
                this.Fs = Fs;
                this.time_data = loadaudio(:,1)';
            end
        end
    end
end