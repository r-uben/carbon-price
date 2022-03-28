from unicodedata import name
import pandas as pd
from aux import Aux

class WIP():

    def __init__(self, init_year) -> None:
        self.aux = Aux()
        self.title      = 'OECDplus6_WIP'
        self.wip        = 'OECD+6NME industrial production'
        self.wip_to_call= 'OECD_plus6_industrial_production'
        name            = self.aux.find_file(self.wip_to_call, 'xlsx')
        self.df         = pd.read_excel(name, sheet_name='world_IP')
        self.init_year  = init_year

    def monthly_index(self):
        new_index = []
        count = 0
        for date in self.df.index:
            new_month = str(date)[:7]
            new_index.append(new_month)
            if float(str(date)[:4]) == self.init_year and count == 0:
                self.init_year = new_month
                count+=1
        self.df.index = new_index

    def fancier_df(self):
        self.df = self.df.set_index(self.df.iloc[:,0])
        self.df = self.df.loc[:, self.wip].to_frame()
        self.df.index.name = None
        self.df.columns = [self.title]
        self.monthly_index()
        self.df = self.df.loc[self.init_year:, :]

    def print_df(self):
        self.fancier_df()
        print(self.df)

    def idx_wip(self):
        self.fancier_df()
        self.aux.save_df(self.df, self.title)