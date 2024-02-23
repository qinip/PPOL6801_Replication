###
### create third round of snippets and for comparison on CrowdFlower
###
###

library("sophistication")

data(data_corpus_sotu, package = "quanteda.corpora")
# use only pre-Trump data (Trump speeches were unavailable at time of creation)
data_corpus_sotu <- corpus_subset(data_corpus_sotu, Date < "2017-01-01")

## 2-sentence snippets
pairs345_360 <- snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
                              nsentence = 2,
                              minchar = 345, maxchar = 360) %>%
    snippets_clean(readability.limits = c(0, 130), measure = "Flesch") %>%
    pairs_regular_make(n.pairs = 2000, seed = 2017)

pairs360_375 <- snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
                              nsentence = 2,
                              minchar = 360, maxchar = 375) %>%
    snippets_clean(readability.limits = c(0, 130), measure = "Flesch") %>%
    pairs_regular_make(n.pairs = 2000, seed = 2017)

pairs375_390 <- snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
                              nsentence = 2,
                              minchar = 375, maxchar = 390) %>%
    snippets_clean(readability.limits = c(0, 130), measure = "Flesch") %>%
    pairs_regular_make(n.pairs = 2000, seed = 2017)

# bridge the samples
bridgingpairs <- pairs_bridge(pairs345_360, pairs360_375, pairs375_390, bridge_size = 7)

allpairs_2sent <- rbind(pairs345_360, pairs360_375, pairs375_390, bridgingpairs)

# randomize order
set.seed(12345)
allpairs_2sent <- allpairs_2sent[sample(seq_len(nrow(allpairs_2sent))), ]

## pairs_regular_browse(allpairs_2sent)



## make gold and screeners
# choose some shorter sentences with greater differences in length for gold
pairsForGold <- snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
                              nsentence = 2,
                              minchar = 160, maxchar = 380) %>%
    snippets_clean(readability.limits = c(-20, 120), measure = "Flesch") %>%
    pairs_regular_make(n.pairs = 5000, seed = 2017)
# pairs_regular_browse(pairsForGold)
# make 15% gold questions
snippetGold <- pairs_gold_make(pairsForGold,
                               n.pairs = round(nrow(allpairs_2sent) * .15),
                               seed = 100)
# inspect the gold pairs
## pairs_gold_browse(snippetGold)
# and some screener questions
snippetScreeners <- pairs_gold_make(allpairs_2sent,
                                    n.pairs = round(nrow(allpairs_2sent) * .05),
                                    screeners = TRUE, seed = 100)
# inspect the screeners
## pairs_gold_browse(snippetScreeners)


## bridge the new draws with the older run
# load the first run results
f921916 <- read.csv(file = "CF_output_f921916.csv", header = TRUE,
                    stringsAsFactors = FALSE)
f921916 <- f921916[, c("docid1", "snippetid1", "text1", "docid2", "snippetid2", "text2")]
names(f921916) <- c("docID1", "snippetID1", "text1", "docID2", "snippetID2", "text2")
# bridge non-gold pairs with them
bridgingpairs2 <- pairs_bridge(f921916, allpairs_2sent, bridge_size = 10)


# create the output data
tmp <- cf_input_make(allpairs_2sent, bridgingpairs2, snippetGold, snippetScreeners,
           filename = "CF_input_999866.csv")

##
## at this point I upload the .csv file to a new job through the CrowdFlower web API
##

## tested but not used

# # 4 sentence snippets
# snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
#               nsentence = 4,
#               minchar = 500, maxchar = 600) %>%
#     snippets_clean(readability.limits = c(0, 130), measure = "Flesch") %>%
#     pairs_regular_make(n.sample = 100, n.pairs = 1000, seed = 2017) %>%
#     pairs_regular_browse()
#
# ## 1 sentence snippets
# pairs200_210 <- snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
#                               nsentence = 1,
#                               minchar = 200, maxchar = 210) %>%
#     snippets_clean(readability.limits = c(0, 130), measure = "Flesch") %>%
#     pairs_regular_make(n.sample = 10, n.pairs = 10, seed = 2017)
#
# pairs190_200 <- snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
#                               nsentence = 1,
#                               minchar = 190, maxchar = 200) %>%
#     snippets_clean(readability.limits = c(0, 130), measure = "Flesch") %>%
#     pairs_regular_make(n.sample = 10, n.pairs = 10, seed = 2017)
#
# pairs180_190 <- snippets_make(corpus_subset(data_corpus_sotu, Date > as.Date("1950-01-01")),
#                               nsentence = 1,
#                               minchar = 180, maxchar = 190) %>%
#     snippets_clean(readability.limits = c(0, 130), measure = "Flesch") %>%
#     pairs_regular_make(n.sample = 10, n.pairs = 10, seed = 2017)
#
# allpairs_1sent <- rbind(pairs180_190, pairs190_200, pairs200_210)
# pairs_regular_browse(allpairs_1sent)
