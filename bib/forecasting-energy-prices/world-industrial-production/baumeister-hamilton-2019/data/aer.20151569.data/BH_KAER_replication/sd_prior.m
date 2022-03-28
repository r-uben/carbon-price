function [s,uhat] = sd_prior(y,p)

x=ones(size(y,1),1);
for jx=1:p
    xx=lag0(y,jx); 
    x=[x xx];
end
k=size(x,2);
y=y(k:end,:);
x=x(k:end,:);
b=inv(x'*x)*(x'*y);
uhat=y-x*b;
s=sqrt(((y-x*b)'*(y-x*b))/(rows(y)));