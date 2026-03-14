# ==============================================================================
# modules/dashboard_ui.R - Dashboard Page (Clean Layout)
# ==============================================================================

dashboard_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      title = tags$span("Control Panel", style = "font-weight:700; font-size:1.1rem;"),
      bg = "transparent",

      # Upload Section
      tags$div(class = "upload-section",
        tags$h6("Upload Dataset", class = "section-label"),
        fileInput(
          ns("fileUpload"),
          label = "Choose CSV file...",
          accept = c("text/csv", ".csv")
        ),
        tags$p("Required: date, steps, calories, distance, sleep_hours",
          class = "text-muted", style = "font-size:0.8rem; margin-top:-8px;"
        )
      ),

      tags$hr(style = "border-color: rgba(255,255,255,0.1);"),

      # Summary Section
      tags$div(class = "summary-section",
        tags$h6("Dataset Summary", class = "section-label"),
        uiOutput(ns("dataSummary"))
      )
    ),

    # MAIN CONTENT
    # Row 1 - KPI Cards
    layout_columns(
      value_box(title = "Total Steps",    value = textOutput(ns("totalSteps")),   theme = "primary"),
      value_box(title = "Avg Calories",   value = textOutput(ns("avgCalories")),  theme = "warning"),
      value_box(title = "Total Distance", value = textOutput(ns("totalDistance")),theme = "success"),
      value_box(title = "Avg Sleep",      value = textOutput(ns("avgSleep")),     theme = "info"),
      col_widths = c(3, 3, 3, 3)
    ),

    # Row 2 - Charts
    layout_columns(
      card(
        card_header("Steps Trend"),
        card_body(plotly::plotlyOutput(ns("stepsChart"), height = "320px"))
      ),
      card(
        card_header("Distance Covered"),
        card_body(plotly::plotlyOutput(ns("distanceChart"), height = "320px"))
      ),
      col_widths = c(6, 6)
    ),

    # Row 3 - More Charts
    layout_columns(
      card(
        card_header("Calories vs Steps"),
        card_body(plotly::plotlyOutput(ns("caloriesVsStepsChart"), height = "320px"))
      ),
      card(
        card_header("Sleep Distribution"),
        card_body(plotly::plotlyOutput(ns("sleepDistChart"), height = "320px"))
      ),
      col_widths = c(6, 6)
    ),

    # Row 4 - Secondary Metrics
    layout_columns(
      value_box(title = "Record Steps",      value = textOutput(ns("mostActiveDay")),     theme = "success"),
      value_box(title = "Activity Level",     value = textOutput(ns("avgDailyActivity")),  theme = "primary"),
      value_box(title = "Sleep Quality",      value = textOutput(ns("sleepQuality")),      theme = "info"),
      value_box(title = "Active Days",        value = textOutput(ns("activityStreak")),    theme = "secondary"),
      col_widths = c(3, 3, 3, 3)
    )
  )
}

dashboard_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    fitness_data <- reactiveVal(NULL)

    # File upload handler
    observeEvent(input$fileUpload, {
      req(input$fileUpload)
      tryCatch({
        df <- read.csv(input$fileUpload$datapath)
        validation <- validate_fitness_data(df)
        if (!validation$valid) {
          showNotification(validation$error, type = "error", duration = 5)
          return()
        }
        fitness_data(validation$data)
        showNotification(
          paste("Data loaded:", validation$rows, "records"),
          type = "message", duration = 3
        )
      }, error = function(e) {
        showNotification(paste("Error:", e$message), type = "error", duration = 5)
      })
    })

    output$dataSummary <- renderUI({
      req(fitness_data())
      df <- fitness_data()
      tagList(
        tags$p(tags$strong("Records: "), format_number(nrow(df))),
        tags$p(tags$strong("Range: "),
          format(min(df$date), "%b %d"), " - ",
          format(max(df$date), "%b %d, %Y")),
        tags$p(tags$strong("Duration: "),
          as.numeric(difftime(max(df$date), min(df$date), units = "days")) + 1, " days")
      )
    })

    # KPIs
    output$totalSteps     <- renderText({ req(fitness_data()); format_compact(sum(fitness_data()$steps)) })
    output$avgCalories    <- renderText({ req(fitness_data()); paste0(round(mean(fitness_data()$calories), 0), " kcal") })
    output$totalDistance  <- renderText({ req(fitness_data()); paste0(round(sum(fitness_data()$distance), 1), " km") })
    output$avgSleep       <- renderText({ req(fitness_data()); paste0(round(mean(fitness_data()$sleep_hours), 1), "h") })
    output$mostActiveDay  <- renderText({ req(fitness_data()); format_compact(max(fitness_data()$steps)) })
    output$avgDailyActivity <- renderText({
      req(fitness_data()); avg <- mean(fitness_data()$steps)
      paste0(format_compact(avg), " (", classify_activity(avg), ")")
    })
    output$sleepQuality <- renderText({
      req(fitness_data()); df <- fitness_data()
      paste0(round((sum(df$sleep_hours >= 7 & df$sleep_hours <= 9)/nrow(df))*100, 0), "%")
    })
    output$activityStreak <- renderText({
      req(fitness_data()); paste0(sum(fitness_data()$steps > ACTIVITY_THRESHOLDS$moderate), " days")
    })

    # Charts
    output$stepsChart          <- plotly::renderPlotly({ req(fitness_data()); plot_steps_trend(fitness_data()) })
    output$distanceChart       <- plotly::renderPlotly({ req(fitness_data()); plot_distance_trend(fitness_data()) })
    output$caloriesVsStepsChart<- plotly::renderPlotly({ req(fitness_data()); plot_calories_vs_steps(fitness_data()) })
    output$sleepDistChart      <- plotly::renderPlotly({ req(fitness_data()); plot_sleep_histogram(fitness_data()) })

    list(data = reactive(fitness_data()))
  })
}
