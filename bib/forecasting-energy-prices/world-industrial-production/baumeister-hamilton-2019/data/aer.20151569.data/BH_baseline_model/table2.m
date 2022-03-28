% Table 2: prior probabilities that impact response is positive

clear; 
clc;

seednumber=140778;
rand('seed',seednumber);
randn('seed',seednumber);

ndraws=2e6;              %number of MH iterations (paper used 2e6)
nburn=1e6;               %number of burn-in draws (paper used 1e6)

nlags=12;        %number of lags
ndet=1;          %number of deterministic variables (1: constant)
n=4;             %number of endogenous variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     ALGORITHM FOR GETTING PRIOR PROBABILITIES FOR IRFS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%Prior for H(2,2)
mu_h2 = 0.8;       % loction parameter of the prior
sig_h2 = 0.2;      % scale parameter of the prior
nu_h2 = 3;         % degrees of freedom

% Set arbitrary initial values for elements of A (prior mode/mean of
% elements in A and L)
A_old=[c_alpha_qp; c_alpha_yp; c_beta_qy; c_beta_qp; alpha_k/(alpha_k+beta_k); ...
       c_psi1; c_psi3; alpha_k/(alpha_k+beta_k)*alpha_l/(alpha_l+beta_l)];   
c=size(A_old,1);           %number of parameters in A 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get starting values for A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fixed parameter values
param=[c_alpha_qp;sigma_alpha_qp;nu_alpha_qp;c_alpha_yp;sigma_alpha_yp;nu_alpha_yp; ...
       c_beta_qy;sigma_beta_qy;nu_beta_qy;c_beta_qp;sigma_beta_qp;nu_beta_qp; ...
       alpha_k;beta_k;c_psi1;sigma_psi1;nu_psi1;c_psi3;sigma_psi3;nu_psi3; ...
       mu_h1;sig_h1;nu_h1;lam_h1;zeta_h1;mu_h2;sig_h2;nu_h2];
   
f_anon = @(theta_hat) post_val_m_prior(theta_hat,param);
    
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 2: Set the variance of the candidate generating density (P) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xsi=0.55^2;       %tuning parameter to achieve a target acceptance rate of around 30-35%
W=xsi*eye(c);     %variance of RW-MH  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: Evaluate posterior at starting value for A:  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluate prior p(A) at old draw
prior1 = student_pos_prior(A_old(1,1),c_alpha_qp,sigma_alpha_qp,nu_alpha_qp);
prior2 = student_neg_prior(A_old(2,1),c_alpha_yp,sigma_alpha_yp,nu_alpha_yp);
prior3 = student_pos_prior(A_old(3,1),c_beta_qy,sigma_beta_qy,nu_beta_qy);
prior4 = student_neg_prior(A_old(4,1),c_beta_qp,sigma_beta_qp,nu_beta_qp);
prior5 = beta_prior(A_old(5,1),alpha_k,beta_k);
prior6 = student_prior(A_old(6,1),c_psi1,sigma_psi1,nu_psi1);
prior7 = student_prior(A_old(7,1),c_psi3,sigma_psi3,nu_psi3);
prior8 = beta_prior(A_old(8,1),alpha_l,beta_l);

A_tilde=[1 0 -A_old(1,1) 0; 0 1 -A_old(2,1) 0; ...
         1 -A_old(3:4,1)' -1/A_old(5,1); -A_old(6,1) 0 -A_old(7,1) 1];

h1 = det(A_tilde);
fh1 = zeta_h1*(log(tpdf((h1-mu_h1)/sig_h1,nu_h1)) + log(normcdf(lam_h1*h1/sig_h1)));

H = inv(A_tilde);
h2 = H(2,2);
prior_h2 = student_prior(h2,mu_h2,sig_h2,nu_h2);
fh2 = log(prior_h2);

% Compute prior value at candidate draw
log_priors=log(prior1)+log(prior2)+log(prior3)+log(prior4)+ ...
           log(prior5)+log(prior6)+log(prior7)+log(prior8)+fh1+fh2;

posteriorOLD=log_priors;

% RW-MH algorithm 
naccept=0;
count=0;

% Store posterior distributions (after burn-in)
A_post_m=zeros(c,ndraws-nburn);
PIRF=zeros(n,n,ndraws-nburn);

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

       H=inv(A_tilde);
       h2=H(2,2);
       prior_h2 = student_prior(h2,mu_h2,sig_h2,nu_h2);
       fh2=log(prior_h2);
       
       % Compute posterior value at new candidate draw
       log_priors=log(prior1)+log(prior2)+log(prior3)+log(prior4)+ ...
                  log(prior5)+log(prior6)+log(prior7)+log(prior8)+fh1+fh2;
       
       posteriorNEW=log_priors;
         
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
         A_post_m(:,count-nburn)=A_old;  
         
         AA_tilde=[1 0 -A_old(1,1) 0; 0 1 -A_old(2,1) 0; ...
                   1 -A_old(3:4,1)' -1/A_old(5,1); -A_old(6,1) 0 -A_old(7,1) 1];
         PIRF(:,:,count-nburn)=impulse_response_prior(A_post_m,AA_tilde,n,nlags);

         clear AA_tilde 
       
    end 
%     
end

% Compute acceptance ratio of RW-MH algorithm
acceptance_ratio=naccept/ndraws;
disp(['Acceptance ratio:' num2str(acceptance_ratio)])

% Table 2: prior probabilities that sign on impact is positive
prior_probs=zeros(n,n,size(PIRF,3));
for jx=1:n
    for jy=1:n
        for jz=1:size(PIRF,3)
            if PIRF(jx,jy,jz)>0
               prior_probs(jx,jy,jz)=1;
            end
        end
    end
end

ps=sum(prior_probs,3);
sign_probs=ps./size(PIRF,3)

save prior_probs sign_probs