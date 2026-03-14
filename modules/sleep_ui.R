# ==============================================================================
# modules/sleep_ui.R - Sleep Analytics (Clean Layout)
# ==============================================================================

sleep_ui <- function(id) {
  ns <- NS(id)

  tagList(
    layout_columns(
      card(
        card_header("Sleep Distribution"),
        card_body(plotly::plotlyOutput(ns("histChart"), height = "380px"))
      ),
      card(
        card_header("Sleep Quality Breakdown"),
        card_body(tableOutput(ns("qualityTable")))
      ),
      col_widths = c(7, 5)
    ),

    layout_columns(
      card(
        card_header("Sleep vs Steps Correlation"),
        card_body(plotly::plotlyOutput(ns("sleepVsStepsChart"), height = "380px"))
      ),
      card(
        card_header("Sleep Metrics Summary"),
        card_body(tableOutput(ns("analysisTable")))
      ),
      col_widths = c(7, 5)
    )
  )
}

sleep_server <- function(id, shared_data) {
  moduleServer(id, function(input, output, session) {
    output$histChart <- plotly::renderPlotly({ req(shared_data$data()); plot_sleep_histogram(shared_data$data()) })
    output$qualityTable <- renderTable({ req(shared_data$data()); analyze_sleep(shared_data$data()) }, striped = TRUE, hover = TRUE)
    output$sleepVsStepsChart <- plotly::renderPlotly({ req(shared_data$data()); plot_sleep_vs_steps(shared_data$data()) })
    output$analysisTable <- renderTable({
      req(shared_data$data()); df <- shared_data$data()
      data.frame(
        Metric = c("Average Sleep", "Min Sleep", "Max Sleep", "Std Deviation", "Healthy Sleep (7-9h)", "Poor Sleep (<5h)"),
        Value = c(
          paste0(round(mean(df$sleep_hours), 1), " hrs"),
          paste0(round(min(df$sleep_hours), 1), " hrs"),
          paste0(round(max(df$sleep_hours), 1), " hrs"),
          paste0(round(sd(df$sleep_hours), 1), " hrs"),
          paste0(sum(df$sleep_hours >= 7 & df$sleep_hours <= 9), " days"),
          paste0(sum(df$sleep_hours < 5), " days")
        )
      )
    }, striped = TRUE, hover = TRUE)
  })
}
