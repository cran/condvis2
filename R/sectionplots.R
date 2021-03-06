

#' Plots the main condvis display
#' 
#' The section plot relates a fit or fits to one or two predictors (\code{sectionvar}), 
#' for fixed values of other predictors in  \code{conditionvals}.
#' 
#' The type of plot depends on the fit and the section variables. Observations with non zero values of the similarity weights 
#' \code{sim} are shown. If no fit is provided, the data are shown as a parallel coordinate plot or pairs
#' plot, depending on \code{dataplot}.
#' The fit could also be a density estimate.
#'
#' @param CVdata the dataset used for the fit
#' @param CVfit a fit or list of fits
#' @param response name of response variable
#' @param preds names of predictors
#' @param sectionvar section variable, or variables.
#' @param conditionvals conditioning values. A vector/list or dataframe with one row
#' @param pointColor a color, vector of colors,or the name of variable to be used for coloring
#' @param sim vector of similarity weights
#'@param threshold used for similarity weights, defaults to 1.
#' @param linecols vector of line colours
#' @param dataplot "pcp" or "pairs". Used when there is no response, or more than two sectionvars.
#'@param gridsize used to construct grid of fitted values.
#'@param probs Logical; if \code{TRUE}, shows predicted class probabilities instead of just predicted classes. Only available with two numeric sectionvars and the model's predict method provides this.
#' @param view3d Logical; if \code{TRUE} plots a three-dimensional regression surface if possible.
#' @param theta3d,phi3d Angles defining the viewing direction. \code{theta3d} gives the azimuthal direction and \code{phi3d} the colatitude. See\code{\link[graphics]{persp}}.
#'@param xlim passed on to plot
#'@param ylim passed on to plot
#'@param zlim passed on to plot
#'@param pointSize used for points
#'@param predictArgs a list with one entry per fit, giving arguments for predict
#'@param resetpar When TRUE (the default) resets pars after drawing.
#'@param density default FALSE. Use TRUE if model is a density function.
#'@param showdata  If FALSE, data on section not shown.
#'@param returnInfo  If TRUE, returns coordinates for some plots
#'@param pointColorFromResponse  ignore--For interactive use only
#'@param pcolInfo  ignore--For interactive use only
#' @return plotted coordinates, for some plots
#' @export
#' @importFrom colorspace  lighten
#' @examples
#' #Fit a model. 
#' f <- lm(Fertility~ ., data=swiss)
#' svar <- "Education"
#' preds <- variable.names(f)[-1]
#' sectionPlot(swiss,f, "Fertility",preds,svar, swiss[12,])
#' sectionPlot(swiss,f, "Fertility",preds,svar, apply(swiss,2,median))
#' sectionPlot(swiss,f, "Fertility",preds,preds[1:2], apply(swiss,2,median))
#' sectionPlot(swiss,f, "Fertility",preds,preds[1:2], apply(swiss,2,median), view3d=TRUE)
#' 
#' # PCP of swiss data, showing only cases whose percent catholic and infant.mortality are
#' # similar to those of the first case
#'sectionPlot(swiss,preds=names(swiss),
#'            sectionvar= names(swiss)[1:4],conditionvals=swiss[1,] )     
#' # Use dataplot="pairs" to switch to a pairs plot
#' 
#' # A density estimate example
#'  \dontrun{
#'  library(ks)
#' fde <-kde(iris[,1:3])
#'sectionPlot(iris,list(kde=fde), response=NULL,
#'            preds=names(iris)[1:3],
#'            sectionvar=names(iris)[1],
#'            conditionvals=iris[1,],density=TRUE)
#'  }

