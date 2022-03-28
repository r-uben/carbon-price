%%% This code replicates Figure 5 in Kilian and Murphy (JEEA 2012), "Why 
%%% Agnostic Sign Restriction are Not Enough: Understanding the Dynamics of 
%%% Oil Market VAR Models" using the BH algorithm and includes posterior 
%%% distributions of key parameters;
%%% See Figures 3-4 in: Baumeister and Hamilton, "Structural Interpretation 
%%% of Vector Autoregressions with Incomplete Identification: Revisiting 
%%% the Role of Oil Supply and Demand Shocks", American Economic Review

%%% Trivariate Oil Market VAR with uninformative priors on lagged coefficients 

%%% Identification of 3 shocks with sign and boundary restrictions: 
%%% demand shock, supply shock, other oil demand shock

%%% By Christiane Baumeister and James D. Hamilton 
%%% (September 2014; updated Nov 2017)

clear; 
clc;

ndraws=2e6;     %number of MH iterations 
nburn=1e6;      %number of burn-in draws 

% NOTE:
% The parameter xsi is the tuning parameter for the MH step and has to be
% re-set for each application such that it implies a 30-35% acceptance
% ratio.
% If acceptance ratio is too high, make xsi bigger;
% if acceptance ratio is too low, make xsi smaller.
xsi=0.17^2;       

nlags=24;        %number of lags
hmax=18;         %impulse response horizon (17 months)
ndet=1;          %number of deterministic variables 
                 %(1: constant; 2: constant and time trend)

load kiliandata.txt           %sample: 1973M2 to 2008M9
% column 1: global crude oil production (in million barrels per day)
% column 2: global real economic activity index (Kilian, AER 2009)
% column 3: real refiners' acquisition cost of crude oil imports (deflated with US CPI)

yy=kiliandata;
time=(1973+1/12:1/12:2008+8/12)';
      
s=size(time,1);
n=size(yy,2);     %number of endogenous variables
                              
% Get data matrices
[X,y,T]=getXy(yy,ndet,nlags);
yyy=y;
xxx=X;

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
x1=-bounds:.0001:0;       %grid for negative parameters
y1=0:.0001:bounds;        %grid for positive parameters
yp1=0:0.0001:0.0258;

% alpha(s): short-run price elasticity of oil supply (uniform [0,0.0258])
a_alpha = 0;
b_alpha = 0.0258;
c_alpha = 0.5*(a_alpha+b_alpha);
prior_alpha = uniform_prior(yp1,a_alpha,b_alpha);
%plot(yp1,prior_alpha,'b','linewidth',3)

% eta(1): short-run oil price elasticity of global demand (sign: negative)
c_eta1 = 0;     
sigma_eta1 = 100;   
nu_eta1 = 3;
prior_eta1 = student_neg_prior(x1,c_eta1,sigma_eta1,nu_eta1);
%plot(x1,prior_eta1,'b','linewidth',3)

% beta(d): short-run price elasticity of oil demand (sign: negative)
c_beta = 0;     
sigma_beta = 100;   
nu_beta = 3;
prior_beta = student_neg_prior(x1,c_beta,sigma_beta,nu_beta);
%plot(x1,prior_beta,'b','linewidth',3)

% gamma_world(2): income elasticity of oil demand (sign: positive)
c_gamma2 = 0;   
sigma_gamma2 = 100;   
nu_gamma2 = 3;
prior_gamma2 = student_pos_prior(y1,c_gamma2,sigma_gamma2,nu_gamma2);
%plot(y1,prior_gamma2,'b','linewidth',3)

% Set arbitrary initial values for elements of A 
A_old=[c_alpha; -0.2; -0.5; 0.15];
c=size(A_old,1);             %number of parameters to be estimated in A

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1b: Set informative priors on lagged coefficients (B) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute standard deviation of each series residual via an OLS regression
% to be used in setting the prior (here: AR(24))
[s11,uhat1]=sd_prior(yy(:,1),nlags);
[s22,uhat2]=sd_prior(yy(:,2),nlags);
[s33,uhat3]=sd_prior(yy(:,3),nlags);

