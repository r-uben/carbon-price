% Asymmetric t distribution 
clear
clc

% choice parameters for asymmetric t-distribution
mu_h = 0.6;   % location parameter (can be obtained empirically with simulate_h1.m)
sig_h = 1.6;  % scale parameter (can be obtained empirically with simulate_h1.m)
nu_h = 3;     % degrees of freedom: nu=3 (Student t); nu=1 (Cauchy); nu=30 (Normal)
lam_h = 2;    % determines asymmetry: lam>0 positive skew; lam<0 negative skew

h=(-13:0.001:20)';
for jj=1:size(h,1)
    fh(jj,1)= log(1/sig_h) + log(tpdf((h(jj,1)-mu_h)/sig_h,nu_h)) + log(normcdf(lam_h*h(jj,1)/sig_h));
end

plot(h,exp(fh))
title('Asymmetric t prior for det(Atilde)')

h1=exp(fh);
prob=1-sum(h1(1:13001,1))/sum(h1(:,1))