sectionPlot <- function(CVdata, CVfit=NULL,response=NULL,preds,sectionvar,conditionvals,pointColor="steelblue",
                        sim=NULL,threshold=1,linecols=NULL,
                        dataplot="pcp", gridsize=50, probs=FALSE, view3d=FALSE,
                        theta3d = 45, phi3d = 20, xlim=NULL,ylim=NULL, zlim=NULL,pointSize=1.5,
                        predictArgs=NULL, resetpar=TRUE, density=FALSE, showdata=density==FALSE,
                        returnInfo=FALSE, pointColorFromResponse=FALSE, pcolInfo=NULL){
  
  op <- par(no.readonly=TRUE)
 
  if (view3d) gridsize <- 20
  if (!showdata) returnInfo<-FALSE
  
  if (density & is.null(response)) {
    response <- "density"
    CVdata$density <- runif(nrow(CVdata))
  }
  if (dataplot %in% c("pairs", "pcp")) dataplot <- get(paste0("sectionPlot", dataplot))
  else dataplot <- sectionPlotpcp
  
  
  conditionvars <-setdiff(preds, sectionvar)
  
  if (!is.data.frame(conditionvals))
    conditionvals <- as.data.frame(as.list(conditionvals))
  
  
  if (!is.null(pointColor)) {
    pc <- pointColor2var(CVdata,pointColor, legend=TRUE)
    CVdata <- pc$data
    pcolInfo <- pc[2:3]
    
  }
  sectionPlotFN <- NULL
  # responsePlot <- !is.null(response) & length(sectionvar) <=2 & !is.null(CVfit)
  responsePlot <- !is.null(response) & length(sectionvar) <=2 
  if (responsePlot){
    sp <- vector("character",3)
    if (is.numeric(CVdata[[response]])) sp[1] <- "n" else sp[1] <- "f"
    if (is.numeric(CVdata[[sectionvar[1]]])) sp[2]<- "n"else sp[2] <- "f"
    if (length(sectionvar)> 1)
      if (is.numeric(CVdata[[sectionvar[2]]])) sp[3]<- "n"else sp[3] <- "f"
      sp <- paste(sp,collapse="")
      sectionPlotFN <- get(paste(c("sectionPlot",sp),collapse=""))
  }
  else sp <- NULL
  
 
  if (is.null(CVfit) ) {
    if (is.null(sim) )
      sim <- similarityweight(conditionvals,CVdata[conditionvars], threshold=threshold)
    
    cols <- weightcolor(CVdata$pointCols, sim)
    # CVdata$pointCols <- NULL
    if (responsePlot)
      res<-sectionPlotFN(CVdata,NULL,sectionvar,response, sim,NULL,linecols=linecols,
                    xlim=xlim,ylim=ylim,pointSize=pointSize,showdata=TRUE,
                    returnInfo=returnInfo,pcolInfo=pcolInfo)
    else
      res<-dataplot(CVdata,c(response,sectionvar),  cols,sim,pcolInfo=pcolInfo, returnInfo=returnInfo)
  }
  else {
    if (is.null(sim) && showdata)
      sim <- similarityweight(conditionvals,CVdata[conditionvars], threshold=threshold)
  
    if (!inherits(CVfit, "list"))  CVfit <- list(CVfit)
    if (is.null(names(CVfit)))
      names(CVfit) <- paste0("fit", 1:length(CVfit))
    fitnames <- names(CVfit)
   
        if (probs && 
        (length(levels(CVdata[[response]])) > 2) ){
      substring(sp,1,1)<- "p"
      sectionPlotFN <- get(paste(c("sectionPlot",sp),collapse=""))
      sectionPlotFN(CVdata,CVfit,sectionvar,response, conditionvals,xlim=xlim,ylim=ylim,predictArgs=predictArgs,
                    returnInfo=returnInfo)
      # res$type <- sp
      # res$nplots <- 1
    }
    else if (!responsePlot)
      dataplot(CVdata,c(response,sectionvar),  cols,sim, pcolInfo=pcolInfo)
    else {
      sectionvals <- lapply(sectionvar, function(p)
        if ( is.factor(CVdata[[p]]))
          levels(CVdata[[p]])
        else  seq(min(CVdata[[p]]),max(CVdata[[p]]),length.out=gridsize)
      )
      
      names(sectionvals)<- sectionvar
      sectionvals <- expand.grid(sectionvals)
      grid <- conditionvals
      class(grid)<- "list"
      grid[sectionvar] <- sectionvals[sectionvar]
      grid <- as.data.frame(grid,optional=T)
      grid1 <- grid
      
      if (!is.null(response) && is.factor(CVdata[[response]]))
        ylevels <- levels(CVdata[[response]])
      else ylevels <- NULL
      
      
      if (length(predictArgs)!= length(CVfit)) predictArgs<- NULL
      
      if (!is.null(ylevels)  & probs)
        if (!is.null(predictArgs))
          predictArgs <- lapply(predictArgs, function(x) { x$ptype <- "prob"; x})
      else predictArgs <- lapply(CVfit, function(x) list(ptype="prob"))
      
      
      if (!is.null(predictArgs)){
        
        for (i  in 1:length(CVfit)){
          fitname <- fitnames[i]
          f <- do.call(CVpredict,  c(list(CVfit[[i]],grid1,ylevels=ylevels), predictArgs[[i]]))
          
          if (is.character(f) & !is.null(ylevels)) f <- factor(f, ylevels)
          
          if (is.vector(f) | is.factor(f))
            grid[[fitname]] <- f
          else { 
            # f should be matrix with cols fit, lowerCI, upperCI
            grid[[fitname]] <- f[,1]
            grid[[paste0(fitname, "L")]] <- f[,2]
            grid[[paste0(fitname, "U")]] <- f[,3]
          }
        }
      }
      else {
        for (i  in 1:length(CVfit)){
          fitname <- fitnames[i]
          f <- CVpredict(CVfit[[i]], grid1, ylevels=ylevels)
          
          if (is.character(f) & !is.null(ylevels)) f <- factor(f, ylevels)
          grid[[fitname]] <- f
        }
      }
      if (sp == "nnn" && view3d  && !is.null(CVfit)){
        sectionPlot3D(CVdata,CVfit,fitnames,sectionvar,response, sim,grid,linecols=linecols,
                      theta3d = theta3d, phi3d = phi3d, xlim=xlim,ylim=ylim, zlim=zlim,
                      pointSize=pointSize, density=density,showdata=showdata, 
                      predictArgs=predictArgs, pcolInfo=pcolInfo)
        # res$type <- "view3d"
        # res$nplots <- length(fitnames)
      }
      else {
        
        res<-sectionPlotFN(CVdata,fitnames,sectionvar,response, sim,grid,linecols=linecols,
                      xlim=xlim,ylim=ylim,zlim=zlim,pointSize=pointSize, density=density,showdata=showdata,
                      returnInfo=returnInfo,pointColorFromResponse=pointColorFromResponse,pcolInfo=pcolInfo)
        # res$type <- sp
        # res$nplots <- if (sp == "nnn" | sp=="fnn") max(1,length(fitnames)) else 1
      }
    }
  }
  
  if (resetpar) par(op)
  # if (! is.null(pcolInfo) && showdata){
  #   legend("topright", legend = names(pcolInfo), col = pcolInfo, pch=19,bty="n", cex=.7, title=pointColor)
  # }
  res <- mget("res",ifnotfound=list(NULL))$res
  
  if(returnInfo && !is.null(res)) return(res)
}





