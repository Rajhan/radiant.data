# CHANGES IN radiant.data 0.8.9.0

* Show Rstudio project information in navbar if available
* If Rstudio project is used _R > Report_ and _R > Code_ will use the project directory as base. This allows users to use relative paths and making it easier to share (reproducible) code
* Specify options in .Rprofile for upload memory limit and running R > Report on server
* `find_project` function based on `rstudioapi`
* Overflow `pre` and `code` blocks in HTML reports generated in _R > Report_
* Read rdata files through _Data > Manage_
* _R > Report_ option to view Editor, Preview, or Both
* _R > Report_ Read button to generate code to load various types of data (e.g., rda, rds, xls, yaml, feather)
* _R > Report_ Read button to generate code to load various types of files in report (e.g., jpg, png, md, Rmd, R). If Radiant was started from an Rstudio project, the file paths used will be relative to the project root. Paths to files synced to local Dropbox or Google Drive folder will use the `find_dropbox` and `find_gdrive` functions to enhances reproducibility.
* _R > Report_ Load Report button can be used to Load Rmarkdown file in the editor. It will also extract the source code from Notebook and HTML filels with embedded Rmarkdown
* _R > Report_ will read Rmd directly from Rstudio when "To Rmd (Rstudio)" is selected. This will make it possible to use Rstudio Server Pro's _Share project_ option for realtime collaboration in Radiant
* Long lines of code generated for _R > Report_ will be wrapped to enhance readability 

# CHANGES IN radiant.data 0.8.7.8

* Added preview options to _Data > Manage_ based on https://github.com/radiant-rstats/radiant/issues/30
* Add selected dataset name as default table download name in _Data > View_, _Data > Pivot_, and _Data > Explore_
* Use "stack" as the default for histograms and frequency charts in _Data > Visualize_
* Fix for large numbers in _Data > Explore_ that could cause an integer overflow
* Cleanup `Stop & Report` option in navbar

# CHANGES IN radiant.data 0.8.7.4

* Upgraded tidyr dependency to 0.7

# CHANGES IN radiant.data 0.8.7.1

* Upgraded dplyr dependency to 0.7.1

# CHANGES IN radiant.data 0.8.6

## NEW FEATURES

* Export `ggplotly` from `plotly` for interactive plots in _R > Report_
* Export `subplot` from `plotly` for grids of interactive plots in _R > Report_
* Set default `res = 96` for `renderPlot` and `dpi = 96` for `knitr::opts_chunk`
* Add `fillcol`, `linecol`, and `pointcol` to `visualize` to set plot colors when no `fill` or `color` variable has been selected
* Reverse legend ordering in _Data > Visualize_ when axes are flipped using `coor_flip()`
* Added functions to choose.files and choose.dir. Uses JavaScript on Mac, utils::choose.files and utils::choose.dir on Windows, and reverts to file.choose on Linux
* Added `find_gdrive` to determine the path to a user's local Google Drive folder if available
* `fixMs` for encoding in reports on Windows

## BUG FIXES

* Chi-sqaure results were not displayed correctly in _Data > Pivot_
* Fix for `state_multiple`

# CHANGES IN radiant.data 0.8.1

## NEW FEATURES

- Specify the maximum number of rows to load for a csv and csv (url) file through _Data > Manage_
- Support for loading and saving feather files, including specifying the maximum number of rows to load through _Data > Manage_
- Added author and year arguments to help modals in inst/app/radiant.R (thanks @kmezhoud)
- Added size argument for scatter plots to create bubble charts (thanks @andrewsali)
- Example and CSS formatting for tables in _R > Report_
- Added `seed` argument to `make_train`
- Added `prop`, `sdprop`, etc. for working with proportions
- Set `ylim` in `visualize` for multiple plots
- Show progress indicator when saving reports from _R > Report_
- `copy_attr` convenience function
- `refactor` function to keep only a subset of levels in a factor and recode the remaining (and first) level to, for example, other
- `register` function to add a (transformed) dataset to the dataset dropdown
- Remember name of state files loaded and suggest that name when re-saving the state
- Show dataset name in output if dataframe passed directly to analysis function
- R-notebooks are now the default option for output saved from _R > Report_ and _R > Code_
- Improved documentation on how to customize plots in _R > Report_
- Keyboard short-cut to put code into _R > Report_ (ALT-enter)

## BUG FIXES

- When clicking the `rename` button, without changing the name, the dataset was set to NULL (thanks @kmezhoud, https://github.com/radiant-rstats/radiant/issues/5)
- Replace ext with .ext in `mutate_each` function call
- Variance estimation in Data > Explore would cause an error with unit cell-frequencies (thanks @kmezhoud, https://github.com/radiant-rstats/radiant/issues/6)
- Fix for as_integer when factor levels are characters
- Fix for integer conversion in explore
- Remove \\r and special characters from strings in r_data and r_state 
- Fix sorting in _R > Report_ for tables created using _Data > Pivot_ and _Data > Explore_ when column headers contain symbols or spaces (thanks @4kammer)
- Set `error = TRUE` for rmarkdown for consistency with knitr as used in R > Report
- Correctly handle decimal indicators when loading csv files in _Data > Manage_
- Don't overwrite a dataset to combine if combine generates an error when user sets the the name of the combined data to that of an already selected dataset
- When multiple variables were selected, data were not correctly summarized in Data > Transform
- Add (function) lable to bar plot when x-variable is an integer
- Maintain order of variables in Data > Visualize when using "color", "fill", "comby", or "combx"
- Avoid warning when switching datasets in Data > Transform and variables being summarized do not exists in the new dataset
- which.pmax produced a list but needed to be integer
- To customized predictions in radiant.model indexr must be able to customize the prediction dataframe
- describe now correctly resets the working directory on exit
- removed all calls to summarise_each and mutate_each from dplyr

## Deprecated
- varp_rm has been deprecated in favor of varpop 
- sdp_rm has been deprecated in favor of sdpop 
- mutate_each has been deprecated in favor of mutate_at, mutate_all, and radiant.data::mutate_ext
