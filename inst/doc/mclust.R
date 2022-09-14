## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width=5, fig.height=5 ,fig.align="center"
)
fpath <- ""

## -----------------------------------------------------------------------------
library(condvis2)
library(mclust)

## -----------------------------------------------------------------------------
data(banknote)
bankDA <- MclustDA(banknote[,-1], banknote[,1],verbose=F)

## -----------------------------------------------------------------------------
table(banknote$Status, CVpredict(bankDA, banknote))

## ----echo=F, eval=F-----------------------------------------------------------
#  bankDA$models$genuine$modelName
#  bankDA$models$genuine$G
#  
#  bankDA$models$counterfeit$modelName
#  bankDA$models$counterfeit$G
#  
#  bankDA$models$counterfeit

## ----eval=F-------------------------------------------------------------------
#  svars <- c("Top", "Diagonal")
#  cvars <- setdiff(names(banknote)[-1], svars)
#  condvis(data = banknote, model = bankDA,
#          response="Status", sectionvars=svars,conditionvars=cvars,
#          pointColor="Status", showsim=TRUE
#          )

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "mclustda1.png"))

## -----------------------------------------------------------------------------
bankDAe <- MclustDA(banknote[,-1], banknote[,1], modelType="EDDA",verbose=F)

## ----eval=F-------------------------------------------------------------------
#  condvis(data = banknote, model = list(bankDA=bankDA, bankDAe=bankDAe),
#          response="Status", sectionvars=svars,conditionvars=cvars,
#          pointColor="Status", showsim=T
#          )

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "mclustda6.png"))

## -----------------------------------------------------------------------------
data(banknote)
dens2 <- densityMclust(banknote[,c("Diagonal","Left")],verbose=F) 
summary(dens2)

## ----eval=F-------------------------------------------------------------------
#  condvis(data = banknote, model = dens2, response=NULL,
#          sectionvars="Diagonal",conditionvars="Left",
#          density=T, showdata=T)

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "left1.png"))

## -----------------------------------------------------------------------------
dens3 <- densityMclust(banknote[,c("Right", "Bottom", "Diagonal")],verbose=F) 
summary(dens3)

## -----------------------------------------------------------------------------
library(ks)
kdens3 <- kde(banknote[,c("Right", "Bottom", "Diagonal")])

## ----eval=F-------------------------------------------------------------------
#  condvis(data = banknote, model = list(mclust=dens3, kde=kdens3), response=NULL,
#          sectionvars=c("Bottom", "Diagonal"),conditionvars="Right",
#          density=T, showdata=T)

## ----echo=FALSE, out.width='100%'---------------------------------------------
knitr::include_graphics(paste0(fpath, "dens3Right2.png"))

## ----eval=F-------------------------------------------------------------------
#  bankC <- Mclust(banknote[,-1],verbose=F) # picks 3 clusters
#  banknote1 <- banknote
#  banknote1$cluster <- factor(CVpredict(bankC, banknote))
#  
#  svars <- c("Top", "Diagonal")
#  cvars <- c("Left",    "Right" ,  "Bottom")
#  condvis(data = banknote1, model = bankC,
#          response="cluster", sectionvars=svars,conditionvars=cvars,
#          pointColor="Status", showsim=TRUE
#  )

