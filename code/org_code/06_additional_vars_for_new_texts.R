### make additional covariates for the requested texts

library("sophistication")

library("spacyr")
spacy_initialize()

# sotu addresses
data(data_corpus_sotu, package = "quanteda.corpora")

x1 <- covars_make(data_corpus_sotu)
x2 <- covars_make_pos(data_corpus_sotu)
x3 <- covars_make_baselines(data_corpus_sotu, 
                            baseline_year = lubridate::year(docvars(data_corpus_sotu, "Date")))

sotu_covars <- cbind(x1, x2, x3)
save(sotu_covars, file = "sotu_covars.rda")
