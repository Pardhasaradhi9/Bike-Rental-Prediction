library(readxl)
library(dplyr)
library(ggplot2)
library(grid)
library(gridExtra)
library(patchwork)
library(ggpubr)
library(randomForest)

data <- read_xlsx("/Users/pardhasaradhichukka/Downloads/OESON/Projects/others/1657875746_day.xlsx")

str(data)

data$instant <- as.factor(data$instant)
data$dteday <- as.Date(data$dteday)
data$season <- as.factor(data$season)
data$yr <- as.factor(data$yr)
data$mnth <- as.factor(data$mnth)
data$holiday <- as.factor(data$holiday)
data$weekday <- as.factor(data$weekday)
data$workingday <- as.factor(data$workingday)
data$weathersit <- as.factor(data$weathersit)

str(data)

missing_values <- colSums(is.na(data))
missing_values


# Summary Statistics numerical variables
summary_stats <- summary(data[, c("temp", "atemp", "hum", "windspeed", 
                                  "casual", "registered", "cnt")])
summary_stats

# Data Visualization
# Histograms for numerical variables
hist_temp <- ggplot(data, aes(x = temp)) +
  geom_histogram(binwidth = 0.05, fill = "skyblue", color = "black") +
  labs(x = "Temperature", y = "Frequency") +
  ggtitle("Distribution of Temperature")

hist_atemp <- ggplot(data, aes(x = atemp)) +
  geom_histogram(binwidth = 0.05, fill = "skyblue", color = "black") +
  labs(x = "Feeling Temperature", y = "Frequency") +
  ggtitle("Distribution of Feeling Temperature")

hist_hum <- ggplot(data, aes(x = hum)) +
  geom_histogram(binwidth = 0.1, fill = "skyblue", color = "black") +
  labs(x = "Humidity", y = "Frequency") +
  ggtitle("Distribution of Humidity")

hist_windspeed <- ggplot(data, aes(x = windspeed)) +
  geom_histogram(binwidth = 0.1, fill = "skyblue", color = "black") +
  labs(x = "Windspeed", y = "Frequency") +
  ggtitle("Distribution of Windspeed")

# Bar plots for categorical variables
bar_season <- ggplot(data, aes(x = factor(season))) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(x = "Season", y = "Frequency") +
  ggtitle("Distribution of Seasons")

bar_yr <- ggplot(data, aes(x = factor(yr))) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(x = "Year", y = "Frequency") +
  ggtitle("Distribution of Years")

bar_mnth <- ggplot(data, aes(x = factor(mnth))) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(x = "Month", y = "Frequency") +
  ggtitle("Distribution of Months")

bar_holiday <- ggplot(data, aes(x = factor(holiday))) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(x = "Holiday", y = "Frequency") +
  ggtitle("Distribution of Holidays")

bar_weekday <- ggplot(data, aes(x = factor(weekday))) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(x = "Weekday", y = "Frequency") +
  ggtitle("Distribution of Weekdays")

bar_workingday <- ggplot(data, aes(x = factor(workingday))) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(x = "Working Day", y = "Frequency") +
  ggtitle("Distribution of Working Days")

bar_weathersit <- ggplot(data, aes(x = factor(weathersit))) +
  geom_bar(fill = "skyblue", color = "black") +
  labs(x = "Weather Situation", y = "Frequency") +
  ggtitle("Distribution of Weather Situations")


# Arrange histograms
hist_page <- ggarrange(
  hist_temp, hist_atemp, hist_hum, hist_windspeed,
  ncol = 2, nrow = 2
)

# Arrange bar plots
bar_page <- ggarrange(
  bar_season, bar_yr, bar_mnth,
  bar_holiday, bar_weekday, bar_workingday,
  bar_weathersit,
  ncol = 3, nrow = 3
)

hist_page
bar_page

# Seasonal Analysis
# Line plot for bike rental trends by season
line_season <- ggplot(data, aes(x = mnth, y = cnt, color = season)) + geom_line() + labs(x = "Month", y = "Bike Rentals") + ggtitle("Bike Rental Trends by Season")
line_season

# Box plots for bike rental trends by season
box_season <- ggplot(data, aes(x = season, y = cnt, fill = season)) +
  geom_boxplot() +
  labs(x = "Season", y = "Bike Rentals") +
  ggtitle("Bike Rental Trends by Season")
box_season

# Correlation matrix
correlation_matrix <- cor(data[, c("temp", "atemp", "hum", "windspeed", "casual", "registered", "cnt")])
correlation_matrix

# Plot Monthly Distribution of Total Bikes Rented
monthly_distribution <- ggplot(data, aes(x = mnth, y = cnt)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black") +
  labs(x = "Month", y = "Total Bikes Rented", title = "Monthly Distribution of Total Bikes Rented") +
  scale_x_discrete(labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
  theme_minimal()

monthly_distribution

# Plot Yearly Distribution of Total Bikes Rented
yearly_distribution <- ggplot(data, aes(x = yr, y = cnt)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black") +
  labs(x = "Year", y = "Total Bikes Rented", title = "Yearly Distribution of Total Bikes Rented") +
  scale_x_discrete(labels = c("2011", "2012")) +
  theme_minimal()

yearly_distribution

# Plot Boxplot for Outliers Analysis
outliers_boxplot <- ggplot(data, aes(x = "", y = cnt)) +
  geom_boxplot(fill = "skyblue", color = "black") +
  labs(x = "", y = "Total Bikes Rented", title = "Boxplot for Outliers Analysis") +
  theme_minimal()

outliers_boxplot

# splitting the data
set.seed(99)  # Set seed for reproducibility
train_indices <- sample(1:nrow(data), 0.8 * nrow(data))  
train_data <- data[train_indices, ]

# Remaining data for validation and test
remaining_data <- data[-train_indices, ]
validation_indices <- sample(1:nrow(remaining_data), 0.5 * nrow(remaining_data))
validation_data <- remaining_data[validation_indices, ]
test_data <- remaining_data[-validation_indices, ]

# random forest model
model_rf <- randomForest(cnt ~ season + yr + mnth + holiday + weekday +
                           workingday + weathersit + temp + atemp + hum +
                           windspeed, data = train_data, ntree = 500)


# Predicting on validation data
predictions_validation <- predict(model_rf, newdata = validation_data)

# Calculating Mean Absolute Error (MAE) on validation data
mae_validation <- mean(abs(predictions_validation - validation_data$cnt))

# Predicting on test data
predictions_test <- predict(model_rf, newdata = test_data)

# Calculating Mean Absolute Error (MAE) on test data
mae_test <- mean(abs(predictions_test - test_data$cnt))

# Displaying MAE on validation and test data
print(paste("Mean Absolute Error (MAE) on Validation Data:", mae_validation))
print(paste("Mean Absolute Error (MAE) on Test Data:", mae_test))