sectionPlotd3 <- function(CVdata0,fitnames,sectionvar,response, sim,grid,linecols, fitcolfn=NULL,pointSize,
                          density=FALSE,showdata,returnInfo=FALSE,pointColorFromResponse=FALSE,pcolInfo=NULL,... ){

  
  par(mar = c(3, 3, 3,.5),
      mgp = c(2, 0.4, 0),
      tck = -.01)

  # if (is.null(fitcolfn)) fitcolfn <- colorfn(CVdata[[response]])

  if (showdata){
    
  pcols <- CVdata0$pointCols
  
  o <- sim>0

  pcolso <- pcols[o]
 
  if (!density){
    pfill <- fitcolfn(CVdata0[,response])
    pfillso <- pfill[o]
    #if needed, reset point colours to match response
    if (pointColorFromResponse){
      pcolso <- "steelblue"
     
    }
  }
   else pfillso <- NULL

  CVdata1 <- CVdata0[o,]
  pointsize <- (sim[o]*.7 + .3)*pointSize*1.5
  }
  m <- rbind(seq(along=fitnames), length(fitnames)+1)

  if (is.null(fitnames)) fitnames <- ""
  if(isRunning() & length(fitnames)==1) {
    m <- rbind(c(0,1,0), c(0,2,0))
    layout(mat = m,heights = c(.9,.1), widths=c(.17,.66,.17))
  }
  else {m <- rbind(seq(along=fitnames), 0)
  m[2,ceiling(length(fitnames)/2)] <- length(fitnames)+1
  layout(mat = m,heights = c(.9,.1))
  
  }
  
  if(isRunning()) {
    legendInset <- c(-.1,-.142)
  }
  else legendInset <- c(0,0)
  
  if (isTRUE(fitnames=="")){
    if (showdata){
    xlim<- range(CVdata0[[sectionvar[1]]], na.rm = TRUE)
    ylim<- range(CVdata0[[sectionvar[2]]], na.rm = TRUE)
     plot(CVdata1[[sectionvar[1]]],CVdata1[[sectionvar[2]]],bg=pfillso,col=pcolso, pch=21, cex=pointsize,
        xlab=sectionvar[1],ylab=sectionvar[2] ,main="",xlim=xlim,ylim=ylim)
     if (! is.null(pcolInfo) && !is.null(pcolInfo$cols)){
       
       legend("topright", legend = names(pcolInfo$cols), 
              col = pcolInfo$cols, pch=19,bty="n", cex=1, title=pcolInfo$cvar, inset=legendInset, xpd=NA)
     }
    }
  }
  else {
    gx <- grid[[sectionvar[1]]]
    gy <- grid[[sectionvar[2]]]
    xoffset <- gx[2]- gx[1]
    yoffset<- min(gy[gy>gy[1]]) - gy[1]
    
    fudgex <- .07*xoffset
    fudgey <- .07*yoffset
    
    for (i in seq(along=fitnames)){
    gf <- grid[[fitnames[i]]]


    plot(c(min(gx)-xoffset,max(gx)+xoffset),  c(min(gy)-yoffset,max(gy)+yoffset),  type="n",xlab=sectionvar[1],
         ylab=if(i==1) sectionvar[2] else "", 
         main=if (length(fitnames) > 1) fitnames[i] else "", xaxs="i", yaxs="i")

    col <- fitcolfn(gf)

    rect(gx-xoffset, gy-yoffset,gx+xoffset+fudgex,gy+yoffset+fudgey, col=col,lty=0)
    if (showdata ){
    points(CVdata1[[sectionvar[1]]],CVdata1[[sectionvar[2]]],bg=pfillso,col=pcolso, pch=21, cex=pointsize)
    if (! is.null(pcolInfo) && !is.null(pcolInfo$cols) && i ==length(fitnames)){
    
      legend("topright", legend = names(pcolInfo$cols), 
             col = pcolInfo$cols, pch=19,bty="n", cex=1, title=pcolInfo$cvar,inset=legendInset, xpd=NA)
    }
    }
    }
  }
  
  if (returnInfo && length(fitnames) <=1 )
    clickCoords <- data.frame(x=CVdata1[[sectionvar[1]]],y=CVdata1[[sectionvar[2]]],casenum=which(o))
    else clickCoords <-NULL
  
  
  if (returnInfo){
    return (list(clickCoords=clickCoords))
  } else return(NULL)
}

