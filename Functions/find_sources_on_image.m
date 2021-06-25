%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
% Lucas Muller Gomes                                                    %
% Acoustical Engineering - UFSM                                         %
% lmgomes96@gmail.com                                                   %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SourcesLocationImage
% Localize noise sources on beamforming maps, transforming it on grey
% images and using 
% Inputs: 2D grey image or a BeamformingResult(class to save the output
% from my beamforming functions)
% Optional Inputs: 'Invert','vertical' or 'horizontal', 'Treshold', value
% of trashold related to the values on 2D matrix or dB if the input is
% BeamformingResult;
% Output: Flipped image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = find_sources_on_image(Input,varargin)


%%
default_args = containers.Map({'treshold','invert','show','interp'},{0,0,'',0});
required_args = ["freq"];
default_inputs = parse_default_args(default_args, varargin);
required_inputs = parse_required_args(required_args, varargin);

%%

Treshold = default_inputs('treshold');
Invert = default_inputs('invert');
Show = default_inputs('show');

min_x = min(min(Input.grid('x')));
max_x = max(max(Input.grid('x')));

min_y = min(min(Input.grid('y')));
max_y = max(max(Input.grid('y')));
x_grid = Input.grid('x_mesh');
y_grid = Input.grid('y_mesh');


Input = Input.get_freq_data('freq',required_inputs('freq'));

if default_args('interp')~=0
    
    [Xq,Yq] = meshgrid(0:default_args('interp'):max_y);
    Xq = Xq + min_x;
  Input = interp2(x_grid,y_grid,Input,Xq,Yq);
end


if Invert ~=0
   Input = InvertImage(Input, Invert);
end

sz = size(Input);
Input = mag2db(abs(Input));
Input = Input - min(min(Input));
if Treshold ~=0 
    Input_max = max(max(Input));
    Input(Input<Input_max-Treshold) = Input_max -Treshold;
end
Input = rescale(Input,0,255);

%%
B = ordfilt2(Input,9,ones(3,3));
Bw = imbinarize(B, 'adaptive');
K = bwpropfilt(Bw, 'EulerNumber',[1 1]);

%%
s = regionprops(K,'Centroid');
centroids = cat(1,s.Centroid);
%%
stats = regionprops('table',Bw,'Centroid',...
    'MajorAxisLength','MinorAxisLength');
centers = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
radii = diameters/2;
%%
% figure()
% imshow(B,[0 255])
% export_fig('median_filter','-png')
% %%
% figure()
% imshow(Bw)
% export_fig('binarize','-png')
% %%
% figure()
% imshow(K)
% export_fig('bwpropfilt','-png')
%%
if Show == 1 
    %%
    figure()
    subplot(1,4,1); imshow(B,[0 255])
    subplot(1,4,2); imshow(Bw)
    subplot(1,4,3); imshow(K)
    subplot(1,4,4); imshow(B); hold on; scatter(centroids(:,1),centroids(:,2),'*');hold on; viscircles(centers,radii);
    %%
    if Show ~= 1
       pause(Show) 
    end
end

%%
out_data = struct();
out_data.x = (centroids(:,1)*abs(max_x+abs(min_x))/sz(1))+min_x;
out_data.y = (centroids(:,2)*max_y/sz(1))+min_y;

%%
if nargout>0
   varargout{1} = out_data; 
end
%%
end