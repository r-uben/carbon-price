function objective=post_val_m(theta_hat,param,S,m,yyy1,yyy2,Pinv,Xtilde,mu)

c_alpha_qp=param(1);
sigma_alpha_qp=param(2);
nu_alpha_qp=param(3);
c_alpha_yp=param(4);
sigma_alpha_yp=param(5);
nu_alpha_yp=param(6);
c_beta_qy=param(7); 
sigma_beta_qy=param(8);
nu_beta_qy=param(9);
c_beta_qp=param(10);
sigma_beta_qp=param(11);
nu_beta_qp=param(12);
alpha_k=param(13);
beta_k=param(14);
c_psi1=param(15);
sigma_psi1=param(16);
nu_psi1=param(17);
c_psi3=param(18);
sigma_psi3=param(19);
nu_psi3=param(20);
omega_tildeT=reshape(param(21:36),4,4);
kappastar=param(37);
kappa=param(38);
T1=param(39);
T2=param(40);
mu_h1=param(41);
sig_h1=param(42);
nu_h1=param(43);
lam_h1=param(44);
zeta_h1=param(45);
mu_h2=param(46);
sig_h2=param(47);
nu_h2=param(48);

prior1 = student_pos_prior(theta_hat(1,1),c_alpha_qp,sigma_alpha_qp,nu_alpha_qp);
prior2 = student_neg_prior(theta_hat(2,1),c_alpha_yp,sigma_alpha_yp,nu_alpha_yp);
prior3 = student_pos_prior(theta_hat(3,1),c_beta_qy,sigma_beta_qy,nu_beta_qy);
prior4 = student_neg_prior(theta_hat(4,1),c_beta_qp,sigma_beta_qp,nu_beta_qp);
prior5 = beta_prior(theta_hat(5,1),alpha_k,beta_k);
prior6 = student_prior(theta_hat(6,1),c_psi1,sigma_psi1,nu_psi1);
prior7 = student_prior(theta_hat(7,1),c_psi3,sigma_psi3,nu_psi3);
chi = alpha_k/(alpha_k+beta_k);
mean_rho = 0.25*chi;
std_rho = 0.12*chi;
[alpha_l,beta_l] = GetBetaParameters(mean_rho,std_rho);
prior8 = beta_prior(theta_hat(8,1),alpha_l,beta_l);

A_tilde=[1 0 -theta_hat(1,1) 0; 0 1 -theta_hat(2,1) 0; ...
         1 -theta_hat(3:4,1)' -1/theta_hat(5,1); -theta_hat(6,1) 0 -theta_hat(7,1) 1];

h1 = det(A_tilde);
fh1 = zeta_h1*(log(tpdf((h1-mu_h1)/sig_h1,nu_h1)) + log(normcdf(lam_h1*h1/sig_h1)));

H = inv(A_tilde);
h2 = H(2,2);
prior_h2 = student_prior(h2,mu_h2,sig_h2,nu_h2);
fh2 = log(prior_h2);
     
P=eye(size(S,1));
P(4,3)=theta_hat(8,1);
A=P*A_tilde;

Ytilde1=[sqrt(mu).*(yyy1*A(1,:)');yyy2*A(1,:)';Pinv'*m(1,:)'];
Ytilde2=[sqrt(mu).*(yyy1*A(2,:)');yyy2*A(2,:)';Pinv'*m(2,:)'];
Ytilde3=[sqrt(mu).*(yyy1*A(3,:)');yyy2*A(3,:)';Pinv'*m(3,:)'];
Ytilde4=[sqrt(mu).*(yyy1*A(4,:)');yyy2*A(4,:)';Pinv'*m(4,:)'];

omega=A*S*A';
taustar1=gettau(kappa,omega(1,1),Ytilde1,Xtilde);
taustar2=gettau(kappa,omega(2,2),Ytilde2,Xtilde);
taustar3=gettau(kappa,omega(3,3),Ytilde3,Xtilde);
taustar4=gettau(kappa,omega(4,4),Ytilde4,Xtilde);

log_priors=log(prior1)+log(prior2)+log(prior3)+log(prior4)+ ...
           log(prior5)+log(prior6)+log(prior7)+log(prior8)+fh1+fh2;
       
new_term1=kappa*log(kappa*omega(1,1));
new_term2=kappa*log(kappa*omega(2,2));
new_term3=kappa*log(kappa*omega(3,3));
new_term4=kappa*log(kappa*omega(4,4));
new_term=new_term1+new_term2+new_term3+new_term4;
up=log_priors+0.5*(mu*T1+T2)*log(det(A*omega_tildeT*A'))+new_term;
down=kappastar*log(2*taustar1/(mu*T1+T2)) ...
     +kappastar*log(2*taustar2/(mu*T1+T2)) ...
     +kappastar*log(2*taustar3/(mu*T1+T2)) ...
     +kappastar*log(2*taustar4/(mu*T1+T2));
objective=-(up-down);