sectionPlotnnn <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,density=FALSE,zlim=NULL,...){

  if (is.null(zlim) && density){
      ymax <- sapply(fitnames, function(fn) max(grid[[fn]]))
      zlim <- c(0, max(ymax))
    }

  if (is.null(zlim))
  fitcolfn <- colorfn(CVdata[[response]], density=density)
  else fitcolfn <- colorfn(zlim, density=density)

  cc <-sectionPlotd3(CVdata,fitnames,sectionvar,response,sim,grid,linecols, fitcolfn=fitcolfn,density=density,...)
  legendn(fitcolfn)
  par(mfrow=c(1,1))
  layout(1)
  return(cc)

}


sectionPlotnnf <- function(CVdata,fitnames,sectionvar,response, sim,grid,
                           jitter=NULL,linecols,drawaxes=TRUE,ylab=response,pointSize,showdata,returnInfo,pcolInfo=NULL,...){

  par(mar = c(3, 3, 3,.5),
      mgp = c(2, 0.4, 0),
      tck = -.01,
      mfrow = c(1, max(1,length(fitnames))))
 
  
  pcols <- CVdata$pointCols
  
  xvar <- sectionvar[1]
  fac <- sectionvar[2]
  faclevels <- levels(CVdata[[fac]])
  CVdata <- pointColor2var(CVdata,fac)
  pfill <- CVdata$pointCols
  linecols <- pfill[match(faclevels,CVdata[[fac]])]
  
    
  # if (length(linecols) < length(faclevels))
  #   if (length(faclevels) <= 8)
  #     linecols <- rev(RColorBrewer::brewer.pal(max(3, length(faclevels)), "Dark2"))[1:length(faclevels)]
  # else linecols <- colors()[1:length(faclevels)]


  x <- CVdata[[xvar]]
  y <- CVdata[[response]]
  xlim <- range(x, na.rm = TRUE)
  ylim <- range(y, na.rm = TRUE)
  if (showdata){
  pcols <- weightcolor(pcols, sim)
  pfill <- weightcolor(pfill, sim)
  o <- attr(pcols, "order")
  pcols <- pcols[o]
  pfill <- pfill[o]
  x <- x[o]
  y <- y[o]
  if (!is.null(jitter)){
    x <- jitter(x, amount=jitter[1])
    y <- jitter(y,amount=jitter[2])
    xlim <- c(xlim[1]- jitter[1], xlim[2]+ jitter[1])
    ylim <- c(ylim[1]- jitter[2], ylim[2]+ jitter[2])
  }
  }
  else {
    x <-NULL
    y <- NULL
    pcols <- NULL
  }
  # plot(x, y, col=pcols,xlim=xlim,ylim=ylim,
  #      xlab=sectionvar, ylab=response,pch=20,cex=2,...)

  if(isRunning() & length(fitnames)==1) {
    ppar <- par("pin")
    ppar[1] <- min(ppar[1], 1.4*ppar[2])
    par(pin=ppar)
  }
  if (is.null(fitnames)) fitnames <- ""
 
  if(isRunning()) {
    legendInset <- c(-.1,-.2)
  }
  else legendInset <- c(0,0)
  
  for (j in seq(along=fitnames)){
    fn <- fitnames[j]

    plot(x, y, col=pcols, bg=pfill,xlim=xlim,ylim=ylim,
         xlab=xvar, ylab=ylab,pch=21,cex=pointSize,
         axes= isTRUE(drawaxes),
         main= if (length(fitnames) > 1) fn else ""
         )
    if (is.function(drawaxes))
      drawaxes()

    for (i in seq(along=faclevels)){
      rows <- grid[[fac]] == faclevels[i]
      lines(grid[rows,xvar], grid[rows,fn], col=linecols[i], lwd=2.5)
    }

    if (j ==1 & length(faclevels) >0)
      legend("topleft", legend = faclevels, col = linecols, lwd=2.5,bty="n", title =fac, cex=.7,
             inset=c(0, legendInset[2]), xpd=NA)
   
    if (! is.null(pcolInfo) && !is.null(pcolInfo$cols) && fac!= pcolInfo$cvar && showdata){
      legend("topright", legend = names(pcolInfo$cols), 
             col = pcolInfo$cols, pch=19,bty="n", cex=.7, title=pcolInfo$cvar, 
             inset=legendInset, xpd=NA)
    }

  }

  if (returnInfo && length(fitnames) <=1 && !is.null(x)){
    clickCoords <- data.frame(x=x,y=y,casenum=o)
    return (list(clickCoords=clickCoords))
  }
  else return(NULL)

}

