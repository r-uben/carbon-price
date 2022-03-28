function taustar = gettau(kappa,omega,Y,X)

tau=kappa*omega;
zetastar=(Y'*Y)-(Y'*X)*inv(X'*X)*(X'*Y);
taustar=tau+0.5*zetastar;

end

