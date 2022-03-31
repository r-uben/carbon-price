
from clean_data  import CleanData
from plot_prices import PlotPrices

### CLASS TO GET DATA OF SOME INDEXES
from idx_cci     import CCIidx
from idx_wip     import WIP
from idx_epu     import EPU

### ENTSOE AND ENTSOG GLASSES
from entsog_getter import EntsogGetter
from entsoe_getter import EntsoeGetter

from pathlib import Path


# def take_only_year(self) -> None:
#                 if len(str(self.t0)) > 4:
#                         self.t0 = int(str(self.t0)[:4])

#         def check_if_complete_date(self) -> None:
#                 if len(str(self.t0)) == 4:
#                         self.t0 = int(str(self.t0) + '0101')
#                         self.t1 = int(str(self.t1) + '0101')

def tex_file(title):
        return "results/" + title + ".txt"


def create_txt(title, text):
        file    = Path(tex_file(title))
        file.write_text(f"{text}")

class GetData(object):

        DEFAULT_COUNTRIES  = ['DE_LU', 'FR', 'IT_NORD', 'ES']
        DEFAULT_PARAM      = 'prices'
        DETAULT_ENERGY     = 'COALGAS'
        DEFAULT_AP         = ["ICEDEU3_EUR_12_22", 'CO1COMDTY_EUR_10_22', 'GASEUEQUITY_EUR_10_22', 'WK2COMBCOMDTY_19_22']

        def __init__(self, t0, t1) -> None:
                self.t0: str = t0
                self.t1: str = t1
                
        # Decorator to write the date correctly
        def only_the_year(fn):
                def wrap(self: 'GetData', *args, **kwargs):
                        # This function receives the input of the function that it's decorating
                        # *args: all the positional parameters
                        # **kwargs: additional parameters bt kewyword (dictionary).
                        if len(self.t0) > 4:
                                self.t0 = int(str(self.t0)[:4])
                        result = fn(self, *args, *kwargs)
                        return result
                return wrap

        def complete_date(fn):
                def wrap(self: 'GetData', *args, **kwargs):
                        # This function receives the input of the function that it's decorating
                        # *args: all the positional parameters
                        # **kwargs: additional parameters bt kewyword (dictionary).
                        if len(str(self.t0)) == 4:
                                self.t0 = int(str(self.t0) + '0101')
                                self.t1 = int(str(self.t1) + '0101')
                        result = fn(self, *args, *kwargs)
                        return result
                return wrap

        def formatted_date(fn):
                def wrap(self: 'GetData', *args, **kwargs):
                        # This function receives the input of the function that it's decorating
                        # *args: all the positional parameters
                        # **kwargs: additional parameters bt kewyword (dictionary).
                        if len(str(self.t0)) == 4:
                                self.t0 = int(str(self.t0) + '0101')
                                self.t1 = int(str(self.t1) + '0101')
                        self.t0 = self.t0[:4] + '-' + self.t0[4:6] + '-' + self.t0[6:8]
                        self.t1 = self.t1[:4] + '-' + self.t1[4:6] + '-' + self.t1[6:8] 
                        result = fn(self, *args, *kwargs)
                        return result
                return wrap

        @formatted_date
        def get_asset_prices(self, title, assets=DEFAULT_AP) -> None:
                '''
                TO CONSTRUCT A DATAFRAME WITH DIFFERENT ASSET (FUTURES & STOCK) PRICES
                Source: Bloomberg
                '''
                data = CleanData(file_titles=assets, init_date=self.t0, end_date=self.t1, csv_title='ASSETPRICES')
                data.CleanData(title)

        @only_the_year 
        def get_cci(self) -> None:
                '''
                TO CONSTRUCT A DATAFRAME WITH THE CONSUMER CONFIDENCE INDEX (CCI)
                Source: https://data.oecd.org/leadind/consumer-confidence-index-cci.htm
                '''
                cci = CCIidx()
                cci.idx_cci()
        
        @only_the_year 
        def get_wip(self) -> None:
                '''
                TO CONSTRUCT A DATA FRAME WITH THE WORLD INDUSTRY PRODUCTION INDEX (WIP)
                Source: https://sites.google.com/site/cjsbaumeister/research
                '''
                # self.take_only_year()
                wip = WIP(init_year=self.t0)
                wip.idx_wip()
        
        @only_the_year 
        def get_epu(self) -> None:
                '''
                TO CONSTRUCT A DATA FRAME WITH THE EUROPEAN POLICY UNCERTAINTY INDEX (EPU)
                Source: https://www.policyuncertainty.com/europe_monthly.html
                '''
                epu = EPU(init_year=self.t0)
                epu.idx_epu()

        @complete_date
        def get_entsoe(self, param=DEFAULT_PARAM, energy=DETAULT_ENERGY, country_codes=DEFAULT_COUNTRIES) -> None:
                entsoe = EntsoeGetter(country_codes=country_codes, start=self.t0, end=self.t1)
                entsoe.entsoe_getter(param, energy)

        @complete_date
        def get_entsog(self, country_codes=DEFAULT_COUNTRIES) -> None:
                entsog = EntsogGetter(country_codes=country_codes, start=self.t0, end=self.t1)
                entsog.entsog_getter()


