function M_i=getM(lambda0,lambda1,lambda2,lambda3,S,nlags,n)

k=nlags*n+1;
M_i=zeros(k,k,n);

i = 0;
while i < n
    i = i + 1;
    M = (lambda0*lambda2)*ones(k,1);
    M(k,1) = (lambda0*lambda3);
    if nlags > 0
        el = 0;
        while el < nlags
            el = el + 1;
            M((el-1)*n+1:el*n,1) = M((el-1)*n+1:el*n,1)./S;
            M((el-1)*n+1:el*n,1) = M((el-1)*n+1:el*n,1)/(el^lambda1);
            M((el-1)*n+i,1) = M((el-1)*n+i,1)/lambda2;
        end
    end
    M = M .^ 2;
    M_i(:,:,i) = diag(M);
end

