disp('working on Figure 8 now...')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute IRFs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IRF=zeros(n,n,hmax,ndraws-nburn);
for jj=1:size(A_post,3)
    if (jj/10000) == floor(jj/10000)
          jj
    end
    IRF(:,:,:,jj)=impulse_response_m(A_post_m(:,jj),A_post(:,:,jj),B_post(:,:,jj),n,nlags,hmax-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot impulse responses for one-unit shocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alph1=0.16;     %68% coverage
alph2=0.025;    %95% coverage
index=[round(alph1*(ndraws-nburn)) round((1-alph1)*(ndraws-nburn)) round((ndraws-nburn)/2) ...
    round(alph2*(ndraws-nburn)) round((1-alph2)*(ndraws-nburn))];   
HO=(0:1:hmax-1)';   %impulse response horizon

figure(8)
subplot(4,4,1)
x=-sort(cumsum(squeeze(IRF(1,1,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 2])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-2:1:2)
ylabel('Oil production','fontsize',12)
title('Oil supply shock','fontsize',12)

subplot(4,4,5)
x=sort(cumsum(squeeze(IRF(1,2,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 2])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-2:1:2)
ylabel('Oil production','fontsize',12)
title('Economic activity shock','fontsize',12)

subplot(4,4,9)
x=sort(cumsum(squeeze(IRF(1,3,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 2])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-2:1:2)
ylabel('Oil production','fontsize',12)
title('Consumption demand shock','fontsize',12)

subplot(4,4,13)
x=sort(cumsum(squeeze(IRF(1,4,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 2])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-2:1:2)
ylabel('Oil production','fontsize',12)
title('Inventory demand shock','fontsize',12)
xlabel('Months','fontsize',11)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,4,2)
x=-sort(cumsum(squeeze(IRF(2,1,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -0.4 0.2])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-4:.2:10)
ylabel('World IP','fontsize',12)
title('Oil supply shock','fontsize',12)

subplot(4,4,6)
x=sort(cumsum(squeeze(IRF(2,2,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2) 
axis([0 hmax-1 0 3])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:1:10)
ylabel('World IP','fontsize',12)
title('Economic activity shock','fontsize',12)

subplot(4,4,10)
x=sort(cumsum(squeeze(IRF(2,3,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2) 
axis([0 hmax-1 -0.4 0.2])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-4:.2:3)
ylabel('World IP','fontsize',12)
title('Consumption demand shock','fontsize',12)

subplot(4,4,14)
x=sort(cumsum(squeeze(IRF(2,4,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2) 
axis([0 hmax-1 -0.4 0.2])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-4:.2:3)
ylabel('World IP','fontsize',12)
title('Inventory demand shock','fontsize',12)
xlabel('Months','fontsize',11)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,4,3)
x=-sort(cumsum(squeeze(IRF(3,1,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 0 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
ylabel('Real oil price','fontsize',12)
title('Oil supply shock','fontsize',12)

subplot(4,4,7)
x=sort(cumsum(squeeze(IRF(3,2,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 0 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
ylabel('Real oil price','fontsize',12)
title('Economic activity shock','fontsize',12)

subplot(4,4,11)
x=sort(cumsum(squeeze(IRF(3,3,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 0 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
title('Consumption demand shock','fontsize',12)
ylabel('Real oil price','fontsize',12)

subplot(4,4,15)
x=sort(cumsum(squeeze(IRF(3,4,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 0 10])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-5:5:10)
title('Inventory demand shock','fontsize',12)
ylabel('Real oil price','fontsize',12)
xlabel('Months','fontsize',11)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,4,4)
x=-sort(cumsum(squeeze(IRF(4,1,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 1])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-1:0.5:1)
ylabel('Stocks','fontsize',12)
title('Oil supply shock','fontsize',12)

subplot(4,4,8)
x=sort(cumsum(squeeze(IRF(4,2,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 1])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-1.5:.5:1)
ylabel('Stocks','fontsize',12)
title('Economic activity shock','fontsize',12)

subplot(4,4,12)
x=sort(cumsum(squeeze(IRF(4,3,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 1])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-1.5:.5:1)
title('Consumption demand shock','fontsize',12)
ylabel('Stocks','fontsize',12)

subplot(4,4,16)
x=sort(cumsum(squeeze(IRF(4,4,:,:)),1),2);
temp1=[x(:,index(3)) x(:,index(1)) x(:,index(2))];
plotx1(temp1,HO); box on; plot(HO,zeros(hmax,1),'k:','linewidth',1), hold on, ...
    plot(HO,x(:,index(4:5)),'b:','linewidth',2)
axis([0 hmax-1 -1 1])
set(gca,'XTick',0:5:20)
set(gca,'YTick',-0.5:.5:1)
title('Inventory demand shock','fontsize',12)
ylabel('Stocks','fontsize',12)
xlabel('Months','fontsize',11)


nuse=ndraws-nburn;
alph=0.16;   
index=[nuse/2 alph*nuse (1-alph)*nuse];    %implies 68% coverage of the entire distribution
IRnorm21=zeros(1,nuse);
IRnorm23=IRnorm21;
IRnorm24=IRnorm21;

IRF21=squeeze(IRF(2,1,:,:));
IRF31=squeeze(IRF(3,1,:,:));
IRF23=squeeze(IRF(2,3,:,:));
IRF33=squeeze(IRF(3,3,:,:));
IRF24=squeeze(IRF(2,4,:,:));
IRF34=squeeze(IRF(3,4,:,:));

%Effect of shocks that lead to 10% oil price increase on economic activity
h=13;
for jj=1:nuse
    a=cumsum(IRF21(1:h,jj))/IRF31(1,jj);  %oil supply shock
    b=cumsum(IRF23(1:h,jj))/IRF33(1,jj);  %oil consumption demand shock
    c=cumsum(IRF24(1:h,jj))/IRF34(1,jj);  %oil inventory demand shock
    IRnorm21(1,jj)=a(end,1);
    IRnorm23(1,jj)=b(end,1);
    IRnorm24(1,jj)=c(end,1);
end

IRnorm21s=sort(IRnorm21);
IRnorm23s=sort(IRnorm23);
IRnorm24s=sort(IRnorm24);

IRn21=10*IRnorm21s(1,index);
IRn23=10*IRnorm23s(1,index);
IRn24=10*IRnorm24s(1,index);

save IRF_norm68 IRn21 IRn23 IRn24

% Table 2: posterior probabilities that sign on impact is positive
post_probs=zeros(n,n,size(IRF,4));
for jx=1:n
    for jy=1:n
        for jz=1:size(IRF,4)
            if IRF(jx,jy,1,jz)>0
               post_probs(jx,jy,jz)=1;
            end
        end
    end
end

ps=sum(post_probs,3);
sign_probs=ps./size(IRF,4)

save posterior_probs sign_probs
