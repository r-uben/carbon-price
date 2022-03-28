%%% Code to replicate the 4-variable oil market VAR(12) model proposed in:
%%% Baumeister and Hamilton, "Structural Interpretation of Vector Autoregressions
%%% with Incomplete Identification: Revisiting the Role of Oil Supply and 
%%% Demand Shocks", American Economic Review;
%%% see Figures 7-9 and Tables 2-4

%%% By Christiane Baumeister and James D. Hamilton 
%%% (July 2015; updated Oct 2015; updated Nov 2017)

%%% BENCHMARK CASE

clear; 
clc;

ndraws=2e6;              %number of MH iterations 
nburn=1e6;               %number of burn-in draws 

% NOTE:
% The parameter xsi is the tuning parameter for the MH step and has to be
% re-set for each application such that it implies a 30-35% acceptance ratio.
% If acceptance ratio is too high, make xsi bigger; 
% if acceptance ratio is too low, make xsi smaller.
xsi=0.4^2;        

% other choice parameters
wti=0;           %'wti=1': WTI is used for entire sample; 'wti=0': RAC is used for second subsample
nlags=12;        %number of lags
hmax=18;         %impulse response horizon (17 months)
ndet=1;          %number of deterministic variables (1: constant)
mu=0.5;          %weight given to first subsample      

load data_BH2_update     %sample: 1958M1 to 2016M12
% column 1: global crude oil production (in million barrels/day)
% column 2: real WTI spot oil price (deflated by US CPI)
% column 3: OECD+6NME industrial production
% column 4: 100*change in proxy for OECD crude oil inventories as a fraction 
%           of previous period's oil production
% column 5: real refiners' acquisition cost of crude oil imports (starts in
%           1974M1, before that '1' indicates missing data)

time=(1958:1/12:2016+11/12)';   %sample period: 1958M1 to 2016M12

% transformations of variables
qo=lagn(100*log(data(:,1)),1);
ip=lagn(100*log(data(:,3)),1);
rpo=lagn(100*log(data(:,2)),1);   
stocks=data(2:end,4);
rac=lagn(100*log(data(:,5)),1);   

yy_wti=[qo ip rpo stocks];    
yy_rac=[qo ip rac stocks];    
time=time(2:end,1);
n=size(yy_wti,2);          %number of endogenous variables

%split sample in 1975M1
yy1=yy_wti(1:204,:);           %first subsample (ends in 1975M1)

if wti==1
    yy2=yy_wti(193:end,:);     %second subsample with WTI
else
    yy2=yy_rac(193:end,:);     %second subsample with RAC
end
                           
% Get data matrices for first subsample
[X1,y1,T1]=getXy(yy1,ndet,nlags);
yyy1=y1;
xxx1=X1;

% Get data matrices for second subsample
[X2,y2,T2]=getXy(yy2,ndet,nlags);
yyy2=y2;
xxx2=X2;

seednumber=140778;
rand('seed',seednumber);
randn('seed',seednumber);           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     ALGORITHM FOR GETTING POSTERIORS OF A, B and D    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1a: Set parameters of the prior distributions for impact coefficients (A) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bounds = 5;
x1=-bounds:.001:0;       %grid for negative parameters
y1=0:.001:bounds;        %grid for positive parameters
z1=-bounds:.001:bounds;  %grid for parameters where no sign is imposed a priori
f1=0:.001:1;             %fraction (for beta distribution)

% alpha(qp): short-run price elasticity of oil supply (sign: positive)
c_alpha_qp = 0.1;            
sigma_alpha_qp = 0.2;       
nu_alpha_qp = 3;
prior_alpha_qp=student_pos_prior(y1,c_alpha_qp,sigma_alpha_qp,nu_alpha_qp);
%plot(y1,prior_alpha_qp,'b','linewidth',3)

% alpha(yp): short-run oil price elasticity of global demand (sign: negative)
c_alpha_yp = -0.05;
sigma_alpha_yp = 0.1;   
nu_alpha_yp = 3;
prior_alpha_yp = student_neg_prior(x1,c_alpha_yp,sigma_alpha_yp,nu_alpha_yp);
%plot(x1,prior_alpha_yp,'b','linewidth',3)

