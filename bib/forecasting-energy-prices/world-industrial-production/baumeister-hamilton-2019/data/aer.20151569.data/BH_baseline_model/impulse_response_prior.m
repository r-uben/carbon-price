function IR = impulse_response_prior(A_m,A_tilde,n,nlags)

chi=A_m(5,1);
J=[eye(n) zeros(n,(nlags-1)*n)];
F=eye(nlags*n,nlags*n);
IR=(J*(F^0)*J')/A_tilde;
IR(:,4)=chi.*IR(:,4);