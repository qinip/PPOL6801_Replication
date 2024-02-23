# 2/19/18 - minor clean up to code.
# note that each of these models takes ~60 seconds to fit.  
# Thus, bootstrapping the pcp is very expensive.

# July 3, 2017
# run the 'optimal models'


rm(list=ls())

## Fit structured BT models ============

library("BradleyTerry2")
load("job999866covars_chameleons.rda")

# baseline Flesch model
BT_basic_Flesch <- BTm(player1 = easier, player2 = harder, 
                       formula = ~ Flesch[ID], id = "ID", 
                       data = job999866covars_chameleons)


# optimal Flesch model
BT_optimal_Flesch <- BTm(player1 = easier, player2 = harder, 
                         formula = ~ meanSentenceLength[ID] + meanWordSyllables[ID], 
                         id = "ID", data = job999866covars_chameleons)

# basic RF model
BT_basic_RF <- BTm(player1 = easier, player2 = harder, 
                   formula = ~ google_min_2000[ID] + meanSentenceChars[ID] + pr_noun[ID], 
                   id ="ID", data = job999866covars_chameleons)

# best model
BT_best <- BTm(player1 = easier, player2 = harder, 
               formula = ~ google_min_2000[ID] +  meanSentenceChars[ID] + pr_noun[ID] + meanWordChars[ID], 
               id = "ID", data = job999866covars_chameleons)

# others we tried

BT_best_adj <- BTm(player1 = easier, player2 = harder, 
               formula = ~ google_min_2000[ID] +  meanSentenceChars[ID] + pr_noun[ID] + pr_adjective[ID] + meanWordChars[ID], 
               id = "ID", data = job999866covars_chameleons)

BT_best_adj_verb <- BTm(player1 = easier, player2 = harder, 
                        formula = ~ google_min_2000[ID] +  meanSentenceChars[ID] + pr_adjective[ID] + pr_verb[ID] + meanWordChars[ID], 
                        id = "ID", data = job999866covars_chameleons)

BT_best_noun_adj_verb <- BTm(player1 = easier, player2 = harder, 
                             formula = ~ google_min_2000[ID] +  meanSentenceChars[ID] + pr_noun[ID] + pr_adjective[ID] + pr_verb[ID] + meanWordChars[ID], 
                             id = "ID", data = job999866covars_chameleons)

# model dropping pr_noun
BT_no_noun <- BTm(player1 = easier, player2 = harder, 
                  formula = ~ google_min_2000[ID] +  meanSentenceChars[ID] +  meanWordChars[ID], 
                  id = "ID", data = job999866covars_chameleons)

# model dropping pr_noun adding pr_verb
BT_verb_no_noun <- BTm(player1 = easier, player2 = harder, 
                       formula = ~google_min_2000[ID] +  meanSentenceChars[ID] + pr_verb[ID] + meanWordChars[ID], 
                       id = "ID", data = job999866covars_chameleons)

BT_adj_no_noun <- BTm(player1 = easier, player2 = harder, 
                       formula = ~google_min_2000[ID] +  meanSentenceChars[ID] + pr_verb[ID] + pr_adjective[ID] + meanWordChars[ID], 
                       id = "ID", data = job999866covars_chameleons)

# model dropping pr_noun adding pr_adjective
BT_adj_no_noun <- BTm(player1 = easier, player2 = harder, 
                      formula = ~google_min_2000[ID] +  
                        meanSentenceChars[ID] + pr_adjective[ID] + meanWordChars[ID], 
                          id = "ID", data = job999866covars_chameleons)

# save the results
model_results <- list(BT_basic_Flesch = BT_basic_Flesch, 
                      BT_basic_RF = BT_basic_RF, 
                      BT_optimal_Flesch = BT_optimal_Flesch, 
                      BT_best = BT_best)
                      # BT_no_noun = BT_no_noun,
                      # BT_adj_no_noun = BT_adj_no_noun,
                      # BT_verb_no_noun = BT_verb_no_noun,
                      # BT_best_adj = BT_best_adj,
                      # BT_best_adj_verb = BT_best_adj_verb,
                      # BT_best_noun_adj_verb = BT_best_noun_adj_verb)
save(model_results, file = "Best_Model_Results_list.rda")

