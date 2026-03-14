# ==============================================================================
# DATA_PROCESSING.R - Data Processing and Analysis Functions
# ==============================================================================

library(dplyr)

# Activity classification with breakdown
analyze_activity <- function(data) {
  data %>%
    mutate(activity_level = classify_activity(steps)) %>%
    group_by(activity_level) %>%
    summarise(
      days = n(),
      avg_steps = round(mean(steps), 0),
      avg_calories = round(mean(calories), 1),
      avg_distance = round(mean(distance), 2),
      avg_sleep = round(mean(sleep_hours), 1),
      .groups = "drop"
    ) %>%
    mutate(activity_level = factor(activity_level, levels = c("Low", "Moderate", "High"))) %>%
    arrange(activity_level)
}

# Sleep pattern analysis
analyze_sleep <- function(data) {
  data %>%
    mutate(sleep_quality = classify_sleep_quality(sleep_hours)) %>%
    group_by(sleep_quality) %>%
    summarise(
      days = n(),
      avg_steps = round(mean(steps), 0),
      avg_calories = round(mean(calories), 1),
      .groups = "drop"
    )
}

# Weekly breakdown
get_weekly_breakdown <- function(data) {
  data %>%
    mutate(week_start = floor_date(date, "week")) %>%
    group_by(week_start) %>%
    summarise(
      total_steps = sum(steps),
      avg_daily_steps = round(mean(steps), 0),
      total_distance = round(sum(distance), 2),
      avg_calories = round(mean(calories), 1),
      avg_sleep = round(mean(sleep_hours), 1),
      days_high_activity = sum(steps > ACTIVITY_THRESHOLDS$moderate),
      .groups = "drop"
    )
}

# Daily breakdown
get_daily_breakdown <- function(data) {
  data %>%
    mutate(
      activity_level = classify_activity(steps),
      day_name = format(date, "%A"),
      week_day = factor(day_name, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
    ) %>%
    arrange(date)
}

# Key insights calculation
calculate_insights <- function(data) {
  summary_stats <- get_summary_stats(data)
  
  # Activity insights
  most_active_day <- data[which.max(data$steps), ]
  least_active_day <- data[which.min(data$steps), ]
  
  # Sleep insights
  good_sleep_days <- sum(data$sleep_hours >= SLEEP_GUIDELINES$min_hours & 
                         data$sleep_hours <= SLEEP_GUIDELINES$max_hours)
  good_sleep_pct <- (good_sleep_days / nrow(data)) * 100
  
  # Correlations
  correlation_steps_calories <- cor(data$steps, data$calories)
  correlation_steps_sleep <- cor(data$steps, data$sleep_hours)
  
  # Trends
  first_week_avg <- mean(data$steps[1:min(7, nrow(data))])
  last_week_avg <- mean(tail(data$steps, min(7, nrow(data))))
  trend <- ((last_week_avg - first_week_avg) / first_week_avg) * 100
  
  list(
    summary = summary_stats,
    most_active_day = most_active_day,
    least_active_day = least_active_day,
    good_sleep_pct = good_sleep_pct,
    correlation_steps_calories = correlation_steps_calories,
    correlation_steps_sleep = correlation_steps_sleep,
    trend = trend,
    activity_breakdown = analyze_activity(data),
    sleep_breakdown = analyze_sleep(data)
  )
}

# Recommendations engine
generate_recommendations <- function(data, insights) {
  recommendations <- list()
  
  avg_steps <- insights$summary$avg_steps
  trend <- insights$trend
  good_sleep_pct <- insights$good_sleep_pct
  
  # Activity recommendation
  if (avg_steps < 5000) {
    recommendations$activity <- list(
      icon = "",
      text = "Low activity detected. Aim for at least 10,000 steps daily.",
      severity = "danger"
    )
  } else if (avg_steps < 10000) {
    recommendations$activity <- list(
      icon = "",
      text = "Good activity! Try to increase to 12,000+ steps.",
      severity = "warning"
    )
  } else {
    recommendations$activity <- list(
      icon = "",
      text = "Excellent! Consistently exceeding activity goals.",
      severity = "success"
    )
  }
  
  # Sleep recommendation
  if (good_sleep_pct < 40) {
    recommendations$sleep <- list(
      icon = "",
      text = "Improve sleep consistency. Aim for 7-9 hours nightly.",
      severity = "danger"
    )
  } else if (good_sleep_pct < 70) {
    recommendations$sleep <- list(
      icon = "",
      text = "Better sleep rhythm. Almost there!",
      severity = "warning"
    )
  } else {
    recommendations$sleep <- list(
      icon = "",
      text = "Excellent sleep consistency maintained.",
      severity = "success"
    )
  }
  
  # Consistency recommendation
  step_sd <- insights$summary$step_sd
  if (step_sd > 3000) {
    recommendations$consistency <- list(
      icon = "",
      text = "Maintain more consistent daily activity levels.",
      severity = "info"
    )
  } else {
    recommendations$consistency <- list(
      icon = "",
      text = "Great consistency in daily activity.",
      severity = "success"
    )
  }
  
  # Trend recommendation
  if (trend > 10) {
    recommendations$trend <- list(
      icon = "",
      text = paste0("Great momentum! +", round(trend, 1), "% increase trend."),
      severity = "success"
    )
  } else if (trend < -10) {
    recommendations$trend <- list(
      icon = "",
      text = paste0("Activity declining. Focus on increasing daily movement."),
      severity = "warning"
    )
  } else {
    recommendations$trend <- list(
      icon = "",
      text = "Steady activity level maintained.",
      severity = "info"
    )
  }
  
  recommendations
}
