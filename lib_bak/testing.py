
import json
import openmeteo_requests

import requests_cache
import pandas as pd
from retry_requests import retry
import datetime as dt



positions = {"ägerisee": (47.111887587987646, 8.633501746880691), "urnersee": (46.9172202976941, 8.608598444129369), "walensee": (47.12118888098282, 9.208373756073712),
"untersee": (47.68, 9.01), "silvaplana": (46.45006704718666, 9.79256710511436), "murtensee": (46.93877461939198, 7.109514699030891), "zürisee": (47.220838545399815, 8.734156412596736),
"lacleman": (46.45955340688029, 6.455802005319578), "neuenburger": (47.00656741527855, 6.98372328605978), "sihlsee": (47.12321386953742, 8.785886902330285),
"luganersee": (45.99286480007178, 8.976621518955124), "como": (46.14244990328864, 9.34168521015605), "maggiore": (46.117869612898645, 8.723550018385247),
"bielersee": (47.11511238013675, 7.21057564487391), "greifensee": (47.36001307831597, 8.670915076007311), "thalwil": (47.29982918681438, 8.57688882738088),
"bodensee":(47.584750252032485, 9.410458860390763), "zugersee": (47.15954625717645, 8.487021207332193), "sempachersee": (47.14584575839154, 8.156032407147828)}

names_clean = {"ägerisee": "Ägerisee", "urnersee": "Urnersee", "walensee": "Walensee",
"untersee": "Untersee", "silvaplana": "Silvaplana", "murtensee": "Murtensee", "zürisee": "Zürichsee (Freienbach)",
"lacleman": "Lac Leman", "neuenburger": "Neuenburgersee", "sihlsee": "Sihlsee",
"luganersee": "Lago di Lugano", "como": "Lago di Como", "maggiore": "Lago Maggiore",
"bielersee": "Bielersee", "greifensee": "Greifensee", "thalwil": "Zürichsee (Thalwil)", "bodensee": "Bodensee", "zugersee": "Zugersee",
"sempachersee": "Sempachersee"}

file_path = ""

lake = "urnersee"

# Setup the Open-Meteo API client with cache and retry on error
cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)

# Make sure all required weather variables are listed here
# The order of variables in hourly or daily is important to assign them correctly below
url = "https://api.open-meteo.com/v1/meteofrance"
params = {
    "latitude": positions[lake][0],
    "longitude": positions[lake][1],
    "hourly": ["temperature_2m", "precipitation", "cloud_cover", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m", "weather_code"],
    "timezone": "GMT",
    "forecast_days": 4,
    "models": ["arome_france_hd", "arpege_europe"]
}
responses = openmeteo.weather_api(url, params=params)

# Process first location. Add a for-loop for multiple locations or weather models
response = responses[0]

# Process hourly data. The order of variables needs to be the same as requested.
hourly = response.Hourly()
hourly_temperature_2m = hourly.Variables(0).ValuesAsNumpy()
hourly_precipitation = hourly.Variables(1).ValuesAsNumpy()
hourly_cloud_cover = hourly.Variables(2).ValuesAsNumpy()
hourly_wind_speed_10m = hourly.Variables(3).ValuesAsNumpy()
hourly_wind_direction_10m = hourly.Variables(4).ValuesAsNumpy()
hourly_wind_gusts_10m = hourly.Variables(5).ValuesAsNumpy()
hourly_weather_code = hourly.Variables(6).ValuesAsNumpy()

hourly_data = {"date": pd.date_range(
    start = pd.to_datetime(hourly.Time(), unit = "s"),
    end = pd.to_datetime(hourly.TimeEnd(), unit = "s"),
    freq = pd.Timedelta(seconds = hourly.Interval()),
    inclusive = "left"
)}
hourly_data["temperature_2m"] = hourly_temperature_2m
hourly_data["precipitation"] = hourly_precipitation

hourly_data["wind_speed_10m"] = hourly_wind_speed_10m
hourly_data["wind_direction_10m"] = hourly_wind_direction_10m
hourly_data["wind_gusts_10m"] = hourly_wind_gusts_10m


hourly_dataframe = pd.DataFrame(data = hourly_data)

# Process first location. Add a for-loop for multiple locations or weather models
response = responses[1]

# Process hourly data. The order of variables needs to be the same as requested.
hourly = response.Hourly()
hourly_temperature_2m = hourly.Variables(0).ValuesAsNumpy()
hourly_precipitation = hourly.Variables(1).ValuesAsNumpy()
hourly_cloud_cover = hourly.Variables(2).ValuesAsNumpy()
hourly_wind_speed_10m = hourly.Variables(3).ValuesAsNumpy()
hourly_wind_direction_10m = hourly.Variables(4).ValuesAsNumpy()
hourly_wind_gusts_10m = hourly.Variables(5).ValuesAsNumpy()
hourly_weather_code = hourly.Variables(6).ValuesAsNumpy()

hourly_data = {"date": pd.date_range(
    start = pd.to_datetime(hourly.Time(), unit = "s"),
    end = pd.to_datetime(hourly.TimeEnd(), unit = "s"),
    freq = pd.Timedelta(seconds = hourly.Interval()),
    inclusive = "left"
)}
hourly_data["temperature_2m"] = hourly_temperature_2m
hourly_data["precipitation"] = hourly_precipitation

hourly_data["wind_speed_10m"] = hourly_wind_speed_10m
hourly_data["wind_direction_10m"] = hourly_wind_direction_10m
hourly_data["wind_gusts_10m"] = hourly_wind_gusts_10m


hourly_dataframe_2 = pd.DataFrame(data = hourly_data)

len_df = len(hourly_dataframe.dropna(subset = "wind_speed_10m"))
hourly_dataframe.iloc[len_df:] = hourly_dataframe_2.iloc[len_df:]

#hourly_dataframe.index = hourly_dataframe["date"]




#hourly_dataframe.to_csv("sample_meteo_data.csv")



# ****************************************

# Setup the Open-Meteo API client with cache and retry on error
cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)

