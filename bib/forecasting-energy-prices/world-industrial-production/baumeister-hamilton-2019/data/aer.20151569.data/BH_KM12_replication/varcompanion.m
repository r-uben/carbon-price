function A=varcompanion(A,ndet,n,p)
%creates companion matrix of A 
A=A(:,1:end-ndet);   
A=[A; eye(n*(p-1)) zeros(n*(p-1),n)];