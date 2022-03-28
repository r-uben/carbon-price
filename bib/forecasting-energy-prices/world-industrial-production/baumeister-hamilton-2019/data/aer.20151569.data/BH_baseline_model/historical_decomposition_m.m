function [HD31,HD32,HD33,HD34,HD35] = historical_decomposition_m(A_m,A,b,n,p,yyy,xxx,d)

%see Appendix D for derivations
P=eye(n);
P(4,3)=A_m(8,1);
A_tilde=P\A;
B_tilde=P\b;

t=size(yyy,1);
phi=A\b;
F=varcompanion(phi,1,n,p);
J=[eye(n) zeros(n,(p-1)*n)];
Q=eye((p-1)*n+n,(p-1)*n+n);
IRF=reshape(J*Q*J'/A_tilde,n^2,1);

%use approximation
for i=1:99
    Q=Q*F;
	IRF=([IRF reshape((J*Q*J')/A_tilde,n^2,1)]);
end

IRF=[IRF zeros(16,t-100)];

%shocks from original model 
u_tilde=A_tilde*yyy'-B_tilde*xxx';

%divide shocks into structural shocks and measurement error
chi=A_m(5,1);
rho=A_m(8,1);
d33=d(3,3);
d44=d(4,4);

%equation (52)
Z=[d33*(1-rho/chi) 0; 0 (d44+rho*(rho-chi)*d33)/chi; -rho*d33 rho*chi*d33];
V=[d33 -rho*d33; -rho*d33 (d44+rho^2*d33)];
HH=Z/V;

uhat=HH*u_tilde(3:4,:);

%cross-multiply the weights for the effect of a given shock on the real
%oil price (given by the relevant row of IRF) with the structural shock
%in question

HD31=zeros(t,1); HD32=HD31; HD33=HD31; HD34=HD31; HD35=HD31;

for i=1:t
     
	HD31(i,:)=dot(IRF(3,1:i),u_tilde(1,i:-1:1));    %oil supply shock
    HD32(i,:)=dot(IRF(7,1:i),u_tilde(2,i:-1:1));    %economic activity shock
    HD33(i,:)=dot(IRF(11,1:i),uhat(1,i:-1:1));      %oil consumption demand shock
    HD34(i,:)=dot(IRF(15,1:i),chi.*uhat(2,i:-1:1)); %speculative oil demand shock
    HD35(i,:)=dot(IRF(11,1:i),-1/chi.*uhat(3,i:-1:1))+dot(IRF(15,1:i),uhat(3,i:-1:1)); %measurement error

end


