# NFL Team Performance Analysis (2018–2022)  
A statistical analysis of NFL team performance metrics to identify key factors contributing to playoff success. This project utilizes play-by-play and schedule data from the `nflverse` R package to explore the relationship between yards gained, points scored, win percentage, and playoff participation.  

## Project Overview  
The goal of this project is to analyze team-level performance across NFL seasons (2018–2022) and determine which metrics correlate most strongly with playoff success. Through exploratory data analysis (EDA), hypothesis testing, and visualization, this project provides insights into the key indicators of winning teams.  

## Key Features  
- **Data Sources**: NFL play-by-play and schedule data (2018–2022) using `nflverse`.  
- **Metrics Analyzed**: Passing yards, rushing yards, total yards gained, points scored, win percentage, and playoff participation.  
- **Techniques**:  
  - Correlation analysis  
  - Welch’s t-tests comparing playoff vs. non-playoff teams  
  - Boxplots and histograms for visualization  
- **Adjustments**: Points scored and allowed were adjusted by dividing by the standard NFL roster size (53).  

## Tools and Libraries  
- **R** (Primary Language)  
- **Packages**: `tidyverse`, `nflverse`, `ggcorrplot`  

## Visualizations  
- Correlation matrix of team performance metrics  
- Boxplots for win percentage, yards gained, and points scored by playoff participation  
- Histograms showing distribution of yards and points by playoff status  

## Results  
- Teams that made the playoffs had significantly higher average points scored, yards gained, and win percentages.  
- Strong correlations exist between points scored and win percentage ($r = 0.80$).  
- Significant differences between playoff and non-playoff teams in key metrics were confirmed by hypothesis testing (p < $2.2 \times 10^{-16}$).  

## How to Run the Analysis  
1. Clone the repository:  
   ```bash
   git clone https://github.com/your-username/nfl-team-analysis.git
