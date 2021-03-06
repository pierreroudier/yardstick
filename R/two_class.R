#' Other Metrics for 2x2 Tables
#' 
#' General metrics for two class problems that are not already
#'  in [sens()] or [recall()] are here, such as the Matthews
#'  correlation coefficient, Youden's J.
#'  
#' There is no common convention on which factor level should
#'  automatically be considered the "event" or "positive" results. 
#'  In `yardstick`, the default is to use the _first_ level. To 
#'  change this, a global option called `yardstick.event_first` is
#'  set to `TRUE` when the package is loaded. This can be changed
#'  to `FALSE` if the last level of the factor is considered the
#'  level of interest. 
#' 
#' If more than one statistic is required, it is more
#'  computationally efficient to create the confusion matrix using
#'  [conf_mat()] and applying the corresponding `summary` method
#'  ([summary.conf_mat()]) to get the values at once.
#' 
#' @inheritParams sens
#' @author Max Kuhn
#' @seealso [conf_mat()], [summary.conf_mat()], [recall()], [sens()]
#' @examples 
#' data("two_class_example")
#'
#' mcc(two_class_example, truth, predicted)
#' 
#' j_index(two_class_example, truth, predicted)
#' @export 
mcc <- function(data, ...)
  UseMethod("mcc")

#' @export
#' @rdname mcc
mcc.data.frame  <-
  function(data, truth, estimate, na.rm = TRUE, ...) {
    vars <-
      factor_select(
        data = data,
        truth = !!enquo(truth),
        estimate = !!enquo(estimate),
        ...
      )
    
    xtab <- vec2table(
      truth = data[[vars$truth]],
      estimate = data[[vars$estimate]],
      na.rm = na.rm,
      two_class = TRUE,
      dnn = c("Prediction", "Truth"),
      ...
    )
    mcc.table(xtab, ...)
  }

#' @rdname mcc
#' @export
"mcc.table" <-
  function(data, ...) {
    ## "truth" in columns, predictions in rows
    check_table(data)
    
    positive <- pos_val(data)
    negative <- neg_val(data)
    
    # This and `prod` below to deal with integer overflow
    data <- as.matrix(data)
    
    tp <- data[positive, positive]
    tn <- data[negative, negative]
    fp <- data[positive, negative]
    fn <- data[negative, positive]
    d1 <- tp + fp 
    d2 <- tp + fn 
    d3 <- tn + fp
    d4 <- tn + fn
    if (d1 == 0 | d2 == 0 | d3 == 0 | d4 == 0)
      return(NA)
    ((tp * tn) - (fp * fn)) / sqrt(prod(d1, d2, d3, d4))
  }

#' @export 
#' @rdname mcc
j_index <- function(data, ...)
  UseMethod("j_index")

#' @export
#' @rdname mcc
j_index.data.frame  <-
  function(data, truth, estimate, na.rm = TRUE, ...) {
    vars <-
      factor_select(
        data = data,
        truth = !!enquo(truth),
        estimate = !!enquo(estimate),
        ...
      )
    
    xtab <- vec2table(
      truth = data[[vars$truth]],
      estimate = data[[vars$estimate]],
      na.rm = na.rm,
      two_class = TRUE,
      dnn = c("Prediction", "Truth"),
      ...
    )
    j_index.table(xtab, ...)
  }

#' @rdname mcc
#' @export
"j_index.table" <-
  function(data, ...) {
    ## "truth" in columns, predictions in rows
    check_table(data)
    sens(data) + spec(data) - 1
  }

