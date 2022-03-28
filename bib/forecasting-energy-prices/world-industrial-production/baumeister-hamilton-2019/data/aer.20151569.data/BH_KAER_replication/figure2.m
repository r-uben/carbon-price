% figure 2
nbin=500;

for jc=1:size(A_post,1)
    [ag,bg]=hist(A_post(jc,:),nbin);
    delta=bg(1,2)-bg(1,1);
    bg_i(jc,:)=bg;
    post_i(jc,:)=ag./((ndraws-nburn)*delta);
    clear ag bg delta
end

%compute posterior density for demand elasticity
jd=2;
[agi,bgi]=hist((1./A_post(jd,:)),5000000);
deltai=bgi(1,2)-bgi(1,1);
post_ii=agi./((ndraws-nburn)*deltai);


figure(2)
subplot(2,2,1)
bar(bg_i(1,:),post_i(1,:)), hold on, plot(z1,prior_eta1,'r','linewidth',2); box on
axis([-1 1 0 3.5])
title('${\alpha}_{yp}$','interpreter','latex','fontsize',18)

subplot(2,2,2)
bar(bg_i(2,:),post_i(2,:)), hold on, plot(z1,prior_beta,'r','linewidth',2); box on
axis([-1 1 0 2.5])
title('${\alpha}_{pq}$','interpreter','latex','fontsize',18)

subplot(2,2,3)
bar(bg_i(3,:),post_i(3,:)), hold on, plot(z1,prior_gamma2,'r','linewidth',2); box on
axis([0 0.5 0 7])
title('${\alpha}_{py}$','interpreter','latex','fontsize',18)

subplot(2,2,4)
bar(bgi,post_ii)
axis([-30 30 0 0.25])
title('Short-run oil demand elasticity','interpreter','latex','fontsize',13)
