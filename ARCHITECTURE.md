# 🏛️ ARCHITECTURE DOCUMENTATION

## System Overview

The Smart Fitness Tracker Dashboard is built on a **modular, scalable architecture** designed for production use.

```
┌─────────────────────────────────────────────────────────┐
│                      app.R (Main Entry)                  │
│                    (Minimal - 15 lines)                  │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
    ┌────────────────┐    ┌──────────────────┐
    │  R/ (Logic)    │    │ modules/ (UI)    │
    ├────────────────┤    ├──────────────────┤
    │ config.R       │    │ dashboard_ui.R   │
    │ utils.R        │    │ activity_ui.R    │
    │ plots.R        │    │ sleep_ui.R       │
    │ data_proc.R    │    │ explorer_ui.R    │
    └────────────────┘    │ insights_ui.R    │
                          └──────────────────┘
        │                         │
        └────────────┬────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │  www/ (Styling)        │
        ├────────────────────────┤
        │ css/styles.css         │
        └────────────────────────┘
```

---

## 📦 Core Modules

### 1. **app.R** (Main Application)
**Purpose**: Entry point that ties everything together

**Responsibilities**:
- Load configuration and utilities
- Load UI modules
- Define overall layout with `page_navbar()`
- Initialize server modules
- Apply global theme

**Key Code**:
```r
# Load all dependencies
source("R/config.R")
source("R/utils.R")
source("R/plots.R")
source("R/data_processing.R")

# Load modules
source("modules/dashboard_ui.R")
source("modules/activity_ui.R")
# ... etc

# Main UI
ui <- page_navbar(...)

# Main Server
server <- function(input, output, session) {
  dashboard_out <- dashboard_server("dashboard")
  activity_server("activity", dashboard_out)
  # ... etc
}

shinyApp(ui, server)
```

**Why This Pattern**:
- Single source of truth for module initialization
- Easy to add/remove pages
- Clean separation of concerns
- Minimal main file = easier to maintain

---

### 2. **R/config.R** (Configuration)
**Purpose**: Centralized settings and constants

**Contains**:
- Color palette definitions
- Activity level thresholds
- Sleep quality guidelines
- Required CSV columns
- Icon mappings

