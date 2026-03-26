## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE, warning=FALSE--------------------------------------
library(SuperSurv)
library(survival)

# Load built-in METABRIC data
data("metabric", package = "SuperSurv")

# Quick 80/20 Train-Test split
set.seed(42)
n_total <- nrow(metabric)
train_idx <- sample(1:n_total, 0.8 * n_total)

train <- metabric[train_idx, ]
test  <- metabric[-train_idx, ]

# Extract just the X covariates (assuming they are named x0, x1, etc.)
x_cols <- grep("^x", names(metabric), value = TRUE)
X_tr <- train[, x_cols]
X_te <- test[, x_cols]

# Define the prediction time grid (e.g., survival at 50, 100, 150, 200 months)
new.times <- c(50, 100, 150, 200)

## ----define-library-----------------------------------------------------------
my_library <- c("surv.coxph", "surv.weibull", "surv.rpart")

## ----fit-models, results='hide', message=FALSE, warning=FALSE-----------------
# Fit 1: Least Squares Meta-learner
fit_ls <- SuperSurv(
  time = train$duration,
  event = train$event,
  X = X_tr,
  newdata = X_te,                 # Predict on the test set immediately
  new.times = new.times,       # Our evaluation time grid
  event.library = my_library,
  cens.library = my_library,
  metalearner = "brier", 
  control = list(saveFitLibrary = TRUE), 
  verbose = T,             # Turn to TRUE in practice to see progress!
  selection = "ensemble",
  nFolds = 5                   # 5-fold CV for the meta-learner
)

# Fit 2: Negative Log-Likelihood Meta-learner
fit_nll <- SuperSurv(
  time = train$duration,
  event = train$event,
  X = X_tr,
  newdata = X_te,
  new.times = new.times,
  event.library = my_library,
  cens.library = my_library,
  metalearner = "logloss",       # Swap to nloglik
  control = list(saveFitLibrary = TRUE), 
  verbose = FALSE,
  selection = "ensemble",
  nFolds = 5
)

## ----inspect-weights----------------------------------------------------------
cat("\n--- LEAST SQUARES METALEARNER ---\n")
print(round(fit_ls$event.coef, 4))
cat("CV Risks (Lower is Better):\n")
print(round(fit_ls$event.cvRisks, 4))

cat("\n--- NLOGLIK METALEARNER ---\n")
print(round(fit_nll$event.coef, 4))
cat("CV Risks (Lower is Better):\n")
print(round(fit_nll$event.cvRisks, 4))

## ----predict-new--------------------------------------------------------------
# Select 3 brand new patients from our test set
new_patients <- X_te[1:6, ]

# Generate predictions using the Least Squares ensemble
ensemble_preds <- predict(
  object = fit_ls, 
  newdata = new_patients, 
  new.times = new.times
)

cat("\n--- PREDICTED SURVIVAL PROBABILITIES ---\n")
final_matrix <- ensemble_preds$event.predict
colnames(final_matrix) <- paste0("Time_", new.times)
rownames(final_matrix) <- paste0("Patient_", 1:6)

print(round(final_matrix, 4))

## ----plot-predict, fig.align='center', fig.width=6, fig.height=5--------------
# Plot the predicted survival curves for our 3 new patients (Rows 1, 2, and 3)
plot_predict(
  preds = ensemble_preds,
  eval_times = new.times,
  patient_idx = 1:6
)

