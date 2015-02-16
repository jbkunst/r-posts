## app.R ##
library(shinydashboard)

ui <- dashboardPage( 
  skin = "black",
  dashboardHeader(title = "MyTestDash"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"), badgeLabel = "new", badgeColor = "green")
      )
    ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "dashboard",
        h2("Start")
        ),
      tabItem(
        tabName = "widgets",
        h2("Widgets tab content")
        )
      )
    )
  )

server <- function(input, output) {

}

shinyApp(ui, server)
