#! /usr/bin/Rscript
library(httr)

api_token          <- "token"
url_get_server     <- "https://api.vk.me/method/messages.getLongPollServer"
url_send_message   <- "https://api.vk.com/method/messages.send"
url_delete_message <- "https://api.vk.com/method/messages.delete"

send_mesage_to <- function(peer_id,
                           text,
                           message_id,
                           delay) {
  data_load_send <- list(
    v            = 5.121,
    random_id    = 0,
    access_token = api_token,
    peer_id      = peer_id,
    message      = text,
    expire_ttl   = delay
  )
  data_load_delete <- list(
    v = 5.103,
    message_ids    = message_id,
    delete_for_all = TRUE,
    spam           = FALSE,
    access_token   = api_token
  )
  POST(url_delete_message,
       body   = data_load_delete,
       encode = "form")
  POST(url_send_message,
       body   = data_load_send,
       encode = "form")
}

data_load_get_server <- list(
  v            = 5.103,
  lp_version   = 3,
  access_token = api_token
)

main <- function() {
  ttl_mode <- FALSE
  get_server_response_raw <- POST(url_get_server,
                                  body   = data_load_get_server,
                                  encode = "form")
  response_formed         <- content(get_server_response_raw)[["response"]]
  got_server              <- response_formed[["server"]]
  got_key                 <- response_formed[["key"]]
  got_ts                  <- response_formed[["ts"]]
  
  repeat {
    url_longpoll       <- paste("https://",
                                got_server,
                                sep = "")
    data_load_longpoll <- list(
      wait    = 25,
      act     = "a_check",
      key     = got_key,
      ts      = got_ts,
      mode    = 2,
      version = 3
    )
    get_longpoll_response_raw <- POST(url_longpoll,
                                      body = data_load_longpoll,
                                      encode = "form")
    longpoll_formed <- content(get_longpoll_response_raw)

    failed_code     <- paste(longpoll_formed["failed"])
    if (failed_code == "2") {
      get_server_response_raw <- POST(url_get_server,
                                      body = data_load_get_server,
                                      encode = "form")
      response_formed         <- content(get_server_response_raw)[["response"]]
      got_key                 <- paste(response_formed["key"])
    } else if (failed_code == "3") {
      get_server_response_raw <- POST(url_get_server,
                                      body = data_load_get_server,
                                      encode = "form")
      response_formed         <- content(get_server_response_raw)[["response"]]
      got_key                 <- paste(response_formed["key"])
      got_ts                  <- paste(response_formed["ts"])
    }
    
    got_updates    <- longpoll_formed[["updates"]]
    got_ts         <- paste(longpoll_formed["ts"])
    updates_length <- length(got_updates)
    
    if (updates_length == 0) {
      next
    }
    
    for (update_number in 1:updates_length) {
      update      <- got_updates[[update_number]]
      event_type  <- update[[1]]
      if (event_type == 4) {
        event_where <- update[[3]]
        if (event_where == 51) {
          ttl_mode <- TRUE
        } else if (update[[4]] >= 2e9) {
            if (update[[7]][["from"]] == "490832562") {
              ttl_mode <- TRUE
          }
        } else {
            ttl_mode <- FALSE
        }
        if (ttl_mode == TRUE) {
          message_text <- update[[6]]
          message_id   <- update[[2]]
          peer_id      <- update[[4]]
          if (grepl("ttl", message_text)) {
            if (grepl("ttl\\d+", message_text)) {
              delay <- regmatches(message_text,
                                  regexpr("ttl\\K\\d+",
                                          message_text,
                                          perl = TRUE))
              start_message <- 4 + nchar(delay)
            } else {
                delay <- 10
                start_message <- 4
            }
            send_mesage_to(peer_id,
                           substr(message_text,
                                  start_message,
                                  nchar(message_text)),
                           message_id,
                           delay)
          }
        } else {
            next
        }
      }
    }
  }
}
repeat {
  main()
}
