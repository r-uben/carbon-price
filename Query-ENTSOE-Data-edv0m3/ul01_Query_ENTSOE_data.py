# -*- coding: utf-8 -*-
"""
Created January 2021
@author: Michael Pertl, 
michael@thesmartinsights.com
www.thesmartinsights.com

Query data from ENTSO-E transparency portal
------------------------------------------------------------------------------
DISCLAIMER: 
You may use the Code for any private or commercial purpose. However, you may not sell, 
sub-license, rent, lease, lend, assign or otherwise transfer, duplicate or otherwise 
reproduce, directly or indirectly, the Code in whole or in part. 

You acknowledge that the Code is provided “AS IS” and thesmartinsights.com expressly 
disclaims all warranties and conditions including, but not limited to, any implied 
warranties for suitability of the Code for a particular purpose, or any form of warranty 
that operation of the Code will be error-free.

You acknowledge that in no event shall thesmartinsights.com or any of its affiliates be 
liable for any damages arising out of the use of the Code or otherwise in connection with 
this agreement, including, without limitation, any direct, indirect special, incidental 
or consequential damages, whether any claim for such recovery is based on theories of 
contract, negligence, and even if thesmartinsights.com has knowledge of the possibility 
of potential loss or damage.
------------------------------------------------------------------------------- 
"""
import pandas as pd
from entsoe import EntsoePandasClient

# %% parameter definitions
client = EntsoePandasClient(api_key='YOUR API KEY GOES HERE')

start = pd.Timestamp('20201201', tz ='UTC')
end = pd.Timestamp('20201202', tz ='UTC')
country_code_1 = 'AT'  # 
country_code_2 = 'DE_LU'  # 
country_code_3 = 'CZ'  # 

#day-ahead market prices (€/MWh)
DA_prices = client.query_day_ahead_prices(country_code_1, start=start,end=end)

#generation (MW)
generation = client.query_generation(country_code_1, start=start,end=end)
generation_per_plant = client.query_generation_per_plant(country_code_1, start=start,end=end)
generation_forecast = client.query_generation_forecast(country_code_1, start=start,end=end)
wind_solar_forecast = client.query_wind_and_solar_forecast(country_code_1, start=start,end=end, psr_type=None)
installed_generation_capacity = client.query_installed_generation_capacity(country_code_1, start=start,end=end)
installed_generation_capacity_per_unit = client.query_installed_generation_capacity_per_unit(country_code_1, start=start,end=end)

#load and load forecast (MW)
load = client.query_load(country_code_1, start=start,end=end)
load_forecast = client.query_load_forecast(country_code_1, start=start,end=end)

#day-ahead scheduled (commercial) exchanges (MW)
scheduled_exchanges = client.query_scheduled_exchanges(country_code_1, country_code_2, start=start,end=end)

#cross-border flows (physical) (MW): to get resulting flow both directions need to be considerd, e.g netflow_AT_DE = (AT-DE) - (DE-AT) 
crossborder_flows_1 = client.query_crossborder_flows(country_code_1, country_code_2, start=start,end=end) 
crossborder_flows_2 = client.query_crossborder_flows( country_code_2,country_code_1, start=start,end=end) 
crossborder_flow_net = crossborder_flows_1 - crossborder_flows_2

#works only for countries without flow-based border (MW)
net_transfer_capacity_dayahead = client.query_net_transfer_capacity_dayahead(country_code_1, country_code_3, start=start,end=end)
net_transfer_capacity_monthahead = client.query_net_transfer_capacity_monthahead(country_code_1, country_code_3, start=start,end=end)
net_transfer_capacity_weekahead = client.query_net_transfer_capacity_weekahead(country_code_1, country_code_3, start=start,end=end)
net_transfer_capacity_yearahead = client.query_net_transfer_capacity_yearahead(country_code_1, country_code_3, start=start,end=end)

#contracted reserves (MW) and prices (€/MW/period)
contracted_reserve_amount = client.query_contracted_reserve_amount(country_code_1, start=start, end=end, type_marketagreement_type='A01')
contracted_reserve_prices = client.query_contracted_reserve_prices(country_code_1, start=start, end=end, type_marketagreement_type='A01')

#unavailability of generation and production units
unavailability_of_generation_units = client.query_unavailability_of_generation_units(country_code_1, start=start,end=end)
unavailability_of_production_units = client.query_unavailability_of_production_units(country_code_1, start=start,end=end)

