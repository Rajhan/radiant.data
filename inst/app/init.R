################################################################################
## functions to set initial values and take information from r_state
## when available
################################################################################

## options to set for debugging
# options(shiny.trace = TRUE)
# options(shiny.reactlog = TRUE)
# options(shiny.error = recover)
# options(warn = 2)
# options(warn = 0)

## turn off warnings globally
# options(warn=-1)

remove_session_files <- function(st = Sys.time()) {
  fl <- list.files(
    normalizePath("~/radiant.sessions/"),
    pattern = "*.rds",
    full.names = TRUE
  )

  for (f in fl) {
    if (difftime(st, file.mtime(f), units = "days") > 7) {
      unlink(f, force = TRUE)
    }
  }
}

remove_session_files()

## from Joe Cheng's https://github.com/jcheng5/shiny-resume/blob/master/session.R
isolate({
  prevSSUID <- parseQueryString(session$clientData$url_search)[["SSUID"]]
})

most_recent_session_file <- function() {
  fl <- list.files(
    normalizePath("~/radiant.sessions/"),
    pattern = "*.rds",
    full.names = TRUE
  )

  if (length(fl) > 0) {
    data.frame(fn = fl, dt = file.mtime(fl), stringsAsFactors = FALSE) %>%
      arrange(desc(dt)) %>%
      slice(1) %>%
      .[["fn"]] %>%
      as.character() %>%
      basename() %>%
      gsub("r_(.*).rds", "\\1", .)
  } else {
    NULL
  }
}

## set the session id
r_ssuid <-
  if (getOption("radiant.local")) {
    if (is.null(prevSSUID)) {
      mrsf <- most_recent_session_file()
      paste0("local-", shiny:::createUniqueId(3))
    } else {
      mrsf <- "0000"
      prevSSUID
    }
  } else {
    ifelse(is.null(prevSSUID), shiny:::createUniqueId(5), prevSSUID)
  }

## (re)start the session and push the id into the url
session$sendCustomMessage("session_start", r_ssuid)

## load for previous state if available but look in global memory first
if (exists("r_data")) {
  r_data <- do.call(reactiveValues, r_data)
  r_state <- if (exists("r_state")) r_state else list()
  suppressWarnings(rm(r_data, r_state, envir = .GlobalEnv))
} else if (!is.null(r_sessions[[r_ssuid]]$r_data)) {
  r_data <- do.call(reactiveValues, r_sessions[[r_ssuid]]$r_data)
  r_state <- r_sessions[[r_ssuid]]$r_state
} else if (file.exists(paste0("~/radiant.sessions/r_", r_ssuid, ".rds"))) {
  ## read from file if not in global
  fn <- paste0(normalizePath("~/radiant.sessions"), "/r_", r_ssuid, ".rds")

  rs <- try(readRDS(fn), silent = TRUE)
  if (is(rs, "try-error")) {
    r_data <- init_data()
    r_state <- list()
  } else {
    if (length(rs$r_data) == 0) {
      r_data <- init_data()
    } else {
      r_data <- do.call(reactiveValues, rs$r_data)
    }

    if (length(rs$r_state) == 0) {
      r_state <- list()
    } else {
      r_state <- rs$r_state
    }
  }

  unlink(fn, force = TRUE)
  rm(rs)
} else if (isTRUE(getOption("radiant.local")) && file.exists(paste0("~/radiant.sessions/r_", mrsf, ".rds"))) {

  ## restore from local folder but assign new ssuid
  fn <- paste0(normalizePath("~/radiant.sessions"), "/r_", mrsf, ".rds")
  rs <- try(readRDS(fn), silent = TRUE)
  if (is(rs, "try-error")) {
    r_data <- init_data()
    r_state <- list()
  } else {
    r_data <- if (length(rs$r_data) == 0) init_data() else do.call(reactiveValues, rs$r_data)
    r_state <- if (length(rs$r_state) == 0) list() else rs$r_state
  }

  ## don't navigate to same tab in case the app locks again
  r_state$nav_radiant <- NULL

  unlink(fn, force = TRUE)
  rm(rs)
} else {
  r_data <- init_data()
  r_state <- list()
}

## identify the shiny environment
r_environment <- environment()

## parse the url and use updateTabsetPanel to navigate to the desired tab
## currently only works with a new or refreshed session
observeEvent(session$clientData$url_search, {
  url_query <- parseQueryString(session$clientData$url_search)
  if ("url" %in% names(url_query)) {
    r_data$url <- url_query$url
  } else if (is_empty(r_data$url)) {
    return()
  }

  ## create an observer and suspend when done
  url_observe <- observe({
    if (is.null(input$dataset)) return()
    url <- getOption("radiant.url.patterns")[[r_data$url]]
    if (is.null(url)) {
      ## if pattern not found suspend observer
      url_observe$suspend()
      return()
    }
    ## move through the url
    for (u in names(url)) {
      if (is.null(input[[u]])) return()
      if (input[[u]] != url[[u]]) {
        updateTabsetPanel(session, u, selected = url[[u]])
      }
      if (names(tail(url, 1)) == u) url_observe$suspend()
    }
  })
})

## keeping track of the main tab we are on
observeEvent(input$nav_radiant, {
  if (!input$nav_radiant %in% c("Refresh", "Stop")) {
    r_data$nav_radiant <- input$nav_radiant
  }
})

## Jump to the page you were on
## only goes two layers deep at this point
if (!is.null(r_state$nav_radiant)) {

  ## don't return-to-the-spot if that was quit or stop
  if (r_state$nav_radiant %in% c("Refresh", "Stop")) return()

  ## naming the observer so we can suspend it when done
  nav_observe <- observe({
    ## needed to avoid errors when no data is available yet
    if (is.null(input$dataset)) return()
    updateTabsetPanel(session, "nav_radiant", selected = r_state$nav_radiant)

    ## check if shiny set the main tab to the desired value
    if (is.null(input$nav_radiant)) return()
    if (input$nav_radiant != r_state$nav_radiant) return()
    nav_radiant_tab <- getOption("radiant.url.list")[[r_state$nav_radiant]] %>% names()

    if (!is.null(nav_radiant_tab) && !is.null(r_state[[nav_radiant_tab]])) {
      updateTabsetPanel(session, nav_radiant_tab, selected = r_state[[nav_radiant_tab]])
    }

    ## once you arrive at the desired tab suspend the observer
    nav_observe$suspend()
  })
}

isolate({
  if (is.null(r_data$plot_height)) r_data$plot_height <- 650
  if (is.null(r_data$plot_width)) r_data$plot_width <- 650
})

## 'sourcing' radiant's package functions in the server.R environment
if (!"package:radiant.data" %in% search() && getOption("radiant.path.data") == "..") {
  ## for shiny-server and development
  for (file in list.files("../../R", pattern = "\\.(r|R)$", full.names = TRUE))
    source(file, encoding = getOption("radiant.encoding"), local = TRUE)
} else {
  ## for use with launcher
  radiant.data::copy_all(radiant.data)
}

## check every 5 seconds if width has been reset
## https://github.com/rstudio/rstudio/issues/1870
## https://community.rstudio.com/t/rstudio-resets-width-option-when-running-shiny-app-in-viewer/3661
reactivePoll(
  5000,
  session,
  checkFunc = function() {
    if (getOption("width", default = 250) != 250) options(width = 250)
  },
  valueFunc = function() {
    return()
  }
)
