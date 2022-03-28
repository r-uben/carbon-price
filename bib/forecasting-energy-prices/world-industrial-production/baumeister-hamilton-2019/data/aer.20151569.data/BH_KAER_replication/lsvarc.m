%function to estimate a VAR(p) by LS
function [A,B,X, SIGMA, U, V]=lsvarc(y,p)

%set up regressors and regressand
[t,K]=size(y);
y=y';
Y=y(:,p:t);

for i=1:p-1
    Y=[Y; y(:,p-i:t-i)];
end

X=[ones(1,t-p); Y(:,1:t-p)];
Y=y(:,p+1:t);

%Run LS regression
B=(Y*X')/(X*X');
U=Y-B*X;
SIGMA=U*U'/(t-p);   
V=B(:,1);
A=B(:,2:K*p+1);