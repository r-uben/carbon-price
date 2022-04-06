
from ast import Param
import pandas as pd
import numpy as np
from datetime import datetime as dt
from clean_data  import CleanData
from plot_prices import PlotPrices

from aux import Aux

### CLASS TO GET DATA OF SOME INDEXES
from idx_cci     import CCIidx
from idx_wip     import WIP
from idx_epu     import EPU

### ENTSOE AND ENTSOG GLASSES
from entsog_getter import EntsogGetter
from entsoe_getter import EntsoeGetter

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

class GetData(object):

        DEFAULT_COUNTRIES  = ['DE_LU', 'FR', 'IT_NORD', 'ES']
        DEFAULT_PARAM      = 'prices'
        DETAULT_ENERGY     = 'COALGAS'
        DEFAULT_TITLE      = ''
        DEFAULT_AP         = ["ICEDEU3_EUR_12_22", 'CO1COMDTY_EUR_10_22','CLJ2COMBCOMDTY_EUR_16_22', 'GASEUEQUITY_EUR_10_22', 'WK2COMBCOMDTY_19_22', 'GFRURUEUINDEX_MILLM3_16_22']
        DEFAULT_DAY_PARAM  = 'mean'
        ISO3               = ['DE', 'FR', 'IT', 'ES', 'UK'] #, 'EU', 'OECD']
        MONTHLY_VARS       = ['CCI_00_22', 'EPU_00_22', 'OECDplus6_WIP_00_22']
        QUART_VARS         = ['GENERATIONGAS_00_22','GENERATIONCOALGAS_00_22', 'GENERATIONSUN_14_22', 'GENERATIONOIL_00_22', 'GENERATIONNUC_00_22', 'GENERATIONBIO_00_22', 'GENERATIONWINDOFFSHORE_14_22', 'GENERATIONWINDONSHORE_14_22', 'GENERATIONHYDROSTORAGE_14_22', 'GENERATIONHYDRORIVER_14_22'] 
        HOURLY_VARS        = ['ELECTRICITYPRICES_10_22']
        DAILY_VARS         = ['ASSETPRICES1_19_22']
        NOT_QUARTERLY      = 'notquarterly'
        DAY_DIVISION       = 'hourly'
        NONE               = None
        VARS               = ['PRICES_19_22']

        def __init__(self, t0, t1) -> None:
                self.t0: str = t0
                self.t1: str = t1
                self.years:  list = []
                self.year0:  int = self.t0[:4]
                self.year1:  int = self.t1[:4]
                self.months: list = []
                self.month0: int = self.t0[4:6]
                self.month1: int = self.t1[4:6]
                self.days:   list = []
                self.day0:   int = self.t0[6:8]
                self.day1:   int = self.t0[6:8]
                self.time_index: list = []
                self.energies: list = ['GAS', 'WINDOFFSHORE', 'WINDONSHORE', 'SUN', 'OIL', 'NUC', 'COALGAS', 'MARINE', 'HYDRORIVER', 'HYDROSTORAGE', 'HARDCOAL', 'BIO']
                self.country_codes: zip = {
                        'DE'    : ['DE', 'DE_LU', 'DE_LU_Eprice'] + ['DE_LU_' + x for x in self.energies] + ['Germany_News_Index', 'DEU_CCI'],
                        'FR'    : ['FR', 'FR_Eprice'] + ['FR_' + x for x in self.energies] + ['France_News_Index', 'FRA_CCI'],
                        'IT'    : ['IT', 'IT_NOR', 'IT_CNOR', 'IT_CNOR_Eprice'] + ['IT_NORD_' + x for x in self.energies] + ['Italy_News_Index', 'ITA_CCI'],
                        'ES'    : ['ES', 'ES_Eprice' 'ES_OIL'] + ['ES_' + x for x in self.energies] + ['Spain_News_Index', 'ESP_CCI'],
                        'UK'    : ['UK'] + ['UK_News_Index', 'GBR_CCI'],
                        'EU'    : ['EU', 'EU_Eprice', 'EU_OIL', 'EU_COALGAS', 'EU_GAS'] + ['European_News_Index', 'EA19_CCI'],
                        'OECD'  : ['OECD']
                }
      
        # Decorator to write the date correctly
        def only_the_year(fn):
                def wrap(self: 'GetData', *args, **kwargs):
                        if len(self.t0) > 4:
                                self.t0 = int(str(self.t0)[:4])
                        return fn(self, *args, *kwargs)
                return wrap

        def complete_date(fn):
                def wrap(self: 'GetData', *args, **kwargs):
                        if len(str(self.t0)) == 4:
                                self.t0 = int(str(self.t0) + '0101')
                                self.t1 = int(str(self.t1) + '0101')
                        return fn(self, *args, *kwargs)
                return wrap

        def formatted_date(fn):
                def wrap(self: 'GetData', *args, **kwargs):
                        if len(str(self.t0)) == 4:
                                self.t0 = int(str(self.t0) + '0101')
                                self.t1 = int(str(self.t1) + '0101')
                        self.t0 = pd.to_datetime(self.t0, format='%Y%m%d').date()
                        self.t1 = pd.to_datetime(self.t1, format='%Y%m%d').date()
                        self.time_index = pd.date_range(self.t0, self.t1, freq='D').date
                        return fn(self, *args, *kwargs)
                return wrap

        def int_time(fn):
                def wrap(self: 'GetData', *args, **kwards):
                        self.year0      = int(self.year0)
                        self.year1      = int(self.year1)
                        self.month0     = int(self.month0)
                        self.month1     = int(self.month1)
                        self.day0       = int(self.day0)
                        self.day1       = int(self.day1)
                        return fn(self, *args, **kwards)
                return wrap

        def set_name_var(self, name, cutter=None):
                name = name.replace('_','')
                name = name.replace('OECDplus6', '')
                for j in range(10):
                        name = name.replace(str(j), '')
                if 'GENERATION' in name:
                        name = name.replace('GENERATION', 'gen')
                if cutter is None:
                        return name
                else: 
                        return cutter + '_' + name
                
        @complete_date
        def get_asset_prices(self, title=DEFAULT_TITLE, assets=DEFAULT_AP) -> None:
                '''
                TO CONSTRUCT A DATAFRAME WITH DIFFERENT ASSET (FUTURES & STOCK) PRICES
                Source: Bloomberg
                '''
                data = CleanData(file_titles=assets, t0=self.t0, t1=self.t1, csv_title='PRICES')
                data.CleanData(title)

        @complete_date 
        def get_cci(self) -> None:
                '''
                TO CONSTRUCT A DATAFRAME WITH THE CONSUMER CONFIDENCE INDEX (CCI)
                Source: https://data.oecd.org/leadind/consumer-confidence-index-cci.htm
                '''

                cci = CCIidx(t0=self.t0, t1=self.t1)
                cci.idx_cci()
        
        @complete_date 
        def get_wip(self) -> None:
                '''
                TO CONSTRUCT A DATA FRAME WITH THE WORLD INDUSTRY PRODUCTION INDEX (WIP)
                Source: https://sites.google.com/site/cjsbaumeister/research
                '''
                # self.take_only_year()
                wip = WIP(t0=self.t0, t1=self.t1)
                wip.idx_wip()
        
        @complete_date
        def get_epu(self) -> None:
                '''
                TO CONSTRUCT A DATA FRAME WITH THE EUROPEAN POLICY UNCERTAINTY INDEX (EPU)
                Source: https://www.policyuncertainty.com/europe_monthly.html
                '''
                epu = EPU(t0=self.t0, t1=self.t1)
                epu.idx_epu()

        @complete_date
        def get_entsoe(self, param=DEFAULT_PARAM, day_division=DAY_DIVISION, energy_code=DETAULT_ENERGY, country_codes=DEFAULT_COUNTRIES) -> None:
                entsoe = EntsoeGetter(t0=self.t0, t1=self.t1, country_codes=country_codes)
                entsoe.entsoe_getter(param, energy_code, day_division)

        @complete_date
        def get_entsog(self, country_codes=DEFAULT_COUNTRIES) -> None:
                entsog = EntsogGetter(start=self.t0, end=self.t1, country_codes=country_codes)
                entsog.entsog_getter()

        @formatted_date
        def set_iso3(self, iso3=ISO3, singleindex=NONE):
                '''
                        This function take the country codes that are gonna be used and construct 
                        a data frame that is gonna be fill in with different variables
                '''
                df = {'times': [],
                'iso3' : []
                }
                times = []
                iso  = []
                # Let's construct a list that is gonna be the index(es) of our dataframe: it contain the date
                # but each day is repeated len(iso3) times (oen for each country) that we are putting in a second column 
                # as a de facto second index column.
                # TODO: MULTI-INDEX SHOULD BE USEFUL HERE
                for t in self.time_index:
                        times += len(iso3)*[t]
                        iso   += iso3
                # Set both column indexes
                df['times'] = times
                df['iso3'] = iso
                # Construct our df:
                df = pd.DataFrame(df)
                if singleindex is None:
                        df.set_index(['times', 'iso3'], inplace=True)
                else:
                        df.set_index('times', inplace=True)
                return df

        def set_hourly_to_daily(self, df, cutter, q=NOT_QUARTERLY):
                '''
                        This function take a dataframe which is defined to be given in hourly dates
                        and it returns three daily dataframes: one with the mean, other with the maximum,
                        and the other which is aggregated.
                '''
                # TODO: This function is an ad hoc function, it should be interesting to create a condition
                # to check whether the data is given quarterly or not. It may be given quarterly sometimes
                # and sometimes hourly.
                if q.lower().replace(' ', '').replace('_','') == 'quarterly':
                        q = 4
                else: 
                        q = 1
                # Ged rid of hours
                df.index = [str(x[:10]) for x in df.index]
                # Take appropriate set of time
                df      = df.loc[self.t0:self.t1, :]
                # Group by day (there are datasets in which the data are given by quarters or by hours)
                df_max  = df.groupby(np.arange(len(df))//(24*q)).max()
                df_mean = df.groupby(np.arange(len(df))//(24*q)).mean()
                df_sum = df.groupby(np.arange(len(df))//(24*q)).sum()
                df_max.index  = self.time_index
                df_mean.index = self.time_index
                df_sum.index  = self.time_index
                if cutter.lower() == 'mean':
                        return df_mean
                if cutter.lower() == 'max' or 'maximum':
                        return df_max
                if cutter.lower() == 'aggregate':
                        return df_sum

        def set_monthly_to_daily(self, df):
                '''
                        This function take a dataframe which is defined to be given in monthly dates
                        and it returns one dataframe with the values repeated in each month.
                '''
                df.index = [dt.strptime(x, '%Y-%m') for x in df.index]
                df = df.reindex(self.time_index, method='ffill')
                return df

        def set_complete_dataset(self, iso3=ISO3, quarterly_vars=QUART_VARS, hourly_vars=HOURLY_VARS, daily_vars=DAILY_VARS, monthly_vars=MONTHLY_VARS):
                aux = Aux()
                df = self.set_iso3(iso3)
                print(df)
                for var_name in daily_vars:
                        vardf = pd.read_csv('data/ready-to-use/' + var_name + '.csv', index_col=0)
                        vardf = vardf[::-1]
                        vardf = vardf.loc[self.t0:self.t1, :]
                        count = 0
                        for col in vardf.columns:
                                df[col] = len(df)*[np.nan]
                                for i in range(len(df.index)):
                                        t = str(df.index[i])
                                        #  Maybe there's some date missing
                                        if str(t) in vardf.index:
                                                df[col].iloc[i] = vardf.loc[t, col]
                                count += 1

                for var_name in quarterly_vars:
                        vardf      = pd.read_csv('data/ready-to-use/' + var_name + '.csv', index_col=0)
                        vardf_sum  = self.set_hourly_to_daily(vardf,'max','quarterly')
                        var_name_sum = self.set_name_var(var_name, 'agg')
                        df[var_name_sum] = len(df)*[np.nan]
                        count = 0
                        for col in vardf.columns:
                                # the indexes are repeated in blocks with the countries. What I do here is to initiate a counter
                                # to localise which country are we looping around. 
                                country = aux.get_key(self.country_codes, col)
                                for i in range(count,len(df)):
                                        #  Maybe there's some date missing
                                        if df.index[i] in vardf_sum.index:
                                                # Check that it is the appropriate country
                                                for country_row in df.loc[df.index[i], 'iso3'].values:
                                                        if country_row == country:
                                                                df[var_name_sum].iloc[i] = vardf_sum.loc[df.index[i], col] 
                                count +=1
                        
                for var_name in hourly_vars:
                        vardf      = pd.read_csv('data/ready-to-use/' + var_name + '.csv', index_col=0)
                        vardf_mean = self.set_hourly_to_daily(vardf, 'mean','hour')
                        vardf_max  = self.set_hourly_to_daily(vardf,'max','hour')
                        var_name_mean = self.set_name_var(var_name, 'mean')
                        var_name_max  = self.set_name_var(var_name, 'max')
                        df[var_name_mean] = len(df)*[np.nan]
                        df[var_name_max]  = len(df)*[np.nan]
                        count = 0
                        for col in vardf.columns:
                                # the indexes are repeated in blocks with the countries. What I do here is to initiate a counter
                                # to localise which country are we looping around. 
                                country = aux.get_key(self.country_codes, col)
                                for i in range(count,len(df),len(self.country_codes)):
                                        #  Maybe there's some date missing
                                        if df.index[i] in vardf_mean.index:
                                                # Check that it is the appropriate country
                                                for country_row in df.loc[df.index[i], 'iso3'].values:
                                                        if country_row == country:

                                                                df[var_name_mean].iloc[i] = vardf_mean.loc[df.index[i], col] 
                                                                df[var_name_max].iloc[i]  = vardf_max.loc[df.index[i], col] 
                                count +=1

                for var_name in monthly_vars:
                        vardf  = pd.read_csv('data/ready-to-use/' + var_name + '.csv', index_col=0)
                        vardf  = self.set_monthly_to_daily(vardf)
                        var_name = self.set_name_var(var_name)
                        df[var_name] = len(df)*[np.nan]
                        count = 0
                        for col in vardf.columns:
                                if len(vardf.columns) > 1:
                                        # the indexes are repeated in blocks with the countries. What I do here is to initiate a counter
                                        # to localise which country are we looping around. 
                                        country = aux.get_key(self.country_codes, col)
                                        for i in range(count,len(df),len(self.country_codes)):
                                                #  Maybe there's some date missing
                                                if str(df.index[i]) in [str(x)[:10] for x in vardf.index]:
                                                        # Check that it is the appropriate country
                                                        for country_row in df.loc[df.index[i], 'iso3'].values:
                                                                if country_row == country:
                                                                        df[var_name].iloc[i] = vardf.loc[df.index[i], col] 
                                else:
                                        for i in range(count,len(df)):
                                                #  Maybe there's some date missing
                                                if str(df.index[i]) in [str(x)[:10] for x in vardf.index]:
                                                        # Check that it is the appropriate country
                                                        for country_row in df.loc[df.index[i], 'iso3'].values:
                                                                df[var_name].iloc[i] = vardf.loc[df.index[i], col] 
                                
                                count +=1
                aux.save_df(df, 'ALL')
        #def set_complete_dataset(self, country_code=DEFAULT_COUNTRIES) -> None:

        def set_our_df(self, vars=VARS, iso3=ISO3):
                # We load an auxiliary class with functions that are usful to us
                aux = Aux()
                # We construct the initial dataframe that we are gonna fill in
                df  = self.set_iso3(iso3)

                for var_name in vars:
                        # Create the column
                        # Load the df
                        vardf = pd.read_csv('data/ready-to-use/final/' + var_name + '.csv', index_col=0, infer_datetime_format='%Y-%m-%d')
                        # datetime control
                        if type(vardf.index[0]) == str:
                                vardf.index = pd.to_datetime(vardf.index).date
                        # check that all is within our teporal window
                        vardf = vardf.loc[self.t0:self.t1, :]
                        # List with couuntries included in the data
                        vardf_countries = [ aux.get_key(self.country_codes, x) for x in vardf.columns ]
                        print(vardf_countries)
                        # control of whether it's a country-specific stuff
                        fancy_var_name = self.set_name_var(var_name)
                        if vardf_countries != [None]*len(vardf_countries):
                                # construct the column
                                df[fancy_var_name] = len(df)*[np.nan]
                        # TODO: Maybe it would be interesting to add some control here in case our self.t0 is
                        # lower than the first date of our dataset
                        for date_and_country in df.index:
                                # Take date
                                date = date_and_country[0]
                                # Take country
                                country  = date_and_country[1]
                                country  = aux.get_key(self.country_codes, country)
                                # If there's data for this date
                                if date in vardf.index:
                                        if vardf_countries != [None]*len(vardf_countries):
                                                count = 0
                                                for country_col in vardf.columns:
                                                        # Include just the country matched tot he index
                                                        if country == aux.get_key(self.country_codes, country_col) :
                                                                df.loc[date_and_country, fancy_var_name] = vardf.loc[date, country_col]
                                                                count+=1
                                        else:
                                                for var in vardf.columns:
                                                        df.loc[date_and_country, var] = vardf.loc[date, var]
                df = df[:-1]
                aux.save_df(df, 'ALL_NEW')            


if __name__=="__main__":

        t0 = '20190101'
        t1 = '20220309'
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
        myvars = ['PRICES_19_22', 'EPU_19_22', 'OECDplus6_WIP', 'CCI_19_22','GENERATION_BIO_19_22', 'GENERATION_NUC_19_22', 'GENERATION_SUN_19_22', 'GENERATION_WINDONSHORE_19_22', 'GENERATION_WINDOFFSHORE_19_22', 'GENERATION_GAS_19_22', 'GENERATION_COALGAS_19_22','GENERATION_HYDROSTORAGE_19_22', 'GENERATION_OIL_19_22']
        data.set_our_df(myvars)
        #data.set_complete_dataset()

       # 'BIO', 'COALGAS', 'GAS', 'GEO','HARDCOAL', 'HYDRORIVER', 'HYDROSTORAGE', 'MARINE', 'NUC', 'OIL',  
        energies = ['SUN', 'WASTE', 'WINDONSHORE', 'WINDOFFSHORE']    
        # for energy in energies:
        #         data.get_entsoe('generation', day_division, energy)

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
    