% beta(qy): income elasticity of oil demand (sign: positive)
c_beta_qy = 0.7;   
sigma_beta_qy = 0.2;   
nu_beta_qy = 3;
prior_beta_qy = student_pos_prior(y1,c_beta_qy,sigma_beta_qy,nu_beta_qy);
%plot(y1,prior_beta_qy,'b','linewidth',3)

% beta(qp): short-run price elasticity of oil demand (sign: negative)
c_beta_qp = -0.1;   
sigma_beta_qp = 0.2;     
nu_beta_qp = 3;
prior_beta_qp = student_neg_prior(x1,c_beta_qp,sigma_beta_qp,nu_beta_qp);
%plot(x1,prior_beta_qp,'b','linewidth',3)

% chi: OECD fraction of true oil inventories (about 60-65%)
alpha_k = 15;
beta_k = 10;
prior_k = beta_prior(f1,alpha_k,beta_k);
%plot(f1,prior_k,'b','linewidth',3)

% psi1: short-run production elasticity of inventory demand (sign:
%       unrestricted)
c_psi1 = 0;
sigma_psi1 = 0.5;
nu_psi1 = 3;
prior_psi1 = student_prior(z1,c_psi1,sigma_psi1,nu_psi1);
%plot(z1,prior_psi1,'b','linewidth',3)

% psi3: short-run price elasticity of inventory demand (sign: unrestricted)
c_psi3 = 0;
sigma_psi3 = 0.5;
nu_psi3 = 3;
prior_psi3 = student_prior(z1,c_psi3,sigma_psi3,nu_psi3);
%plot(z1,prior_psi3,'b','linewidth',3)

% rho: importance of measurement error (between 0 and chi)
% prior conditional on chi
chi = alpha_k/(alpha_k+beta_k);
mean_rho = 0.25*chi;
std_rho = 0.12*chi;
[alpha_l,beta_l] = GetBetaParameters(mean_rho,std_rho);
prior_lambda = beta_prior(f1,alpha_l,beta_l);
%plot(f1,prior_lambda,'b','linewidth',3)

%Prior for det(Atilde)
zeta_h1 = 1;       % overall weight put on the prior for h1
mu_h1 = 0.6;       % location parameter of the prior (obtained by simulation: see simulate_h1.m)
sig_h1 = 1.6;      % scale parameter of the prior (obtained by simulation: see simulate_h1.m)
nu_h1 = 3;         % degrees of freedom
lam_h1 = 2;        % determines asymmetry of the prior
prior_h1 = log(1/sig_h1) + log(tpdf((z1-mu_h1)/sig_h1,nu_h1)) + log(normcdf(lam_h1*z1/sig_h1));
%plot(z1,exp(prior_h1),'b','linewidth',3)

%Prior for H(2,2)
mu_h2 = 0.8;       % loction parameter of the prior
sig_h2 = 0.2;      % scale parameter of the prior
nu_h2 = 3;         % degrees of freedom
prior_h22 = student_prior(z1,mu_h2,sig_h2,nu_h2);
%plot(z1,prior_h22,'b','linewidth',3)


% Set arbitrary initial values for elements of A (prior mode/mean of
% elements in A and L)
A_old=[c_alpha_qp; c_alpha_yp; c_beta_qy; c_beta_qp; alpha_k/(alpha_k+beta_k); ...
       c_psi1; c_psi3; alpha_k/(alpha_k+beta_k)*alpha_l/(alpha_l+beta_l)];   
c=size(A_old,1);           %number of parameters in A to be estimated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1b: Set informative priors on lagged coefficients (B) %
%          and for inverse of diagonal elements (D)          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute standard deviation of each series residual via an OLS regression
% to be used in setting the prior (here: AR(12))
[s11,uhat1]=sd_prior(yy1(:,1),nlags);
[s22,uhat2]=sd_prior(yy1(:,2),nlags);
[s33,uhat3]=sd_prior(yy1(:,3),nlags);
[s44,uhat4]=sd_prior(yy1(:,4),nlags);

% See Doan (2013) for choices of values of hyperparameters (Minnesota-type prior)
lambda0=0.5;     %overall confidence in prior
lambda1=1;       %confidence on higher-order lags (lambda1 = 0 gives all lags equal weight)
lambda2=1;       %confidence in other-than-own lags 
lambda3=100;     %tightness of constant term 

