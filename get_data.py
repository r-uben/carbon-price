import pandas as pd
import numpy as np
from datetime import datetime as dt
from getters.securities_data  import SecuritiesData

from aux import Aux

### CLASS TO GET DATA OF SOME INDEXES
from getters.idx_cci     import CCIidx
from getters.idx_wip     import WIP
from getters.idx_epu     import EPU

### ENTSOE AND ENTSOG GLASSES
from getters.entsog_getter import EntsogGetter
from getters.entsoe_getter import EntsoeGetter


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
                        'DE'    : ['DE', 'DE_LU', 'DE_LU_Eprice_max', 'DE_LU_Eprice_min'] + ['DE_LU_' + x for x in self.energies] + ['Germany_News_Index', 'DEU_CCI'],
                        'FR'    : ['FR', 'FR_Eprice_max', 'FR_Eprice_min'] + ['FR_' + x for x in self.energies] + ['France_News_Index', 'FRA_CCI'],
                        'IT'    : ['IT', 'IT_NOR', 'IT_CNOR', 'IT_NORD_Eprice_max', 'IT_NORD_Eprice_min'] + ['IT_NORD_' + x for x in self.energies] + ['Italy_News_Index', 'ITA_CCI'],
                        'ES'    : ['ES', 'ES_Eprice_max','ES_Eprice_min', 'ES_OIL'] + ['ES_' + x for x in self.energies] + ['Spain_News_Index', 'ESP_CCI'],
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
        def get_securities_data(self, title=DEFAULT_TITLE, assets=DEFAULT_AP) -> None:
                '''
                TO CONSTRUCT A DATAFRAME WITH DIFFERENT ASSET (FUTURES & STOCK) PRICES
                Source: Bloomberg
                '''
                data = SecuritiesData(file_titles=assets, t0=self.t0, t1=self.t1, csv_title='PRICES')
                data.securities_data(title)

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

