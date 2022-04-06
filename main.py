
from ast import Param
import pandas as pd
import numpy as np
from datetime import datetime as dt
from plot_prices import PlotPrices

from get_data import GetData

from aux import Aux
from pathlib import Path


# def take_only_year(self) -> None:
#                 if len(str(self.t0)) > 4:
#                         self.t0 = int(str(self.t0)[:4])

#         def check_if_complete_date(self) -> None:
#                 if len(str(self.t0)) == 4:
#                         self.t0 = int(str(self.t0) + '0101')
#                         self.t1 = int(str(self.t1) + '0101')

def tex_file(title):
        return "results/" + title + ".txt"


def create_txt(title, text):
        file    = Path(tex_file(title))
        file.write_text(f"{text}")


if __name__=="__main__":

        t0 = '20190101'
        t1 = '20220310'
        if int(t0) > 20180930:
                day_division = 'quarterly'
        if int(t0) < 20180930 and int(t1) > 20180930:
                print('Timing inconsistency')
        if int(t0) < 20180930 and int(t1) < 20180930:
                day_division = 'hourly'


        data = GetData(t0=t0, t1=t1)
        #data.get_asset_prices('')
        # data.get_cci()
        # data.get_wip()
        # data.get_epu()
        energies = ['SUN', 'WASTE', 'WINDONSHORE', 'WINDOFFSHORE', 'BIO', 'COALGAS', 'GAS', 'GEO','HARDCOAL', 'HYDRORIVER', 'HYDROSTORAGE', 'MARINE', 'NUC', 'OIL']    
        for energy in energies:
                data.get_entsoe('generation', day_division, energy)

        index_vars       = ['EPU_19_22', 'OECDplus6_WIP', 'CCI_19_22']
        electricity_vars = ['MAX_ELECTRICITYPRICES_19_22', 'MIN_ELECTRICITYPRICES_19_22']
        generation_vars  = ['GENERATION_BIO_19_22', 'GENERATION_NUC_19_22', 'GENERATION_SUN_19_22', 'GENERATION_WINDONSHORE_19_22', 'GENERATION_WINDOFFSHORE_19_22', 'GENERATION_GAS_19_22', 'GENERATION_COALGAS_19_22','GENERATION_HYDROSTORAGE_19_22', 'GENERATION_OIL_19_22']
        other_vars       = ['PRICES_19_22']
        myvars           = other_vars + generation_vars + electricity_vars + index_vars
        data.get_entsoe('prices')
        data.set_our_df(myvars)
        #data.set_complete_dataset()

       # 'BIO', 'COALGAS', 'GAS', 'GEO','HARDCOAL', 'HYDRORIVER', 'HYDROSTORAGE', 'MARINE', 'NUC', 'OIL',  

        # start = pd.Timestamp('20171201', tz='Europe/Brussels')
        # end = pd.Timestamp('20220320', tz='Europe/Brussels')
        # country_code = 'DE'  # Belgium
        # #df = client.query_aggregated_data(start=start, end=end, country_code=country_code)
        # df = client.query_aggregated_data(start = start, end = end, country_code=country_code)
        # print(df.columns)
        # print(df[['year', 'month', 'day', 'value']])
        #pow_gen.power_generation()
        # 'DE_GASPOOL', 'DE_NCG', 'UK', 'ES', 'IT', 'PL', 'EE_LV', 'UA'
        # country_codes = ['DE']
        # indicators= ['GCV']
        #entsog = EntsogGetter(start=20220101,end=20220106, country_codes=country_codes, indicators=indicators)
        # entsog.entsog_getter()


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
    