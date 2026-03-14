# Validation script to check if app.R runs without errors
tryCatch({
  source("app.R")
  cat("✓ App loaded successfully!\n")
  cat("✓ Ready to run: shiny::runApp()\n")
}, error = function(e) {
  cat("✗ Error found:\n")
  cat(e$message, "\n")
})