% See Doan (2013) for choices of values of hyperparameters (Minnesota prior)
lambda0=10^9;    %overall confidence in prior (smaller lambda0 implies greater weight to RW)
lambda1=1;       %confidence on higher-order lags (lambda1 = 0 gives all lags equal weight)
lambda2=1;       %confidence in other-than-own lags 
lambda3=100;     %tightness of constant term 

% Specify the prior mean of the coefficients of the 3 equations of the VAR
% and their prior covariance

% EXPECTED VALUE OF REDUCED-FORM COEFFICIENTS
eta=[eye(n) zeros(n,(n*nlags+1)-n)];

% PRIOR COVARIANCE 
SS=[s11;s22;s33];
M=getM(lambda0,lambda1,lambda2,lambda3,SS,nlags,n);
M1=M(:,:,1);
M2=M(:,:,2);
M3=M(:,:,3);

% Compute summary statistics of the observed data:
Syy=yyy'*yyy;
Sxx=xxx'*xxx;
Sxy=yyy'*xxx;
omega_hatT=(Syy-Sxy*inv(Sxx)*Sxy')/T;
d3=sqrt(omega_hatT(3,3));

%uniform prior for H(2,3) over [-1.5;0]
a_h = -1.5;
b_h = 0;
xp1=a_h:0.0001:b_h;
prior_h23 = uniform_prior(xp1,a_h,b_h);
%plot(xp1,prior_h23,'b','linewidth',3)

% Compute M_star(i) 
M_star1=inv(Sxx+inv(M1));
M_star2=inv(Sxx+inv(M2));
M_star3=inv(Sxx+inv(M3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1c: Set priors for inverse of diagonal elements (D) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The mean is calibrated on diagonal elements in omega
uhat=[uhat1 uhat2 uhat3];
S=uhat'*uhat/T;

kappa=0.5;
kappastar = kappa + (T/2); % posterior kappastar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get starting values for A via optimization %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fixed parameter values
param=[c_eta1;sigma_eta1;nu_eta1;c_gamma2;sigma_gamma2;nu_gamma2; ...
       c_beta;sigma_beta;nu_beta;T;vec(omega_hatT);kappastar;kappa];
   
f_anon = @(theta_hat)post_val_KMuniform(theta_hat,param,Syy,Sxy,eta,M1,M2,M3,M_star1,M_star2,M_star3,S);

% find posterior mode
theta_zero = A_old;     %mode of prior distributions
options = optimset('LargeScale','off','MaxFunEvals',10000);
[theta_max,val_max,exitm,om,gm,HM] = fminunc(f_anon,theta_zero,options);
if min(eig(inv(HM)))>0
    PH=chol(inv(HM))';
else
    PH=eye(c);
end
PH

%start MH algorithm with theta_max
A_old=theta_max;
A=[1 0 -A_old(1,1); 0 1 -A_old(2,1); -A_old(3:4,1)' 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 2: Set the variance of the candidate generating density (P) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W=xsi*eye(c);      %variance of RW-MH  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: Evaluate posterior at starting value for A:  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
omega=A*S*A';
taustar1=gettau(kappa,omega(1,1),A(1,:),Syy,Sxy,eta,M1,M_star1);
taustar2=gettau(kappa,omega(2,2),A(2,:),Syy,Sxy,eta,M2,M_star2);
taustar3=gettau(kappa,omega(3,3),A(3,:),Syy,Sxy,eta,M3,M_star3);
       
% Evaluate prior p(A) at old draw
prior_e = student_neg_prior(A_old(2,1),c_eta1,sigma_eta1,nu_eta1);
prior_b = student_neg_prior(A_old(3,1),c_beta,sigma_beta,nu_beta);
prior_c = student_pos_prior(A_old(4,1),c_gamma2,sigma_gamma2,nu_gamma2);

% Compute posterior value at candidate draw
log_priors=log(prior_e)+log(prior_c)+log(prior_b);

up=log_priors + T/2*log(det(A*omega_hatT*A'));
down=kappastar*log((2/T)*taustar1) ...
    +kappastar*log((2/T)*taustar2) ...
    +kappastar*log((2/T)*taustar3);
posteriorOLD=up-down;

% RW-MH algorithm 
naccept=0;
count=0;

% Store posterior distribution (after burn-in)
A_post=zeros(c+1,ndraws-nburn);
IRF=zeros(n,n,hmax,ndraws-nburn);

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
    A=[1 0 -A_new(1,1); 0 1 -A_new(2,1); -A_new(3:4,1)' 1];
    H=d3*A_new(2,1)/det(A);
    
    if A_new(1,1)>0 && A_new(1,1)<0.0258 && A_new(2,1)<0 && A_new(3,1)<0 && ...
            A_new(4,1)>0 && H<0 && H>-1.5
       % Evaluate prior p(A) at new draw
       prior_e = student_neg_prior(A_new(2,1),c_eta1,sigma_eta1,nu_eta1);
       prior_b = student_neg_prior(A_new(3,1),c_beta,sigma_beta,nu_beta);
       prior_c = student_pos_prior(A_new(4,1),c_gamma2,sigma_gamma2,nu_gamma2);
             
       omega=A*S*A';
       taustar1=gettau(kappa,omega(1,1),A(1,:),Syy,Sxy,eta,M1,M_star1);
       taustar2=gettau(kappa,omega(2,2),A(2,:),Syy,Sxy,eta,M2,M_star2);
       taustar3=gettau(kappa,omega(3,3),A(3,:),Syy,Sxy,eta,M3,M_star3);
       
       % Compute posterior value at new candidate draw
       log_priors=log(prior_e)+log(prior_c)+log(prior_b);
       up=log_priors + T/2*log(det(A*omega_hatT*A'));
       down=kappastar*log((2/T)*taustar1) ...
           +kappastar*log((2/T)*taustar2) ...
           +kappastar*log((2/T)*taustar3);
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
       AA=[1 0 -A_old(1,1); 0 1 -A_old(2,1); -A_old(3:4,1)' 1];
       A_post(:,count-nburn)=[A_old;d3*A_old(2,1)/det(AA)];
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % STEP 7: Generate a draw for d(ii)^-1 from independent gamma %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       omega=AA*S*AA';
       d11=inv(gamrnd(kappastar,1/gettau(kappa,omega(1,1),AA(1,:),Syy,Sxy,eta,M1,M_star1)));
       d22=inv(gamrnd(kappastar,1/gettau(kappa,omega(2,2),AA(2,:),Syy,Sxy,eta,M2,M_star2)));
       d33=inv(gamrnd(kappastar,1/gettau(kappa,omega(3,3),AA(3,:),Syy,Sxy,eta,M3,M_star3)));
       DD=diag([d11;d22;d33]);
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % STEP 8: Generate a draw for b(i) from multivariate normal %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       m1_star=getmstar(M_star1,Sxy,M1,eta,AA(1,:));
       m2_star=getmstar(M_star2,Sxy,M2,eta,AA(2,:));
       m3_star=getmstar(M_star3,Sxy,M3,eta,AA(3,:));
       
       b1=m1_star+(randn(1,nlags*n+1)*chol(d11.*M_star1))';
       b2=m2_star+(randn(1,nlags*n+1)*chol(d22.*M_star2))';
       b3=m3_star+(randn(1,nlags*n+1)*chol(d33.*M_star3))';
       BB=[b1';b2';b3']; 
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % STEP 9: Compute IRFs (not cumulated) %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       IRF(:,:,:,count-nburn)=impulse_response_1SD(AA,DD,BB,n,nlags,hmax-1);
       
       clear AA DD BB
       
    end 
    
end

% Compute acceptance ratio of RW-MH algorithm
acceptance_ratio=naccept/ndraws;
disp(['Acceptance ratio:' num2str(acceptance_ratio)])

figure3   %plots prior and posterior distributions                                   
 
figure4   %plots IRFs together with representative IRFs from KM12

% save results_KM12