sectionPlotnfn <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,...){
  sectionPlotnnf(CVdata,fitnames,rev(sectionvar),response, sim,grid,linecols= linecols,...)
}

sectionPlotnff <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,...){
  levels1 <- levels(CVdata[[sectionvar[1]]])
  levels2 <- levels(CVdata[[sectionvar[2]]])
  # if (length(levels2) > length(levels1)){
  #   sectionvar <- rev(sectionvar)
  #   levels1 <- levels2
  # }
  CVdata[[sectionvar[1]]] <- as.numeric(CVdata[[sectionvar[1]]])
  drawaxes <- function(){
    axis(2)
    axis(1, at=seq(along=levels1), labels=levels1)
  }
  sectionPlotnnf(CVdata,fitnames,sectionvar,response,sim,grid, jitter=c(.03,0),linecols, drawaxes=drawaxes,...)

}

sectionPlotfnf <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,...){
  levs <- levels(CVdata[[response]])

  fitp <- any(sapply(grid[,fitnames], function(p) is.double(p) && all(p >= 0) && all(p <=1)))
  grid <- makeFnumeric(grid,fitnames, prob=fitp)
  CVdata <- makeYnumeric(CVdata,response,prob=fitp)

  if (fitp) {
    ticy <- (0:4)/4
    ylab <- paste0("prob(", response, "=", tail(levs,1), ")")
    levs <- ticy
  }
  else {
    ticy <- seq(along=levs)
    ylab <- response
  }

  drawaxes <- function(){
    axis(2, at=ticy, labels=levs)
    axis(1)
  }

  sectionPlotnnf(CVdata,fitnames,sectionvar,response, sim,grid,jitter=c(0,.03),
                 linecols,drawaxes=drawaxes,ylab=ylab,...)
}



sectionPlotffn <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,...){
  sectionPlotfnf(CVdata,fitnames,rev(sectionvar),response, sim,grid,linecols,...)
}

sectionPlotfnn <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,returnInfo=FALSE,...){
  levs <- levels(CVdata[[response]])
  fitp <- any(sapply(grid[,fitnames], function(p) is.double(p) && all(p >= 0) && all(p <=1)))

  if (fitp){
    colorY <- colorfnfp()
    CVdata <- makeYnumeric(CVdata,response, fitp)
  } else
  colorY <- colorfnf(CVdata[[response]])
  cc <-sectionPlotd3(CVdata,fitnames,sectionvar,response,sim,grid,linecols,fitcolfn=colorY,...)

  if (fitp)
    legendn(colorY)
 else legendf(colorY)
  par(mfrow=c(1,1))
  layout(1)
  if (returnInfo) return(cc)
}


sectionPlotfff <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,...){
  levs <- levels(CVdata[[response]])
  levels1 <- levels(CVdata[[sectionvar[1]]])
  levels2 <- levels(CVdata[[sectionvar[2]]])
  if (length(levels2) > length(levels1)){
    sectionvar <- rev(sectionvar)
    levels1 <- levels2
  }

  fitp <- any(sapply(grid[,fitnames], function(p) is.double(p) && all(p >= 0) && all(p <=1)))

  grid <- makeFnumeric(grid,fitnames, prob=fitp)
  CVdata <- makeYnumeric(CVdata,response, prob=fitp)

  CVdata[,sectionvar[1]] <- as.numeric(CVdata[,sectionvar[1]])

  if (fitp) {
    ticy <- (0:4)/4
    ylab <- paste0("prob(", response, "=", tail(levs,1), ")")
    levs <- ticy
  }
  else {
    ticy <- seq(along=levs)
    ylab <- response
  }

  drawaxes <- function(){
    axis(2, at=ticy, labels=levs)
    axis(1, at=seq(along=levels1), labels=levels1)
  }

  sectionPlotnnf(CVdata,fitnames,sectionvar,response, sim,grid, jitter=c(.03,.03),linecols, drawaxes=drawaxes,ylab=ylab,...)
}

#-------------------------





