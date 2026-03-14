# ==============================================================================
# modules/activity_ui.R - Activity Analytics (Clean Layout)
# ==============================================================================

activity_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # Row 1 - Main Charts
    layout_columns(
      card(
        card_header("Activity Level Distribution"),
        card_body(plotly::plotlyOutput(ns("activityDistChart"), height = "380px"))
      ),
      card(
        card_header("Activity Statistics"),
        card_body(tableOutput(ns("activityTable")))
      ),
      col_widths = c(7, 5)
    ),

    # Row 2
    layout_columns(
      card(
        card_header("Weekly Step Totals"),
        card_body(plotly::plotlyOutput(ns("weeklyChart"), height = "380px"))
      ),
      card(
        card_header("7-Day Moving Average"),
        card_body(plotly::plotlyOutput(ns("maChart"), height = "380px"))
      ),
      col_widths = c(6, 6)
    ),

    # Row 3 - Heatmap Full Width
    card(
      card_header("Activity Heatmap"),
      card_body(plotly::plotlyOutput(ns("heatmapChart"), height = "400px"))
    )
  )
}

activity_server <- function(id, shared_data) {
  moduleServer(id, function(input, output, session) {
    output$activityDistChart <- plotly::renderPlotly({ req(shared_data$data()); plot_activity_distribution(shared_data$data()) })
    output$activityTable     <- renderTable({ req(shared_data$data()); analyze_activity(shared_data$data()) }, striped = TRUE, hover = TRUE, digits = 1)
    output$weeklyChart       <- plotly::renderPlotly({ req(shared_data$data()); plot_weekly_activity(shared_data$data()) })
    output$maChart           <- plotly::renderPlotly({ req(shared_data$data()); plot_moving_average(shared_data$data()) })
    output$heatmapChart      <- plotly::renderPlotly({ req(shared_data$data()); plot_activity_heatmap(shared_data$data()) })
  })
}
