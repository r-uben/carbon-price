% ols.m

% This program runs a univariate OLS regression and returns the coefficient
% estimates, standard errors, t-values, fitted values and residuals

function [bhat,bhatstd,tbhat,yhat,ehat]=ols(y,X)

% Let T=sample size and v=number of coefficients
[T,v] = size(X);

% Regression coefficients and residuals
bhat=(X'*X)\(X'*y);
yhat=X*bhat;
ehat=y-yhat;           


% Estimated variance of the disturbance term
sigma=ehat'*ehat/(T-v);

% Variance-covariance matrix of bhat
bhatcov=sigma*inv(X'*X);

% Read off the standard errors of bhat
bhatstd=sqrt(diag(bhatcov));

% Calculate the t values of bhat
tbhat=bhat./bhatstd;
