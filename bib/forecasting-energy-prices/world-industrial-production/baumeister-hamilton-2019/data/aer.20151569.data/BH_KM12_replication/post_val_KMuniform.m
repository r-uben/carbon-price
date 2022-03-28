function objective=post_val_KMuniform(theta_hat,param,Syy,Sxy,eta,M1,M2,M3,M_star1,M_star2,M_star3,S)

c_eta1=param(1);
sigma_eta1=param(2);
nu_eta1=param(3);
c_gamma2=param(4);
sigma_gamma2=param(5);
nu_gamma2=param(6); 
c_beta=param(7);
sigma_beta=param(8);
nu_beta=param(9);
T=param(10);
omega_hatT=reshape(param(11:19),3,3);
kappastar=param(20);
kappa=param(21);

prior_e = student_neg_prior(theta_hat(2,1),c_eta1,sigma_eta1,nu_eta1);
prior_b = student_neg_prior(theta_hat(3,1),c_beta,sigma_beta,nu_beta);
prior_c = student_pos_prior(theta_hat(4,1),c_gamma2,sigma_gamma2,nu_gamma2);
    
A=[1 0 -theta_hat(1,1); 0 1 -theta_hat(2,1); -theta_hat(3:4,1)' 1];

omega=A*S*A';
taustar1=gettau(kappa,omega(1,1),A(1,:),Syy,Sxy,eta,M1,M_star1);
taustar2=gettau(kappa,omega(2,2),A(2,:),Syy,Sxy,eta,M2,M_star2);
taustar3=gettau(kappa,omega(3,3),A(3,:),Syy,Sxy,eta,M3,M_star3);

log_priors=log(prior_e)+log(prior_c)+log(prior_b);

up=log_priors+T/2*log(det(A*omega_hatT*A'));
down=kappastar*log((2/T)*taustar1) ...
    +kappastar*log((2/T)*taustar2) ...
    +kappastar*log((2/T)*taustar3);
objective=-(up-down);









