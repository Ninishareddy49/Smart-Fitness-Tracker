# ==============================================================================
# modules/insights_ui.R - Insights & Recommendations (Clean Layout)
# ==============================================================================

insights_ui <- function(id) {
  ns <- NS(id)

  tagList(
    layout_columns(
      card(
        card_header("Key Findings"),
        card_body(uiOutput(ns("keyInsights")))
      ),
      card(
        card_header("Recommendations"),
        card_body(uiOutput(ns("recommendations")))
      ),
      col_widths = c(6, 6)
    ),

    card(
      card_header("Correlation Analytics"),
      card_body(
        layout_columns(
          uiOutput(ns("insight1")),
          uiOutput(ns("insight2")),
          uiOutput(ns("insight3")),
          col_widths = c(4, 4, 4)
        )
      )
    )
  )
}

insights_server <- function(id, shared_data) {
  moduleServer(id, function(input, output, session) {

    insights <- reactive({ req(shared_data$data()); calculate_insights(shared_data$data()) })
    recommendations <- reactive({ req(insights()); generate_recommendations(shared_data$data(), insights()) })

    output$keyInsights <- renderUI({
      req(insights()); ins <- insights()
      tagList(
        tags$div(class = "insight-item",
          tags$h6("Peak Performance", style = "color:#00f5a7; font-weight:700;"),
          tags$p(tags$strong(format(ins$most_active_day$date, "%A, %B %d")), tags$br(),
            format_number(ins$most_active_day$steps), " steps")
        ),
        tags$hr(style = "border-color:rgba(255,255,255,0.08);"),
        tags$div(class = "insight-item",
          tags$h6("Lowest Activity", style = "color:#ff4b5c; font-weight:700;"),
          tags$p(tags$strong(format(ins$least_active_day$date, "%A, %B %d")), tags$br(),
            format_number(ins$least_active_day$steps), " steps")
        ),
        tags$hr(style = "border-color:rgba(255,255,255,0.08);"),
        tags$div(class = "insight-item",
          tags$h6("Daily Average", style = "color:#00d4ff; font-weight:700;"),
          tags$p(format_number(round(ins$summary$avg_steps, 0)), " steps", tags$br(),
            tags$span(classify_activity(ins$summary$avg_steps), style = "opacity:0.7;"))
        ),
        tags$hr(style = "border-color:rgba(255,255,255,0.08);"),
        tags$div(class = "insight-item",
          tags$h6("Sleep Rating", style = "color:#5a6eff; font-weight:700;"),
          tags$p(tags$strong(paste0(round(ins$good_sleep_pct, 0), "%")), " within 7-9hr standard")
        )
      )
    })

    output$recommendations <- renderUI({
      req(recommendations()); recs <- recommendations()
      make_rec <- function(rec) {
        border_color <- switch(rec$severity,
          "success" = "#00f5a7", "warning" = "#ffb300",
          "danger" = "#ff4b5c", "info" = "#00d4ff", "#a0aec0")
        tags$div(
          style = paste0("border-left:4px solid ", border_color, "; padding:12px 16px; margin-bottom:16px; background:rgba(255,255,255,0.02); border-radius:0 8px 8px 0;"),
          tags$p(rec$text, style = "margin:0;")
        )
      }
      tagList(make_rec(recs$activity), make_rec(recs$sleep), make_rec(recs$consistency), make_rec(recs$trend))
    })

    output$insight1 <- renderUI({
      req(insights()); corr <- round(insights()$correlation_steps_calories, 3)
      tags$div(class = "metric-card",
        tags$h6("Steps-Calories", style = "font-weight:700; opacity:0.7;"),
        tags$p(tags$strong(corr), style = "font-size:2rem; margin:8px 0;"),
        tags$p(ifelse(corr > 0.7, "Strong positive correlation",
          ifelse(corr > 0.4, "Moderate correlation", "Weak correlation")),
          style = "font-size:0.85rem; opacity:0.6;")
      )
    })

    output$insight2 <- renderUI({
      req(insights()); corr <- round(insights()$correlation_steps_sleep, 3)
      tags$div(class = "metric-card",
        tags$h6("Steps-Sleep", style = "font-weight:700; opacity:0.7;"),
        tags$p(tags$strong(corr), style = "font-size:2rem; margin:8px 0;"),
        tags$p(ifelse(corr > 0.4, "Activity influences sleep", "Independent patterns"),
          style = "font-size:0.85rem; opacity:0.6;")
      )
    })

    output$insight3 <- renderUI({
      req(insights()); trend <- round(insights()$trend, 1)
      tags$div(class = "metric-card",
        tags$h6("Activity Trend", style = "font-weight:700; opacity:0.7;"),
        tags$p(tags$strong(paste0(ifelse(trend > 0, "+", ""), trend, "%")),
          style = paste0("font-size:2rem; margin:8px 0; color:", ifelse(trend > 0, "#00f5a7", "#ff4b5c"), ";")),
        tags$p(ifelse(trend > 0, "Positive momentum", "Declining activity"),
          style = "font-size:0.85rem; opacity:0.6;")
      )
    })
  })
}