**Why This Matters**:
- Change colors in one place
- Adjust thresholds globally
- DRY principle (Don't Repeat Yourself)

**Example**:
```r
COLORS <- list(
  primary = "#1f77b4",
  secondary = "#ff7f0e"
)

ACTIVITY_THRESHOLDS <- list(
  low = 5000,
  moderate = 10000
)
```

---

### 3. **R/utils.R** (Utility Functions)
**Purpose**: Reusable helper functions

**Key Functions**:
- `validate_fitness_data()` - CSV validation
- `format_number()` - Number formatting
- `format_compact()` - Compact format (12K, 1.5M)
- `classify_activity()` - Activity level classification
- `classify_sleep_quality()` - Sleep quality rating
- `calc_moving_avg()` - Moving average calculation
- `get_summary_stats()` - Statistical summary

**Why Modularize**:
- Functions used across multiple modules
- Easy to test independently
- Reusable in other projects
- Clear, focused responsibilities

---

### 4. **R/plots.R** (Visualization Functions)
**Purpose**: All Plotly chart functions

**Chart Functions**:
- `plot_steps_trend()` - Line chart with fill
- `plot_distance_trend()` - Distance over time
- `plot_calories_vs_steps()` - Scatter plot
- `plot_sleep_histogram()` - Distribution  
- `plot_activity_distribution()` - Bar chart
- `plot_weekly_activity()` - Weekly breakdown
- `plot_moving_average()` - 7-day MA trend
- `plot_sleep_vs_steps()` - Correlation
- `plot_activity_heatmap()` - Heatmap

**Base Theme**:
```r
theme_fitness_plot <- function() {
  list(
    font = list(family = "Inter, sans-serif"),
    plot_bgcolor = "#f8f9fa",
    paper_bgcolor = "white",
    margin = list(l = 50, r = 50, t = 30, b = 50)
  )
}
```

**Why Separate**:
- Reusable across modules
- Consistent chart styling
- Easy to update all charts at once
- Reduces code duplication

---

### 5. **R/data_processing.R** (Analysis & Insights)
**Purpose**: Data analysis and insights generation

**Key Functions**:
- `analyze_activity()` - Activity breakdown
- `analyze_sleep()` - Sleep quality analysis
- `get_weekly_breakdown()` - Weekly stats
- `get_daily_breakdown()` - Daily stats
- `calculate_insights()` - Comprehensive analysis
- `generate_recommendations()` - AI suggestions

**Insight Levels**:
1. **Summary Statistics**: Basic aggregations
2. **Classifications**: Activity & sleep quality levels
3. **Correlations**: Relationships between metrics
4. **Trends**: Historical patterns
5. **Recommendations**: Personalized suggestions

---

## 🎨 UI Module Pattern

All modules follow the same pattern:

```r
# UI Function
module_name_ui <- function(id) {
  ns <- NS(id)
  
  # UI elements referencing ns()
  page_content(
    card(output$chart <- plotly::plotlyOutput(ns("chart")))
  )
}

# Server Function
module_name_server <- function(id, shared_data) {
  moduleServer(id, function(input, output, session) {
    # Reactive logic
    output$chart <- plotly::renderPlotly({
      req(shared_data$data())
      plot_function(shared_data$data())
    })
  })
}
```

**Why This Pattern**:
- Namespace isolation (prevents ID conflicts)
- Reusable module code
- Easy to understand and maintain
- Standard Shiny module system

---

## 📊 Module Descriptions

### **Dashboard Module** (`modules/dashboard_ui.R`)
**Purpose**: Overview and data upload

**Features**:
- CSV file upload
- Data validation
- 8 KPI metric boxes
- 4 main charts
- Data summary sidebar

**Exports**:
```r
list(
  data = reactive(fitness_data())
)
```

### **Activity Module** (`modules/activity_ui.R`)
**Purpose**: Activity analytics

**Features**:
- Activity classification
- Weekly breakdown
- 7-day moving average
- Activity heatmap

**Inputs**: Shared data

### **Sleep Module** (`modules/sleep_ui.R`)
**Purpose**: Sleep analysis

**Features**:
- Sleep distribution
- Sleep quality breakdown
- Sleep vs steps correlation
- Sleep statistics

**Inputs**: Shared data

### **Explorer Module** (`modules/explorer_ui.R`)
**Purpose**: Data exploration

**Features**:
- Interactive DT table
- Advanced filtering
- Search capability
- Export functionality

**Inputs**: Shared data

### **Insights Module** (`modules/insights_ui.R`)
**Purpose**: Analysis and recommendations

**Features**:
- Key findings
- Personalized recommendations
- Correlation analysis
- Trend detection

**Inputs**: Shared data

---

## 🔄 Data Flow

```
User Upload CSV
      │
      ▼
dashboard_server() validates
      │
      ▼
fitness_data reactive updated
      │
      ├─────────────────────────┐
      │                         │
      ▼                         ▼
Shared with all modules   Used in calculations
      │                         │
      ├─ activity_server()      │
      ├─ sleep_server()         │
      ├─ explorer_server()      │
      └─ insights_server()      │
            │                   │
            └───────────────────┘
                     │
                     ▼
            Charts & Tables Render
```

---

## 🎨 Styling Architecture

### **Bootstrap 5 Theme** (bslib)
- Dark navbar with gradients
- Professional color scheme
- Responsive grid layout
- Built-in components

### **Custom CSS** (`www/css/styles.css`)
- Value box styling
- Card animations
- Hover effects
- Loading states
- Responsive design
- Scrollbar styling

### **CSS Features**:
```css
:root {
  --primary: #1f77b4;
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.12);
  --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.value-box {
  animation: slideInUp 0.5s ease-out;
  transition: var(--transition);
}

.value-box:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-lg);
}
```

---

## 🔐 Data Validation Pipeline

```
CSV Upload
    │
    ▼
Read File
    │
    ▼
Check Columns Exist
    │ (if missing → error)
    ▼
Type Conversion
    │ date, steps, calories, distance, sleep_hours
    ▼
Remove NA Values
    ▼
Sort by Date
    │
    ├─ if 0 rows → error
    └─ if > 0 rows → load success
    │
    ▼
Store in fitness_data reactive
    │
    ▼
Notify User & Render Charts
```

---

## 🚀 Scalability Considerations

### **Adding a New Page**

1. **Create Module** (`modules/newpage_ui.R`):
```r
newpage_ui <- function(id) {
  ns <- NS(id)
  page_fillable(
    card(plotly::plotlyOutput(ns("chart")))
  )
}

newpage_server <- function(id, shared_data) {
  moduleServer(id, function(input, output, session) {
    output$chart <- plotly::renderPlotly({
      plot_new_chart(shared_data$data())
    })
  })
}
```

2. **Update app.R**:
```r
source("modules/newpage_ui.R")  # Add load

# In UI:
nav_panel(
  title = "New Page",
  icon = icon("icon-name"),
  newpage_ui("newpage")
)

# In Server:
newpage_server("newpage", dashboard_out)
```

### **Adding a New Chart**

1. **Create Function** in `R/plots.R`:
```r
plot_new_chart <- function(data) {
  plot_ly(data) %>%
    layout(title = "New Chart")
}
```

2. **Use in Module**:
```r
output$new <- plotly::renderPlotly({
  plot_new_chart(shared_data$data())
})
```

---

## ⚡ Performance Optimization

### **Data Size**: 50,000+ rows supported
- Efficient dplyr operations
- Plotly client-side rendering
- DT pagination (25 rows/page)
- Reactive caching

### **Chart Rendering**:
- Plotly uses WebGL for large datasets
- Charts only update when data changes
- Hover data cached locally

### **Memory Management**:
- No global data copies
- Reactive values only
- Module isolation

---

## 🧪 Testing Strategy

### **Unit Tests** (Individual Functions)
```r
# Test validate_fitness_data()
test_df <- data.frame(
  date = "2024-01-01",
  steps = 10000,
  calories = 500,
  distance = 5,
  sleep_hours = 7
)
result <- validate_fitness_data(test_df)
```

### **Integration Tests** (Modules)
- Test module UI rendering
- Test reactive dependencies
- Test data flow between modules

### **Visual Tests**
- Check chart rendering
- Verify styling
- Test responsiveness

---

## 📚 Code Organization Summary

| File | Lines | Purpose |
|------|-------|---------|
| `app.R` | 15 | Main entry point |
| `R/config.R` | 30 | Configuration |
| `R/utils.R` | 150 | Utilities |
| `R/plots.R` | 250 | Charts |
| `R/data_processing.R` | 150 | Analysis |
| `modules/*_ui.R` | 100 each | UI modules |
| `www/css/styles.css` | 550 | Styling |
| **Total** | **~1200** | **Organized, maintainable!** |

---

## 🎯 Design Principles

1. **Modularity**: Each module has single responsibility
2. **DRY**: No code duplication
3. **Reactive**: Efficient data flow
4. **Scalable**: Easy to add features
5. **Professional**: Production-ready code
6. **Documented**: Comments throughout
7. **Tested**: Error handling included
8. **Accessible**: Keyboard navigation works

---

## 🔧 Maintenance Guidelines

### **Adding a Feature**:
1. Identify which module it belongs to
2. Add UI to `*_ui.R`
3. Add server logic to same file
4. Reuse functions from `R/`
5. Test thoroughly

### **Fixing a Bug**:
1. Find relevant module
2. Check util functions in `R/`
3. Test with sample data
4. Verify styling in CSS
5. Update documentation

### **Updating Theme**:
1. Edit colors in `R/config.R`
2. Update CSS in `www/css/styles.css`
3. Update color references in plots
4. Test all pages

---

## 📖 Summary

This architecture provides:

✅ **Clean Code**: Modular, DRY, well-organized  
✅ **Maintainability**: Easy to find and fix code  
✅ **Scalability**: Simple to add features  
✅ **Performance**: Optimized for large datasets  
✅ **Professional**: Production-ready structure  
✅ **Documentation**: Comments and guides  
✅ **User Experience**: Modern, responsive UI  
✅ **Reliability**: Error handling throughout  

**The result**: A **professional-grade Shiny application** that's easy to maintain, scale, and share.

---

*For questions, review the inline code comments and function documentation throughout the project.*
