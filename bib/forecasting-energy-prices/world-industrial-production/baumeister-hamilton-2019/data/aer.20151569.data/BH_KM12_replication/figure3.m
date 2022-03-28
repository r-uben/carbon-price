%figure 3
nbin=500;

for jc=1:size(A_post,1)
    [ag,bg]=hist(A_post(jc,:),nbin);
    delta=bg(1,2)-bg(1,1);
    bg_i(jc,:)=bg;
    post_i(jc,:)=ag./((ndraws-nburn)*delta);
    clear ag bg delta
end

%compute posterior density for demand elasticity
jd=3;
[agi,bgi]=hist((1./A_post(jd,:)),10000000);
deltai=bgi(1,2)-bgi(1,1);
post_ii=agi./((ndraws-nburn)*deltai);

yx1=0:.0001:2;
yx2=-2:0.0001:0;

figure(3)
subplot(3,2,1)
bar(bg_i(1,:),post_i(1,:)), hold on, plot(yx1,(1/(b_alpha-a_alpha))*[zeros(1,1) ones(1,258) zeros(1,20001-259)],'r','linewidth',2); box on
axis([0 0.2 0 50])
title('${\alpha}_{qp}$','interpreter','latex','fontsize',16)

subplot(3,2,2)
bar(bg_i(2,:),post_i(2,:)), hold on, plot(x1,prior_eta1,'r','linewidth',2); box on
axis([-1.5 0 0 5])
title('${\alpha}_{yp}$','interpreter','latex','fontsize',16)

subplot(3,2,3)
bar(bg_i(3,:),post_i(3,:)), hold on, plot(x1,prior_beta,'r','linewidth',2); box on
axis([-1.5 0 0 3])
title('${\alpha}_{pq}$','interpreter','latex','fontsize',16)

subplot(3,2,4)
bar(bg_i(4,:),post_i(4,:)), hold on, plot(y1,prior_gamma2,'r','linewidth',2); box on
axis([0 1.5 0 2])
title('${\alpha}_{py}$','interpreter','latex','fontsize',16)

subplot(3,2,5)
bar(bg_i(5,:),post_i(5,:)), hold on, plot(yx2,(1/abs(b_h-a_h))*[zeros(1,5000) ones(1,20001-5001) zeros(1,1)],'r','linewidth',2); box on
axis([-2 0 0 1.5])
title('${h}_{23}$','interpreter','latex','fontsize',15)

subplot(3,2,6)
bar(bgi,post_ii)
axis([-20 5 0 0.5])
title('Short-run oil demand elasticity','interpreter','latex','fontsize',13)
