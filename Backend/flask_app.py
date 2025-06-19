
# A very simple Flask Hello World app for you to get started with...

from flask import Flask,jsonify,request
import json
import openmeteo_requests

import requests_cache
import pandas as pd
from retry_requests import retry
import datetime as dt
import math

app = Flask(__name__)

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


@app.route('/sessions/<lake>/<date>')
def get_session(lake, date):
    list_people = []
    list_people.append({"user": "sui-60", "text": "sehr schön gsi", "strength": "3-4bft", "material": "PD Foil Comp v3 85cm, PD HA 7.4, Aeon 650er"})
    list_people.append({"user": "sui-50", "text": "chli wenig wind", "strength": "2-4bft", "material": "FMX Hyperion 85cm, S2Maui 7.8, Aeon 900er"})
    dic_people = {"result": list_people}
    return json.dumps(dic_people)

@app.route('/lake/<lake>')
def get_lake_forecast(lake):

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
    	"latitude": positions[lake][0],
    	"longitude": positions[lake][1],
        "timezone": "GMT",
    	"hourly": ["temperature_2m", "precipitation", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m"],
    	"forecast_days": 14
    }
    responses = openmeteo.weather_api(url, params=params)

    # Process first location. Add a for-loop for multiple locations or weather models
    response = responses[0]

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
        summary[i] = {
            "wind": round(float(wind)) if not math.isnan(wind) else 0,
            "gusts": round(float(wind_gust)) if not math.isnan(wind_gust) else 0,
            "direction": round(float(wind_direction)) if not math.isnan(wind_direction) else 0,
            "temp": round(float(temp)) if not math.isnan(temp) else 0,
            "rain": round(float(precipitation)) if not math.isnan(precipitation) else 0,
            "time": str(wind_pos)
        }


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
    #json_["now"] = dt.datetime.utcnow()
    #json_ = {"Hello": "World"}
    return json_

