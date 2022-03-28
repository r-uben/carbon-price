function vecy=vec(y)

% This function vectorizes an (a x b) matrix y.  The resulting vector vecy
% has dimension (a*b x 1).

[row,column]=size(y);
vecy=reshape(y,row*column,1);
