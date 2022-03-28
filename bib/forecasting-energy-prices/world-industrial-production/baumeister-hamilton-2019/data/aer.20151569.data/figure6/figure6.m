%%% This file generates Figure 6 in Baumeister and Hamilton, 
%%% "Structural Interpretation of Vector Autoregressions with Incomplete 
%%% Identification: Revisiting the Role of Oil Supply and Demand Shocks", 
%%% American Economic Review

%%% By Christiane Baumeister and James D. Hamilton (Sept 2014)

clear;
clc;

%data for 23 OECD countries for the years
%1998,2000,2002,2004,2006,2008,2010,2012

load consumption     %petroleum consumption in million gallons/year (EIA)
load gdp             %real GDP in billion chained 2005 USD (World Bank)
load prices          %nominal gasoline prices in USD/gallon (World Bank)

jx=4;   %2004
    y=log(cons(:,jx)./gdp(:,jx));
    x=[ones(size(y,1),1) log(p(:,jx))];
    [bhat,bhatstd,tbhat,ff,ehat] = ols(y,x);
    result=[bhat(2,1);tbhat(2,1)]
a=[0;log(p(:,jx));2];
fitted=[ones(size(a,1),1) a]*bhat;

figure(1)
subplot(2,2,1)
scatter(log(p(:,jx)),y,'linewidth',3), hold on, plot(a,fitted,'r','linewidth',2)
text(0.1,3.8,['slope = ' num2str(bhat(2,1),2)],'Color','Black','fontsize',12)
axis([0 2 2 4])
ylabel('Log petroleum consumption (gallons/year/real GDP) in 2004','fontsize',12)
xlabel('Log gasoline price ($ per gallon) in 2004','fontsize',12)

jx=4;   %2004
    y=log(cons(:,jx)./gdp(:,jx));
    x=[ones(size(y,1),1) log(p(:,jx-2))];
    [bhat,bhatstd,tbhat,ff,ehat] = ols(y,x);
    result=[bhat(2,1);tbhat(2,1)]
a=[0;log(p(:,jx-2));2];
fitted=[ones(size(a,1),1) a]*bhat;

subplot(2,2,2)
scatter(log(p(:,jx-2)),y,'linewidth',3), hold on, plot(a,fitted,'r','linewidth',2)
text(0.1,3.8,['slope = ' num2str(bhat(2,1),2)],'Color','Black','fontsize',12)
axis([0 2 2 4])
ylabel('Log petroleum consumption (gallons/year/real GDP) in 2004','fontsize',12)
xlabel('Log gasoline price ($ per gallon) in 2000','fontsize',12)
