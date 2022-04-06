import pandas as pd
import numpy as np
from aux import Aux

class CCIidx(object):

    '''
        This class constructs a joint dataset of fhe consumer confidence index (CCI) 
        of the countries which are defined within it. However, to adapt this code to 
        different data sets, you just need to change the names and the dates.

        Source: https://data.oecd.org/leadind/consumer-confidence-index-cci.htm
    '''

    def __init__(self, t0, t1) -> None:
        self.aux            = Aux()
        self.title          = 'CCI_14_22'
        self.cci_csv        = self.aux.find_file(self.title, 'csv')
        self.cci_df         = pd.read_csv(self.cci_csv, sep=',', usecols=['TIME', 'LOCATION', 'Value'])

        self.t0             = pd.to_datetime(t0, format='%Y%m%d')
        self.t1             = pd.to_datetime(t1, format='%Y%m%d')
        self.init           = str(self.t0.year)[2:]
        self.ending         = str(self.t1.year)[2:]
        self.title_to_save   = 'CCI_' + self.init + '_' + self.ending

        self.countries      = [
            'OECDE',
            'OECD',
            'G-7',
            'EA19',
            'USA',
            'ESP',
            'FRA',
            'ITA',
            'GBR',
            'DEU',
            'RUS'
        ]

        self.time   = {}
        self.df     = {}
        self.cci    = pd.DataFrame()
        
    def daily(fn):
        def wrap(self: 'WIP', *args, **kwargs):
            result = fn(self,*args,**kwargs)
            start_date  = self.cci.index.min() - pd.DateOffset(day=1)
            end_date    = self.cci.index.max() + pd.DateOffset(day=31)
            dates       = pd.date_range(start_date, end_date, freq='D')
            self.cci    = self.cci.reindex(dates, method='ffill')
            return result
        return wrap

    def create_df(self):
        for country in self.countries:
            self.df[country]    = []
            self.time[country]  = []

    def country_value(self, country):
        return country + '_CCI'

    @daily
    def set_cci_df(self):

        self.create_df()

        for i in self.cci_df.index:
            month   = self.cci_df.loc[i,'TIME']
            country = self.cci_df.loc[i,'LOCATION']
            value   = self.cci_df.loc[i,'Value']
            self.df[country].append(value)
            self.time[country].append(month)

        count = 0
        for country in self.countries:
            self.df[country] = pd.DataFrame(self.df[country], index=self.time[country], columns=[self.country_value(country)])
            if count == 0:
                self.cci = self.df[country]
                count   += 1
            if count == 1:
                self.cci = pd.concat([self.cci, self.df[country]], axis=1)    
        self.cci.index = pd.to_datetime(self.cci.index).date
        self.cci = self.cci.loc[self.t0:self.t1, :]

    def idx_cci(self):
        self.set_cci_df()
        self.aux.save_df(self.cci, self.title_to_save)