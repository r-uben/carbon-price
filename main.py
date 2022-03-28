
from tty         import CC
from unicodedata import name
import pandas    as pd
from clean_data  import CleanData
from plot_prices import PlotPrices
from idx_cci     import CCIidx
from idx_wip     import WIP
from idx_epu     import EPU
from power_generation import PowerGeneration


from pathlib import Path

import statsmodels.api as sm
from statsmodels.iolib.summary2 import summary_col

def tex_file(title):
        return "results/" + title + ".txt"


def create_txt(title, text):
        file    = Path(tex_file(title))
        file.write_text(f"{text}")

if __name__=="__main__":


        ### TO CONSTRUCT A DATAFRAME WITH DIFFERENT ASSET (FUTURES & STOCK) PRICES
        ### Source: Bloomberg
        #     titles = ["ICEDEU3_EUR_12_22", 'CO1COMDTY_EUR_10_22', 'GASEUEQUITY_EUR_10_22', 'WK2COMBCOMDTY_19_22']#, 'GFRURUEUINDEX_MILLM3_16_22']
        #     data = CleanData(file_titles=titles, init_date='2019-12-31', end_date='2022-03-09', csv_title='1st_df')
        #     data.CleanData()

        ### TO CONSTRUCT A DATAFRAME WITH THE CONSUMER CONFIDENCE INDEX (CCI)
        ### Source: https://data.oecd.org/leadind/consumer-confidence-index-cci.htm
        cci = CCIidx()
        #cci.idx_cci()
        
        ### TO CONSTRUCT A DATA FRAME WITH THE WORLD INDUSTRY PRODUCTION INDEX (WIP)
        ### Source: https://sites.google.com/site/cjsbaumeister/research
        wip = WIP(init_year=2000)
        #wip.idx_wip()

        ### TO CONSTRUCT A DATA FRAME WITH THE EUROPEAN POLICY UNCERTAINTY INDEX (EPU)
        ### Source: https://www.policyuncertainty.com/europe_monthly.html
        epu = EPU(init_year=2000)
        #epu.idx_epu()

        pow_gen = PowerGeneration()
        pow_gen.power_generation()

    # df = pd.read_csv('data/1st_df.csv', index_col=[0])
    # df1 = df.copy()

    #plt = PlotPrices(df=df1, lastNdays=150, name='1st_df_last150days_prices', format='eps', linewidth=0.8, dpi=700)
    #plt.plot_prices()

    # plt = PlotPrices(df=df1, lastNdays=90, name='1st_df_last90days_prices', format='png', dpi=100)
    # plt.plot_prices()

    #cols = df.columns.tolist()
    #idx  = df.columns.tolist()
    #print(df)
#     d = {
#         'eua_futures':  cols[0],
#         'brent':        cols[1],
#         'crude_oil':    cols[2],
#         'gas':          cols[3],
#         'wheat':        cols[4],
#         'germ_gas':     cols[5]
#     }

#     selection = [d['brent'], d['crude_oil'], d['gas'], d['wheat'], d['germ_gas']]

#     X    = df[selection] 
#     y    = df[d['eua_futures']]
#     reg = sm.OLS(y.astype(float), X.astype(float)).fit(cov_type='HAC', cov_kwds={'maxlags':12}) 
#     sum = summary_col(results=reg, float_format='%0.2f', stars=True, info_dict=None,  drop_omitted=True)
#     tex    = sum.as_latex()
#     create_txt('since2019-reg', tex)
#     print()
#     print("###################")
#     print("SINCE 2019")
#     print(sum)

#     df2  = df.iloc[:150]
#     X    = df2[selection] 
#     y    = df2[d['eua_futures']]
#     reg = sm.OLS(y.astype(float), X.astype(float)).fit(cov_type='HAC', cov_kwds={'maxlags':12}) 
#     sum = summary_col(results=reg, float_format='%0.2f', stars=True, info_dict=None,  drop_omitted=True)
#     tex    = sum.as_latex()
#     create_txt('last150days-reg', tex)
#     print()
#     print("###################")
#     print("LAST 150 DAYS")
#     print(sum)

#     df2  = df.iloc[:60]
#     X    = df2[selection] 
#     y    = df2[d['eua_futures']]
#     reg = sm.OLS(y.astype(float), X.astype(float)).fit(cov_type='HAC', cov_kwds={'maxlags':12}) 
#     sum = summary_col(results=reg, float_format='%0.2f', stars=True, info_dict=None,  drop_omitted=True)
#     tex    = sum.as_latex()
#     print()
#     print("###################")
#     print("LAST 60 DAYS")
#     create_txt('last60days-reg', tex)
#     print(sum)
    