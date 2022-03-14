import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
import matplotlib.dates as mdates





class PlotPrices(object):

    def __init__(self, df, lastNdays = 0, name = 'default', linewidth = 1,  format = 'eps', dpi = 100):

        self.dpi = dpi
        self.linewidth = linewidth
        self.format = format

        if lastNdays == 0:
            self.df     = df
            # Replace zeros with NaNs
            self.df.replace(0, np.nan, inplace=True)
        else:
            self.df     = df.iloc[:lastNdays]
            # Replace zeros with NaNs
            self.df.replace(0, np.nan, inplace=True)
        # Columns
        self.cols   = self.df.columns.tolist()
        #
        self.T      = self.df.index.tolist()
        self.name   = name

    def get_name(self, name):
        names = {
            'ICEDEU3'               : 'EUA Futures (EUR)',
            'CO1COMDTY'             : 'Generic 1st, Brent Future (EUR)',
            'CLJ2COMBCOMDTY'        : 'WTI Crude Oil Future, Apr22 (EUR',
            'GASEUEQUITY'           : 'Naturgy Energy Group SA, Gas equity (EUR)',
            'WK2COMBCOMDTY'         : 'Wheat Futures (EUR)',
            'GT1CDEGSACT24AVINEXMW' : 'Germany Gas Index',
            'GFRURUEUINDEX'         : 'Gas supply from Rusia',
            'EGTPNTRNINDEX'         : 'Russia Gas Flow (MCM/D)'
        }
        return names[name]

    def get_relevant_dates(self):
        self.init_year  = int(self.T[-1][:4])
        self.init_month = int(self.T[-1][5:7])
        self.init_day   = int(self.T[-1][8:10])
        self.end_year   = int(self.T[0][:4])
        self.end_month  = int(self.T[0][5:7])
        self.end_day    = int(self.T[0][8:10])

    def get_vector_prices(self, i):
        prices = self.df[self.cols[i]]
        prices = prices[::-1]
        return prices

    def plot_prices(self):
        # See: https://stackoverflow.com/questions/30146921/matplotlib-adjusting-date-spacing-on-the-x-axis
        # See: https://stackoverflow.com/questions/6390393/matplotlib-make-tick-labels-font-size-smaller
        fig, axs = plt.subplots(len(self.cols), figsize=(16,20), dpi=2000)
        for i in range(len(self.cols)):
            prices = self.get_vector_prices(i)
            ax = axs[i]
            ax.grid(True, linewidth=0.7, linestyle='--')
            ax.xaxis.set_major_locator(mdates.WeekdayLocator(byweekday=3, interval=2))
            ax.xaxis.set_minor_locator(mdates.WeekdayLocator(byweekday=3, interval=2))
            ax.tick_params(axis='both', which='major', labelsize=12)
            ax.tick_params(axis='both', which='minor', labelsize=12)
            ax.plot(prices, linewidth=self.linewidth, color="darkred", label=self.get_name(self.cols[i]))
            ax.legend(loc="upper left", fontsize=10)
            fig.autofmt_xdate()
        if self.name != 'default':
            plt.savefig('figures/' + self.name + "." + self.format, format= self.format)
        else:
            plt.show()
