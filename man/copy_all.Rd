% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/radiant.R
\name{copy_all}
\alias{copy_all}
\title{Source all package functions}
\usage{
copy_all(.from)
}
\arguments{
\item{.from}{The package to pull the function from}
}
\description{
Source all package functions
}
\details{
Equivalent of source with local=TRUE for all package functions. Adapted from functions by smbache, author of the import package. See \url{https://github.com/smbache/import/issues/4} for a discussion. This function will be depracated when (if) it is included in \url{https://github.com/smbache/import}
}
\examples{
copy_all(radiant.data)

}
