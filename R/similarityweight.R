#' @title Calculate the similarity weight for a set of observations
#'
#' @description Calculate the similarity weight for a set of observations, based
#' on their distance from some arbitrary points in data space. Observations which
#' are very similar to the point under consideration are given weight 1, while
#' observations which are dissimilar to the point are given weight zero.
#'
#' @param x A dataframe describing arbitrary points in the space of the data
#'   (i.e., with same \code{colnames} as \code{data}).
#' @param data A dataframe representing observed data.
#' @param threshold Threshold distance outside which observations will
#'   be assigned similarity weight zero. This is numeric and should be > 0.
#'   Defaults to 1.
#' @param distance The type of distance measure to be used, currently just three
#'   types of Minkowski distance: \code{"euclidean"} (default),
#'   \code{"maxnorm"}, \code{"manhattan"} and also \code{"gower"}
#' @param lambda  A constant to multiply by the number of categorical
#'mismatches, before adding to the Minkowski distance, to give a general
#'dissimilarity measure. If left \code{NULL}, behaves as though \code{lambda}
#'is set larger than \code{threshold}, meaning that one factor mismatch
#'guarantees zero weight.
#' @param scale defaults to TRUE, in which case numeric variables are scaled to unit sd.
#' @return A numeric vector or matrix, with values from 0 to 1. The similarity
#'   weights for the observations in \code{data} arranged in rows for each row
#'   in \code{x}.
#'
#' @details Similarity weight is assigned to observations based on their
#'   distance from a given point. The distance is calculated as Minkowski
#'   distance between the numeric elements for the observations whose
#'   categorical elements match, or else the Gower distance.
#'
#' @examples
#' ## Say we want to find observations similar to the first observation.
#' ## The first observation is identical to itself, so it gets weight 1. The
#' ## second observation is similar, so it gets some weight. The rest are more
#' ## different, and so get zero weight.
#'
#' data(mtcars)
#' similarityweight(x = mtcars[1, ], data = mtcars)
#'
#' ## By increasing the threshold, we can find observations which are more
#' ## approximately similar to the first row. Note that the second observation
#' ## now has weight 1, so we lose some ability to discern how similar
#' ## observations are by increasing the threshold.
#'
#' similarityweight(x = mtcars[1, ], data = mtcars, threshold = 5)
#'
#' ## Can provide a number of points to 'x'. Here we see that the Mazda RX4 Wag
#' ## is more similar to the Merc 280 than the Mazda RX4 is.
#'
#' similarityweight(mtcars[1:2, ], mtcars, threshold = 3)
#' @export
#'
#' @references O'Connell M, Hurley CB and Domijan K (2017). ``Conditional
#'   Visualization for Statistical Models: An Introduction to the
#'   \strong{condvis} Package in R.''\emph{Journal of Statistical Software},
#'   \strong{81}(5), pp. 1-20. <URL:http://dx.doi.org/10.18637/jss.v081.i05>.

similarityweight <-
function (x, data, threshold =1, distance = "euclidean", lambda=NULL, scale=TRUE)
{
  ## Initialise the internal function

  vwfun <- if (distance=="gower")
    gowersimfn(data)
  else similarityweightfn(xc = data, scale=scale)
  
  # if (distance=="gower") threshold <- threshold/20
  ## Make empty matrix for weights
  
  k <- matrix(nrow = nrow(x), ncol = nrow(data), dimnames = list(rownames(
    x), rownames(data)))
  
  ## Loop through rows of 'x'
  
  for (i in 1:nrow(x)){
    k[i, ] <- do.call(vwfun, list(xc.cond = x[i, , drop = FALSE], sigma =
                                    threshold, distance = distance, lambda = NULL))$k
  }
  
  ## Return the matrix of weights, dropping to vector if possible
  
  k[, , drop = TRUE]
}

## Internal function which does some preprocessing (particularly scaling) and
## returns a function which calculates similarity weight for a single row of a
## dataframe.

