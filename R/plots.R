# ==============================================================================
# PLOTS.R - All Chart and Visualization Functions
# ==============================================================================

library(plotly)
library(dplyr)

# Base Plotly theme
theme_fitness_plot <- function() {
  list(
    font = list(family = "Poppins, sans-serif", color = "#e6edf3", size = 12),
    plot_bgcolor = "#161b22",
    paper_bgcolor = "#0d1117",
    margin = list(l = 50, r = 50, t = 30, b = 50)
  )
}

# Daily steps trend with gradient fill
plot_steps_trend <- function(data) {
  plot_ly(
    data = data,
    x = ~date,
    y = ~steps,
    type = "scatter",
    mode = "lines+markers",
    fill = "tozeroy",
    line = list(color = COLORS$primary, width = 3),
    marker = list(size = 6, color = COLORS$primary, opacity = 0.8),
    fillcolor = paste0(COLORS$primary, "19"),
    hovertemplate = "<b>%{x|%B %d, %Y}</b><br>Steps: %{y:,}<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      yaxis = list(title = "Steps", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)" ),
      hovermode = "x unified",
      theme_fitness_plot()
    )
}

# Distance trend chart
plot_distance_trend <- function(data) {
  plot_ly(
    data = data,
    x = ~date,
    y = ~distance,
    type = "scatter",
    mode = "lines+markers",
    fill = "tozeroy",
    line = list(color = COLORS$success, width = 3),
    marker = list(size = 6, color = COLORS$success, opacity = 0.8),
    fillcolor = paste0(COLORS$success, "19"),
    hovertemplate = "<b>%{x|%B %d, %Y}</b><br>Distance: %{y:.2f} km<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      yaxis = list(title = "Distance (km)", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      hovermode = "x unified",
      theme_fitness_plot()
    )
}

# Calories vs Steps scatter
plot_calories_vs_steps <- function(data) {
  plot_ly(
    data = data,
    x = ~steps,
    y = ~calories,
    type = "scatter",
    mode = "markers",
    marker = list(
      size = 10,
      color = ~distance,
      colorscale = "Viridis",
      showscale = TRUE,
      colorbar = list(title = "Distance<br>(km)"),
      opacity = 0.8
    ),
    text = ~paste0("<b>", format(date, "%b %d"), "</b><br>",
                   "Steps: ", format_number(steps), "<br>",
                   "Calories: ", format_number(calories), "<br>",
                   "Distance: ", round(distance, 2), " km"),
    hovertemplate = "%{text}<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "Steps", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      yaxis = list(title = "Calories (kcal)", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      hovermode = "closest",
      theme_fitness_plot()
    )
}

# Sleep distribution histogram
plot_sleep_histogram <- function(data) {
  plot_ly(
    x = data$sleep_hours,
    type = "histogram",
    nbinsx = 15,
    xbins = list(size = 0.5), # Fix for "Something went wrong with axis scaling"
    marker = list(color = COLORS$info, opacity = 0.8),
    hovertemplate = "Sleep: %{x:.1f} - %{x+0.5:.1f} hrs<br>Days: %{y}<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "Sleep Hours", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      yaxis = list(title = "Frequency (Days)", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      theme_fitness_plot(),
      showlegend = FALSE
    )
}

