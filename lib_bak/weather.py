import openmeteo_requests
import json
import requests_cache
import pandas as pd
import datetime as dt
from retry_requests import retry

positions = {"ägerisee": (47.111887587987646, 8.633501746880691), "urnersee": (46.9172202976941, 8.608598444129369), "walensee": (47.12118888098282, 9.208373756073712),
"untersee": (47.68, 9.01), "silvaplana": (46.45006704718666, 9.79256710511436), "murtensee": (46.93877461939198, 7.109514699030891), "zürisee": (47.220838545399815, 8.734156412596736),
"lacleman": (46.45955340688029, 6.455802005319578)}

file_path = ""

for key in positions:

    with open(file_path + key + "_forecast.json", "r") as file:
        json_ = json.loads(file.read())
        time_last = dt.datetime.strptime(json_["time"][:19], '%Y-%m-%d %H:%M:%S')
    if dt.datetime.utcnow() - time_last < dt.timedelta(hours = 1) and False:
        print(1)
    else:
        cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
        retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
        openmeteo = openmeteo_requests.Client(session = retry_session)

        # Make sure all required weather variables are listed here
        # The order of variables in hourly or daily is important to assign them correctly below
        url = "https://api.open-meteo.com/v1/meteofrance"
        params = {
            "latitude": positions[key][0],
            "longitude": positions[key][1],
            "hourly": ["temperature_2m", "precipitation", "cloud_cover", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m", "weather_code"],
            "timezone": "Europe/Berlin",
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
        hourly_data["cloud_cover"] = hourly_cloud_cover
        hourly_data["wind_speed_10m"] = hourly_wind_speed_10m
        hourly_data["wind_direction_10m"] = hourly_wind_direction_10m
        hourly_data["wind_gusts_10m"] = hourly_wind_gusts_10m
        hourly_data["weather_code"] = hourly_weather_code

        hourly_dataframe = pd.DataFrame(data = hourly_data)

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
        hourly_data["cloud_cover"] = hourly_cloud_cover
        hourly_data["wind_speed_10m"] = hourly_wind_speed_10m
        hourly_data["wind_direction_10m"] = hourly_wind_direction_10m
        hourly_data["wind_gusts_10m"] = hourly_wind_gusts_10m
        hourly_data["weather_code"] = hourly_weather_code

        hourly_dataframe_2 = pd.DataFrame(data = hourly_data)

        len_df = len(hourly_dataframe.dropna(subset = "wind_speed_10m"))
        hourly_dataframe.iloc[len_df:] = hourly_dataframe_2.iloc[len_df:]

        hourly_dataframe.index = hourly_dataframe["date"]
        #print(dt.datetime.combine(dt.date.today(), dt.datetime.min.time()))
        summary = {}
        for i in range(4):
            wind = hourly_dataframe[(hourly_dataframe.index > dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i) + dt.timedelta(hours = 9)) & 
                                    (hourly_dataframe.index < dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i + 1) - dt.timedelta(hours = 5))]["wind_speed_10m"].rolling(3).mean().max()
            wind_pos = hourly_dataframe[(hourly_dataframe.index > dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i) + dt.timedelta(hours = 9)) & 
                                    (hourly_dataframe.index < dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i + 1) - dt.timedelta(hours = 5))]["wind_speed_10m"].rolling(3).mean().idxmax()
            wind_gust = hourly_dataframe["wind_gusts_10m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
            wind_direction = hourly_dataframe["wind_direction_10m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
            temp = hourly_dataframe["temperature_2m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()

            print(wind_pos)
            print(wind)
            print(hourly_dataframe[(hourly_dataframe.index > dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i) + dt.timedelta(hours = 9)) & 
                                    (hourly_dataframe.index < dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i + 1) - dt.timedelta(hours = 5))]["wind_speed_10m"])

            break
            summary[i] = {"wind": float(wind), "gusts": float(wind_gust), "direction": float(wind_direction), "temp": float(temp)}

        
        hourly_dataframe.index = [str(x) for x in hourly_dataframe.index]

        hourly_dataframe = hourly_dataframe[["wind_speed_10m", "wind_gusts_10m", "temperature_2m", "wind_direction_10m", "weather_code"]]
        hourly_dataframe = hourly_dataframe.replace("null", None)
        hourly_dataframe = hourly_dataframe.dropna()

        hourly_dataframe["temperature_2m"] = hourly_dataframe["temperature_2m"].round()

        hourly_dataframe.to_csv("sample_meteo_data.csv")

        json_ = hourly_dataframe.to_dict()
        json_["time"] = str(dt.datetime.utcnow())
        json_["summary"] = summary



        with open(file_path + key + "_forecast.json", "w") as f:
            f.write(json.dumps(json_))
        print("lake " + str(key))
        break
