# ==============================================================================
# UTILS.R - Utility Functions
# ==============================================================================

# Data Validation
validate_fitness_data <- function(df) {
  # Check if required columns exist
  missing_cols <- setdiff(REQUIRED_COLUMNS, names(df))
  if (length(missing_cols) > 0) {
    return(list(
      valid = FALSE,
      error = paste("Missing columns:", paste(missing_cols, collapse = ", "))
    ))
  }
  
  # Try to convert columns to appropriate types
  tryCatch({
    df <- df %>%
      mutate(
        date = as.Date(date),
        steps = as.numeric(steps),
        calories = as.numeric(calories),
        distance = as.numeric(distance),
        sleep_hours = as.numeric(sleep_hours)
      )
    
    # Check for rows with all NAs
    df <- df %>% na.omit()
    
    if (nrow(df) == 0) {
      return(list(
        valid = FALSE,
        error = "No valid data after cleaning"
      ))
    }
    
    return(list(
      valid = TRUE,
      data = df %>% arrange(date),
      rows = nrow(df)
    ))
  }, error = function(e) {
    return(list(
      valid = FALSE,
      error = paste("Data conversion error:", e$message)
    ))
  })
}

# Format large numbers with commas
format_number <- function(x, digits = 1) {
  format(round(x, digits), big.mark = ",", trim = TRUE)
}

# Format numbers with K/M suffix
format_compact <- function(x) {
  if (x >= 1000000) {
    return(paste0(round(x / 1000000, 1), "M"))
  } else if (x >= 1000) {
    return(paste0(round(x / 1000, 1), "K"))
  } else {
    return(format(round(x, 0), big.mark = ","))
  }
}

# Classify activity level
classify_activity <- function(steps) {
  case_when(
    steps < ACTIVITY_THRESHOLDS$low ~ "Low",
    steps >= ACTIVITY_THRESHOLDS$low & steps <= ACTIVITY_THRESHOLDS$moderate ~ "Moderate",
    steps > ACTIVITY_THRESHOLDS$moderate ~ "High"
  )
}

# Get activity color
get_activity_color <- function(level) {
  case_when(
    level == "Low" ~ COLORS$danger,
    level == "Moderate" ~ COLORS$warning,
    level == "High" ~ COLORS$success
  )
}

# Classify sleep quality
classify_sleep_quality <- function(hours) {
  case_when(
    hours < 5 ~ "Poor",
    hours >= 5 & hours < 7 ~ "Fair",
    hours >= SLEEP_GUIDELINES$min_hours & hours <= SLEEP_GUIDELINES$max_hours ~ "Good",
    hours > 9 ~ "Excessive",
    TRUE ~ "Fair"
  )
}

# Get sleep quality color
get_sleep_color <- function(hours) {
  quality <- classify_sleep_quality(hours)
  case_when(
    quality == "Poor" ~ COLORS$danger,
    quality == "Fair" ~ COLORS$warning,
    quality == "Good" ~ COLORS$success,
    quality == "Excessive" ~ COLORS$secondary
  )
}

# Calculate moving average efficiently
calc_moving_avg <- function(x, window = 7) {
  library(zoo)
  zoo::rollmean(x, k = window, fill = NA, align = "right")
}

# Format percentage
format_percentage <- function(x, digits = 1) {
  paste0(round(x * 100, digits), "%")
}

# Create a professional card wrapper
create_info_box <- function(title, value, icon = "", color = COLORS$primary) {
  icon_html <- ""
  if (!is.null(icon) && nzchar(icon)) {
    # icons disabled: do not render <i> elements
    icon_html <- ""
  }

  HTML(
    sprintf(
      '<div class="info-box" style="border-left: 4px solid %s; display: flex; align-items: center; gap: 0.5rem;">
         %s
         <div>
           <p style="color: #7f8c8d; margin-bottom: 0.25rem;">%s</p>
           <h4 style="color: %s; margin: 0;">%s</h4>
         </div>
       </div>',
      color, icon_html, title, color, value
    )
  )
}

# Create metric card
metric_card <- function(metric, value, change = NULL) {
  class <- if (!is.null(change) && change > 0) "positive" else if (!is.null(change)) "negative" else ""
  HTML(
    sprintf(
      '<div class="metric-card %s">
         <div class="metric-label">%s</div>
         <div class="metric-value">%s</div>
         %s
       </div>',
      class, metric, value,
      ifelse(!is.null(change),
        sprintf('<div class="metric-change">%s</div>', 
                ifelse(change > 0, paste0("+", change, "%"), paste0(change, "%"))),
        "")
    )
  )
}

# Summary statistics
get_summary_stats <- function(df) {
  list(
    total_days = nrow(df),
    date_range = paste(min(df$date), "to", max(df$date)),
    total_steps = sum(df$steps),
    avg_steps = mean(df$steps),
    total_calories = sum(df$calories),
    avg_calories = mean(df$calories),
    total_distance = sum(df$distance),
    avg_distance = mean(df$distance),
    avg_sleep = mean(df$sleep_hours),
    max_steps = max(df$steps),
    min_steps = min(df$steps),
    step_sd = sd(df$steps)
  )
}
