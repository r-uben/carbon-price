import pandas as pd
from aux import Aux

class EPU(object):


    def __init__(self, t0, t1) -> None:
        
        self.aux        = Aux()
        self.t0         = pd.to_datetime(t0, format='%Y%m%d')
        self.t1         = pd.to_datetime(t1, format='%Y%m%d')
        self.t0_year    = str(self.t0.year) 
        self.t1_year    = str(self.t1.year) 
        self.title     = 'EPU_' + self.t0_year[2:4] + '_' + self.t1_year[2:4]

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

    def daily(fn):
        def wrap(self: 'EPU', *args, **kwargs):
            result = fn(self,*args,**kwargs)
            start_date  = self.epu_df.index.min() - pd.DateOffset(day=1)
            end_date    = self.epu_df.index.max() + pd.DateOffset(day=31)
            dates       = pd.date_range(start_date, end_date, freq='D')
            self.epu_df = self.epu_df.reindex(dates, method='ffill')
            return result
        return wrap

    @daily
    def set_epu_df(self):
        new_index = []
        print(self.epu_df.index)
        for i in self.epu_df.index:
            year    = str(int(self.epu_df.loc[i,'Year']))
            month   = str(int(self.epu_df.loc[i,'Month']))
            if len(month) == 1:
                month = '0' + month
            date    = year + month + '01'
            new_index.append(date)

        self.epu_df.index = new_index
        self.epu_df       = self.epu_df.drop(['Year', 'Month'], axis = 1)
        self.epu_df.index = pd.to_datetime(self.epu_df.index).date
 

    def idx_epu(self):
        self.set_epu_df()
        self.epu_df       = self.epu_df.loc[self.t0:self.t1,:]
        self.aux.save_df(self.epu_df, self.title)