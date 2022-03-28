function theta = draw_student(c,sigma,nu)

u=randn(1);
ee=randn(nu,1);
v=(1/nu)*(ee'*ee);    %chi-square(nu)
nd=u/sqrt(v);
theta=c+sigma*nd;
