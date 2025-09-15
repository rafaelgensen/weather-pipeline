import os
import requests
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Set your OpenWeather API key and the city to query
API_KEY = os.getenv("TF_VAR_API_KEY_CG")
city = 'London'

# API endpoint for 5-day weather forecast (3-hour intervals)
url = f'http://api.openweathermap.org/data/2.5/forecast?q={city}&appid={API_KEY}&units=metric'

# Step 1: Make the API request
response = requests.get(url)
data = response.json()

# Step 2: Normalize JSON data into a pandas DataFrame
weather_list = data['list']
df = pd.json_normalize(weather_list)

# Step 3: Select and rename relevant columns
df = df[['dt_txt', 'main.temp', 'main.feels_like', 'main.humidity', 'main.pressure', 'wind.speed', 'weather']]
df.rename(columns={
    'dt_txt': 'datetime',
    'main.temp': 'temp_celsius',
    'main.feels_like': 'feels_like_celsius',
    'main.humidity': 'humidity',
    'main.pressure': 'pressure',
    'wind.speed': 'wind_speed'
}, inplace=True)

# Extract weather description from the nested 'weather' list
df['weather_desc'] = df['weather'].apply(lambda x: x[0]['description'])

# Convert datetime strings to pandas datetime objects
df['datetime'] = pd.to_datetime(df['datetime'])

# Step 4: Prepare 9 plots to show in a 3x3 grid
sns.set(style='whitegrid')
fig, axes = plt.subplots(3, 3, figsize=(18, 12))
axes = axes.flatten()  # Flatten axes array for easy iteration

# Plot 1: Temperature over time
sns.lineplot(data=df, x='datetime', y='temp_celsius', ax=axes[0])
axes[0].set_title('Temperature (°C)')
axes[0].set_xlabel('')
axes[0].set_ylabel('°C')

# Plot 2: Feels Like Temperature over time
sns.lineplot(data=df, x='datetime', y='feels_like_celsius', ax=axes[1], color='orange')
axes[1].set_title('Feels Like Temp (°C)')
axes[1].set_xlabel('')
axes[1].set_ylabel('°C')

# Plot 3: Humidity over time
sns.lineplot(data=df, x='datetime', y='humidity', ax=axes[2], color='green')
axes[2].set_title('Humidity (%)')
axes[2].set_xlabel('')
axes[2].set_ylabel('%')

# Plot 4: Atmospheric Pressure over time
sns.lineplot(data=df, x='datetime', y='pressure', ax=axes[3], color='purple')
axes[3].set_title('Pressure (hPa)')
axes[3].set_xlabel('')
axes[3].set_ylabel('hPa')

# Plot 5: Wind Speed over time
sns.lineplot(data=df, x='datetime', y='wind_speed', ax=axes[4], color='brown')
axes[4].set_title('Wind Speed (m/s)')
axes[4].set_xlabel('')
axes[4].set_ylabel('m/s')

# Plot 6: Count of different weather conditions (bar chart)
weather_counts = df['weather_desc'].value_counts()
sns.barplot(x=weather_counts.values, y=weather_counts.index, ax=axes[5], palette='coolwarm')
axes[5].set_title('Weather Conditions Frequency')
axes[5].set_xlabel('Count')
axes[5].set_ylabel('')

# Plot 7: Temperature vs Humidity scatterplot
sns.scatterplot(data=df, x='temp_celsius', y='humidity', ax=axes[6], hue='weather_desc', palette='tab10', legend=False)
axes[6].set_title('Temp vs Humidity')
axes[6].set_xlabel('Temp (°C)')
axes[6].set_ylabel('Humidity (%)')

# Plot 8: Temperature distribution (histogram)
sns.histplot(df['temp_celsius'], bins=15, kde=True, ax=axes[7], color='skyblue')
axes[7].set_title('Temperature Distribution')
axes[7].set_xlabel('Temp (°C)')
axes[7].set_ylabel('Frequency')

# Plot 9: Humidity distribution (histogram)
sns.histplot(df['humidity'], bins=15, kde=True, ax=axes[8], color='lightgreen')
axes[8].set_title('Humidity Distribution')
axes[8].set_xlabel('Humidity (%)')
axes[8].set_ylabel('Frequency')

# Rotate x-axis labels for all time-series plots to improve readability
for i in [0, 1, 2, 3, 4]:
    for label in axes[i].get_xticklabels():
        label.set_rotation(45)
        label.set_horizontalalignment('right')

plt.tight_layout()
plt.show()