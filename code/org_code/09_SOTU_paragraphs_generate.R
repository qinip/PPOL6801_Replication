library("sophistication")
library("spacyr")

load("BT_best.rda")
spacy_initialize()
data(data_corpus_sotu, package = "quanteda.corpora")

# convert to paragraphs and tidy up

data_corpus_sotuparagraphs <- corpus_reshape(data_corpus_sotu, to = "paragraphs")
toremove <- rep(FALSE, ndoc(data_corpus_sotuparagraphs))

# remove paragraphs with all caps titles
# toremove <- toremove | 
#     grepl("^(([A-Z.\"\'&-]|[0-9])+\\.{0,1}\\s{1,})*([A-Z]+\\s{0,1})+[.:]{0,1}$", texts(data_corpus_sotuparagraphs))
toremove <- toremove | 
    grepl("^([A-Z0-9[:punct:]]+\\s{0,1})+\\.{0,1}$", texts(data_corpus_sotuparagraphs))

# remove paragraphs with long figures (from a table)
toremove <- toremove | 
     grepl("(\\d{1,3}(,\\d{3}){1,}(\\.\\d{2})*(\\s\\-\\s)+)", texts(data_corpus_sotuparagraphs))
    
# remove any snippets with long ....
toremove <- toremove | 
    grepl("\\.{4,}", texts(data_corpus_sotuparagraphs))

# remove any snippets with ----- (indicates a table)
toremove <- toremove |
    grepl("\\-{4,}", texts(data_corpus_sotuparagraphs))

# remove e.g. "(a) For veterans."
toremove <- toremove |
    (grepl("^\\([a-zA-Z0-9]+\\)\\s+.*\\.$",  texts(data_corpus_sotuparagraphs)) &
         ntoken(data_corpus_sotuparagraphs) <= 30)

data_corpus_sotuparagraphs <- corpus_subset(data_corpus_sotuparagraphs, !toremove)


# summary statistics
summary(summary(data_corpus_sotuparagraphs, n = ndoc(data_corpus_sotuparagraphs)))

# add readability stats
docvars(data_corpus_sotuparagraphs, "Flesch") <- 
    textstat_readability(data_corpus_sotuparagraphs, "Flesch")[["Flesch"]]

set.seed(10000)

# add predicted BMS "static"
rdblty_2000 <- predict_readability(BT_best, data_corpus_sotuparagraphs,
                                   baseline_year = 2000, bootstrap_n = 100)
names(rdblty_2000) <- paste(names(rdblty_2000), "2000", sep = "_")
# add predicted BMS "dynamic"
rdblty_local <- predict_readability(BT_best, data_corpus_sotuparagraphs,
                                    baseline_year = lubridate::year(docvars(data_corpus_sotuparagraphs, "Date")),
                                    bootstrap_n = 100)
names(rdblty_local) <- paste(names(rdblty_local), "local", sep = "_")


docvars(data_corpus_sotuparagraphs) <- 
    cbind(docvars(data_corpus_sotuparagraphs), rdblty_2000, rdblty_local)

save(data_corpus_sotuparagraphs, file = "data_corpus_sotuparagraphs.rda")
