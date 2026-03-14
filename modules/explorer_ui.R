# ==============================================================================
# modules/explorer_ui.R - Data Explorer (Clean Layout)
# ==============================================================================

explorer_ui <- function(id) {
  ns <- NS(id)
  card(
    card_header("Full Dataset"),
    card_body(DTOutput(ns("dataTable"))),
    full_screen = TRUE
  )
}

explorer_server <- function(id, shared_data) {
  moduleServer(id, function(input, output, session) {
    output$dataTable <- DT::renderDT({
      req(shared_data$data())
      df <- shared_data$data() %>%
        mutate(
          date = format(date, "%Y-%m-%d"),
          steps = format_number(steps),
          calories = round(calories, 1),
          distance = round(distance, 2),
          sleep_hours = round(sleep_hours, 1)
        )
      DT::datatable(
        df,
        options = list(
          pageLength = 25, searchHighlight = TRUE,
          dom = "lBfrtip",
          buttons = c("copy", "csv", "excel", "pdf", "print"),
          columnDefs = list(list(className = "dt-center", targets = "_all"))
        ),
        extensions = c("Buttons", "Scroller"),
        rownames = FALSE, filter = "top"
      )
    })
  })
}
