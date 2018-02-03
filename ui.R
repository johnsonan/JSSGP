library(shiny)
library(shinyBS)
library(shinydashboard)
library(shinyjs)

shinyUI(
  
  dashboardPage(
    
    dashboardHeader(title = "JSS Group Policies"),
    
    dashboardSidebar(width = 350,
                     tags$head(tags$style(HTML(
                       "#console { max-height:15vh; max-width:50vh; overflow:auto; }"
                     ))),
                     
                     useShinyjs(),  
                     
                     selectizeInput("groupInput", label = "Enter a Group Name", choices = NULL, width = 325),
                     actionButton("btnGeneSearch", "Search")
                     
    ), 
    
    dashboardBody(
      
      fluidRow(
        
        conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                         HTML("<br><br>"),
                         HTML("<div class=\"progress\" style=\"height:25px !important\"><div class=\"progress-bar progress-bar-striped active\" role=\"progressbar\" aria-valuenow=\"100\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width:100%\">
                                                          <span id=\"bar-text\"><b><font size=\"+1.5\">Loading, please wait...</font></b></span></div></div>")
        ),
        
        bsModal("loginModal", "Login", "",
                textInput("user", "Username", value = "", width = "100%"),
                passwordInput("pass", "Password", value = "", width = "100%"),
                actionButton("btnLogin", "Login"),
                size = "large"
        ),
        tags$head(tags$style("#loginModal .modal-footer{ display:none}"))
        
      ),
      
      fluidRow(
        shiny::column(width = 12,
                      tabsetPanel(
                        tabPanel("Policies", dataTableOutput("policyResults")),
                        tabPanel("Computers", dataTableOutput("computerResults"))
                      )
        )
      )
    )
  )
)