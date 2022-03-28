% Prepare histograms of posterior distribution for A and H
nbin=500;

for jc=1:size(A_post_m,1)
    [ag,bg]=hist(A_post_m(jc,:),nbin);
    delta=bg(1,2)-bg(1,1);
    bg_i(jc,:)=bg;
    post_i(jc,:)=ag./((ndraws-nburn)*delta);
    clear ag bg delta
end

figure(7)
subplot(2,5,1)
bar(bg_i(1,:),post_i(1,:)), hold on, plot(y1,prior_alpha_qp,'r','linewidth',2); box on
axis([0 1 0 8])
title('${\alpha}_{qp}$','interpreter','latex','fontsize',14)

subplot(2,5,2)
bar(bg_i(2,:),post_i(2,:)), hold on, plot(x1,prior_alpha_yp,'r','linewidth',2); box on
axis([-0.5 0 0 30])
title('${\alpha}_{yp}$','interpreter','latex','fontsize',14)

subplot(2,5,3)
bar(bg_i(3,:),post_i(3,:)), hold on, plot(y1,prior_beta_qy,'r','linewidth',2); box on
axis([0 1.5 0 3])
title('${\beta}_{qy}$','interpreter','latex','fontsize',14)

subplot(2,5,4)
bar(bg_i(4,:),post_i(4,:)), hold on, plot(x1,prior_beta_qp,'r','linewidth',2); box on
axis([-1 0 0 4])
title('${\beta}_{qp}$','interpreter','latex','fontsize',14)

subplot(2,5,5)
bar(bg_i(5,:),post_i(5,:)), hold on, plot(f1,prior_k,'r','linewidth',2); box on
axis([0 1 0 5])
title('${\chi}$','interpreter','latex','fontsize',14)

subplot(2,5,6)
bar(bg_i(6,:),post_i(6,:)), hold on, plot(z1,prior_psi1,'r','linewidth',2); box on
axis([-1 1 0 4])
title('${\psi}_{1}$','interpreter','latex','fontsize',14)

subplot(2,5,7)
bar(bg_i(7,:),post_i(7,:)), hold on, plot(z1,prior_psi3,'r','linewidth',2); box on
axis([-1 1 0 12])
title('${\psi}_{3}$','interpreter','latex','fontsize',14)

subplot(2,5,8)
bar(bg_i(8,:),post_i(8,:)), hold on, plot(f1,prior_lambda,'r','linewidth',2); box on
axis([0 1 0 8])
title('${\rho}$','interpreter','latex','fontsize',14)

subplot(2,5,9)
bar(bg_i(9,:),post_i(9,:)), hold on, plot(z1,exp(prior_h1),'r','linewidth',2); box on
axis([-0.5 2 0 5])
title('det(${\tilde A}$)','interpreter','latex','fontsize',14)

subplot(2,5,10)
bar(bg_i(10,:),post_i(10,:)), hold on, plot(z1,prior_h22,'r','linewidth',2); box on
axis([0 1.5 0 6])
title('${h}_{22}$','interpreter','latex','fontsize',14)


nuse=size(A_post_m,2);
alph=0.16;   
index=[round(nuse/2) round(alph*nuse) round((1-alph)*nuse)];    %implies 68% coverage of the entire distribution

sup_ela=sort(A_post_m(1,:));      
dem_ela=sort(A_post_m(4,:));

alpha_qp=sup_ela(1,index); 
beta_qp=dem_ela(1,index);

save elasticities68 alpha_qp beta_qp

