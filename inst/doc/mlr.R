## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width=5, fig.height=5 ,fig.align="center"
)
fpath <- "vignettefigs/"

## ----eval=F-------------------------------------------------------------------
#  library(mlr)
#  library(MASS)
#  library(condvis2)
#  Boston1 <- Boston[,9:14]
#  
#  rtask <- makeRegrTask(id = "bh", data = Boston1, target = "medv")
#  rmod <- train(makeLearner("regr.lm"), rtask)
#  rmod1 <- train(makeLearner("regr.fnn"), rtask)

## ----eval=F-------------------------------------------------------------------
#  condvis(Boston1, model=list(rmod,rmod1), response="medv", sectionvars="lstat")

## ----eval=F-------------------------------------------------------------------
#  rmod <- train(makeLearner("regr.lm", predict.type="se"), rtask)
#  condvis(Boston1, model=rmod, response="medv", sectionvars="lstat", predictArgs=list(list(pinterval="confidence")))

## ----eval=F-------------------------------------------------------------------
#  cltask = makeClassifTask(data = iris, target = "Species")
#  cllrn = makeLearner("classif.lda",predict.type = "prob") # need predict.type ="probs" to get probs
#  clmod = train(cllrn, cltask)

## ----eval=F-------------------------------------------------------------------
#  condvis(iris, model=clmod, response="Species", sectionvars=c("Petal.Length", "Petal.Width"), pointColor="Species")

## ----eval=F-------------------------------------------------------------------
#  
#  ctask = makeClusterTask(data = iris[,-5])
#  clrn = makeLearner("cluster.kmeans")
#  cmod = train(clrn, ctask)

## ----eval=F-------------------------------------------------------------------
#  library(dplyr)
#  iris1 <- iris
#  
#  iris1$pclass <- cmod %>%
#    predict(newdata=iris[,-5]) %>%
#    getPredictionResponse() %>%
#      as.factor()
#  

## ----eval=F-------------------------------------------------------------------
#  condvis(data = iris1, model = cmod,
#          response="pclass",
#          sectionvars=c("Petal.Length", "Petal.Width"),
#          conditionvars=c("Sepal.Length", "Sepal.Width"),pointColor="Species"
#  )
#  

