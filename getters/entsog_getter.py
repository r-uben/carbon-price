import pandas as pd 
from entsog.entsog import EntsogPandasClient
from aux import Aux


class EntsogGetter(object):


    def __init__(self, start, end, country_codes) -> None:
        self.aux = Aux()
        self.t0         = str(start)[2:4]
        self.t1         = str(end)[2:4]
        self.start  = self.appropriate_timer(start)
        self.end    = self.appropriate_timer(end)
        self.client = EntsogPandasClient()
        self.country_codes  = country_codes

        self.df = {}

    def set_header(self, country_code, header):
        return country_code + '_' + header
    
    def set_title(self, title):
        return title + '_' + self.t0 + '_' +self.t1
        
    def appropriate_timer(self, time):
        year    = int(str(time)[:4])
        month   = int(str(time)[4:6])
        day     = int(str(time)[6:8])
        return pd.Timestamp(year, month, day)

    def set_df_of_physical_flow(self):
        columns = ['indicator', 'operator_key', 'direction_key', 'year', 'month', 'day', 'unit', 'value']
        for country_code in self.country_codes:
            df = {}
            country_specific_df = self.client.query_aggregated_data(start=self.start, end=self.end, country_code=country_code)
            for col in columns:
                header              = self.set_header(country_code, col)
                df[header]          = country_specific_df.loc[:,col]
            df = pd.DataFrame(df)
            self.aux.save_df(df, self.set_title('GASFLOW' + '_' + country_code))

    def entsog_getter(self):
        self.set_df_of_physical_flow()