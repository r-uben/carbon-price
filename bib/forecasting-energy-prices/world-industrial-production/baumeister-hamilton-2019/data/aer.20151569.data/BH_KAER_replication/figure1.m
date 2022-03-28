%figure 1
alpha=0.025;
index=[alpha*(ndraws-nburn) (1-alpha)*(ndraws-nburn)]; %implies 68% coverage of the entire distribution
HO=(0:1:hmax-1)';                                      %impulse response horizon

load KAER_original

%%%%%%%%%%%%%%%%%%

figure(1)
subplot(3,3,1)
x1=-sort(cumsum(squeeze(IRF(1,1,:,:)),1),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,-cumsum(squeeze(ir_aer(1,1,:))),'r:','linewidth',2)
axis([0 hmax-1 -2.5 1.5])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-2.5:1:1.5)
ylabel('Oil production','fontsize',11)
title('Oil supply shock','fontsize',11)
%ylabel('percent','fontsize',12)

subplot(3,3,4)
x1=sort(cumsum(squeeze(IRF(1,2,:,:)),1),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,cumsum(squeeze(ir_aer(1,2,:))),'r:','linewidth',2)
axis([0 hmax-1 -2.5 1.5])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-2.5:1:1.5)
ylabel('Oil production','fontsize',11)
title('Aggregate demand shock','fontsize',11)

subplot(3,3,7)
x1=sort(cumsum(squeeze(IRF(1,3,:,:)),1),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,cumsum(squeeze(ir_aer(1,3,:))),'r:','linewidth',2)
axis([0 hmax-1 -2.5 1.5])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-2.5:1:1.5)
ylabel('Oil production','fontsize',11)
title('Oil-specific demand shock','fontsize',11)
xlabel('Months','fontsize',10)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,3,2)
x1=-sort(squeeze(IRF(2,1,:,:)),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,-squeeze(ir_aer(2,1,:)),'r:','linewidth',2)
axis([0 hmax-1 -5 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
ylabel('Real activity','fontsize',11)
title('Oil supply shock','fontsize',11)
%ylabel('percent','fontsize',12)

subplot(3,3,5)
x1=sort(squeeze(IRF(2,2,:,:)),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,squeeze(ir_aer(2,2,:)),'r:','linewidth',2) 
axis([0 hmax-1 -5 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
ylabel('Real activity','fontsize',11)
title('Aggregate demand shock','fontsize',11)

subplot(3,3,8)
x1=sort(squeeze(IRF(2,3,:,:)),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,squeeze(ir_aer(2,3,:)),'r:','linewidth',2) 
axis([0 hmax-1 -5 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:35)
ylabel('Real activity','fontsize',11)
title('Oil-specific demand shock','fontsize',11)
xlabel('Months','fontsize',10)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,3,3)
x1=-sort(squeeze(IRF(3,1,:,:)),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,-squeeze(ir_aer(3,1,:)),'r:','linewidth',2)
axis([0 hmax-1 -5 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
ylabel('Real oil price','fontsize',11)
title('Oil supply shock','fontsize',11)
%ylabel('percent','fontsize',12)

subplot(3,3,6)
x1=sort(squeeze(IRF(3,2,:,:)),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,squeeze(ir_aer(3,2,:)),'r:','linewidth',2)
axis([0 hmax-1 -5 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
ylabel('Real oil price','fontsize',11)
title('Aggregate demand shock','fontsize',11)

subplot(3,3,9)
x1=sort(squeeze(IRF(3,3,:,:)),2);
temp1=[(median(x1,2)) x1(:,index(1)) x1(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, plot(HO,squeeze(ir_aer(3,3,:)),'r:','linewidth',2)
axis([0 hmax-1 -5 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
title('Oil-specific demand shock','fontsize',11)
ylabel('Real oil price','fontsize',11)
xlabel('Months','fontsize',10)
