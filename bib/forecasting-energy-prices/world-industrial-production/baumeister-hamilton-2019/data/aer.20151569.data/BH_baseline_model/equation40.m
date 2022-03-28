% computes the determinant and adjoint for Atilde to determine the 
% impact signs implied by priors on elements in Atilde
syms alpha_qp beta_qp beta_qy invxi alpha_yp psi_1 psi_3
Atilde = [1 0 -alpha_qp 0; 0 1 -alpha_yp 0; 1 -beta_qy -beta_qp -invxi; -psi_1 0 -psi_3 1];
Atilde
det(Atilde)               %determinant
det(Atilde)*inv(Atilde)   %adjoint
