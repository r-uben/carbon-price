import pandas as pd

class CleanData(object):

    def __init__(self, file_titles, init_date, end_date, csv_title):

        self.csv_title   = csv_title
        self.file_titles = file_titles
        self.init_date   = init_date
        self.init_year   = init_date[:4]
        self.end_date    = end_date
        self.end_year    = end_date[:4]
        self.columns     = []
        self.dfs = {}
        self.df = pd.DataFrame()


    def find_file(self, name, type):
        if type == 'xlsx':
            return "data/raw_files/" + name + ".xlsx"

    def read_data(self):
        for title in self.file_titles:
            df = pd.read_excel(self.find_file(title, 'xlsx'), sheet_name="Worksheet", index_col=None, na_values=['NA'], usecols="A,B", names=["Date", "PX_LAST"],dtype=str)
            df = self.set_date_as_index(df)
            new_title = self.set_col_title(title)
            self.columns.append(new_title)
            df = df.rename(columns={'PX_LAST': new_title})
            df = self.set_window(df)
            self.dfs[new_title] = df[new_title].tolist()

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

    def set_window(self, df):
        self.idx = pd.date_range(self.init_date, self.end_date)[::-1]
        init = 0
        end  = 0
        dates = df.index.tolist()
        to_drop = []
        for date in dates:
            year = int(date[:4])
            if year == int(self.end_year) and init == 0:
                i = dates.index(date)   
                dates = dates[i:]
                to_drop = to_drop + dates[:i]
                init = 1
            if year == int(self.init_year) and end == 0:
                i = dates.index(date)
                dates = dates[:i]
                to_drop = to_drop + dates[:i]
                end = 1
        df = df.loc[to_drop]
        df.index = pd.DatetimeIndex(df.index)
        df = df.reindex(self.idx, fill_value = 0)
        return df

    def join_all(self):
        self.df = pd.DataFrame(self.dfs, columns=self.columns, index=self.idx)
        print(self.df)

    def save_df(self):
        self.df.to_csv('data/'+self.csv_title + '.csv')

    def CleanData(self):
        self.read_data()
        self.join_all()
        self.save_df()