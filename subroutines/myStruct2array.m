% JN Kather 2020
% introduced to circumvent Matlab's error for missing undocumented funtion
% struct2array, see https://de.mathworks.com/support/search.html/answers/
% 493612-any-fixes-for-undefined-function-or-variable-struct2array?q=&fq=asset_type_name:answer%20category:matlab/graphics-objects-programming&page=-4

function out = myStruct2array(structIn)
temp = struct2cell(structIn);
out = horzcat(temp{:});
end