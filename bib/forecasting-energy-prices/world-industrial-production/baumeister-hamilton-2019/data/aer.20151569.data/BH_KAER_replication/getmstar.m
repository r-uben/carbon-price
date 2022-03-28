function m_star = getmstar(M_star,Sxy,M,eta,A)

m_star=M_star*(Sxy'+inv(M)*eta')*A';

end