similarityweightfn <-function (xc, scale=TRUE){
  ## Scale the dataframe and calculate a few things for later use.
  
  nrow.xc <- nrow(xc)
  if (nrow.xc < 2)
    scale <- FALSE
  colnames.xc <- colnames(xc)
  arefactors <- vapply(xc, is.factor, logical(1))
  xc.factors <- data.matrix(xc[, arefactors, drop = FALSE])
  xc.num <- data.matrix(xc[, !arefactors, drop = FALSE])
  if (scale){
    x.scaled <- scale(xc.num)
    # four lines added by CH
    zeros <- attr(x.scaled, "scaled:scale") ==0
    attr(x.scaled, "scaled:scale")[zeros]<- 1
    attr(x.scaled, "scaled:center")[zeros]<- 0
    x.scaled[,zeros]<- xc.num[,zeros]
  }
  else x.scaled <- xc.num
  
  k <- rep(0, nrow.xc)
  
  ## Return a function which will calculate the weights for a single arbitrary
  ## point in the data space.
  
  function (xc.cond,  sigma = NULL, distance = c("euclidean", "maxnorm", "manhattan"),
            lambda = NULL)
  {
    ## Set up values
    
    sigma <- if (is.null(sigma))
      1
    else sigma
    distance <- match.arg(distance)
    # p <- if (identical(distance, "euclidean")) 2 else 1
    
    ## If 'sigma' is Inf, return 1s for all observations
    
    if (identical(sigma, Inf))
      return(list(k = rep(1, nrow.xc), sigma = sigma, distance = distance))
    
    ## Get the arbitary point in order.
    
    xc.cond <- xc.cond[, colnames.xc, drop = FALSE]
    xc.cond.factors <- data.matrix(xc.cond[, arefactors, drop = FALSE])
    xc.cond.num <- data.matrix(xc.cond[, !arefactors, drop = FALSE])
    
    ## 'factormatches' is the index of observations on which we will calculate
    ## the Minkowski distance. Basically pre-filtering for speed.
    ##
    ## If 'lambda' is NULL, require all factors to be equal to even bother
    ## calculating Minkowski distance.
    ##
    ## If 'lambda' is supplied, only want observations with less than
    ## (sigma / lambda) mismatches in the factors.
    ##
    ## If there are no factors, want all rows.
    
    factormatches <- if (any(arefactors)){
      if (is.null(lambda)){
        which((nfactormatches <- rowSums(xc.factors == matrix(xc.cond.factors,
                                                              ncol = length(xc.cond.factors), nrow = nrow.xc, byrow = TRUE))) ==
                length(xc.cond.factors))
      } else {
        which(length(xc.cond.factors) - (nfactormatches <- rowSums(xc.factors ==
                                                                     matrix(xc.cond.factors, ncol = length(xc.cond.factors), nrow = nrow.xc
                                                                            , byrow = TRUE))) <= (sigma / lambda))
      }
    } else {rep(TRUE, nrow.xc)}
    
    ## If any observations make it past the above filtering, calculate the
    ## dissimilarity 'd' as Minkowski distance plus 'lambda' times number of
    ## factor mismatches if 'lambda' is supplied.
    ##
    ## Convert the dissimilarity to similarity weights 'k', between 0 and 1.
    
    if ((lfm <- length(factormatches)) > 0){
      if (all(arefactors)){
        if (is.null(lambda)){
          d <- rep(0, lfm)
        } else {
          d <- lambda * (sum(arefactors) - nfactormatches[factormatches]) 
        }
      } else {
        if (scale)
          xcond.scaled <- (xc.cond.num - attr(x.scaled, "scaled:center")) / attr(
            x.scaled, "scaled:scale")
        else xcond.scaled <- xc.cond.num
        d <- dist1(xcond.scaled, x.scaled[factormatches, ], distance) +
          if (any(arefactors) && !is.null(lambda))
            lambda * (sum(arefactors) - nfactormatches[factormatches]) 
        else 0
      }
      
      k[factormatches] <- pmax(0, 1 - d  / sigma)
    }
    list(k = k, sigma = sigma, distance = distance)
  }
}



