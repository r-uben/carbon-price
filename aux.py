import pandas as pd

class Aux():

    def find_file(self, name, type):
        if type == 'xlsx':
            return "data/raw_files/" + name + ".xlsx"
        if type == 'csv':
            return "data/raw_files/" + name + ".csv"

    def save_df(self, df, name):
        df.to_csv('data/ready-to-use/final/'+ name + '.csv')
        

    def concatenate_weird_df(self, df):
        return pd.DataFrame(dict([(k, v) for k,v in df.items()]))

    def get_key(self, my_dict, val):
        for key, value in my_dict.items():
            if val in value:
                return key
        return None