# ==============================================================================
# CONFIG.R - Application Configuration
# ==============================================================================

# Application Settings
APP_NAME <- "Smart Fitness Tracker Dashboard"
APP_VERSION <- "2.0.0"

# Colors Theme
COLORS <- list(
  primary = "#1f77b4",
  secondary = "#ff7f0e",
  success = "#2ca02c",
  danger = "#d62728",
  warning = "#ff9800",
  info = "#17a2b8",
  dark = "#1a1a2e",
  light = "#f8f9fa",
  bg_gradient_1 = "#f5f7fa",
  bg_gradient_2 = "#c3cfe2"
)

# Activity Level Thresholds
ACTIVITY_THRESHOLDS <- list(
  low = 5000,
  moderate = 10000
)

# Sleep Quality Guidelines
SLEEP_GUIDELINES <- list(
  min_hours = 7,
  max_hours = 9,
  excellent_min = 8,
  excellent_max = 8
)

# Required CSV Columns
REQUIRED_COLUMNS <- c("date", "steps", "calories", "distance", "sleep_hours")

# Icons for different metrics
METRIC_ICONS <- list(
  steps = "",
  calories = "",
  distance = "",
  sleep = "",
  heart = "",
  activity = ""
)