# Make sure all required weather variables are listed here
# The order of variables in hourly or daily is important to assign them correctly below
url = "https://api.open-meteo.com/v1/forecast"
params = {
	"latitude": 52.52,
	"longitude": 13.41,
    "timezone": "GMT",
	"hourly": ["temperature_2m", "precipitation", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m"],
	"forecast_days": 14
}
responses = openmeteo.weather_api(url, params=params)

# Process first location. Add a for-loop for multiple locations or weather models
response = responses[0]
print(f"Coordinates {response.Latitude()}°N {response.Longitude()}°E")
print(f"Elevation {response.Elevation()} m asl")
print(f"Timezone {response.Timezone()} {response.TimezoneAbbreviation()}")
print(f"Timezone difference to GMT+0 {response.UtcOffsetSeconds()} s")

# Process hourly data. The order of variables needs to be the same as requested.
hourly = response.Hourly()
hourly_temperature_2m = hourly.Variables(0).ValuesAsNumpy()
hourly_precipitation = hourly.Variables(1).ValuesAsNumpy()
hourly_wind_speed_10m = hourly.Variables(2).ValuesAsNumpy()
hourly_wind_direction_10m = hourly.Variables(3).ValuesAsNumpy()
hourly_wind_gusts_10m = hourly.Variables(4).ValuesAsNumpy()

hourly_data = {"date": pd.date_range(
	start = pd.to_datetime(hourly.Time(), unit = "s", utc = True),
	end = pd.to_datetime(hourly.TimeEnd(), unit = "s", utc = True),
	freq = pd.Timedelta(seconds = hourly.Interval()),
	inclusive = "left"
)}
hourly_data["temperature_2m"] = hourly_temperature_2m
hourly_data["precipitation"] = hourly_precipitation
hourly_data["wind_speed_10m"] = hourly_wind_speed_10m
hourly_data["wind_direction_10m"] = hourly_wind_direction_10m
hourly_data["wind_gusts_10m"] = hourly_wind_gusts_10m

hourly_dataframe_3 = pd.DataFrame(data = hourly_data)

len_df = len(hourly_dataframe.dropna(subset = "wind_speed_10m"))

hourly_dataframe_3['date'] = pd.to_datetime(hourly_dataframe_3['date']).dt.tz_convert(None)
hourly_dataframe.index = hourly_dataframe["date"]
hourly_dataframe_3.index = hourly_dataframe_3["date"]
print(hourly_dataframe_3)
print(hourly_dataframe)
#hourly_dataframe.iloc[len_df:] = hourly_dataframe_3.iloc[len_df:]
hourly_dataframe_3.iloc[:len_df] = hourly_dataframe
hourly_dataframe = hourly_dataframe_3

summary = {}
for i in range(4):
    wind = hourly_dataframe[(hourly_dataframe.index > dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i) + dt.timedelta(hours = 9)) &
                            (hourly_dataframe.index < dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i + 1) - dt.timedelta(hours = 5))]["wind_speed_10m"].rolling(3).mean().max()
    wind_pos = hourly_dataframe[(hourly_dataframe.index > dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i) + dt.timedelta(hours = 9)) &
                            (hourly_dataframe.index < dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i + 1) - dt.timedelta(hours = 5))]["wind_speed_10m"].rolling(3).mean().idxmax()
    wind_gust = hourly_dataframe["wind_gusts_10m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
    wind_direction = hourly_dataframe["wind_direction_10m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
    temp = hourly_dataframe["temperature_2m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
    precipitation = hourly_dataframe["precipitation"][wind_pos-dt.timedelta(hours = 2):wind_pos].sum()
    summary[i] = {"wind": round(float(wind)), "gusts": round(float(wind_gust)), "direction": round(float(wind_direction)), "temp": round(float(temp)), "rain": round(float(precipitation)), "time": str(wind_pos)}


hourly_dataframe.index = [str(x) for x in hourly_dataframe.index]
hourly_dataframe = hourly_dataframe[["wind_speed_10m", "wind_gusts_10m", "temperature_2m", "wind_direction_10m", "precipitation", ]]
hourly_dataframe = hourly_dataframe.replace("null", None)
hourly_dataframe = hourly_dataframe.dropna(subset = ["wind_speed_10m", "wind_gusts_10m"])
hourly_dataframe["precipitation"] = [round(x, 1) for x in hourly_dataframe["precipitation"]]
hourly_dataframe["temperature_2m"] = hourly_dataframe["temperature_2m"].round()

json_ = hourly_dataframe.to_json()
json_ = json.loads(json_)
json_["summary"] = summary
json_ = json.dumps(json_)

print(json_)
#json_["now"] = dt.datetime.utcnow()
#json_ = {"Hello": "World"}