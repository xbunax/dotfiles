# adapted from https://github.com/weirane/dotfiles/blob/macos/dotconfig/sketchybar/plugins/weather.sh

get_icon() {
if [[ $is_day == 1 ]]; then
    case $code in
        1000) icon= ;; # Sunny, Clear/113
        1003) icon= ;; # Partly cloudy/116
        1006) icon= ;; # Cloudy/119
        1009) icon= ;; # Overcast/122
        1030) icon= ;; # Mist/143
        1063) icon= ;; # Patchy rain possible/176
        1066) icon= ;; # Patchy snow possible/179
        1069) icon= ;; # Patchy sleet possible/182
        1072) icon= ;; # Patchy freezing drizzle possible/185
        1087) icon= ;; # Thundery outbreaks possible/200
        1114) icon= ;; # Blowing snow/227
        1117) icon= ;; # Blizzard/230
        1135) icon= ;; # Fog/248
        1147) icon= ;; # Freezing fog/260
        1150) icon= ;; # Patchy light drizzle/263
        1153) icon= ;; # Light drizzle/266
        1168) icon= ;; # Freezing drizzle/281
        1171) icon= ;; # Heavy freezing drizzle/284
        1180) icon= ;; # Patchy light rain/293
        1183) icon= ;; # Light rain/296
        1186) icon= ;; # Moderate rain at times/299
        1189) icon= ;; # Moderate rain/302
        1192) icon= ;; # Heavy rain at times/305
        1195) icon= ;; # Heavy rain/308
        1198) icon= ;; # Light freezing rain/311
        1201) icon= ;; # Moderate or heavy freezing rain/314
        1204) icon= ;; # Light sleet/317
        1207) icon= ;; # Moderate or heavy sleet/320
        1210) icon= ;; # Patchy light snow/323
        1213) icon= ;; # Light snow/326
        1216) icon= ;; # Patchy moderate snow/329
        1219) icon= ;; # Moderate snow/332
        1222) icon= ;; # Patchy heavy snow/335
        1225) icon= ;; # Heavy snow/338
        1237) icon= ;; # Ice pellets/350
        1240) icon= ;; # Light rain shower/353
        1243) icon= ;; # Moderate or heavy rain shower/356
        1246) icon= ;; # Torrential rain shower/359
        1249) icon= ;; # Light sleet showers/362
        1252) icon= ;; # Moderate or heavy sleet showers/365
        1255) icon= ;; # Light snow showers/368
        1258) icon= ;; # Moderate or heavy snow showers/371
        1261) icon= ;; # Light showers of ice pellets/374
        1264) icon= ;; # Moderate or heavy showers of ice pellets/377
        1273) icon= ;; # Patchy light rain with thunder/386
        1276) icon= ;; # Moderate or heavy rain with thunder/389
        1279) icon= ;; # Patchy light snow with thunder/392
        1282) icon= ;; # Moderate or heavy snow with thunder/395
    esac
else
    case $code in
        1000) icon= ;; # Sunny, Clear/113
        1003) icon= ;; # Partly cloudy/116
        1006) icon= ;; # Cloudy/119
        1009) icon= ;; # Overcast/122
        1030) icon= ;; # Mist/143
        1063) icon= ;; # Patchy rain possible/176
        1066) icon= ;; # Patchy snow possible/179
        1069) icon= ;; # Patchy sleet possible/182
        1072) icon= ;; # Patchy freezing drizzle possible/185
        1087) icon= ;; # Thundery outbreaks possible/200
        1114) icon= ;; # Blowing snow/227
        1117) icon= ;; # Blizzard/230
        1135) icon= ;; # Fog/248
        1147) icon= ;; # Freezing fog/260
        1150) icon= ;; # Patchy light drizzle/263
        1153) icon= ;; # Light drizzle/266
        1168) icon= ;; # Freezing drizzle/281
        1171) icon= ;; # Heavy freezing drizzle/284
        1180) icon= ;; # Patchy light rain/293
        1183) icon= ;; # Light rain/296
        1186) icon= ;; # Moderate rain at times/299
        1189) icon= ;; # Moderate rain/302
        1192) icon= ;; # Heavy rain at times/305
        1195) icon= ;; # Heavy rain/308
        1198) icon= ;; # Light freezing rain/311
        1201) icon= ;; # Moderate or heavy freezing rain/314
        1204) icon= ;; # Light sleet/317
        1207) icon= ;; # Moderate or heavy sleet/320
        1210) icon= ;; # Patchy light snow/323
        1213) icon= ;; # Light snow/326
        1216) icon= ;; # Patchy moderate snow/329
        1219) icon= ;; # Moderate snow/332
        1222) icon= ;; # Patchy heavy snow/335
        1225) icon= ;; # Heavy snow/338
        1237) icon= ;; # Ice pellets/350
        1240) icon= ;; # Light rain shower/353
        1243) icon= ;; # Moderate or heavy rain shower/356
        1246) icon= ;; # Torrential rain shower/359
        1249) icon= ;; # Light sleet showers/362
        1252) icon= ;; # Moderate or heavy sleet showers/365
        1255) icon= ;; # Light snow showers/368
        1258) icon= ;; # Moderate or heavy snow showers/371
        1261) icon= ;; # Light showers of ice pellets/374
        1264) icon= ;; # Moderate or heavy showers of ice pellets/377
        1273) icon= ;; # Patchy light rain with thunder/386
        1276) icon= ;; # Moderate or heavy rain with thunder/389
        1279) icon= ;; # Patchy light snow with thunder/392
        1282) icon= ;; # Moderate or heavy snow with thunder/395
    esac
fi
}

API="https://api.weatherapi.com/v1/current.json"
# get KEY and CITY from the config file
source ./scripts/weather.env.sh

for i in {1..4}; do
    weather=$(curl -sf --retry 3 "$API?key=$KEY&q=$CITY")
    if [[ -z $weather || $(echo $weather | jq -r ".current") == '{}' ]]; then
        echo "[WARNING] [$(gdate --iso-8601=seconds)] Weather API request failed $(echo $weather | jq -r ".current")" >&2
        if ((i == 4)); then
            echo "[ERROR] [$(gdate --iso-8601=seconds)] Weather API request failed 4 times" >&2
            exit 0
        fi
        sleep 10
    else
        break
    fi
done

temp=$(echo "$weather" | jq -r ".current.temp_f")
is_day=$(echo $weather | jq -r ".current.is_day")
code=$(echo "$weather" | jq -r ".current.condition.code")
get_icon
city=$(echo "$weather" | jq -r ".location.name")
condition=$(echo "$weather" | jq -r ".current.condition.text")
feelslike=$(echo "$weather" | jq -r ".current.feelslike_f")
uv=$(echo "$weather" | jq -r ".current.uv")
humidity=$(echo "$weather" | jq -r ".current.humidity")
wind_speed=$(echo "$weather" | jq -r ".current.wind_kph")
wind_direction=$(echo "$weather" | jq -r ".current.wind_dir")

sketchybar --set $NAME drawing=on icon=$icon label="${temp%%.*}°F" # \
        #    --set weather.location label="Location: $city" \
        #    --set weather.condition label="Condition: $condition" \
        #    --set weather.feels_like label="Feels Like: $feelslike°F" \
        #    --set weather.uv label="UV Index: $uv" \
        #    --set weather.humidity label="Humidity: $humidity%" \
        #    --set weather.wind label="Wind: $wind_speed km/h $wind_direction" \
        #    --set weather.lastupdated label="Last Updated: $(gdate +%T)"