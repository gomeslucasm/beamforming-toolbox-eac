
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
% Lucas Muller Gomes                                                    %
% Acoustical Engineering - UFSM                                         %
% lmgomes96@gmail.com                                                   %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% InvertImage
% Function that flips an image horizontally or vertically
% Inputs: image data,(horizontal or vertical): default(vertical)
% Output: Flipped image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function img_out = InvertImage(img_in, direction)
if nargin<2
   direction = 'vertical'; 
end
switch direction
    case 'vertical'
        sz = size(img_in);
        cache_img = zeros(sz(1),sz(2));
        for i =0:1:sz(2)-1
            cache_img(sz(2)-i,:) = img_in(i+1,:);
        end
    case 'horizontal'
        sz = size(img_in);
        cache_img = zeros(sz(1),sz(2));
        for i =0:1:sz(2)-1
            cache_img(:,sz(2)-i) = img_in(:,i+1);
        end
end

img_out = cache_img;


end










