import pandas as pd
from aux import Aux
class PowerGeneration(object):

    def __init__(self) -> None:
        self.aux = Aux()
        self.countries = [
            'DE_LU',
            'ES',
            'FR',
            'IT_NORD',
            'NO_1',
            'NO_2',
            'NO_3',
            'NO_4',
            'NO_5'
        ]

        self.dfs = {}
        for country in self.countries:
            name = 'generation' + country
            path = self.aux.find_file(name, 'csv')
            self.dfs[country] = pd.read_csv(path)

    def power_generation(self):
        
        print(self.dfs['ES'])