@app.route('/SpotsOfTheDay/<day>')
def spots_of_the_day(day):
    cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
    retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
    openmeteo = openmeteo_requests.Client(session = retry_session)

    # Make sure all required weather variables are listed here
    # The order of variables in hourly or daily is important to assign them correctly below
    url = "https://api.open-meteo.com/v1/meteofrance"
    summary = {}
    for lake in positions:
        params = {
    	"latitude": positions[lake][0],
    	"longitude": positions[lake][1],
    	"hourly": ["temperature_2m", "precipitation", "cloud_cover", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m", "weather_code"],
    	"timezone": "GMT",
    	"forecast_days": 1 + int(day),
    	"models": ["arome_france_hd"]
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
        hourly_dataframe.index = hourly_dataframe["date"]

        i = int(day)
        wind = hourly_dataframe[(hourly_dataframe.index > dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i) + dt.timedelta(hours = 9)) &
                                (hourly_dataframe.index < dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i + 1) - dt.timedelta(hours = 5))]["wind_speed_10m"].rolling(3).mean().max()
        wind_pos = hourly_dataframe[(hourly_dataframe.index > dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i) + dt.timedelta(hours = 9)) &
                                (hourly_dataframe.index < dt.datetime.combine(dt.date.today(), dt.datetime.min.time()) + dt.timedelta(days = i + 1) - dt.timedelta(hours = 5))]["wind_speed_10m"].rolling(3).mean().idxmax()
        wind_gust = hourly_dataframe["wind_gusts_10m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
        wind_direction = hourly_dataframe["wind_direction_10m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
        temp = hourly_dataframe["temperature_2m"][wind_pos-dt.timedelta(hours = 2):wind_pos].mean()
        precipitation = hourly_dataframe["precipitation"][wind_pos-dt.timedelta(hours = 2):wind_pos].sum()
        rating = (wind + wind_gust) / 2 - precipitation * 8
        if (wind + wind_gust) / 2 > 20:
            rating = rating + 20
        if temp < 15:
            if temp < 10:
                if temp < 5:
                    if temp < 2:
                        rating = rating - 20
                    else:
                        rating = rating - 10
                else:
                    rating = rating - 5
            else:
                rating = rating - 3
        summary[lake] = {"rating": rating,"wind": round(float(wind)), "gusts": round(float(wind_gust)), "direction": round(float(wind_direction)),
        "temp": round(float(temp)), "rain": round(float(precipitation)), "time": str(wind_pos)}
    max = -100
    max_lake = ""
    for lake in summary:
        if summary[lake]["rating"] > max:
            max = summary[lake]["rating"]
            max_lake = lake
    summary[max_lake]["rating"] = -100
    summary[max_lake]["lake"] = names_clean[max_lake]
    summary[max_lake]["lake_back"] = max_lake

    max = -100
    max_lake_2 = ""
    for lake in summary:
        if summary[lake]["rating"] > max:
            max = summary[lake]["rating"]
            max_lake_2 = lake
    summary[max_lake_2]["rating"] = -100
    summary[max_lake_2]["lake"] = names_clean[max_lake_2]
    summary[max_lake_2]["lake_back"] = max_lake_2

    max = -100
    max_lake_3 = ""
    for lake in summary:
        if summary[lake]["rating"] > max:
            max = summary[lake]["rating"]
            max_lake_3 = lake
    summary[max_lake_3]["rating"] = -100
    summary[max_lake_3]["lake"] = names_clean[max_lake_3]
    summary[max_lake_3]["lake_back"] = max_lake_3

    max = -100
    max_lake_4 = ""
    for lake in summary:
        if summary[lake]["rating"] > max:
            max = summary[lake]["rating"]
            max_lake_4 = lake
    summary[max_lake_4]["rating"] = -100
    summary[max_lake_4]["lake"] = names_clean[max_lake_4]
    summary[max_lake_4]["lake_back"] = max_lake_4


    result = {}
    result["1"] = summary[max_lake]
    result["2"] = summary[max_lake_2]
    result["3"] = summary[max_lake_3]
    result["4"] = summary[max_lake_4]
    json_ = json.dumps(result)
    return json_


@app.route('/refresh_data')
def refresh_all_data():
    for key in positions:
        json_ =  get_lake_forecast(key)
        with open("forecast_" + key + ".json", "w") as file:
            file.write(json.dumps(json_))
    return "done"

@app.route('/lake_cached/<lake>')
def get_lake_forecast_cached(lake):
    with open("forecast_" + lake + ".json", "r") as file:
        json_ = json.loads(file.read())
    return json_

@app.route('/refresh_spots_of_the_day')
def refresh_spots_of_the_day():
    for i in [0,1]:
        json_ = spots_of_the_day(i)
        with open("SpotsOfTheDay" + str(i) + ".json", "w") as file:
            file.write(json.dumps(json_))
    return "done"

@app.route('/SpotsOfTheDay_cached/<day>')
def spots_of_the_day_cached(day):
    with open("SpotsOfTheDay" + str(day) + ".json", "r") as file:
        json_ = json.loads(file.read())
    return json_


@app.route('/forecast_loc/<lat>/<lon>')
def get_loc_forecast(lat, lon):

   # Setup the Open-Meteo API client with cache and retry on error
    cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
    retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
    openmeteo = openmeteo_requests.Client(session = retry_session)

    # Make sure all required weather variables are listed here
    # The order of variables in hourly or daily is important to assign them correctly below
    url = "https://api.open-meteo.com/v1/meteofrance"
    params = {
        "latitude": lat,
        "longitude": lon,
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
    	"latitude": lat,
    	"longitude": lon,
        "timezone": "GMT",
    	"hourly": ["temperature_2m", "precipitation", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m"],
    	"forecast_days": 14
    }
    responses = openmeteo.weather_api(url, params=params)

    # Process first location. Add a for-loop for multiple locations or weather models
    response = responses[0]

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
        summary[i] = {
            "wind": round(float(wind)) if not math.isnan(wind) else 0,
            "gusts": round(float(wind_gust)) if not math.isnan(wind_gust) else 0,
            "direction": round(float(wind_direction)) if not math.isnan(wind_direction) else 0,
            "temp": round(float(temp)) if not math.isnan(temp) else 0,
            "rain": round(float(precipitation)) if not math.isnan(precipitation) else 0,
            "time": str(wind_pos)
        }


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
    #json_["now"] = dt.datetime.utcnow()
    #json_ = {"Hello": "World"}
    return json_





@app.route('/refresh_data_old')
def get_all_data():
    for key in positions:
        try:
            with open(file_path + key + "_forecast.json", "r") as file:
                json_ = json.loads(file.read())
                time_last = dt.datetime.strptime(json_["time"][:19], '%Y-%m-%d %H:%M:%S')
        except:
            time_last = None
        if time_last is None or dt.datetime.utcnow() - time_last > dt.timedelta(hours = 1):
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
                "timezone": "GMT",
                "forecast_days": 3,
                "models": ["arome_seamless", "arome_france", "arome_france_hd"]
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

            hourly_dataframe.index = [str(x) for x in hourly_dataframe["date"]]
            hourly_dataframe = hourly_dataframe[["wind_speed_10m", "wind_gusts_10m", "temperature_2m", "wind_direction_10m", "precipitation"]]
            hourly_dataframe = hourly_dataframe.replace("null", None)
            hourly_dataframe = hourly_dataframe.dropna()

            hourly_dataframe["temperature_2m"] = hourly_dataframe["temperature_2m"].round()

            json_ = hourly_dataframe.to_dict()
            json_["time"] = str(dt.datetime.utcnow())
            with open(file_path + key + "_forecast.json", "w") as f:
                f.write(json.dumps(json_))

            return "Done"
        else:
            return "Already up to date"