# Activity level distribution bar chart
plot_activity_distribution <- function(data) {
  data_with_level <- data %>%
    mutate(activity_level = classify_activity(steps)) %>%
    group_by(activity_level) %>%
    summarise(count = n(), .groups = "drop") %>%
    mutate(activity_level = factor(activity_level, levels = c("Low", "Moderate", "High"))) %>%
    arrange(activity_level) %>%
    mutate(color = sapply(activity_level, get_activity_color))
  
  plot_ly(
    data = data_with_level,
    x = ~activity_level,
    y = ~count,
    type = "bar",
    marker = list(color = ~color),
    hovertemplate = "<b>%{x} Activity</b><br>Days: %{y}<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "Activity Level"),
      yaxis = list(title = "Number of Days", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      theme_fitness_plot(),
      showlegend = FALSE
    )
}

# Weekly activity trend
plot_weekly_activity <- function(data) {
  weekly_data <- data %>%
    mutate(
      week_num = as.numeric(format(date, "%V")),
      year = format(date, "%Y")
    ) %>%
    group_by(year, week_num) %>%
    summarise(total_steps = sum(steps), .groups = "drop") %>%
    mutate(label = paste0("W", week_num, "-", year)) %>%
    filter(!is.na(week_num) & !is.na(total_steps) & total_steps > 0)
  
  if(nrow(weekly_data) == 0) {
    return(plotly::plot_ly() %>% layout(title = "No data available"))
  }
  
  plot_ly(
    data = weekly_data,
    x = ~label,
    y = ~total_steps,
    type = "bar",
    marker = list(color = COLORS$primary, opacity = 0.8),
    hovertemplate = "<b>%{x}</b><br>Steps: %{y:,}<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "Week", showgrid = FALSE, categoryorder = "array", categoryarray = ~label),
      yaxis = list(title = "Total Steps", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      theme_fitness_plot(),
      showlegend = FALSE
    )
}

# Moving average chart
plot_moving_average <- function(data) {
  ma_data <- data %>%
    arrange(date) %>%
    mutate(ma_steps = calc_moving_avg(steps, window = 7)) %>%
    filter(!is.na(ma_steps))
  
  if(nrow(ma_data) == 0) {
    return(plotly::plot_ly() %>% layout(title = "No data available"))
  }
  
  plot_ly(
    data = ma_data,
    x = ~date
  ) %>%
    add_trace(
      y = ~steps,
      name = "Daily Steps",
      type = "scatter",
      mode = "lines",
      line = list(color = paste0(COLORS$primary, "40"), width = 1),
      hovertemplate = "<b>%{x|%B %d}</b><br>Steps: %{y:,}<extra></extra>"
    ) %>%
    add_trace(
      y = ~ma_steps,
      name = "7-Day Moving Avg",
      type = "scatter",
      mode = "lines",
      line = list(color = COLORS$danger, width = 3),
      hovertemplate = "<b>%{x|%B %d}</b><br>MA: %{y:,.0f}<extra></extra>"
    ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      yaxis = list(title = "Steps", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      hovermode = "x unified",
      theme_fitness_plot()
    )
}

# Sleep vs Steps correlation
plot_sleep_vs_steps <- function(data) {
  plot_ly(
    data = data,
    x = ~sleep_hours,
    y = ~steps,
    type = "scatter",
    mode = "markers",
    marker = list(
      size = 10,
      color = ~calories,
      colorscale = "Plasma",
      showscale = TRUE,
      colorbar = list(title = "Calories"),
      opacity = 0.8
    ),
    text = ~paste0("<b>", format(date, "%b %d"), "</b><br>",
                   "Sleep: ", round(sleep_hours, 1), " hrs<br>",
                   "Steps: ", format_number(steps)),
    hovertemplate = "%{text}<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "Sleep Hours", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      yaxis = list(title = "Steps", showgrid = TRUE, gridwidth = 1, gridcolor = "rgba(255,255,255,0.1)"),
      hovermode = "closest",
      theme_fitness_plot()
    )
}

# Heatmap of daily activity
plot_activity_heatmap <- function(data) {
  day_order <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
  
  heatmap_data <- data %>%
    mutate(
      week = as.numeric(format(date, "%V")),
      day = factor(format(date, "%a"), levels = day_order),
      activity_level = classify_activity(steps)
    ) %>%
    group_by(week, day) %>%
    summarise(avg_steps = round(mean(steps), 0), .groups = "drop") %>%
    filter(!is.na(week) & !is.na(day) & !is.na(avg_steps)) %>%
    mutate(
      week = as.character(week),
      day = as.character(day)
    )
  
  if(nrow(heatmap_data) == 0) {
    return(plotly::plot_ly() %>% layout(title = "No data available"))
  }
  
  plot_ly(
    data = heatmap_data,
    x = ~day,
    y = ~week,
    z = ~avg_steps,
    type = "heatmap",
    colorscale = "Viridis",
    hovertemplate = "<b>Week %{y}, %{x}</b><br>Avg Steps: %{z:,.0f}<extra></extra>"
  ) %>%
    layout(
      title = list(text = "", x = 0, xanchor = "left"),
      xaxis = list(title = "Day of Week", categoryorder = "array", categoryarray = day_order),
      yaxis = list(title = "Week Number"),
      theme_fitness_plot()
    )
}
