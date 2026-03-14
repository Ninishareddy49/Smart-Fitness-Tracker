# ==============================================================================
# SMART FITNESS TRACKER - MAIN APPLICATION
# Production-Ready Shiny App with Premium UI
# ==============================================================================

library(shiny)
library(bslib)
library(plotly)
library(dplyr)
library(DT)
library(ggplot2)

# Load configuration and utilities
source("R/config.R")
source("R/utils.R")
source("R/plots.R")
source("R/data_processing.R")

# Load UI modules
source("modules/dashboard_ui.R")
source("modules/activity_ui.R")
source("modules/sleep_ui.R")
source("modules/explorer_ui.R")
source("modules/insights_ui.R")

# ==============================================================================
# UI DEFINITION
# ==============================================================================

ui <- page_navbar(
  title = tags$span(
    tags$span("SmartFit", style = "font-weight:800;"),
    tags$span("PRO", style = "color:#00d4ff; font-weight:800;")
  ),

  theme = bs_theme(
    version = 5,
    bg = "#0d1117",
    fg = "#e6edf3",
    primary = "#00d4ff",
    secondary = "#5a6eff",
    success = "#00f5a7",
    danger = "#ff4b5c",
    warning = "#ffb300",
    info = "#00d4ff",
    base_font = font_google("Poppins"),
    heading_font = font_google("Poppins"),
    "navbar-bg" = "#0d1117",
    "body-bg" = "#0d1117",
    "card-bg" = "rgba(22, 27, 34, 0.95)"
  ),

  header = tags$head(
    tags$link(rel = "stylesheet", href = "css/styles.css"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$script(src = "js/main.js")
  ),

  # PAGE 1: DASHBOARD
  nav_panel(
    title = "Dashboard",
    icon = tags$svg(
      width = "16", height = "16", viewBox = "0 0 24 24",
      fill = "none", stroke = "currentColor", `stroke-width` = "2",
      tags$rect(x = "3", y = "3", width = "7", height = "7"),
      tags$rect(x = "14", y = "3", width = "7", height = "7"),
      tags$rect(x = "14", y = "14", width = "7", height = "7"),
      tags$rect(x = "3", y = "14", width = "7", height = "7")
    ),
    dashboard_ui("dashboard")
  ),

  # PAGE 2: ACTIVITY
  nav_panel(
    title = "Activity",
    icon = tags$svg(
      width = "16", height = "16", viewBox = "0 0 24 24",
      fill = "none", stroke = "currentColor", `stroke-width` = "2",
      tags$polyline(points = "22 12 18 12 15 21 9 3 6 12 2 12")
    ),
    activity_ui("activity")
  ),

  # PAGE 3: SLEEP
  nav_panel(
    title = "Sleep",
    icon = tags$svg(
      width = "16", height = "16", viewBox = "0 0 24 24",
      fill = "none", stroke = "currentColor", `stroke-width` = "2",
      tags$path(d = "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z")
    ),
    sleep_ui("sleep")
  ),

  # PAGE 4: DATA
  nav_panel(
    title = "Data",
    icon = tags$svg(
      width = "16", height = "16", viewBox = "0 0 24 24",
      fill = "none", stroke = "currentColor", `stroke-width` = "2",
      tags$ellipse(cx = "12", cy = "5", rx = "9", ry = "3"),
      tags$path(d = "M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"),
      tags$path(d = "M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5")
    ),
    explorer_ui("explorer")
  ),

  # PAGE 5: INSIGHTS
  nav_panel(
    title = "Insights",
    icon = tags$svg(
      width = "16", height = "16", viewBox = "0 0 24 24",
      fill = "none", stroke = "currentColor", `stroke-width` = "2",
      tags$path(d = "M13 2L3 14h9l-1 8 10-12h-9l1-8z")
    ),
    insights_ui("insights")
  )
)

# ==============================================================================
# SERVER DEFINITION
# ==============================================================================

server <- function(input, output, session) {
  dashboard_out <- dashboard_server("dashboard")
  activity_server("activity", dashboard_out)
  sleep_server("sleep", dashboard_out)
  explorer_server("explorer", dashboard_out)
  insights_server("insights", dashboard_out)
}

# ==============================================================================
# RUN APPLICATION
# ==============================================================================

shinyApp(ui = ui, server = server)
