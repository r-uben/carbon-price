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

    def __init__(self) -> None:
        self.aux            = Aux()
        self.title          = 'CCI_00_22'
        self.format         = 'csv'
        self.cci_csv        = self.aux.find_file(self.title, self.format)
        self.cci_df         = pd.read_csv(self.cci_csv, sep=',', usecols=['TIME', 'LOCATION', 'VALUE'])
        self.countries      = [
            'OECDE',
            'OECD',
            'G-7',
            'EA19',
            'USA',
            'FRA',
            'GBR',
            'DEU',
            'RUS'
        ]

        self.time   = {}
        self.df     = {}
        self.cci    = pd.DataFrame()
        
    def create_df(self):
        for country in self.countries:
            self.df[country]    = []
            self.time[country]  = []

    def country_value(self, country):
        return country + '_CCI'

    def split_df(self):

        self.create_df()

        for i in self.cci_df.index:
            month   = self.cci_df.loc[i,'TIME']
            country = self.cci_df.loc[i,'LOCATION']
            value   = self.cci_df.loc[i,'VALUE']
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

    def print_df(self):
        self.split_df()
        print(self.cci)
    
    def idx_cci(self):
        self.split_df()
        self.aux.save_df(self.cci, self.title)