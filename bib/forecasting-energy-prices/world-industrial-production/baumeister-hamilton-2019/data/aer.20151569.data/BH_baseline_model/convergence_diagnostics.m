function autoc=convergence_diagnostics(A,p1,p2)
% ===================================================
% By Christiane Baumeister and James D. Hamilton (Nov 2014)
% this performs assorted diagnostics on whether the (nA x nmonte) matrix A of nmonte draws
% on an (nA x 1) vector has converged
nA = size(A,1);
nmonte = size(A,2);

% ====================================================
% calculate autocorrelation function
nmax = 50;                 % nmax is maximum number of autocorrelations sought
autoc = zeros(nA,nmax);    % autoc will be the autocorrelation function
mu = sum(A')'/nmonte;
Atilde = A - mu*ones(1,nmonte);
var = diag(Atilde*Atilde')/nmonte;
for j=1:nmax
    autoc(:,j) = diag(Atilde(:,j+1:end)*Atilde(:,1:end-j)')'/nmonte;
    autoc(:,j) = autoc(:,j)./var;
end
figure(10)
for i=1:nA
    subplot(nA,1,i)
    plot(1:nmax,autoc(i,:))
    title_a = strcat('Autocorrelation of variable  ',num2str(i));
    axis([1 nmax 0 1])
    title(title_a,'fontsize',10)
end
%'Autocorrelation function is'
%autoc

% ==================================================
% graph parameter draws to check for mixing
figure(11)
for i=1:nA
    subplot(nA,1,i)
    plot(A(i,:)')
    title_a = strcat('Draws of variable  ',num2str(i));
    title(title_a,'fontsize',10)
end
    

% ===============================================================
% GEWEKE'S TEST: equality in means

nobs1 = round(p1*nmonte);
nobs2 = round(p2*nmonte);
draws1 = A(:,1:nobs1)';
draws2 = trimr(A',nobs2,0);

res1 = momentg(draws1);
res2 = momentg(draws2);

resapm = apm(res1,res2);

c = '%';
% print results 
fprintf(2,'Geweke Chi-squared test for each parameter chain \n');
fprintf(1,'First %2.0f%s versus Last %2.0f%s of the sample \n',100*p1,c,100*p2,c);

in.cnames = strvcat('Chi-sq Prob for Equality of Means');
in.rnames = strvcat('Decay in autocovariance function','4% taper','8% taper','15% taper');
in.fmt = '%40.6f';
in.fid = 1;

for i=1:nA
  fprintf(2,'Variable %1s\n', num2str(i)); 
  gout3 = zeros(3,1);
  for k=2:4
%       gout3(k-1,1) = resapm(i).pmean(k);
%       gout3(k-1,2) = resapm(i).nse(k);
      gout3(k-1,1) = resapm(i).prob(k);
  end
 
mprint(gout3,in);
end