% The mean for D is calibrated on diagonal elements in omega
uhat=[uhat1 uhat2 uhat3 uhat4];
S=uhat'*uhat/T1;

kappa=2;                          %prior 
kappastar=kappa+(mu*T1+T2)/2;     %posterior kappa 

% Specify the prior mean of the coefficients of the 4 equations of the VAR
% and their prior covariance
% PRIOR MEAN
m=zeros(n,(n*nlags+1));
m(1,3)=0.1;
m(3,3)=-0.1;

% PRIOR COVARIANCE 
v1 = 1:nlags;
v1 = v1'.^(-2*lambda1);
v2 = 1./diag(S);
v3 = kron(v1,v2);
v3 = lambda0^2*[v3; lambda3^2];
v3 = 1./v3;
Pinv = diag(sqrt(v3));

% Compute summary statistics of the observed data for first subsample:
Syy1=yyy1'*yyy1;
Sxx1=xxx1'*xxx1;
Sxy1=yyy1'*xxx1;
zeta1=(Syy1-Sxy1*inv(Sxx1)*Sxy1');

% Compute summary statistics of the observed data for second subsample:
Syy2=yyy2'*yyy2;
Sxx2=xxx2'*xxx2;
Sxy2=yyy2'*xxx2;
zeta2=(Syy2-Sxy2*inv(Sxx2)*Sxy2');

omega_tildeT=(mu*T1+T2)\(mu*zeta1+zeta2);

Xtilde=[sqrt(mu).*xxx1;xxx2;Pinv];

% Compute M_star
M_star=inv(Xtilde'*Xtilde);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get starting values for A via optimization %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fixed parameter values
param=[c_alpha_qp;sigma_alpha_qp;nu_alpha_qp;c_alpha_yp;sigma_alpha_yp;nu_alpha_yp; ...
       c_beta_qy;sigma_beta_qy;nu_beta_qy;c_beta_qp;sigma_beta_qp;nu_beta_qp; ...
       alpha_k;beta_k;c_psi1;sigma_psi1;nu_psi1;c_psi3;sigma_psi3;nu_psi3; ...
       vec(omega_tildeT);kappastar;kappa;T1;T2;mu_h1;sig_h1;nu_h1;lam_h1;zeta_h1; ...
       mu_h2;sig_h2;nu_h2];
   
f_anon = @(theta_hat) post_val_m(theta_hat,param,S,m,yyy1,yyy2,Pinv,Xtilde,mu);
    
%starting value for theta
theta_zero=A_old;   %mode/mean of prior distributions
options = optimset('LargeScale','off','MaxFunEvals',5000);
[theta_max,val_max,exitm,~,~,HM] = fminunc(f_anon,theta_zero,options);

%find Hessian of log posterior
if min(eig(inv(HM))) > 0
     PH = chol(inv(HM))';
else
     PH = eye(c);
end

% start MH algorithm with theta_max
A_old=theta_max;
A_tilde=[1 0 -A_old(1,1) 0; 0 1 -A_old(2,1) 0; ...
         1 -A_old(3:4,1)' -1/A_old(5,1); -A_old(6,1) 0 -A_old(7,1) 1];
P=eye(n);
P(4,3)=A_old(8,1);
A=P*A_tilde;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     ALGORITHM FOR GETTING POSTERIORS OF A, B and D    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ytilde1=[sqrt(mu).*(yyy1*A(1,:)');yyy2*A(1,:)';Pinv'*m(1,:)'];
Ytilde2=[sqrt(mu).*(yyy1*A(2,:)');yyy2*A(2,:)';Pinv'*m(2,:)'];
Ytilde3=[sqrt(mu).*(yyy1*A(3,:)');yyy2*A(3,:)';Pinv'*m(3,:)'];
Ytilde4=[sqrt(mu).*(yyy1*A(4,:)');yyy2*A(4,:)';Pinv'*m(4,:)'];

% Compute m_star(i)
m_star1=(Xtilde'*Xtilde)\(Xtilde'*Ytilde1);
m_star2=(Xtilde'*Xtilde)\(Xtilde'*Ytilde2);
m_star3=(Xtilde'*Xtilde)\(Xtilde'*Ytilde3);
m_star4=(Xtilde'*Xtilde)\(Xtilde'*Ytilde4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 2: Set the variance of the candidate generating density (P) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W=xsi*eye(c);     %variance of RW-MH  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: Evaluate posterior at starting value for A:  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
omega=A*S*A';
taustar1=gettau(kappa,omega(1,1),Ytilde1,Xtilde);
taustar2=gettau(kappa,omega(2,2),Ytilde2,Xtilde);
taustar3=gettau(kappa,omega(3,3),Ytilde3,Xtilde);
taustar4=gettau(kappa,omega(4,4),Ytilde4,Xtilde);

% Evaluate prior p(A) at old draw
prior1 = student_pos_prior(A_old(1,1),c_alpha_qp,sigma_alpha_qp,nu_alpha_qp);
prior2 = student_neg_prior(A_old(2,1),c_alpha_yp,sigma_alpha_yp,nu_alpha_yp);
prior3 = student_pos_prior(A_old(3,1),c_beta_qy,sigma_beta_qy,nu_beta_qy);
prior4 = student_neg_prior(A_old(4,1),c_beta_qp,sigma_beta_qp,nu_beta_qp);
prior5 = beta_prior(A_old(5,1),alpha_k,beta_k);
prior6 = student_prior(A_old(6,1),c_psi1,sigma_psi1,nu_psi1);
prior7 = student_prior(A_old(7,1),c_psi3,sigma_psi3,nu_psi3);
prior8 = beta_prior(A_old(8,1),alpha_l,beta_l);

h1 = det(A_tilde);
fh1 = zeta_h1*(log(tpdf((h1-mu_h1)/sig_h1,nu_h1)) + log(normcdf(lam_h1*h1/sig_h1)));

H = inv(A_tilde);
h2 = H(2,2);
prior_h2 = student_prior(h2,mu_h2,sig_h2,nu_h2);
fh2 = log(prior_h2);

% Compute posterior value at candidate draw
log_priors=log(prior1)+log(prior2)+log(prior3)+log(prior4)+ ...
           log(prior5)+log(prior6)+log(prior7)+log(prior8)+fh1+fh2;
new_term1=kappa*log(kappa*omega(1,1));
new_term2=kappa*log(kappa*omega(2,2));
new_term3=kappa*log(kappa*omega(3,3));
new_term4=kappa*log(kappa*omega(4,4));       
new_term=new_term1+new_term2+new_term3+new_term4; 
up=log_priors+(mu*T1+T2)/2*log(det(A*omega_tildeT*A'))+new_term;
down=kappastar*log(2*taustar1/(mu*T1+T2)) ...
     +kappastar*log(2*taustar2/(mu*T1+T2)) ...
     +kappastar*log(2*taustar3/(mu*T1+T2)) ...
     +kappastar*log(2*taustar4/(mu*T1+T2));
posteriorOLD=up-down;

% RW-MH algorithm 
naccept=0;
count=0;

% Store posterior distributions (after burn-in)
A_post_m=zeros(c+2,ndraws-nburn);
A_post=zeros(n,n,ndraws-nburn);
B_post=zeros(n,n*nlags+1,ndraws-nburn);
D_post=zeros(n,n,ndraws-nburn);

while count<ndraws 
      count=count+1;
      if (count/10000) == floor(count/10000)
          count
      end
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % STEP 4a: Generate draw for A from the RW candidate density %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A_new=A_old+chol(W)'*PH*randn(c,1)/sqrt(0.5*(randn(1)^2 + randn(1)^2));    % fat tails
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STEP 4b: Evaluate posterior at new draw %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % impose signs/ranges
    if A_new(1,1)>0 && A_new(2,1)<0 && A_new(3,1)>0 && A_new(4,1)<0 && ...
            A_new(5,1)>0 && A_new(5,1)<1 && A_new(8,1)>0 && A_new(8,1)<1            
        
       % Evaluate prior p(A) at new draw
       prior1 = student_pos_prior(A_new(1,1),c_alpha_qp,sigma_alpha_qp,nu_alpha_qp);
       prior2 = student_neg_prior(A_new(2,1),c_alpha_yp,sigma_alpha_yp,nu_alpha_yp);
       prior3 = student_pos_prior(A_new(3,1),c_beta_qy,sigma_beta_qy,nu_beta_qy);
       prior4 = student_neg_prior(A_new(4,1),c_beta_qp,sigma_beta_qp,nu_beta_qp);
       prior5 = beta_prior(A_new(5,1),alpha_k,beta_k);
       prior6 = student_prior(A_new(6,1),c_psi1,sigma_psi1,nu_psi1);
       prior7 = student_prior(A_new(7,1),c_psi3,sigma_psi3,nu_psi3);
       prior8 = beta_prior(A_new(8,1),alpha_l,beta_l);

       % Construct full matrix A 
       A_tilde=[1 0 -A_new(1,1) 0; 0 1 -A_new(2,1) 0; ...
                1 -A_new(3:4,1)' -1/A_new(5,1); -A_new(6,1) 0 -A_new(7,1) 1];
       
       h1 = det(A_tilde);
       fh1 = zeta_h1*(log(tpdf((h1-mu_h1)/sig_h1,nu_h1)) + log(normcdf(lam_h1*h1/sig_h1)));

       H = inv(A_tilde);
       h2 = H(2,2);
       prior_h2 = student_prior(h2,mu_h2,sig_h2,nu_h2);
       fh2 = log(prior_h2);
            
       P=eye(n);
       P(4,3)=A_new(8,1);
       A=P*A_tilde;
       
       Ytilde1=[sqrt(mu).*(yyy1*A(1,:)');yyy2*A(1,:)';Pinv'*m(1,:)'];
       Ytilde2=[sqrt(mu).*(yyy1*A(2,:)');yyy2*A(2,:)';Pinv'*m(2,:)'];
       Ytilde3=[sqrt(mu).*(yyy1*A(3,:)');yyy2*A(3,:)';Pinv'*m(3,:)'];
       Ytilde4=[sqrt(mu).*(yyy1*A(4,:)');yyy2*A(4,:)';Pinv'*m(4,:)'];
       
       m_star1=(Xtilde'*Xtilde)\(Xtilde'*Ytilde1);
       m_star2=(Xtilde'*Xtilde)\(Xtilde'*Ytilde2);
       m_star3=(Xtilde'*Xtilde)\(Xtilde'*Ytilde3);
       m_star4=(Xtilde'*Xtilde)\(Xtilde'*Ytilde4);
       
       omega=A*S*A';
       taustar1=gettau(kappa,omega(1,1),Ytilde1,Xtilde);
       taustar2=gettau(kappa,omega(2,2),Ytilde2,Xtilde);
       taustar3=gettau(kappa,omega(3,3),Ytilde3,Xtilde);
       taustar4=gettau(kappa,omega(4,4),Ytilde4,Xtilde);

       % Compute posterior value at new candidate draw
       log_priors=log(prior1)+log(prior2)+log(prior3)+log(prior4)+ ...
                  log(prior5)+log(prior6)+log(prior7)+log(prior8)+fh1+fh2;
       new_term1=kappa*log(kappa*omega(1,1));
       new_term2=kappa*log(kappa*omega(2,2));
       new_term3=kappa*log(kappa*omega(3,3));
       new_term4=kappa*log(kappa*omega(4,4));       
       new_term=new_term1+new_term2+new_term3+new_term4;       
       up=log_priors+(mu*T1+T2)/2*log(det(A*omega_tildeT*A'))+new_term;
       down=kappastar*log(2*taustar1/(mu*T1+T2)) ...
            +kappastar*log(2*taustar2/(mu*T1+T2)) ...
            +kappastar*log(2*taustar3/(mu*T1+T2)) ...
            +kappastar*log(2*taustar4/(mu*T1+T2));
       posteriorNEW=up-down;
         
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % STEP 5: Compute acceptance probability %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       accept=min([exp(posteriorNEW-posteriorOLD);1]);
       u=rand(1);                     %draw from a uniform distribution
       if u<=accept
          A_old=A_new;                %we retain the new draw
          posteriorOLD=posteriorNEW;
          naccept=naccept+1;          %count the number of acceptances
       end
       
    end
    
    if count>nburn
         %Store results after burn-in    
         AA_tilde=[1 0 -A_old(1,1) 0; 0 1 -A_old(2,1) 0; ...
                   1 -A_old(3:4,1)' -1/A_old(5,1); -A_old(6,1) 0 -A_old(7,1) 1];
         HH=inv(AA_tilde);
         A_post_m(:,count-nburn)=[A_old; det(AA_tilde); HH(2,2)];    
               
         P=eye(n);
         P(4,3)=A_old(8,1);
         AA=P*AA_tilde;
         A_post(:,:,count-nburn)=AA;
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % STEP 7: Generate a draw for d(ii)^-1 from independent gamma %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         Ytilde1=[sqrt(mu).*(yyy1*AA(1,:)');yyy2*AA(1,:)';Pinv'*m(1,:)'];
         Ytilde2=[sqrt(mu).*(yyy1*AA(2,:)');yyy2*AA(2,:)';Pinv'*m(2,:)'];
         Ytilde3=[sqrt(mu).*(yyy1*AA(3,:)');yyy2*AA(3,:)';Pinv'*m(3,:)'];
         Ytilde4=[sqrt(mu).*(yyy1*AA(4,:)');yyy2*AA(4,:)';Pinv'*m(4,:)'];
       
         m_star1=(Xtilde'*Xtilde)\(Xtilde'*Ytilde1);
         m_star2=(Xtilde'*Xtilde)\(Xtilde'*Ytilde2);
         m_star3=(Xtilde'*Xtilde)\(Xtilde'*Ytilde3);
         m_star4=(Xtilde'*Xtilde)\(Xtilde'*Ytilde4);
       
         omega=AA*S*AA';
         d11=inv(gamrnd(kappastar,1/gettau(kappa,omega(1,1),Ytilde1,Xtilde)));
         d22=inv(gamrnd(kappastar,1/gettau(kappa,omega(2,2),Ytilde2,Xtilde)));
         d33=inv(gamrnd(kappastar,1/gettau(kappa,omega(3,3),Ytilde3,Xtilde)));
         d44=inv(gamrnd(kappastar,1/gettau(kappa,omega(4,4),Ytilde4,Xtilde)));          
         DD=diag([d11;d22;d33;d44]);
         D_post(:,:,count-nburn)=DD;
                 
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % STEP 8: Generate a draw for b(i) from multivariate normal %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 
         b1=m_star1+(randn(1,nlags*n+1)*chol(d11.*M_star))';
         b2=m_star2+(randn(1,nlags*n+1)*chol(d22.*M_star))';
         b3=m_star3+(randn(1,nlags*n+1)*chol(d33.*M_star))';
         b4=m_star4+(randn(1,nlags*n+1)*chol(d44.*M_star))';
         BB=[b1';b2';b3';b4']; 
         B_post(:,:,count-nburn)=BB;
        
         clear AA_tilde AA BB DD
       
     end 
%     
end

% Compute acceptance ratio of RW-MH algorithm
acceptance_ratio=naccept/ndraws;
disp(['Acceptance ratio:' num2str(acceptance_ratio)])

save posterior_draws A_post_m A_post B_post D_post

% Analyze convergence of the chain
% p1=0.1;   %first 10% of the sample (for Geweke's (1992) convergence diagnostic)
% p2=0.5;   %last 50% of the sample
% autoc = convergence_diagnostics(A_post_m,p1,p2);

figure7   %plots the prior and posterior distributions for the elements in A and H
          %computes the entries in Table 3, panels (A) and (B) 
          %[stored in elasticities68.mat]

figure8   %computes and plots the impulse-response functions
          %computes the entries in Table 3, panels (C)-(E)
          %[stored in IRF_norm68.mat]
          %computed the entries in Table 2 for posterior
          %probabilities [stored in posterior_probs.mat]

figure9   %computes and plots the historical decompositions
          
table4    %computes contribution of oil supply shocks to real oil price
          %for selected historical episodes 

%NOTE: running table2.m clears the workspace 
%table2   %computes the entries in Table 2 for prior probabilities
          %[stored in prior_probs.mat]

