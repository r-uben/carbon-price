from entsoe import EntsoePandasClient
import pandas as pd

client = EntsoePandasClient(api_key='c7f6fea4-4222-4c61-a6a8-4a23ac1f1a7d')

start = pd.Timestamp('20000101', tz='Europe/Brussels')
end = pd.Timestamp('20220320', tz='Europe/Brussels')
country_code = 'BE'  # Belgium
country_code_from = 'FR'  # France
country_code_to = 'DE_LU' # Germany-Luxembourg
type_marketagreement_type = 'A01'
contract_marketagreement_type = "A01"

# ts = client.query_day_ahead_prices(country_code, start=start, end=end)
# ts.to_csv('data/outfile.csv')

# df = client.query_generation(country_code, start=start, end=end)
# df.to_csv('data/generation_BE.csv')

country_codes = ['DE_LU', 'IT_NORD', 'NO_1', 'NO_2', 'NO_3', 'NO_4', 'NO_5', 'ES', 'FR']

for country in country_codes:
    df = client.query_generation(country_code, start=start, end=end)
    df.to_csv('data/generation' + country + '.csv')