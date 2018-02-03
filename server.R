library(shiny)
library(DT)
library(data.table)
library(XML)
library(httr)

shinyServer(function(input, output, session){
  
  getSmartGroups <- function(user, pass){
    
    # Setup REST API call
    base = "https://ecsu-jss.easternct.edu:8443/JSSResource/"
    endpoint = "computergroups"
    username = user
    password = pass
    
    # Make API call
    group_call <- paste(base,endpoint,sep="")
    get_computergroups = GET(group_call, authenticate(username, password, type="basic"))
    
    # Parse returned XML for group names
    computergroups = xmlParse(content(get_computergroups, "text"))
    groups = xpathSApply(computergroups, "/computer_groups/computer_group/name/text()", saveXML)
    
    return(groups)
    
  }
  
  getProfiles <- function(user, pass){
    
    # Setup REST API call
    base = "https://ecsu-jss.easternct.edu:8443/JSSResource/"
    endpoint = "osxconfigurationprofiles"
    username = user
    password = pass
    
    # Make API call
    profile_call = paste(base, endpoint ,sep="")
    get_profiles = GET(profile_call, authenticate(username, password, type="basic"))
    
    # Parse returned XML for profile IDs
    profile_content = xmlParse(content(get_profiles, "text"))
    profiles = xpathSApply(profile_content, 
                           "/os_x_configuration_profiles/os_x_configuration_profile/id/text()", saveXML)
    
    return(profiles)
  }
  
  findProfiles <- function(group, profile){
    call = paste("https://ecsu-jss.easternct.edu:8443/JSSResource/osxconfigurationprofiles/id/", profile, sep="")
    profile = GET(call, authenticate(input$user, input$pass, type="basic"))
    profile = xmlParse(content(profile, "text"))
    profilename = xpathSApply(profile, "/os_x_configuration_profile/general/name/text()", saveXML)
    groupname = xpathSApply(profile, "/os_x_configuration_profile/scope/computer_groups/computer_group/name/text()", saveXML)
    
    if(group %in% groupname){
      return(profilename)
    }
    
  }
  
  findComputers <- function(group){
    call = paste("https://ecsu-jss.easternct.edu:8443/JSSResource/computergroups/name/",
                 group, sep="") %>% URLencode()
    computers = GET(call, authenticate(input$user, input$pass, type="basic"))
    computers = xmlParse(content(computers, "text"))
    computernames = xpathSApply(computers, "/computer_group/computers/computer/name/text()", saveXML)
    
    return(computernames)
    
  }
  
  toggleModal(session, "loginModal", toggle = "open")
  
  observeEvent(input$btnLogin, {
    groups = getSmartGroups(input$user, input$pass)
    updateSelectizeInput(session, "groupInput", choices = groups, selected = NULL)
    toggleModal(session, "loginModal", toggle = "open")
  })
  
  observeEvent(input$btnGeneSearch, {
    profiles = getProfiles(input$user, input$pass)
    profileresults = sapply(profiles, findProfiles, group = input$groupInput)
    computerresults = findComputers(input$groupInput)
    output$policyResults = renderDataTable(as.data.frame(unlist(profileresults)), colnames = c("Profiles"))
    output$computerResults = renderDataTable(as.data.frame(computerresults), colnames = c("Computer Names"))
  })
  
  
})