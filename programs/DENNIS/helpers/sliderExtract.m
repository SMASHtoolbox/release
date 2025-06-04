function sliderVal = sliderExtract(h_slider, h_sliderStr, varargin)

sliderVal = get(h_slider, 'Value');
str = num2str(sliderVal);
if sliderVal > 0 && nargin < 3
    str = ['+', str];
end
set(h_sliderStr, 'String', str);

end