sectionPlotd2 <- function(CVdata,fitnames,sectionvar,response, sim,grid,
                          jitter=NULL,linecols,xlim=NULL,ylim=NULL,xlab=sectionvar,ylab=response,pointSize=1,
                          density=FALSE,showdata=TRUE,returnInfo=FALSE,pointColorFromResponse=FALSE,pcolInfo=NULL,...){

   par(mar = c(3, 3, 3,.5),
      mgp = c(2, 0.4, 0),
      tck = -.01)

  if (length(linecols) < length(fitnames))
    if (length(fitnames) <= 8)
      linecols <- rev(RColorBrewer::brewer.pal(max(3, length(fitnames)), "Dark2"))[1:length(fitnames)]
    else linecols <- rainbow(length(fitnames))

   #pcols <- alpha(CVdata[["pointCols"]],sim)
   x <- CVdata[[sectionvar]]
   y <- CVdata[[response]]
   
   if (density && is.null(ylim)){
     ymax <- sapply(fitnames, function(fn) max(grid[[fn]]))
     ylim <- c(0, max(ymax))
     y <- y*ymax/10
   }

   if (is.null(xlim))  xlim <- range(x, na.rm=TRUE)
   if (is.null(ylim))  ylim <- range(y, na.rm=TRUE)


   if (showdata){
   pcols <- weightcolor(CVdata$pointCols, sim)
   o <- attr(pcols, "order")
   pcols <- pcols[o]
   x <- x[o]
   y <- y[o]
   
   if (!is.null(jitter)){
     x <- jitter(x, amount=jitter[1])
     y <- jitter(y,amount=jitter[2])
     xlim <- c(xlim[1]- jitter[1], xlim[2]+ jitter[1])
     ylim <- c(ylim[1]- jitter[2], ylim[2]+ jitter[2])
   }
   if (returnInfo)
   clickCoords <- data.frame(x=x,y=y,casenum=o)
   else clickCoords <- NULL
   }
   else {
     x <- NULL
     y <- NULL
     pcols <- NULL
     clickCoords <- NULL
   }
  
   
   if(isRunning()) {
     ppar <- par("pin")
     ppar[1] <- min(ppar[1], 1.4*ppar[2])
     par(pin=ppar)
     legendInset <- c(-.1,-.2)
   }
   else legendInset <- c(0,0)
   
   # if(isRunning() & length(fitnames)==1) {
   #   m <- rbind(c(0,1,0))
   #   layout(mat = m,heights = 1, widths=c(.17,.66,.17))
   # }
   # zx <<- par()
   
    plot(x, y, col=pcols,xlim=xlim,ylim=ylim,
       xlab=xlab, ylab=ylab,pch=19,cex=pointSize,main="",...)
    
    if (! is.null(pcolInfo) && !is.null(pcolInfo$cols) && showdata){
      legend("topright", legend = names(pcolInfo$cols), 
             col = pcolInfo$cols, pch=19,bty="n", cex=.7, title=pcolInfo$cvar, inset=legendInset,xpd=NA)
    }
  if (!is.null(grid)){

  for (i in 1:length(fitnames)){
    fn <- fitnames[i]
    lines(grid[,sectionvar], grid[,fn], col=linecols[i], lwd=2.5)
    
    if (paste0(fn,"L") %in% names(grid))
      lines(grid[,sectionvar], grid[,paste0(fn,"L")], col=lighten(linecols[i],.3), lwd=1,lty=2)
    if (paste0(fn,"U") %in% names(grid))
      lines(grid[,sectionvar], grid[,paste0(fn,"U")], col=lighten(linecols[i],.3), lwd=1,lty=2)
      
  }
    if (length(fitnames)> 1)
      legend("topleft", legend = fitnames, col = linecols, lwd=2.5,bty="n", cex=.7,
             inset=c(0, legendInset[2]), xpd=NA)
  }
   if (returnInfo)
    return (list(clickCoords=clickCoords))

}



sectionPlotnn <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,...){
  sectionPlotd2(CVdata,fitnames,sectionvar,response,sim,grid,linecols=linecols,...)
}

sectionPlotnf <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,...){
  levs <- levels(CVdata[[sectionvar]])
  CVdata[[sectionvar]]<- as.numeric(CVdata[[sectionvar]])
  clickc <- sectionPlotd2(CVdata,fitnames,sectionvar,response,sim,grid,jitter=c(0.03,0),linecols=linecols,
                axes=F,...)

  axis(1, at=seq(along=levs), labels=levs)
  axis(2)
  return(clickc)
}