## NOTE: this is also the object data_BTm_bms in the sophistication R package
save(BT_best, file = "BT_best.rda")

##  for sophistication package only
# data_BTm_bms <- model_results[["BT_best"]]
# devtools::use_data(data_BTm_bms, overwrite = TRUE)


## OUTPUT FOR TABLE 2 ================

# function for fit (percent corr predicted)
prop.correct <- function(x = BTFRE) { 
    sum(predict(x, type = "response") > .5) / length(predict(x, type = "response"))
}

library("apsrtable")
with(model_results, apsrtable(BT_basic_Flesch, BT_optimal_Flesch, BT_basic_RF, BT_best))

# order the models in descending order of PCP
# model_results <- model_results[names(sort(sapply(model_results, prop.correct), decreasing = TRUE))]

# output models in terms of PCP
table2 <- paste("\nBottom row of TABLE 2\n -----------------------------------------\n",
                sprintf("%-20s ", "Model"), "     PCP      AIC\n",
                "========================  =====  ========\n") 
for (m in seq_along(model_results)) {
    table2 <- paste(table2, 
                    sprintf("%-25s", names(model_results)[m]),
                    sprintf("%2.3f", prop.correct(model_results[[m]]) / .79), 
                    sprintf(" %5.2f", model_results[[m]][["aic"]]), 
                    "\n")
}
table2 <- paste0(table2, " -----------------------------------------\n\n")
cat(table2)

# Bottom row of TABLE 2
#
# Model                      PCP      AIC
# BT_basic_Flesch           0.719  26267.79 
# BT_basic_RF               0.737  25915.01 
# BT_optimal_Flesch         0.738  25910.29 
# BT_best                   0.741  25740.25 



## Bootstrap CIs ===============

# we want to bootstrap the results of a BT model
# to do that, we can use the internal subset= argument
# Except that, in each case, the subset is a sample of all the rows

library("BradleyTerry2")
load("job999866covars_chameleons.rda")
load("Best_Model_Results_list.rda")

# function for fit (percent corr predicted)
prop.correct <- function(x = BTFRE) { 
    sum(predict(x, type = "response") > .5) / length(predict(x, type = "response"))
}

# Basic function to do a subset bootstrap
# It returns an accuracy estimate adjusted as it should be
boot.one.time <- function(d = job999866covars_chameleons, refmodel) {
    samp <<- sample(1:nrow(d$easier), nrow(d$easier), replace = TRUE)
    model.call <<- as.formula(refmodel)
    BT_resamp <<- BTm(player1 = easier, player2 = harder, formula = model.call, 
                      id = "ID", data = job999866covars_chameleons, subset = samp)
    adj.acc <<- prop.correct(BT_resamp) / 0.79
    adj.acc
}

attach(model_results)
n <- 500 # number of samples

# baseline Flesch model bootstrap
# so let's fit this to the BT_basic_Flesch model, 2 times
bs.draws_basic <- replicate(n, boot.one.time(d=job999866covars_chameleons, refmodel = BT_basic_Flesch))

# basic RF model
bs.draws_basicRF <- replicate(n, boot.one.time(d=job999866covars_chameleons, refmodel = BT_basic_RF))

# optimal Flesch model
bs.draws_opt <- replicate(n, boot.one.time(d=job999866covars_chameleons, refmodel = BT_optimal_Flesch))

# best model
bs.draws_best <- replicate(n, boot.one.time(d=job999866covars_chameleons, refmodel = BT_best))

BS_results <- data.frame(bs.draws_basic, bs.draws_basicRF, bs.draws_opt, bs.draws_best)
detach(model_results)
save(BS_results, file = "bootstrap_results_AJPSR2.rda")

lapply(BS_results, function(y) round(quantile(y, c(0.025, .975)), 3))
# $bs.draws_basic
#  2.5% 97.5% 
# 0.710 0.727 
# 
# $bs.draws_basicRF
#  2.5% 97.5% 
# 0.728 0.747 
#
# $bs.draws_opt
#  2.5% 97.5% 
# 0.729 0.748 
# 
# $bs.draws_best
#  2.5% 97.5% 
# 0.733 0.751 

lapply(BS_results, function(y) round(mean(y), 3))
