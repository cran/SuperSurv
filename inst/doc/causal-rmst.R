## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE, warning=FALSE--------------------------------------
library(SuperSurv)
set.seed(123)

# Load built-in data
data("metabric", package = "SuperSurv")

# Define predictors and time grid
X <- metabric[, grep("^x", names(metabric))]
new.times <- seq(10, 150, by = 10)

## ----train-model, eval=FALSE--------------------------------------------------
# fit <- SuperSurv(
#   time = metabric$duration,
#   event = metabric$event,
#   X = X,
#   newdata = X,
#   new.times = new.times,
#   event.library = c("surv.coxph", "surv.rfsrc"),
#   cens.library = c("surv.coxph"),
#   control = list(saveFitLibrary = TRUE)
# )

## ----causal-effect, eval=FALSE------------------------------------------------
# # Estimate the adjusted difference up to tau = 100 months
# results <- estimate_marginal_rmst(
#   fit = fit,
#   data = metabric,
#   trt_col = "x4",
#   times = new.times,
#   tau = 100
# )
# 
# print(results$ATE_RMST)

## ----plot-curve, eval=FALSE---------------------------------------------------
# # Plot the Delta RMST across a sequence of tau values
# tau_grid <- seq(20, 140, by = 20)
# plot_marginal_rmst_curve(
#   fit = fit,
#   data = metabric,
#   trt_col = "x4",
#   times = new.times,
#   tau_seq = tau_grid
# )

## ----plot-obs, eval=FALSE-----------------------------------------------------
# plot_rmst_vs_obs(
#   fit = fit,
#   data = metabric,
#   time_col = "duration",
#   event_col = "event",
#   times = new.times,
#   tau = 350
# )

