function pg = uniform_prior(y,a_alpha,b_alpha)

for jj=1:size(y,2)
    pg(jj,1)=1/abs(b_alpha-a_alpha);
end
