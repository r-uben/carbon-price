disp('working on Figure 9 now...')
% historical decomposition of the real oil price
if (ndraws-nburn)>500000
    ndraws_short=nburn+500000;   %fewer draws because of memory constraints
else
    ndraws_short=ndraws;
end

% decomposition in 5 shocks
HD31=zeros(size(yyy2,1),ndraws_short-nburn);
HD32=HD31;
HD33=HD31;
HD34=HD31;
HD35=HD31;

for jj=1:size(HD31,2)
    if (jj/10000) == floor(jj/10000)
          jj
    end
    [HD31(:,jj),HD32(:,jj),HD33(:,jj),HD34(:,jj),HD35(:,jj)] =  ...
        historical_decomposition_m(A_post_m(:,jj),A_post(:,:,jj), ...
        B_post(:,:,jj),n,nlags,yyy2,xxx2,D_post(:,:,jj));
end

save HD_bench HD31 HD32 HD33 HD34 HD35
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HISTORICAL DECOMPOSITION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t=time(193+nlags:end,1);
alph=0.025;   % 95% coverage
index=[round(alph*(ndraws_short-nburn)) round((1-alph)*(ndraws_short-nburn)) round((ndraws_short-nburn)/2)];

% historical decomposition of real oil price growth
yhat31=sort(HD31,2);
clear HD31
yhat32=sort(HD32,2);
clear HD32
yhat33=sort(HD33,2);
clear HD33
yhat34=sort(HD34,2);
clear HD34
yhat35=sort(HD35,2);
clear HD35

figure(9)
subplot(2,1,1)
temp1=[yhat31(:,index(3)) yhat31(:,index(1)) yhat31(:,index(2))];
plotx2(temp1,t); box on; plot(t,yy2(nlags+1:end,3),'r:','linewidth',2), hold on, plot(t,temp1(:,1),'LineWidth',1), hold on, plot(t,zeros(size(t,1),1),'k:') 
axis([1975 2017 -40 40])
ylabel('Percent')
title('Effect of oil supply shocks on oil price growth')
% 
subplot(2,1,2)
temp2=[yhat32(:,index(3)) yhat32(:,index(1)) yhat32(:,index(2))];
plotx2(temp2,t); box on; plot(t,yy2(nlags+1:end,3),'r:','linewidth',2), hold on, plot(t,temp2(:,1),'LineWidth',1), hold on, plot(t,zeros(size(t,1),1),'k:')
axis([1975 2017 -40 40])
ylabel('Percent')
title('Effect of economic activity shocks on oil price growth')
% 
figure(10)
subplot(2,1,1)
temp3=[yhat33(:,index(3)) yhat33(:,index(1)) yhat33(:,index(2))];
plotx2(temp3,t); box on; plot(t,yy2(nlags+1:end,3),'r:','linewidth',2), hold on, plot(t,temp3(:,1),'LineWidth',1), hold on, plot(t,zeros(size(t,1),1),'k:')
axis([1975 2017 -40 40])
ylabel('Percent')
title('Effect of oil consumption demand shocks on oil price growth')
% 
subplot(2,1,2)
temp4=[yhat34(:,index(3)) yhat34(:,index(1)) yhat34(:,index(2))];
plotx2(temp4,t); box on; plot(t,yy2(nlags+1:end,3),'r:','linewidth',2), hold on, plot(t,temp4(:,1),'LineWidth',1), hold on, plot(t,zeros(size(t,1),1),'k:')
axis([1975 2017 -40 40])
ylabel('Percent')
title('Effect of oil inventory demand shocks on oil price growth')

% figure(13)
% subplot(2,1,1)
% temp5=[yhat35(:,index(3)) yhat35(:,index(1)) yhat35(:,index(2))];
% plotx2(temp5,t); box on; plot(t,yy2(nlags+1:end,3),'r:','linewidth',2), hold on, plot(t,temp5(:,1),'LineWidth',1), hold on, plot(t,zeros(size(t,1),1),'k:')
% axis([1975 2017 -40 40])
% ylabel('Percent')
% title('Effect of measurement error on oil price growth')

%check that it reproduces original series
%total=yhat31(:,index(3))+yhat32(:,index(3))+yhat33(:,index(3))+yhat34(:,index(3))+yhat35(:,index(3));


