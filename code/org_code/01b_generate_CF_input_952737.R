###
### create second round of snippets and for comparison on CrowdFlower
###
###

library("sophistication")

data(data_corpus_sotu, package = "quanteda.corpora")
# use only pre-Trump data (Trump speeches were unavailable at time of creation)
data_corpus_sotu <- corpus_subset(data_corpus_sotu, Date < "2017-01-01")

## put the main snippets together from the corpus
# make the snippets
snippetData1 <- snippets_make(data_corpus_sotu, nsentence = 1, minchar = 100, maxchar = 300)
snippetData2 <- snippets_make(data_corpus_sotu, nsentence = 2, minchar = 180, maxchar = 400)
snippetData <- rbind(snippetData1, snippetData2)

# clean the text snippets
snippetData <- snippets_clean(snippetData, readability.limits = c(10, 100), measure = "Flesch")

## make gold and screeners
goldPairs <- pairs_regular_make(snippetData, n.sample = 2000, n.pairs = 10000, seed = 100)
# make 1000 gold questions
snippetGold <- pairs_gold_make(goldPairs, min.diff.quantile = c(.20, .80), n.pairs = 1000)
# inspect the gold pairs
##pairs_gold_browse(snippetGold)

# and 20 screener questions
snippetScreeners <- pairs_gold_make(goldPairs, n.pairs = 100, screeners = TRUE, seed = 100)
# inspect the screeners
##pairs_gold_browse(snippetScreeners)

## make the pairs to be CrowdFlowered
snippetPairs <- pairs_regular_make(snippetData, n.sample = 2000, n.pairs = 10000, seed = 100)
# pairs_regular_browse(snippetPairs)


# create the output data
tmp <- cf_input_make(snippetPairs, snippetGold, snippetScreeners,
           filename = "CF_input_952737.csv")

##
## at this point I upload the .csv file to a new job through the CrowdFlower web API
##
