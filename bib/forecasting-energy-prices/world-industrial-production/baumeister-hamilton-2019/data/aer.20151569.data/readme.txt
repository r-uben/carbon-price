This folder contains four subfolders with Matlab code to replicate all the 
results in:
Baumeister, Christiane and James D. Hamilton, "Structural Interpretation of
Vector Autoregressions with Incomplete Identification: Revisiting the Role
of Oil Supply and Demand Shocks," American Economic Review.


The subfolder 'BH_KAER_replication' produces Figures 1 and 2 by running the
script main_KAER_replication.m which calls all the other functions.

The subfolder 'BH_KM12_replication' produces Figures 3 and 4 by running the
script main_KM12_replication.m which calls all the other functions.

The subfolder 'BH_baseline_model' produces Figure 7-9 and Tables 2 and 4, column(3)
by running the script main_BH_AER.m which calls most of the other functions.
The file data_BH_baseline.xlsx contains the data used in the baseline model.
The tab 'delta inventories' shows how the inventory variable has been obtained.
The file equation40.m produces the entries in equation (40) in the paper.
The file simulate_h1.m takes draws from the prior distributions for the elements
in A to obtain the location and scale parameters for the prior for det(A_tilde).
The file my_asymmetric_t_prior.m plots the prior for det(A_tilde).

The subfolder 'figure6' produces Figure 6 by running the script figure6.m.
It also contains the raw data and information about the data sources in 
data_figure6.xlsx.


For questions, please contact: cjsbaumeister@gmail.com



