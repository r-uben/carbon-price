load kiliandata.txt
[BETAnc,B1,XZ, SIGMA, U, V]=lsvarc(kiliandata,24);
xmax=17;
[IRFaer, K1]=VARirf(BETAnc,SIGMA,xmax);
ir_aer=reshape(IRFaer,3,3,18);
save KAER_original ir_aer