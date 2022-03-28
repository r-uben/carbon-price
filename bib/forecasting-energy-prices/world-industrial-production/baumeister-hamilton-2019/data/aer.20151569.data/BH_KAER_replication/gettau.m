function taustar = gettau(kappa,omega,A,Syy,Sxy,eta,M,M_star)

tau=kappa/(1/omega);
m=A*eta;
taustar=tau+0.5*(A*Syy*A'+m*inv(M)*m')-0.5*(A*Sxy*M_star*Sxy'*A') ...
         -0.5*(m*inv(M)*M_star*inv(M)*m')-(m*inv(M)*M_star*Sxy'*A');


end