sectionPlotfn <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,xlim,ylim,...){
  levs <- levels(CVdata[[response]])

  CVdata <- makeYnumeric(CVdata,response)
  
  if (!is.null(grid)){
  fitp <- any(sapply(grid[,fitnames], function(p) is.double(p) && all(p >= 0) && all(p <=1)))

  grid <- makeFnumeric(grid,fitnames, prob=fitp)
  CVdata <- makeYnumeric(CVdata,response, prob=fitp)
  }
  else fitp <- FALSE
  if (fitp) {
    ticy <- (0:4)/4
    ylab <- paste0("prob(", response, "=", tail(levs,1), ")")
    levs <- ticy
  }
  else {
    ticy <- seq(along=levs)
    ylab=response
  }

  ylim1 <- c(ticy[1]-.03, tail(ticy,1)+.03 )
  if (is.null(ylim)) ylim <- ylim1
  else ylim <- c(max(ylim[1], ylim1[1]), min(ylim[2], ylim1[2]))

  clickc <- sectionPlotd2(CVdata,fitnames,sectionvar,response,sim,grid, jitter=c(0,.03),linecols=linecols,
                axes=F, xlim=xlim,ylim=ylim, ylab=ylab,...)
  axis(1)
  
  axis(2, at=ticy, labels=levs)
  
 

  return(clickc)
}

sectionPlotff <- function(CVdata,fitnames,sectionvar,response, sim,grid,linecols,xlim,ylim,...){
    levs <- levels(CVdata[[sectionvar]])
   levsr <- levels(CVdata[[response]])
   
   if (!is.null(grid)){
   fitp <- any(sapply(grid[,fitnames], function(p) is.double(p) && all(p >= 0) && all(p <=1)))
   grid <- makeFnumeric(grid,fitnames, fitp)
   }
   else 
     fitp <- FALSE
     CVdata <- makeYnumeric(CVdata,response, fitp)
     CVdata[[sectionvar]] <- as.numeric(CVdata[[sectionvar]])
     

   if (fitp) {
     ticy <- (0:4)/4
     ylab <- paste0("prob(", response, "=", tail(levsr,1), ")")
     levsr <- ticy
   }
   else {
     ticy <- seq(along=levsr)
    ylab <- response
   }

   ylim1 <- c(ticy[1]-.03, tail(ticy,1)+.03 )
   if (is.null(ylim)) ylim <- ylim1
   else ylim <- c(max(ylim[1], ylim1[1]), min(ylim[2], ylim1[2]))

   clickCoords <- sectionPlotd2(CVdata,fitnames,sectionvar,response,sim,grid,jitter=c(0.03,0.03),linecols=linecols,
                 axes=F, xlim=xlim,ylim=ylim, ylab=ylab,...)
   axis(1, at=seq(along=levs), labels=levs)
   axis(2, at=ticy, labels=levsr)
   return(clickCoords)

}


makeYnumeric <- function(CVdata, response,prob=FALSE){
  CVdata[[response]]<- as.numeric(CVdata[[response]])
  if (prob) CVdata[[response]]<-CVdata[[response]]-1
  CVdata
}

makeFnumeric <- function(grid, fitnames, prob=FALSE){
  for (f in fitnames){
    if (is.factor(grid[[f]])){
      grid[[f]] <- as.numeric(grid[[f]])
      if (prob) grid[[f]] <- grid[[f]]-1
    }
  }
  grid
}


sectionPlotpairs <- function(CVdata, sectionvars, cols,sim,pcolInfo=NULL,returnInfo=FALSE,...){
 
  par(mar = c(3, 3, 3,.5),
      mgp = c(2, 0.4, 0),
      tck = -.01)
  
  CVdata <- CVdata[,sectionvars,drop=FALSE]
  # if (length(sectionvars) ==1){
  #   index <- 1:nrow(CVdata)
  #   CVdata$index <-index
  #   CVdata <- CVdata[,2:1]
  # }
  # for ( i in 1:ncol(CVdata)){
  #   if (is.factor(CVdata[[i]]))
  #     CVdata[[i]]<- as.numeric(CVdata[[i]])
  # }
  # nums <- sapply(CVdata, is.numeric)
  # CVdata <- as.matrix(CVdata[nums])
  
  if(isRunning()) {
    ppar <- par("pin")
    ppar[1] <- min(ppar[1], 1.8*ppar[2])
    par(pin=ppar)
    legendInset <- c(0.05,-.12)
  }
  else legendInset <- c(0,0)
  
  
  if (nrow(CVdata) != 0){
       o <- attr(cols, "order")
    xo <- which(!(1:nrow(CVdata) %in% o))
    o <- c(o,xo)
    plot(CVdata[o,,drop=FALSE], col=cols[o],pch=19)
   
    if (! is.null(pcolInfo) && !is.null(pcolInfo$cols) ){
      legend("topright", legend = names(pcolInfo$cols), 
             col = pcolInfo$cols, pch=19,bty="n", cex=.7, title=pcolInfo$cvar, inset=legendInset, xpd=NA)
    }
  
  }
  if (length(sectionvars)==2){
    clickCoords <- data.frame(x=CVdata[o,1],y=CVdata[o,2],casenum=o)
    if (returnInfo)
      return (list(clickCoords=clickCoords))
  }
}
sectionPlotpcp <- function(CVdata, sectionvars, cols,sim,pcolInfo=NULL,...){
  
  par(mar = c(3, 3, 3,.5),
      mgp = c(2, 0.4, 0),
      tck = -.01)
  
  CVdata <- CVdata[,sectionvars,drop=FALSE]
  if (length(sectionvars) ==1){
    index <- 1:nrow(CVdata)
    CVdata$index <-index
    CVdata <- CVdata[,2:1]
  }
 
  for ( i in 1:ncol(CVdata)){
    if (is.factor(CVdata[[i]]))
      CVdata[[i]]<- as.numeric(CVdata[[i]])
  }
  nums <- sapply(CVdata, is.numeric)
  CVdata <- as.matrix(CVdata[nums])

  if (nrow(CVdata) != 0){
    lwd <- rep(1, nrow(CVdata))
    lwd[sim==1]<- 2

    o <- attr(cols, "order")
    xo <- which(!(1:nrow(CVdata) %in% o))
    o <- c(o,xo)
    

    parcoord1(CVdata[o,], cols[o],lwd=lwd[o])
    # axis(2)
    
    if (! is.null(pcolInfo) && !is.null(pcolInfo$cols) ){
      
      if(isRunning()) {
        legendInset <- c(.05,-.15)
      }
      else legendInset <- c(0,0)
      
      legend("topright", legend = names(pcolInfo$cols), 
             col = pcolInfo$cols, pch=19,bty="n", cex=.7, 
             title=pcolInfo$cvar,inset=legendInset,xpd=NA)
    }
  }
}

