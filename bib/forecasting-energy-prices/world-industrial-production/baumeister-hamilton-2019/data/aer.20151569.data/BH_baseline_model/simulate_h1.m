% simulate h to obtain empirically location and scale parameters

clear;
clc;
   
ndraws=50000;     %number of draws

%===========================================================
% set prior for A
nA = 8;

% alpha(qp): short-run price elasticity of oil supply (sign: positive)
c_alpha_qp = 0.1;            
sigma_alpha_qp = 0.2;       
nu_alpha_qp = 3;

% alpha(yp): short-run oil price elasticity of global demand (sign: negative)
c_alpha_yp = -0.05;
sigma_alpha_yp = 0.1;   
nu_alpha_yp = 3;

% beta(qy): income elasticity of oil demand (sign: positive)
c_beta_qy = 0.7;   
sigma_beta_qy = 0.2;   
nu_beta_qy = 3;

% beta(qp): short-run price elasticity of oil demand (sign: negative)
c_beta_qp = -0.1;   
sigma_beta_qp = 0.2;     
nu_beta_qp = 3;

% chi: OECD fraction of true oil inventories (about 60-65%)
alpha_k = 15;
beta_k = 10;

% psi1: short-run production elasticity of inventory demand (sign:
%       unrestricted)
c_psi1 = 0;
sigma_psi1 = 0.5;
nu_psi1 = 3;

% psi3: short-run price elasticity of inventory demand (sign: unrestricted)
c_psi3 = 0;
sigma_psi3 = 0.5;
nu_psi3 = 3;

% rho: importance of measurement error (between 0 and chi)
% prior conditional on chi
chi = alpha_k/(alpha_k+beta_k);
mean_rho = 0.25*chi;
std_rho = 0.12*chi;
[alpha_l,beta_l] = GetBetaParameters(mean_rho,std_rho);

cA=[c_alpha_qp; c_alpha_yp; c_beta_qy; c_beta_qp; c_psi1; c_psi3];
sigA=[sigma_alpha_qp; sigma_alpha_yp; sigma_beta_qy; sigma_beta_qp; sigma_psi1; sigma_psi3];
nuA=[nu_alpha_qp; nu_alpha_yp; nu_beta_qy; nu_beta_qp; nu_psi1; nu_psi3];

seednumber=140778;
rand('seed',seednumber);
randn('seed',seednumber);

count=0;
h1=zeros(ndraws,1);
  
while count<ndraws 
    count=count+1;
    if (count/1000) == floor(count/1000)
        count
    end
    
    %take random draws from prior distributions of elements in A
    theta1=draw_truncated_student(cA(1),sigA(1),nuA(1),1);
    theta2=draw_truncated_student(cA(2),sigA(2),nuA(2),-1);
    theta3=draw_truncated_student(cA(3),sigA(3),nuA(3),1);
    theta4=draw_truncated_student(cA(4),sigA(4),nuA(4),-1);
    theta5=betarnd(alpha_k,beta_k);
    theta6=draw_student(cA(5),sigA(5),nuA(5));
    theta7=draw_student(cA(6),sigA(6),nuA(6));
    theta8=betarnd(alpha_l,beta_l);
    theta_hat=[theta1; theta2; theta3; theta4; theta5; theta6; theta7; theta8];
    
    A_tilde=[1 0 -theta_hat(1,1) 0; 0 1 -theta_hat(2,1) 0; ...
         1 -theta_hat(3:4,1)' -1/theta_hat(5,1); -theta_hat(6,1) 0 -theta_hat(7,1) 1];
    %define additional constraint on combination of parameters
    h1(count,1) = det(A_tilde);
    
end

mean(h1)
std(h1)
 
