import pandas as pd
from aux import Aux

class EPU(object):


    def __init__(self, init_year) -> None:
        
        self.aux      = Aux()
        self.init_year = str(init_year)
        self.title    = 'EPU_' + str(init_year)[2:4] + '_22'
        self.format   = 'xlsx'
        self.epu_path = self.aux.find_file('Europe_Policy_Uncertainty_Index', self.format)
        self.epu_df   = pd.read_excel(self.epu_path, sheet_name='European News-Based Index')
        self.countries = {
            'EUR' : 'European_News_Index',
            'GER' : 'Germany_News_Index',
            'IT'  : 'Italy_News_Index',
            'UK'  : 'UK_News_Index',
            'FRA' : 'France_News_Index',
            'ESP' : 'Spain_News_Index'
        }

    def fix_index(self):

        new_index = []
        count = 0
        for i in self.epu_df.index:
            year    = str(int(self.epu_df.loc[i,'Year']))
            month   = str(int(self.epu_df.loc[i,'Month']))
            if len(month) == 1:
                month = '0' + month
            date    = year + '-' + month
            if year == self.init_year and count == 0:
                self.init_year = date
                count += 1
            new_index.append(date)
        
        self.epu_df.index = new_index
        self.epu_df       = self.epu_df.drop(['Year', 'Month'], axis = 1)
        self.epu_df       = self.epu_df.loc[self.init_year:,:]



    def idx_epu(self):
        self.fix_index()
        self.aux.save_df(self.epu_df, self.title)