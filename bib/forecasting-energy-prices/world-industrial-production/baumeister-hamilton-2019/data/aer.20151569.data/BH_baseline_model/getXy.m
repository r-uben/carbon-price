function [X,y,ess] = getXy(data,ndet,nlags)

const=ones(size(data,1),1);   %deterministic term: constant
trend=(1:1:size(data,1))';    %time trend

if ndet==1
    data=[data const];
elseif ndet==2
    data=[data const trend];
end
 
[sp,nvars]=size(data);   %sp is the total number of observations
nvars=nvars-ndet;        %takes out the counting of deterministic variables
            
ess=sp-nlags;       %effective sample size after taking lags into account
sb=nlags+1;         %sample beginning
sl=sp;              %last period of sample
ncoe=nvars*nlags;   %number of coefficients without deterministic variables

% Construct X for Y=X*B+U

x=data(:,1:end-ndet);

X=zeros(ess,ncoe);
for k=1:nlags
    X(:,nvars*(k-1)+1:nvars*k) = x(sb-k:sl-k,:);  %first lag of all variables, second lag of all variables etc.
end

if ndet==1
    X=[X ones(ess,1)];   %without trend
elseif ndet==2
    X=[X ones(ess,1) trend(1:ess,1)];
end

y=x(sb:sl,:);