# similarityweightfn <-function (xc, scale=TRUE){
#   ## Scale the dataframe and calculate a few things for later use.
#   
#   nrow.xc <- nrow(xc)
#   if (nrow.xc < 2)
#     scale <- FALSE
#   colnames.xc <- colnames(xc)
#   arefactors <- vapply(xc, is.factor, logical(1))
#   xc.factors <- data.matrix(xc[, arefactors, drop = FALSE])
#   xc.num <- data.matrix(xc[, !arefactors, drop = FALSE])
#   if (scale){
#     x.scaled <- scale(xc.num)
#     # four lines added by CH
#     zeros <- attr(x.scaled, "scaled:scale") ==0
#     attr(x.scaled, "scaled:scale")[zeros]<- 1
#     attr(x.scaled, "scaled:center")[zeros]<- 0
#     x.scaled[,zeros]<- xc.num[,zeros]
#   }
#   else x.scaled <- xc.num
#   
#   k <- rep(0, nrow.xc)
#   
#   ## Return a function which will calculate the weights for a single arbitrary
#   ## point in the data space.
#   
#   function (xc.cond, sigma = NULL, distance = c("euclidean", "maxnorm", "manhattan"),
#             lambda = NULL)
#   {
#     ## Set up values
#     
#     sigma <- if (is.null(sigma))
#       1
#     else sigma
#     distance <- match.arg(distance)
#     p <- if (identical(distance, "euclidean")) 2 else 1
#     
#     ## If 'sigma' is Inf, return 1s for all observations
#     
#     if (identical(sigma, Inf))
#       return(list(k = rep(1, nrow.xc), sigma = sigma, distance = distance))
#     
#     ## Get the arbitary point in order.
#     
#     xc.cond <- xc.cond[, colnames.xc, drop = FALSE]
#     xc.cond.factors <- data.matrix(xc.cond[, arefactors, drop = FALSE])
#     xc.cond.num <- data.matrix(xc.cond[, !arefactors, drop = FALSE])
#     
#     ## 'factormatches' is the index of observations on which we will calculate
#     ## the Minkowski distance. Basically pre-filtering for speed.
#     ##
#     ## If 'lambda' is NULL, require all factors to be equal to even bother
#     ## calculating Minkowski distance.
#     ##
#     ## If 'lambda' is supplied, only want observations with less than
#     ## (sigma / lambda) mismatches in the factors.
#     ##
#     ## If there are no factors, want all rows.
#     
#     factormatches <- if (any(arefactors)){
#       if (is.null(lambda)){
#         which((nfactormatches <- rowSums(xc.factors == matrix(xc.cond.factors,
#                                                               ncol = length(xc.cond.factors), nrow = nrow.xc, byrow = TRUE))) ==
#                 length(xc.cond.factors))
#       } else {
#         which(length(xc.cond.factors) - (nfactormatches <- rowSums(xc.factors ==
#                                                                      matrix(xc.cond.factors, ncol = length(xc.cond.factors), nrow = nrow.xc
#                                                                             , byrow = TRUE))) <= (sigma / lambda))
#       }
#     } else {rep(TRUE, nrow.xc)}
#     
#     ## If any observations make it past the above filtering, calculate the
#     ## dissimilarity 'd' as Minkowski distance plus 'lambda' times number of
#     ## factor mismatches if 'lambda' is supplied.
#     ##
#     ## Convert the dissimilarity to similarity weights 'k', between 0 and 1.
#     
#     if ((lfm <- length(factormatches)) > 0){
#       if (all(arefactors)){
#         if (is.null(lambda)){
#           d <- rep(0, lfm)
#         } else {
#           d <- lambda * (sum(arefactors) - nfactormatches[factormatches]) ^ p
#         }
#       } else {
#         if (scale)
#           xcond.scaled <- (xc.cond.num - attr(x.scaled, "scaled:center")) / attr(
#             x.scaled, "scaled:scale")
#         else xcond.scaled <- xc.cond.num
#         d <- dist1(xcond.scaled, x.scaled[factormatches, ], distance) +
#           if (any(arefactors) && !is.null(lambda))
#             (lambda * (sum(arefactors) - nfactormatches[factormatches])) ^ p
#         else 0
#       }
#       
#       
#       k[factormatches] <- pmax(0, 1 - (d ^ (1 / p)) / (sigma))
#     }
#     list(k = k, sigma = sigma, distance = distance)
#   }
# }
# original
# dist1 <-function (x, X, p = 2, inf = FALSE)
# {
#   X <- if (is.null(dim(X)))
#     matrix(X, ncol = length(x))
#   else as.matrix(X)
#   dif <- abs(X - matrix(as.numeric(x), nrow = nrow(X), ncol = ncol(X), byrow =
#     TRUE))
#   if (inf)
#     return(apply(dif, 1, max))
#   tmp <- dif ^ p
#   rowSums(tmp)
# }

dist1 <-function (x, X, distance)
{
  X <- if (is.null(dim(X)))
    matrix(X, ncol = length(x))
  else as.matrix(X)
  dif <- abs(X - matrix(as.numeric(x), nrow = nrow(X), ncol = ncol(X), byrow =
    TRUE))
  if (distance=="maxnorm")
    ans <- apply(dif, 1, max)
  else if (distance=="manhattan")
    ans <- rowSums(dif)
  else ans <- sqrt(rowSums(dif^2))
  ans
}


gowersimfn <- function(xc) {
  function(xc.cond,  sigma = 1,...){
    d <- gower::gower_dist(xc.cond, xc)*ncol(xc)
    k <- pmax(0, 1 - d  / sigma)
    list(k = k, sigma = sigma, distance = "gower")
  }
}