if __name__=="__main__":

        t0 = '20190412'
        t1 = '20220309'
        data = GetData(t0=t0, t1=t1)
        data.get_asset_prices('1')

        # data.get_entsog(['ES', 'IT'])
        #data.get_entsoe('generation', 'SUN')
        #data.get_entsoe('generation', 'WINDONSHORE')
        #data.get_entsoe('generation', 'WINDOFFSHORE')
        #data.get_entsoe('generation', 'HARDCOAL')
        #data.get_entsoe('generation', 'MARINE')
        #data.get_entsoe('generation', 'HYDROSTORAGE')
        #data.get_entsoe('generation', 'HYDRORIVER')

        # start = pd.Timestamp('20171201', tz='Europe/Brussels')
        # end = pd.Timestamp('20220320', tz='Europe/Brussels')
        # country_code = 'DE'  # Belgium
        # #df = client.query_aggregated_data(start=start, end=end, country_code=country_code)
        # df = client.query_aggregated_data(start = start, end = end, country_code=country_code)
        # print(df.columns)
        # print(df[['year', 'month', 'day', 'value']])
        #pow_gen.power_generation()
        # 'DE_GASPOOL', 'DE_NCG', 'UK', 'ES', 'IT', 'PL', 'EE_LV', 'UA'
        # country_codes = ['DE']
        # indicators= ['GCV']
        #entsog = EntsogGetter(start=20220101,end=20220106, country_codes=country_codes, indicators=indicators)
        # entsog.entsog_getter()


    # df = pd.read_csv('data/1st_df.csv', index_col=[0])
    # df1 = df.copy()

    #plt = PlotPrices(df=df1, lastNdays=150, name='1st_df_last150days_prices', format='eps', linewidth=0.8, dpi=700)
    #plt.plot_prices()

    # plt = PlotPrices(df=df1, lastNdays=90, name='1st_df_last90days_prices', format='png', dpi=100)
    # plt.plot_prices()

    #cols = df.columns.tolist()
    #idx  = df.columns.tolist()
    #print(df)
#     d = {
#         'eua_futures':  cols[0],
#         'brent':        cols[1],
#         'crude_oil':    cols[2],
#         'gas':          cols[3],
#         'wheat':        cols[4],
#         'germ_gas':     cols[5]
#     }

#     selection = [d['brent'], d['crude_oil'], d['gas'], d['wheat'], d['germ_gas']]

#     X    = df[selection] 
#     y    = df[d['eua_futures']]
#     reg = sm.OLS(y.astype(float), X.astype(float)).fit(cov_type='HAC', cov_kwds={'maxlags':12}) 
#     sum = summary_col(results=reg, float_format='%0.2f', stars=True, info_dict=None,  drop_omitted=True)
#     tex    = sum.as_latex()
#     create_txt('since2019-reg', tex)
#     print()
#     print("###################")
#     print("SINCE 2019")
#     print(sum)

#     df2  = df.iloc[:150]
#     X    = df2[selection] 
#     y    = df2[d['eua_futures']]
#     reg = sm.OLS(y.astype(float), X.astype(float)).fit(cov_type='HAC', cov_kwds={'maxlags':12}) 
#     sum = summary_col(results=reg, float_format='%0.2f', stars=True, info_dict=None,  drop_omitted=True)
#     tex    = sum.as_latex()
#     create_txt('last150days-reg', tex)
#     print()
#     print("###################")
#     print("LAST 150 DAYS")
#     print(sum)

#     df2  = df.iloc[:60]
#     X    = df2[selection] 
#     y    = df2[d['eua_futures']]
#     reg = sm.OLS(y.astype(float), X.astype(float)).fit(cov_type='HAC', cov_kwds={'maxlags':12}) 
#     sum = summary_col(results=reg, float_format='%0.2f', stars=True, info_dict=None,  drop_omitted=True)
#     tex    = sum.as_latex()
#     print()
#     print("###################")
#     print("LAST 60 DAYS")
#     create_txt('last60days-reg', tex)
#     print(sum)
    