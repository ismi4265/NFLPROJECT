if (!require("remotes")) install.packages("remotes")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggcorrplot")) install.packages("ggcorrplot")

remotes::install_github("nflverse/nflverse")

library(nflverse)   # NFL data
library(tidyverse)  # data manipulation 
library(ggcorrplot) # visualization

pbp <- nflreadr::load_pbp(seasons = 2018:2022)
schedules <- nflreadr::load_schedules()

# playoff teams
playoff_teams <- schedules %>%
  filter(game_type != "REG") %>%
  select(season, home_team, away_team) %>%
  pivot_longer(cols = c(home_team, away_team), names_to = "team_role", values_to = "team") %>%
  distinct(season, team) %>%
  mutate(playoff = 1)

# Calculate team-level statistics
team_stats <- pbp %>%
  filter(!is.na(posteam)) %>%
  group_by(season, posteam) %>%
  summarise(
    passing_yards = sum(passing_yards, na.rm = TRUE),
    rushing_yards = sum(rushing_yards, na.rm = TRUE),
    yards_for = sum(yards_gained, na.rm = TRUE),
    yards_against = sum(yards_gained[posteam != defteam], na.rm = TRUE), 
    points_for = sum(if_else(posteam == home_team, total_home_score, 
                             if_else(posteam == away_team, total_away_score, 0)), na.rm = TRUE) / 53,  
    points_against = sum(if_else(posteam != home_team & defteam == home_team, total_home_score, 
                                 if_else(posteam != away_team & defteam == away_team, total_away_score, 0)), na.rm = TRUE) / 53,   .groups = "drop"
  ) %>%
  rename(team = posteam)

# Merge playoff
team_stats <- team_stats %>%
  left_join(playoff_teams, by = c("season", "team")) %>%
  mutate(playoff = ifelse(is.na(playoff), 0, playoff))

win_percentage <- schedules %>%
  mutate(
    winner = ifelse(home_score > away_score, home_team, ifelse(away_score > home_score, away_team, NA)),
    loser = ifelse(home_score < away_score, home_team, ifelse(away_score < home_score, away_team, NA))
  ) %>%
  pivot_longer(cols = c(home_team, away_team), names_to = "team_role", values_to = "team") %>%
  group_by(season, team) %>%
  summarise(
    wins = sum(winner == team, na.rm = TRUE),
    losses = sum(loser == team, na.rm = TRUE),
    win_percentage = wins / (wins + losses),
    .groups = "drop"
  )

# Merge win percentage
team_stats <- team_stats %>%
  left_join(win_percentage, by = c("season", "team"))

# Descriptive Statistics
summary_stats <- team_stats %>%
  summarise(
    avg_passing_yards = mean(passing_yards, na.rm = TRUE),
    avg_rushing_yards = mean(rushing_yards, na.rm = TRUE),
    avg_yards_for = mean(yards_for, na.rm = TRUE),
    avg_yards_against = mean(yards_against, na.rm = TRUE),
    avg_points_for = mean(points_for, na.rm = TRUE),
    avg_points_against = mean(points_against, na.rm = TRUE),
    avg_win_percentage = mean(win_percentage, na.rm = TRUE)
  )
print("Summary of Team-Level Statistics:")
print(summary_stats)

# Correlation Analysis
correlation_matrix <- team_stats %>%
  select(passing_yards, rushing_yards, yards_for, yards_against, points_for, points_against, win_percentage, playoff) %>%
  cor(use = "complete.obs")

print("Correlation Matrix:")
print(correlation_matrix)

#  Correlation Matrix
ggcorrplot(correlation_matrix, hc.order = TRUE, type = "lower", lab = TRUE) +
  ggtitle("Correlation Matrix for Team Statistics") +
  theme_minimal()

# Boxplots 
ggplot(team_stats, aes(x = factor(playoff), y = points_for)) +
  geom_boxplot(fill = "skyblue") +
  labs(title = "Points Scored by Playoff Participation", x = "Playoff (0 = No, 1 = Yes)", y = "Points Scored") +
  theme_minimal()

ggplot(team_stats, aes(x = factor(playoff), y = yards_for)) +
  geom_boxplot(fill = "lightgreen") +
  labs(title = "Yards Gained by Playoff Participation", x = "Playoff (0 = No, 1 = Yes)", y = "Yards Gained") +
  theme_minimal()

ggplot(team_stats, aes(x = factor(playoff), y = win_percentage)) +
  geom_boxplot(fill = "orange") +
  labs(title = "Win Percentage by Playoff Participation", x = "Playoff (0 = No, 1 = Yes)", y = "Win Percentage") +
  theme_minimal()

# Histograms for Variables
ggplot(team_stats, aes(x = points_for, fill = factor(playoff))) +
  geom_histogram(binwidth = 100, position = "identity", alpha = 0.7) +
  labs(title = "Distribution of Points Scored", x = "Points Scored", y = "Frequency") +
  theme_minimal()

ggplot(team_stats, aes(x = yards_for, fill = factor(playoff))) +
  geom_histogram(binwidth = 200, position = "identity", alpha = 0.7) +
  labs(title = "Distribution of Yards Gained", x = "Yards Gained", y = "Frequency") +
  theme_minimal()

#  Testing
t_test_win <- t.test(win_percentage ~ playoff, data = team_stats)
t_test_points <- t.test(points_for ~ playoff, data = team_stats)
t_test_yards <- t.test(yards_for ~ playoff, data = team_stats)

print("T-Test Results for Win Percentage:")
print(t_test_win)

print("T-Test Results for Points Scored:")
print(t_test_points)

print("T-Test Results for Yards Gained:")
print(t_test_yards)

# Confidence Intervals
ci_points_for <- t_test_points$conf.int
ci_yards_for <- t_test_yards$conf.int

print("Confidence Interval for Points For:")
print(ci_points_for)

print("Confidence Interval for Yards For:")
print(ci_yards_for)

# Save Final Dataset
write.csv(team_stats, "final_team_stats.csv", row.names = FALSE)
print("Final dataset saved to 'final_team_stats.csv'")

