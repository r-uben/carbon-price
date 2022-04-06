import pandas as pd
import numpy as np

from aux import Aux
from entsoe import EntsoePandasClient

class EntsoeGetter(object):

    '''
    DE_50HZ =       '10YDE-VE-------2', '50Hertz CA, DE(50HzT) BZA',                    'Europe/Berlin',
    AL =            '10YAL-KESH-----5', 'Albania, OST BZ / CA / MBA',                   'Europe/Tirane',
    DE_AMPRION =    '10YDE-RWENET---I', 'Amprion CA',                                   'Europe/Berlin',
    AT =            '10YAT-APG------L', 'Austria, APG BZ / CA / MBA',                   'Europe/Vienna',
    BY =            '10Y1001A1001A51S', 'Belarus BZ / CA / MBA',                        'Europe/Minsk',
    BE =            '10YBE----------2', 'Belgium, Elia BZ / CA / MBA',                  'Europe/Brussels',
    BA =            '10YBA-JPCC-----D', 'Bosnia Herzegovina, NOS BiH BZ / CA / MBA',    'Europe/Sarajevo',
    BG =            '10YCA-BULGARIA-R', 'Bulgaria, ESO BZ / CA / MBA',                  'Europe/Sofia',
    CZ_DE_SK =      '10YDOM-CZ-DE-SKK', 'BZ CZ+DE+SK BZ / BZA',                         'Europe/Prague',
    HR =            '10YHR-HEP------M', 'Croatia, HOPS BZ / CA / MBA',                  'Europe/Zagreb',
    CWE =           '10YDOM-REGION-1V', 'CWE Region',                                   'Europe/Brussels',
    CY =            '10YCY-1001A0003J', 'Cyprus, Cyprus TSO BZ / CA / MBA',             'Asia/Nicosia',
    CZ =            '10YCZ-CEPS-----N', 'Czech Republic, CEPS BZ / CA/ MBA',            'Europe/Prague',
    DE_AT_LU =      '10Y1001A1001A63L', 'DE-AT-LU BZ',                                  'Europe/Berlin',
    DE_LU =         '10Y1001A1001A82H', 'DE-LU BZ / MBA',                               'Europe/Berlin',
    DK =            '10Y1001A1001A65H', 'Denmark',                                      'Europe/Copenhagen',
    DK_1 =          '10YDK-1--------W', 'DK1 BZ / MBA',                                 'Europe/Copenhagen',
    DK_2 =          '10YDK-2--------M', 'DK2 BZ / MBA',                                 'Europe/Copenhagen',
    DK_CA =         '10Y1001A1001A796', 'Denmark, Energinet CA',                        'Europe/Copenhagen',
    EE =            '10Y1001A1001A39I', 'Estonia, Elering BZ / CA / MBA',               'Europe/Tallinn',
    FI =            '10YFI-1--------U', 'Finland, Fingrid BZ / CA / MBA',               'Europe/Helsinki',
    MK =            '10YMK-MEPSO----8', 'Former Yugoslav Republic of Macedonia, MEPSO BZ / CA / MBA', 'Europe/Skopje',
    FR =            '10YFR-RTE------C', 'France, RTE BZ / CA / MBA',                    'Europe/Paris',
    DE =            '10Y1001A1001A83F', 'Germany',                                      'Europe/Berlin'
    GR =            '10YGR-HTSO-----Y', 'Greece, IPTO BZ / CA/ MBA',                    'Europe/Athens',
    HU =            '10YHU-MAVIR----U', 'Hungary, MAVIR CA / BZ / MBA',                 'Europe/Budapest',
    IS =            'IS',               'Iceland',                                      'Atlantic/Reykjavik',
    IE_SEM =        '10Y1001A1001A59C', 'Ireland (SEM) BZ / MBA',                       'Europe/Dublin',
    IE =            '10YIE-1001A00010', 'Ireland, EirGrid CA',                          'Europe/Dublin',
    IT =            '10YIT-GRTN-----B', 'Italy, IT CA / MBA',                           'Europe/Rome',
    IT_SACO_AC =    '10Y1001A1001A885', 'Italy_Saco_AC',                                'Europe/Rome',
    IT_CALA =   '10Y1001C--00096J', 'IT-Calabria BZ',                                'Europe/Rome',
    IT_SACO_DC =    '10Y1001A1001A893', 'Italy_Saco_DC',                                'Europe/Rome',
    IT_BRNN =       '10Y1001A1001A699', 'IT-Brindisi BZ',                               'Europe/Rome',
    IT_CNOR =       '10Y1001A1001A70O', 'IT-Centre-North BZ',                           'Europe/Rome',
    IT_CSUD =       '10Y1001A1001A71M', 'IT-Centre-South BZ',                           'Europe/Rome',
    IT_FOGN =       '10Y1001A1001A72K', 'IT-Foggia BZ',                                 'Europe/Rome',
    IT_GR =         '10Y1001A1001A66F', 'IT-GR BZ',                                     'Europe/Rome',
    IT_MACRO_NORTH = '10Y1001A1001A84D', 'IT-MACROZONE NORTH MBA',                      'Europe/Rome',
    IT_MACRO_SOUTH = '10Y1001A1001A85B', 'IT-MACROZONE SOUTH MBA',                      'Europe/Rome',
    IT_MALTA =      '10Y1001A1001A877', 'IT-Malta BZ',                                  'Europe/Rome',
    IT_NORD =       '10Y1001A1001A73I', 'IT-North BZ',                                  'Europe/Rome',
    IT_NORD_AT =    '10Y1001A1001A80L', 'IT-North-AT BZ',                               'Europe/Rome',
    IT_NORD_CH =    '10Y1001A1001A68B', 'IT-North-CH BZ',                               'Europe/Rome',
    IT_NORD_FR =    '10Y1001A1001A81J', 'IT-North-FR BZ',                               'Europe/Rome',
    IT_NORD_SI =    '10Y1001A1001A67D', 'IT-North-SI BZ',                               'Europe/Rome',
    IT_PRGP =       '10Y1001A1001A76C', 'IT-Priolo BZ',                                 'Europe/Rome',
    IT_ROSN =       '10Y1001A1001A77A', 'IT-Rossano BZ',                                'Europe/Rome',
    IT_SARD =       '10Y1001A1001A74G', 'IT-Sardinia BZ',                               'Europe/Rome',
    IT_SICI =       '10Y1001A1001A75E', 'IT-Sicily BZ',                                 'Europe/Rome',
    IT_SUD =        '10Y1001A1001A788', 'IT-South BZ',                                  'Europe/Rome',
    RU_KGD =        '10Y1001A1001A50U', 'Kaliningrad BZ / CA / MBA',                    'Europe/Kaliningrad',
    LV =            '10YLV-1001A00074', 'Latvia, AST BZ / CA / MBA',                    'Europe/Riga',
    LT =            '10YLT-1001A0008Q', 'Lithuania, Litgrid BZ / CA / MBA',             'Europe/Vilnius',
    LU =            '10YLU-CEGEDEL-NQ', 'Luxembourg, CREOS CA',                         'Europe/Luxembourg',
    MT =            '10Y1001A1001A93C', 'Malta, Malta BZ / CA / MBA',                   'Europe/Malta',
    ME =            '10YCS-CG-TSO---S', 'Montenegro, CGES BZ / CA / MBA',               'Europe/Podgorica',
    GB =            '10YGB----------A', 'National Grid BZ / CA/ MBA',                   'Europe/London',
    GB_IFA =        '10Y1001C--00098F', 'GB(IFA) BZN',                                  'Europe/London',
    GB_IFA2 =       '17Y0000009369493', 'GB(IFA2) BZ',                                  'Europe/London',
    GB_ELECLINK =   '11Y0-0000-0265-K', 'GB(ElecLink) BZN',                             'Europe/London',
    UK =            '10Y1001A1001A92E', 'United Kingdom',                               'Europe/London',
    NL =            '10YNL----------L', 'Netherlands, TenneT NL BZ / CA/ MBA',          'Europe/Amsterdam',
    NO_1 =          '10YNO-1--------2', 'NO1 BZ / MBA',                                 'Europe/Oslo',
    NO_2 =          '10YNO-2--------T', 'NO2 BZ / MBA',                                 'Europe/Oslo',
    NO_2_NSL =      '10YNO-2--------T', 'NO2 BZ / MBA',                                 'Europe/Oslo',
    NO_3 =          '10YNO-3--------J', 'NO3 BZ / MBA',                                 'Europe/Oslo',
    NO_4 =          '10YNO-4--------9', 'NO4 BZ / MBA',                                 'Europe/Oslo',
    NO_5 =          '10Y1001A1001A48H', 'NO5 BZ / MBA',                                 'Europe/Oslo',
    NO =            '10YNO-0--------C', 'Norway, Norway MBA, Stattnet CA',              'Europe/Oslo',
    PL_CZ =         '10YDOM-1001A082L', 'PL-CZ BZA / CA',                               'Europe/Warsaw',
    PL =            '10YPL-AREA-----S', 'Poland, PSE SA BZ / BZA / CA / MBA',           'Europe/Warsaw',
    PT =            '10YPT-REN------W', 'Portugal, REN BZ / CA / MBA',                  'Europe/Lisbon',
    MD =            '10Y1001A1001A990', 'Republic of Moldova, Moldelectica BZ/CA/MBA',  'Europe/Chisinau',
    RO =            '10YRO-TEL------P', 'Romania, Transelectrica BZ / CA/ MBA',         'Europe/Bucharest',
    RU =            '10Y1001A1001A49F', 'Russia BZ / CA / MBA',                         'Europe/Moscow',
    SE_1 =          '10Y1001A1001A44P', 'SE1 BZ / MBA',                                 'Europe/Stockholm',
    SE_2 =          '10Y1001A1001A45N', 'SE2 BZ / MBA',                                 'Europe/Stockholm',
    SE_3 =          '10Y1001A1001A46L', 'SE3 BZ / MBA',                                 'Europe/Stockholm',
    SE_4 =          '10Y1001A1001A47J', 'SE4 BZ / MBA',                                 'Europe/Stockholm',
    RS =            '10YCS-SERBIATSOV', 'Serbia, EMS BZ / CA / MBA',                    'Europe/Belgrade',
    SK =            '10YSK-SEPS-----K', 'Slovakia, SEPS BZ / CA / MBA',                 'Europe/Bratislava',
    SI =            '10YSI-ELES-----O', 'Slovenia, ELES BZ / CA / MBA',                 'Europe/Ljubljana',
    GB_NIR =        '10Y1001A1001A016', 'Northern Ireland, SONI CA',                    'Europe/Belfast',
    ES =            '10YES-REE------0', 'Spain, REE BZ / CA / MBA',                     'Europe/Madrid',
    SE =            '10YSE-1--------K', 'Sweden, Sweden MBA, SvK CA',                   'Europe/Stockholm',
    CH =            '10YCH-SWISSGRIDZ', 'Switzerland, Swissgrid BZ / CA / MBA',         'Europe/Zurich',
    DE_TENNET =     '10YDE-EON------1', 'TenneT GER CA',                                'Europe/Berlin',
    DE_TRANSNET =   '10YDE-ENBW-----N', 'TransnetBW CA',                                'Europe/Berlin',
    TR =            '10YTR-TEIAS----W', 'Turkey BZ / CA / MBA',                         'Europe/Istanbul',
    UA =            '10Y1001C--00003F', 'Ukraine, Ukraine BZ, MBA',                     'Europe/Kiev',
    UA_DOBTPP =     '10Y1001A1001A869', 'Ukraine-DobTPP CTA',                           'Europe/Kiev',
    UA_BEI =        '10YUA-WEPS-----0', 'Ukraine BEI CTA',                              'Europe/Kiev',
    UA_IPS =        '10Y1001C--000182', 'Ukraine IPS CTA',                              'Europe/Kiev',
    XK =            '10Y1001C--00100H', 'Kosovo/ XK CA / XK BZN',                       'Europe/Rome'
    '''

    DAY_DIVISION = 'hourly'
    ENERGY_CODE  = 'SUN'

    def __init__(self, t0, t1, country_codes) -> None:

        self.aux        = Aux()
        self.country_codes = country_codes
        self.t0: str    = t0
        self.t1: str    = t1
        self.init: str  = t0
        self.ending: str = t1
        self.start      = pd.Timestamp(t0, tz='Europe/Brussels')
        self.end        = pd.Timestamp(t1, tz='Europe/Brussels')
        self.client     = EntsoePandasClient(api_key='c7f6fea4-4222-4c61-a6a8-4a23ac1f1a7d')
        self.df         = {}
        self.energy_zip = {
            'BIO'           : 'Biomass',
            'COALGAS'       : 'Fossil Coal-derived gas',
            'GAS'           : 'Fossil Gas',
            'HARDCOAL'      : 'Fosil Hard coal',
            'OIL'           : 'Fossil Oil',
            'GEO'           : 'Geothermal',
            'HYDROSTORAGE'  : 'Hydro Pumped Storage',
            'HYDRORIVER'    : 'Hydro Run-of-river and poundage',
            'HYDRORESERVOIR': 'Hydro Water Reservoir',
            'MARINE'        : 'Marine',
            'NUC'           : 'Nuclear',
            'SUN'           : 'Solar',
            'WASTE'         : 'Waste',
            'WINDONSHORE'   : 'Wind Onshore',
            'WINDOFFSHORE'  : 'Wind Offshore'            
        }
        self.day_division = {
            'hourly'    : 1,
            'half'      : 2,
            'quarterly' : 4
        }
        self.time_index: list =  []

    def formatted_date(fn):
        '''
            This function takes initial and end dates as a string and updates them to 
            a format %Y-%m-%d (year, month, date)
        '''
        def wrap(self: 'EntsoeGetter', *args, **kwargs):
            if len(str(self.t0)) == 4:
                    self.t0 = int(str(self.t0) + '0101')
                    self.t1 = int(str(self.t1) + '0101')
            self.t0         = pd.to_datetime(self.t0, format='%Y%m%d')
            self.init       = str(self.t0.year)[2:]
            self.t1         = pd.to_datetime(self.t1, format='%Y%m%d')
            self.ending     = str(self.t1.year)[2:]
            self.time_index = pd.date_range(self.t0, self.t1, freq='D').date
            return fn(self, *args, *kwargs)
        return wrap

    def set_header(self, country_code, header):
        return country_code + '_' + header

    def set_df(self, country_code, method):
        if method == 'prices':
            df = self.client.query_day_ahead_prices(country_code, start=self.start, end=self.end)
        if method == 'generation':
            df = self.client.query_generation(country_code, start= self.start, end = self.end)
        if method == 'green':
            df = self.client.query_wind_and_solar_forecast(country_code, start=self.start, end=self.end)
        if method == 'imbalance_prices':
            df = self.client.imbalance_prices(country_code, start=self.start, end=self.end)
        if method == 'generation_per_plant':
            df = self.client.query_generation_per_plant(country_code, start=self.start, end=self.end)
        if method == 'import':
            df = self.client.query_import(country_code, start=self.start, end=self.end)
        return df

    def set_col(self, energy, type):
        return (energy, type)

    def set_title(self, title):
        '''
            This function sets the format of our title where the date is included
            just by referring to the last two digits of the year
        '''
        return title + '_' + self.init + '_' + self.ending

    def set_daily_index(self, df):
        df.index = pd.to_datetime(df.index)
        df       = df.groupby(pd.Grouper(freq='D', level=0)).sum()
        ## Take date as our index
        df.index = df.index.date
        # Just in case there have been more dates that have been added
        df       = df.loc[self.t0:self.t1, :]
        return df

    @formatted_date
    def set_df_of_generation(self, energy_code=ENERGY_CODE, day_division=DAY_DIVISION):
        '''
            This function saves a dataframe with the generation of electircity (by country and kind of energy).
        '''
        ## dataframe which is gonna be constructed
        df = {}
        ## indicator for the time-division of the day: it can be quarterly (q=4, each 15min),
        ## hourly (q=1, each hour) or half hour (q=2, each 30min).
        q = self.day_division[day_division]
        ## energy generation (kWh) to be added
        energy = self.energy_zip[energy_code]
        ## we start the loop among all the countries that are gonna be added
        for country_code in self.country_codes:
            ## df of all generation for each country
            country_specific_df = self.set_df(country_code, 'generation')
            ## is the energy to be added within the generation data of the country that
            ## are we scrapping in this loop?
            if energy in [x[0] for x in country_specific_df.columns]:
                ## if yes, we take the specific column 
                col                 = self.set_col(energy, 'Actual Aggregated')
                if col in country_specific_df:
                    ## if the column belongs also the the country-specific-df, then re-name
                    ## the column with a better understandable name
                    col_to_save         = self.set_header(country_code, energy_code)
                    ## save the column
                    df[col_to_save] = country_specific_df.loc[:, col]
        ## Join everything with a function that sorts differences among df
        #self.aux.save_df(pd.DataFrame(df), 'whathappens1')
        df = self.aux.concatenate_weird_df(df)
        ## Convert hourly to daily
        df = self.set_daily_index(df)
        ## Save the dataframe
        self.aux.save_df(df, self.set_title('GENERATION_' + energy_code))

    @formatted_date
    def set_df_of_prices(self):
        df = {}
        count = 0
        for country_code in self.country_codes:
            country_specific_df = self.set_df(country_code, 'prices')
            header              = self.set_header(country_code, 'Eprice')
            df[header]          = country_specific_df.iloc[:]
        df = self.aux.concatenate_weird_df(df)
        # Convert hourly to daily
        df = self.set_daily_index(df)
        # Save dataframe
        self.aux.save_df(df, self.set_title('ELECTRICITYPRICES_'))

    def set_df_of_green_forecast(self):
        df = {}
        for country_code in self.country_codes:
            country_specific_df = self.set_df(country_code, 'green')
            header              = self.set_header(country_code, 'Egreen')
            for col in df.columns:
                df[header]          = country_specific_df.loc[:, col]
        df      = self.aux.concatenate_weird_df(df)
        self.aux.save_df(df, self.set_title('GENERATIONGREEN'))

    def entsoe_getter(self, param, energy_code=ENERGY_CODE, day_division=DAY_DIVISION):
        param = param.lower().replace(' ', '_')
        if param == 'prices':
            self.set_df_of_prices()
        if param == 'generation':
            self.set_df_of_generation(energy_code, day_division)
        if param == 'green':
            self.set_df_of_green_forecast()
