import pandas as pd
from aux import Aux
import numpy as np

class SecuritiesData(object):

    def __init__(self, file_titles, t0, t1, csv_title):
        self.aux = Aux()
        self.csv_title   = csv_title
        self.file_titles = file_titles
        self.t0   = pd.to_datetime(t0, format='%Y%m%d').date()
        self.t0_year   = str(self.t0.year)
        self.t1    = pd.to_datetime(t1, format='%Y%m%d').date()
        self.t1_year    = str(self.t1.year)
        self.columns     = []
        self.dfs = {}
        self.df = pd.DataFrame()
        self.headers = {
            'WK2COMBCOMDTY'         : 'futWHEAT',
            'GFRURUEUINDEXMILLM3'   : 'gasflowRUStoDE',
            'ICEDEU3'               : 'futEUA',
            'CO1COMDTY'             : 'futBRENT',
            'CLJ2COMBCOMDTY'        : 'futWIT',   
            'GASEUEQUITY'           : 'eqGAS'
        }
    
    def set_date_as_index(self, df):
        if "Date" in df.columns:
            df = df.set_index("Date")
            df = df.rename_axis(index=None, columns=None)
            if type(df.index[0]) == str:
                df.index = pd.to_datetime(df.index).date 
            df = df.astype(float)
            return df
        else:
            return 'Please, add a temporal column'

    def set_col_title(self, title):
        title = title[:-5]
        title = title.replace("_EUR_", "").replace("_DOLAR_", "").replace("_","")
        return title

    def set_name(self, title):
        return self.csv_title + title + '_' + self.t0_year[2:4] + '_' + self.t1_year[2:4]

    def set_df(self):
        for title in self.file_titles:
            file = self.aux.find_file(title, 'xlsx')
            df = pd.read_excel(file, sheet_name="Worksheet", index_col=None, na_values=['NA'], usecols="A,B", names=["Date", "PX_LAST"],dtype=str)
            df = self.set_date_as_index(df)
            new_title = self.headers[self.set_col_title(title)]
            self.columns.append(new_title)
            df = df.rename(columns={'PX_LAST': new_title})
            self.dfs[new_title] = df.loc[:,new_title]
        self.df = self.aux.concatenate_weird_df(self.dfs)  
        self.df.index = pd.to_datetime(self.df.index).date
        self.df = self.df.loc[self.t0:self.t1,:]

    def securities_data(self, title):
        self.set_df()
        self.aux.save_df(self.df, self.set_name(title))