parcoord1 <-
  function (x, col = 1, lty = 1, horiz=TRUE, autoscale=FALSE,var.label = FALSE, ...){
    
     if (autoscale){
   
    rx <- apply(x, 2L, range, na.rm = TRUE)
    rx1 <- rx[2,]- rx[1,]
    if (max(rx1)/min(rx1) > 4)
      x <- apply(x, 2L, function(x) (x - min(x, na.rm = TRUE))/(max(x,
                                                                    na.rm = TRUE) - min(x, na.rm = TRUE)))
     }

      
    axisr <- range(x, na.rm = TRUE)

    if (horiz){

      matplot(1L:ncol(x), t(x), type = "l", col = col, lty = lty,
              xlab = "", ylab = "", axes = FALSE, ...)
      axis(1, at = 1L:ncol(x), labels = colnames(x))
      for (i in 1L:ncol(x)) {
        lines(c(i, i), axisr, col = "grey70")
        if (var.label)
          text(c(i, i), axisr, labels = format(rx[, i], digits = 3),
               xpd = NA, offset = 0.3, pos = c(1, 3), cex = 0.7)
      }
    }
    else {
      matplot(t(x), 1L:ncol(x),  type = "l", col = col, lty = lty,
              xlab = "", ylab = "", axes = FALSE, ...)
      axis(2, at = 1L:ncol(x), labels = colnames(x))
      for (i in 1L:ncol(x)) {
        lines(axisr,c(i, i),  col = "grey70")
        if (var.label)
          text(axisr,c(i, i),  labels = format(rx[, i], digits = 3),
               xpd = NA, offset = 0.3, pos = c(1, 3), cex = 0.7)
      }
    }
    invisible()
  }




legendn <- function(colorY){
 
  #  if (par("pin")[1]> 6)
  #   inset<- 12
  # else inset <- 8
  
  insetx <- par("pin")[1]*1.5
  insety <- par("pin")[2]*.5
  
  r <- attr(colorY, "breaks")
  z1<- r[-length(r)]
  z2<- r[-1]
  rectcols <- colorY(r)
  
  # par(mar=c(1,inset,.5,inset))
  par(mar=c(insety,insetx,.5,insetx))
  plot( c(z1[1], z2[length(z2)]),c(0,1),  ann=FALSE, axes=F, type="n")

  rect(z1,0,z2,1,col=rectcols, lty=0)
  par(mgp = c(2, 0.2, 0))
  axis(1,cex.axis=.7, lwd=0, lwd.ticks=.5 )
}

legendf <- function(colorY){
  r <- attr(colorY, "levels")
  
  insetx <- par("pin")[1]*1.5
  
  insety <- par("pin")[2]*.5
  z1<- seq(along=r)
  z2<- z1+1
    rectcols <- colorY(r)
  par(mar=c(insety,insetx,.5,insetx))
  plot( c(z1[1], z2[length(z2)]),c(0,1),  ann=FALSE, axes=F, type="n")

  rect(z1,0,z2,1,col=rectcols, lty=0)
  par(mgp = c(2, 0.2, 0))
  axis(1,cex.axis=.7, lwd=0, at=(z1+z2)/2, labels=r )
}
