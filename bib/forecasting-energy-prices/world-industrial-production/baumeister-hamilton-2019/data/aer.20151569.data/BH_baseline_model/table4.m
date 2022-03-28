load('HD_bench.mat', 'HD31')

tt=time(193+nlags:end,1);
alph=0.16;     % 68% coverage 
index=[round((ndraws_short-nburn)/2) round(alph*(ndraws_short-nburn)) round((1-alph)*(ndraws_short-nburn))];

% HISTORICAL EPISODES
%July-Oct 1990
tbeg90=186;
tend90=189;

%Feb 2007 - June 2008
tbeg07=385;
tend07=401; 

%July 2014 - Jan 2016
tbeg14=474;
tend14=492;

%March 2016 - Dec 2016
tbeg16=494;
tend16=503;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oilprice=yy2(nlags+1:end,3);

disp('Table 4')

HD31_90=sum(HD31(tbeg90:tend90,:),1);
HD31_90s=sort(HD31_90);

disp('June-Oct 1990')
disp('   Actual    median   lower 16%    upper 16%')
episode1=[sum(oilprice(tbeg90:tend90,1)) HD31_90s(1,index)]
disp ('Percent')
perc90=episode1(2)/episode1(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HD31_07=sum(HD31(tbeg07:tend07,:),1);
HD31_07s=sort(HD31_07);

disp('Jan 2007-June 2008')
disp('   Actual    median   lower 16%    upper 16%')
episode2=[sum(oilprice(tbeg07:tend07,1)) HD31_07s(1,index)]
disp('Percent')
perc07=episode2(2)/episode2(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HD31_14=sum(HD31(tbeg14:tend14,:),1);
HD31_14s=sort(HD31_14);

disp('June 2014-Jan 2016')
disp('   Actual    median   lower 16%    upper 16%')
episode3=[sum(oilprice(tbeg14:tend14,1)) HD31_14s(1,index)]
disp('Percent')
perc14=episode3(2)/episode3(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HD31_16=sum(HD31(tbeg16:tend16,:),1);
HD31_16s=sort(HD31_16);

disp('Feb 2016-Dec 2016')
disp('   Actual    median   lower 16%    upper 16%')
episode4=[sum(oilprice(tbeg16:tend16,1)) HD31_16s(1,index)]
disp('Percent')
perc16=episode4(2)/episode4(1)

save HD_episodes episode1 episode2 episode3 episode4 perc90 perc07 perc14 perc16