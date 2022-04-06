from unicodedata import name
import pandas as pd
from aux import Aux

class WIP():

    def __init__(self, t0, t1) -> None:
        self.aux = Aux()
        self.title      = 'OECDplus6_WIP'
        self.wip        = 'OECD+6NME industrial production'
        self.wip_to_call= 'OECD_plus6_industrial_production'
        name            = self.aux.find_file(self.wip_to_call, 'xlsx')
        self.wip_df     = pd.read_excel(name, sheet_name='world_IP', index_col=0)

        self.t0         = pd.to_datetime(t0, format='%Y%m%d').date()
        self.t1         = pd.to_datetime(t1, format='%Y%m%d').date()

    def daily(fn):
        def wrap(self: 'WIP', *args, **kwargs):
            result = fn(self,*args,**kwargs)
            start_date  = self.wip_df.index.min() - pd.DateOffset(day=1)
            end_date    = self.wip_df.index.max() + pd.DateOffset(day=31)
            dates       = pd.date_range(start_date, end_date, freq='D')
            self.wip_df = self.wip_df.reindex(dates, method='ffill')
            return result
        return wrap
    
    @daily
    def set_wip_df(self):
        self.wip_df.index =  pd.to_datetime(self.wip_df.index, format='%Y%m%d').date
        #self.wip_df.index.name = None
        self.wip_df.columns = [self.title]
        self.wip_df.index = pd.to_datetime(self.wip_df.index).date
    


    def idx_wip(self):
        self.set_wip_df()
        self.wip_df = self.wip_df.loc[self.t0:self.t1,:]
        self.aux.save_df(self.wip_df, self.title)