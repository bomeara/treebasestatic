library(targets)

source("R/functions.R")
source("_packages.R")


# Set target-specific options such as packages.
tar_option_set(packages = "dplyr")


# End this file with a list of target objects.
list(
  tar_target(trees_df, GetTrees()),
  tar_target(taxa_df, GetTaxa()),
  tar_render(index_page, "index.Rmd", params = list(trees = trees_df)),
  tar_render(taxa_page, "taxa.Rmd", params = list(taxa = taxa_df)),
  tar_render(about_page, "about.Rmd"),
  tar_render(references_page, "references.Rmd"),
  tar_target(each_tree, SaveEachTree(trees_df)),
  tar_target(each_study, SaveEachStudy(trees_df))
)
