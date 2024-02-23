### make additional covariates for the requested texts
### kb

##
## shorter code to save the whole thing in chameleons format
##
library(reticulate)
use_condaenv("ppol6801", conda = "C:/Users/j_i/anaconda3/condabin/conda.bat", required = TRUE)


devtools::install_github("quanteda/spacyr", build_vignettes = FALSE)
library("spacyr")
spacy_install()
spacy_initialize()
devtools::install_github("kbenoit/sophistication")
library("sophistication")

# read in the last two jobs
allsentences <-
    rbind(read.csv("CF_output_f999866.csv", stringsAsFactors = FALSE),
          read.csv("CF_output_f952737.csv", stringsAsFactors = FALSE))

# create chameleons format data
# note: this also requires spacyr to be installed
job999866covars_chameleons <-
    bt_input_make(allsentences, covars = TRUE,
                  readability_measure = c("Flesch",
                                          "Dale.Chall",
                                          "FOG",
                                          "SMOG",
                                          "Spache",
                                          "Coleman.Liau"),
                  covars_baseline = TRUE, covars_pos = TRUE, normalize = TRUE)

save(job999866covars_chameleons, file = "my_job999866covars_chameleons.rda")

# job999866covars_chameleons_normalized <-
#     bt_input_make(allsentences, covars = TRUE, readability_measure = "Flesch",
#                   covars_baseline = TRUE, covars_pos = TRUE, normalize = TRUE)
#
# save(job999866covars_chameleons_normalized, file = "R_intermediate/job999866covars_chameleons_normalized.rda")



##
## the same data, as a data.frame
##

require(sophistication)

## get sentences

allsentences <-
    rbind(read.csv("CF_output_f999866.csv", stringsAsFactors = FALSE),
          read.csv("CF_output_f952737.csv", stringsAsFactors = FALSE))
# select just the texta and their IDs
allsentences <- allsentences[, c("snippetid1", "text1", "snippetid2", "text2")]
# wrap the sentences
allsentences <- data.frame(snippetid = c(allsentences[, "snippetid1"],
                                         allsentences[, "snippetid2"]),
                           text = c(allsentences[, "text1"],
                                    allsentences[, "text2"]),
                           stringsAsFactors = FALSE)
# just keep the unique ones
allsentences <- allsentences[!duplicated(allsentences$snippetid), ]
nrow(allsentences)

# create the basic covariates
allsentences_covars <- cbind(
    allsentences,
    covars_make(allsentences$text, readability_measure = "Flesch"),
    covars_make_baselines(allsentences$text)
)

txt <- allsentences$text
names(txt) <- allsentences$snippetid

# add the POS covariates
allsentences_pos <- covars_make_pos(txt)

job999866covars <-
    merge(allsentences_covars, allsentences_pos, by.x = "snippetid", by.y = "doc_id")
save(job999866covars, file = "my_job999866covars.rda")
