import pandas as pd

class Aux():

    def find_file(self, name, type):
        if type == 'xlsx':
            return "data/raw_files/" + name + ".xlsx"
        if type == 'csv':
            return "data/raw_files/" + name + ".csv"

    def save_df(self, df, name):
        df.to_csv('data/ready-to-use/'+ name + '.csv')

    def set_header(self, country_code, header):
        return country_code + '_' + header

    def concatenate_weird_df(self, df):
        return pd.DataFrame(dict([(k, pd.Series(v)) for k,v in df.items()]))