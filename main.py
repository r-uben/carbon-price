import csv
from clean_data import CleanData



if __name__=="__main__":
    
    titles = ["ICEDEU3_EUR_12_22", 'EECXSYR1TNRG_EUR_10_22', 'CO1COMDTY_EUR_10_22', 'CLJ2COMBCOMDTY_EUR_16_22', 'GASEUEQUITY_EUR_10_22', 'WK2COMBCOMDTY_19_22', 'GT1CDEGSACT24AVINEX_MW_15_22']#, 'GFRURUEUINDEX_MILLM3_16_22']
    data = CleanData(file_titles=titles, init_date='2019-12-31', end_date='2022-03-09', csv_title='1st_df')
    data.CleanData()