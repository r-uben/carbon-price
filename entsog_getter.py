import pandas as pd 
from entsog.entsog import EntsogPandasClient
from aux import Aux


class EntsogGetter(object):


    def __init__(self, start, end, country_codes, indicators) -> None:
        self.aux = Aux()
        self.start  = self.appropriate_timer(start)
        self.end    = self.appropriate_timer(end)
        self.client = EntsogPandasClient()
        self.country_codes  = country_codes
        self.indicators     = indicators
        self.df = {}
        
    def appropriate_timer(self, time):
        year    = int(str(time)[:4])
        month   = int(str(time)[4:6])
        day     = int(str(time)[6:8])
        return pd.Timestamp(year, month, day)

    def get_df(self, country):
        df = self.client.query_operational_data(start = self.start, end = self.end, country_code = country, indicators = self.indicators)
        #df = df[['id', 'period_from', 'period_to', 'point_type', 'id_point_type', 'is_archived']]
        return df

    def entsog_getter(self):
        for country_code in self.country_codes:
            self.df[country_code] = self.get_df(country_code)
            self.aux.save_df(self.df[country_code], 'proof')