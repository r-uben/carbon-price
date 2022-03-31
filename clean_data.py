import pandas as pd
from aux import Aux
import numpy as np

class CleanData(object):

    def __init__(self, file_titles, init_date, end_date, csv_title):
        self.aux = Aux()
        self.csv_title   = csv_title
        self.file_titles = file_titles
        self.init_date   = init_date
        self.init_year   = init_date[:4]
        self.end_date    = end_date
        self.end_year    = end_date[:4]
        self.columns     = []
        self.dfs = {}
        self.df = pd.DataFrame()


    def read_data(self):
        for title in self.file_titles:
            file = self.aux.find_file(title, 'xlsx')
            df = pd.read_excel(file, sheet_name="Worksheet", index_col=None, na_values=['NA'], usecols="A,B", names=["Date", "PX_LAST"],dtype=str)
            df = self.set_date_as_index(df)
            new_title = self.set_col_title(title)
            self.columns.append(new_title)
            df = df.rename(columns={'PX_LAST': new_title})
            self.dfs[new_title] = df.loc[:,new_title]
        self.df = self.aux.concatenate_weird_df(self.dfs)
        self.df = self.df[::-1]

    def set_date_as_index(self, df):
        if "Date" in df.columns.tolist():
            df.loc[:, "Date"] = df["Date"].str.slice(0,10).tolist()
            df = df.set_index("Date")
            df = df.rename_axis(index=None, columns=None)
            df = df.astype(float)
            return df
        else:
            return 'Please, add a temporal column'

    def set_col_title(self, title):
        title = title[:-5]
        title = title.replace("_EUR_", "").replace("_DOLAR_", "").replace("_","")
        return title

    def set_name(self, title):
        return self.csv_title + title + '_' + self.init_year[2:4] + '_' + self.end_year[2:4]

    def CleanData(self, title):
        self.read_data()
        self.aux.save_df(self.df, self.set_name(title))