% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_optimal.R
\name{find_optimal}
\alias{find_optimal}
\title{Find an optimal classification among competing clustering solutions}
\usage{
find_optimal(data, clustering, family, K = 1, cutree = NULL,
  cutreeLevels = 2:10, cutreeOveride = FALSE)
}
\arguments{
\item{data}{a data frame (or object that can be coerced by \code{\link[base]{as.data.frame}} containing the "raw" multivariate data. This is not necessarily the data used by the clustering algorithm - it is the data on which you are testing the predictive ability of the clustering solutions.}

\item{clustering}{either an object on which \code{\link[stats]{cutree}} will work, or a list with one or more components, each containing an atomic vector of cluster labels (that can be coerced by \code{\link[base]{as.factor}}). The number of cluster labels (either generated by \code{\link[stats]{cutree}} or supplied in each list component) must match the number of rows of the object supplied in the \code{data} argument.}

\item{family}{a character string denoting the error distribution to be used for model fitting. The options are similar to those in \code{\link[stats]{family}}, but are more limited - see Details.}

\item{K}{number of trials in binomial regression. By default, K=1 for presence-absence data (with cloglog link).}

\item{cutree}{logical, but default is \code{NULL} for auto-detection. Whether \code{\link[stats]{cutree}} should be used on the object supplied to the \code{clustering} argument}

\item{cutreeLevels}{a numerical vector specifying the different partitioning levels to calculate sum-of-AIC for (that is the values of \code{k} to be supplied to \code{\link[stats]{cutree}}). Ignored if \code{cutree = FALSE}, as the number of partitions will be automatically generated from the number of unique levels in each component of \code{clustering}.}

\item{cutreeOveride}{logical. Ignored if \code{cutree = FALSE}. Should the checks on whether the object supplied to the \code{clustering} works with \code{\link[stats]{cutree}}? WARNING: only set \code{cutreeOveride = TRUE} if you are totally sure \code{\link[stats]{cutree}} works, but the error message is telling you it doesn't. See Arguments in \code{\link[stats]{cutree}} and first consider modifying the object supplied to clustering=.}
}
\value{
a data frame containing the sum-of-AIC value for each clustering solution, along with the number of clusters the solution had. The object is of class \code{aicsums}.

Attributes for the data frame are:

\describe{
  \item{\code{family}}{ which error distribution was used for modelling, see Arguments}
  \item{\code{K}}{ number of cases for Binomial regression, see Arguments}
  \item{\code{cutree}}{ whether \code{\link[stats]{cutree}} was used, see Arguments}
  \item{\code{cutreeLevels}}{ number of partitioning levels specified, see Arguments}
}
}
\description{
\code{find_optimal} takes a clustering solution, or a set of related clustering solutions, fits models based on the underlying multivariate data, and calculates the sum-of-AIC value for the solution/s. The smallest sum-of-AIC value is the optimal solution.
}
\details{
\code{find_optimal} is built on the premise that a \emph{good} clustering solution (i.e. a classification) should provide information about the composition and abundance of the multivariate data it is classifying. A natural way to formalize this is with a predictive model, where group membership (clusters) is the predictor, and the multivariate data (site by variables matrix) is the response. \code{find_optimal} fits linear models to each variable, and calculates the sum of the AIC value (sum-of-AIC) for each model. sum-of-AIC is motivated as an estimate of Kullback-Leibler distance, so we posit that the clustering solution that minimises the sum-of-AIC value is the \emph{best}. So, in context of optimal partitioning, \code{find_optimal} can be used to automatically and objectively decide which clustering solution is the best among competing solutions. Lyons et al. (2016) provides background, a detailed description of the methodology, and application of sum-of-AIC on both real and simulated ecological multivariate abundance data.

At present, \code{find_optimal} supports the following error distributions for model fitting:
\itemize{
  \item Gaussian (LM)
  \item Negative Binomial (GLM with log link)
  \item Poisson (GLM with log link)
  \item Binomial (GLM with cloglog link for binary data, logit link otherwise)
  \item Ordinal (Proportional odds model with logit link)
}

Gaussian LMs should be used for 'normal' data. Negative Binomial and Poisson GLMs should be used for count data. Binomial GLMs should be used for binary and presence/absence data (when \code{K=1}), or trials data (e.g. frequency scores). If Binomial regression is being used with \code{K>1}, then \code{data} should be numerical values between 0 and 1, interpreted as the proportion of successful cases, where the total number of cases is given by \code{K} (see Details in \code{\link[stats]{family}}). Ordinal regression should be used for ordinal data, for example, cover-abundance scores. For ordinal regression, data should be supplied as either 1) factors, with the appropriate ordinal level order specified (see \code{\link[base]{levels}}) or 2) numeric, which will be coerced into a factor with levels ordered in numerical order (e.g. cover-abundance/numeric response scores). LMs fit via \code{\link[mvabund]{manylm}}; GLMs fit via \code{\link[mvabund]{manyglm}}; proportional odds model fit via \code{\link[ordinal]{clm}}.
}
\examples{

## Prep the 'swamps' data
## ======================

data(swamps) # see ?swamps
swamps <- swamps[,-1]

## Assess clustering solutions using cutree() method
## =================================================

## perhaps not the best clustering option, but this is base R
swamps_hclust <- hclust(d = dist(x = log1p(swamps), method = "canberra"),
                       method = "complete")

## calculate sum-of-AIC values for 10:25 clusters, using the hclust() output
swamps_hclust_aics <- find_optimal(data = swamps, clustering = swamps_hclust,
family = "poisson", cutreeLevels = 10:25)

## Looks like ~20 clusters is where predictive performance levels off

## Note here that the data passed to find_optimal() was actually NOT the
## data used for clustering (transform/distance), rather it was the
## original abundance (response) data of interest

## plot - lower sum-of-AIC valuea indicate 'better' clustering
plot(swamps_hclust_aics)


\dontrun{
## Assess clustering solutions by supplying a list of solutions
## ============================================================

## again, we probably wouldn't do this, but for illustrative purposes
## note that we are generating a list of solutions this time
swamps_kmeans <- lapply(X = 2:40,
FUN = function(x, data) {stats::kmeans(x = data, centers = x)$cluster},
data = swamps)

## calculate sum-of-AIC values for the list of clustering solutions
swamps_kmeans_aics <- find_optimal(data = swamps, clustering = swamps_kmeans,
family = "poisson") # note cutreeLevels= argument is not needed

plot(swamps_kmeans_aics)
}

## See vignette for more explanation than this example
## ============================================================

}
\references{
Lyons et al. 2016. Model-based assessment of ecological community classifications. \emph{Journal of Vegetation Science}, \strong{27 (4)}: 704--715.
}
\seealso{
\code{\link[optimus]{plot.aicsums}}, \code{\link[optimus]{get_characteristic}}, \code{\link[optimus]{merge_clusters}}, S3 for residual plots (at some stage)
}
\author{
Mitchell Lyons
}
\keyword{optimal,}
\keyword{partition,}
\keyword{partitioning}
