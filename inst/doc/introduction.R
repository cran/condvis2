## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width=5, fig.height=5 ,fig.align="center"
)
fpath <- ""

## -----------------------------------------------------------------------------
ozone <- na.omit(airquality)

## -----------------------------------------------------------------------------
fit1 <- loess(Ozone~Wind, data=ozone)
plot(Ozone~Wind, data=ozone, xlim=c(1.5, 21), ylim=c(-5,175))
wind <- seq(min(ozone$Wind),  max(ozone$Wind), length.out=30)
lines(wind, predict(fit1, data.frame(Wind=wind)))

## ----fig.width=7.3, fig.height=2.7--------------------------------------------
fit2 <- loess(Ozone~Wind+Solar.R, data=ozone)
par(mfrow=c(1,3))
par(mar=c(5,5,3,1))
for (s in quantile(ozone$Solar.R, c(.25,.5,.75))){
plot(Ozone~Wind, data=subset(ozone, Solar.R <= s+20 & Solar.R >= s-20),
     xlim=c(1.5, 21),ylim=c(-5,175), main=paste0("Solar.R=",s))
lines(wind, predict(fit2, data.frame(Wind=wind, Solar.R= s)))
}

## ----eval=F-------------------------------------------------------------------
#  suppressMessages(library(condvis2))
#  condvis(ozone, fit2,sectionvars="Wind", conditionvars="Solar.R")

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "ozone.png"))

## -----------------------------------------------------------------------------
fit3 <- loess(Ozone~Wind+Solar.R+Temp, data=ozone)

## ----eval=F-------------------------------------------------------------------
#  condvis(ozone, fit3, sectionvars="Wind", conditionvars=c("Solar.R", "Temp"))

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "ozone1.png"))

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "ozone4.png"))

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "ozone3.png"))

## ----eval=F-------------------------------------------------------------------
#  library(e1071)
#  fit4 <- svm(Ozone~Wind+Solar.R+Temp, data=ozone)
#  condvis(ozone, list(loess=fit3,svm=fit4), sectionvars="Wind", conditionvars=c("Solar.R", "Temp"))

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "ozone5.png"))

## ----eval=F-------------------------------------------------------------------
#  fit5 <- lm(Ozone~Wind+Solar.R+Temp, data=ozone)
#  condvis(ozone, fit5,
#          sectionvars="Wind", conditionvars=c("Solar.R", "Temp"), predictArgs=list(list(pinterval="confidence")))
#  

## ----eval=F-------------------------------------------------------------------
#  fitu <- fit3
#  class(fitu)<- c("upper", class(fitu))
#  
#  CVpredict.upper <- function(f, newdata, ...){
#    p <- predict(f, newdata, se=T)
#    p$fit+ 2*p$se.fit
#  }
#  
#  fitl <- fit3
#  class(fitl)<- c("lower", class(fitu))
#  
#  CVpredict.lower <- function(f, newdata, ...){
#    p <- predict(f, newdata, se=T)
#    p$fit- 2*p$se.fit
#  }
#  
#  condvis(ozone, list(loess=fit3,lower=fitl,upper=fitu),
#          sectionvars="Wind", conditionvars=c("Solar.R", "Temp"),
#          linecols=c("red", "blue","blue"))

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "ozone6.png"))

## ----eval=F-------------------------------------------------------------------
#  library(ks)
#  data(iris)
#  irisf <- kde(x=iris[,1:3])
#  
#  condvis(data = iris, model = list(kde=irisf),
#          sectionvars= c("Sepal.Length", "Sepal.Width"),
#          conditionvars= "Petal.Length", density=T)
#  

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "iris.png"))

