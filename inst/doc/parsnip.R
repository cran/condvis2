## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width=5, fig.height=5 ,fig.align="center"
)
fpath <- "vignettefigs/"

## ----eval=F-------------------------------------------------------------------
#  library(parsnip)
#  library(MASS)
#  library(condvis2)
#  Boston1 <- Boston[,9:14]
#  
#  fitlm <-
#    linear_reg() %>%
#    set_engine("lm") %>%
#    fit(medv ~ ., data = Boston1)
#  
#  fitrf <- rand_forest(mode="regression") %>%
#    set_engine("randomForest") %>%
#    fit(medv ~ ., data = Boston1)
#  

## ----eval=F-------------------------------------------------------------------
#  condvis(Boston1, model=list(lm=fitlm,rf=fitrf), response="medv", sectionvars="lstat")

## ----eval=F-------------------------------------------------------------------
#  condvis(Boston1, model=list(lm=fitlm,rf=fitrf), response="medv", sectionvars="lstat",
#          predictArgs=list(list(pinterval="confidence"), NULL))

## ----eval=F-------------------------------------------------------------------
#  clmodel <-
#     svm_poly(mode="classification") %>%
#    set_engine("kernlab") %>%
#    fit(Species ~ ., data = iris )

## ----eval=F-------------------------------------------------------------------
#  condvis(iris, model=clmodel, response="Species", sectionvars=c("Petal.Length", "Petal.Width"), pointColor="Species")

## ----eval=F-------------------------------------------------------------------
#  library(survival) # for the data
#  smodel <-
#    surv_reg() %>%
#    set_engine("survival") %>%
#    fit(Surv(time, status) ~ inst+age+sex+ph.ecog, data=lung)
#  
#  condvis(na.omit(lung), smodel, response="time", sectionvars = c("inst","sex"), conditionvars=c("age","ph.ecog"))
#  

