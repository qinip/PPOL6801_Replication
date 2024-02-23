###
### create snippets and test cases for comparison on CrowdFlower
###
### this is the new version based on the sophistication package
###

library("sophistication")

data(data_corpus_sotu, package = "quanteda.corpora")
# use only pre-Trump data (Trump speeches were unavailable at time of creation)
data_corpus_sotu <- corpus_subset(data_corpus_sotu, Date < "2017-01-01")

## put the main snippets together from the corpus
# make the snippets
snippetData <- snippets_make(data_corpus_sotu, nsentence = 1, minchar = 120, maxchar = 300)
# clean the text snippets
snippetData <- snippets_clean(snippetData, readability.limits = c(10, 100), measure = "Flesch")

## make gold and screeners
goldPairs <- pairs_regular_make(snippetData, n.sample = 1000, n.pairs = 5000, seed = 11)
# make 50 gold questions
snippetGold <- pairs_gold_make(goldPairs, min.diff.quantile = c(.20, .80), n.pairs = 50)
# inspect the gold pairs
## pairs_gold_browse(snippetGold)
# and 20 screener questions
snippetScreeners <- pairs_gold_make(goldPairs, n.pairs = 20, screeners = TRUE, seed = 10)
# inspect the screeners
## pairs_gold_browse(snippetScreeners)

## make the pairs to be CrowdFlowered
# select 200 from the original range
snippetPairs <- pairs_regular_make(snippetData, n.sample = 100, n.pairs = 200, seed = 12)
# select 100 from narrower range
snippetPairs2 <- pairs_regular_make(subset(snippetData, nchar(snippetData$text) >= 140 & nchar(snippetData$text) <= 180),
                              n.sample = 50, n.pairs = 100, seed = 10)
# select 100 from different range
snippetPairs3 <- pairs_regular_make(subset(snippetData, nchar(snippetData$text) >= 170 & nchar(snippetData$text) <= 200),
                              n.sample = 50, n.pairs = 100, seed = 10)

# to inspect any of them:
## pairs_regular_browse(snippetPairs)

# make some bridging pairs between the three sets
bridgingPairs <- pairs_bridge(snippetPairs, snippetPairs2, snippetPairs3)
## browsePairs(bridgingPairs)

# create the output data
tmp <- cf_input_make(snippetPairs, snippetPairs2, snippetPairs3, bridgingPairs,
                     snippetGold, snippetScreeners,
                     filename = "CF_input_921916.csv")

##
##
## at this point I upload the .csv file to a new job through the CrowdFlower web API
##
##
