# Quick Setup Guide

## Prerequisites

- R 4.0 or higher
- RStudio (recommended but not required)

## Step 1: Install Required Packages

Run this in your R console:

```r
# Install all required packages at once
packages <- c("shiny", "bslib", "plotly", "dplyr", "DT", "ggplot2", "zoo")
install.packages(packages)
```

Alternative: Install packages individually:
```r
install.packages("shiny")
install.packages("bslib")
install.packages("plotly")
install.packages("dplyr")
install.packages("DT")
install.packages("ggplot2")
install.packages("zoo")
```

## Step 2: Load and Run the App

### Option A: From RStudio
1. Open `app.R` in RStudio
2. Click the **"Run App"** button in the top-right corner
3. The dashboard will open in your browser

### Option B: From R Console
```r
shiny::runApp("path/to/smart_fitness_traker/app.R")

# Or if you're already in the project directory:
setwd("path/to/smart_fitness_traker")
shiny::runApp()
```

### Option C: Direct Run
```r
source("app.R")
```

## Step 3: Test with Sample Data

1. Once the app opens, click the **"Data Management"** section in the sidebar
2. Click **"Upload Fitness Data (CSV)"**
3. Select the provided `sample_fitness_data.csv` file
4. The dashboard will populate with sample data

## Step 4: Use Your Own Data

Create a CSV file with these columns:
- **date**: Format as YYYY-MM-DD
- **steps**: Numeric values
- **calories**: Numeric values
- **distance**: Numeric values
- **sleep_hours**: Numeric values

Example:
```
date,steps,calories,distance,sleep_hours
2024-03-01,9500,450,7.2,7.5
2024-03-02,11200,520,8.9,8.0
```

## Troubleshooting

### "Package not found" error
- Ensure all packages are installed: `install.packages("package_name")`
- Restart R session: Session → Restart R

### "File not found" error
- Double-check the file path is correct
- Use full absolute paths: `C:/Users/YourName/project/app.R`

### Charts not showing
- Make sure data is loaded first
- Check that CSV file has all required columns
- Verify date format is YYYY-MM-DD

### App won't start
```r
# Check if Shiny is working
library(shiny)
runExample("01_hello")  # This should work if Shiny is installed correctly
```

## File Structure

```
smart_fitness_traker/
├── app.R                      # Main application file
├── README.md                  # Full documentation
├── SETUP.md                   # This file
└── sample_fitness_data.csv   # Sample data for testing
```

## Next Steps

1. **Customize Colors**: Edit the `bs_theme()` section in app.R
2. **Add More Tabs**: Follow the pattern in the `nav_panel()` sections
3. **Deploy**: Use Shiny Server or shinyapps.io for online hosting

## Resources

- [Shiny Documentation](https://shiny.rstudio.com/)
- [bslib Documentation](https://rstudio.github.io/bslib/)
- [Plotly R Documentation](https://plotly.com/r/)
- [dplyr Cheatsheet](https://dplyr.tidyverse.org/)

## Performance Tips

- The app handles datasets with 50,000+ rows
- For larger datasets, consider data pagination
- Use the Data Explorer tab for full dataset browsing

---

**Ready to go!** 🚀 Upload your fitness data and start exploring your health insights.
