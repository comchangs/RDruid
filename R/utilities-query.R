#
# Copyright 2013 Metamarkets Group Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


#' calls toJSON with a default set of arguments
#' 
#' - sets the default number of digits to 22 to retain maximum precisioin
#' - removes newlines and spaces from json string
#' 
#' @param obj object to pass to toJSON
#' @param ... other arguments to pass to toJSON
json <- function(obj, ...) {
  toJSON(obj, digits=22, auto_unbox = T, force = T, null = "null", ...)
}

#' Send a JSON query to Druid
#'
#' Takes a JSON string and uses httr to send a query to the endpoint
#' specified by url.  Typically this function is not called on its own,
#' instead the end user should use the query family of functions
#'
#' @param jsonstr JSON string containing details of the query.
#' @param url the endpoint for where this query should be sent. Use druid.url()
#'   to construct the URL.
#' @keywords database, druid, query
#' @seealso \code{\link{druid.query.timeseries}}
query <- function(jsonstr, url, verbose = F, benchmark = F, ...){
        if(is.null(jsonstr)) {
          res <- httr::GET(url = url, encoding = "gzip", .encoding = "UTF-8", ...)
        } else {
          if(verbose) {
            message(jsonstr)
          }
          res <- httr::POST(
            url, content_type_json(),
            body = jsonstr,
            encoding = "gzip",
            .encoding = "UTF-8",
            verbose = verbose
          )
        }

        if(httr::status_code(res) >= 300 && !is.na(pmatch("application/json", res$header$`content-type`))) {
          err <- httr::content(res, type = "application/json", simplifyVector = TRUE)
          stop(httr::http_condition(res, "error", message = err$error, call = sys.call(-1)))
        }
        else {
          httr::stop_for_status(res)
        }
        
        if(benchmark) {
          list()
        } else {
          httr::content(res, type = "application/json", simplifyVector = TRUE, simplifyDataFrame = FALSE)
        }
}
