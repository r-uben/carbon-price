function IR = impulse_response_m(A_m,A,b,n,nlags,hmax)

chi=A_m(5,1);
P=eye(n);
P(4,3)=A_m(8,1);
A_tilde=P\A;
phi=A\b;
F=varcompanion(phi,1,n,nlags);
J=[eye(n) zeros(n,(nlags-1)*n)];
IR=[];
for h=0:hmax
    IR=cat(3,IR,(J*(F^h)*J')/A_tilde);
end
IR(:,4,:)=chi.*IR(:,4,:);