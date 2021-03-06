% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/createServer.R
\name{createCVServer}
\alias{createCVServer}
\title{Title Creates a shiny server}
\usage{
createCVServer(
  CVfit,
  CVdata = NULL,
  response = NULL,
  sectionvars,
  conditionvars,
  predsInit = NULL,
  pointColor = NULL,
  cPlotPCP = FALSE,
  cPlotn = 1000,
  orderConditionVars,
  threshold = 1,
  thresholdmax,
  tours = NULL,
  linecols = NULL,
  dataplot = "pcp",
  probs,
  view3d,
  theta3d,
  phi3d,
  predictArgs,
  xlim = NULL,
  ylim = NULL,
  zlim = NULL,
  density = FALSE,
  showdata = TRUE
)
}
\arguments{
\item{CVfit}{a list of fits}

\item{CVdata}{the dataset used for the fit}

\item{response}{name of response variable}

\item{sectionvars}{names of at most two sectionvars}

\item{conditionvars}{names of conditionvars}

\item{predsInit}{starting value for predicts. Defaults to medoid.}

\item{pointColor}{a color, or the name of variable to be used for coloring. If the named variable is numeric, it is first converted to a factor with 3 levels.}

\item{cPlotPCP}{if TRUE, conditionplots are drawn as a single PCP (for more than two conditionvars)}

\item{cPlotn}{Shows a sample of this number of points in conditionplots.}

\item{orderConditionVars}{If supplied, a function to order the Condition Vars}

\item{threshold}{used for similarity weights, defaults to 1.}

\item{thresholdmax}{maximum value allowed of threshold.}

\item{tours}{A list of pre-calculated tours}

\item{linecols}{vector of colors to be used for fits}

\item{dataplot}{"pcp" or "pairs". Used when there is no response, or more than two sectionvars.}

\item{probs}{Logical; if \code{TRUE}, shows predicted class probabilities instead of just predicted classes.}

\item{view3d}{Logical; if \code{TRUE}, includes option for a three-dimensional  regression surface if possible.}

\item{theta3d, phi3d}{Angles defining the viewing direction. \code{theta3d} gives the azimuthal direction and \code{phi3d} the colatitude. See \code{\link[graphics]{persp}}.}

\item{predictArgs}{a list with one entry per fit, giving arguments for CVpredict}

\item{xlim}{passed on to sectionplot}

\item{ylim}{passed on to sectionplot}

\item{zlim}{passed on to sectionplot}

\item{density}{default FALSE. Use TRUE if model is a density function.}

\item{showdata}{If FALSE, data on section not shown.}
}
\value{
a function
}
\description{
Title Creates a shiny server
}
