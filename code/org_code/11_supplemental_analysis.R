# August 8, 2018

# Code to replicate the 'upper bound' on performance by our modeling approach.
# Full discussion of approach is as SUPPORTING INFORMATON C, 
# "Assessing Model Performance".  Ultimately this code produces a scalar value, 
# 0.79, which is treated as the 'true' denominator for the PCP of the various models.

# MOTIVATION:
# Note that the lower bound is percent correct predicted = .5
# But upper bound can be defined in various ways; ultimately it but needs to 
# reflect the fact that coders are gold standard, but that often DISAGREE.
#  No model, that's attempting to replicate what the coders do and is
# simultaneously producing a y in {0,1} prediction can cater to that 
# disagreement, so we need to divide performance  by a plausible (average) 
# UPPER BOUND.

rm(list=ls())

# function for fit (percent corr predicted)
prop.correct <- function(x, correction = 0.79) {
    sum(predict(x, type = "response") > .5) / length(predict(x, type = "response")) / correction
}

# create a subfolder for figures, if not already existing
dir.create("figures", showWarnings = FALSE)

## Appendix C -----------

# load the contest data
load("job999866covars_chameleons.rda")

# we need winner and loser columns
won_name <- as.character(job999866covars_chameleons$easier[,1])
lost_name <- as.character(job999866covars_chameleons$harder[,1])

# We need to know how many contests involved a given pair.
# That is, we need the denominator for our performance measure.
# For example, we could have contest A_B (A won, B lost)
# and a contest B_A (B won, A lost).  These contests are both 
# btwn A and B.  Clearly tho, upper bound on performance is 50%

# Now generate that denominator
# (1) put all the contests in one matrix
contests <- data.frame(won_name, lost_name)
# (2) sort 
contests.sort <- t(apply(contests, 1, sort))
# (3) combine the player names, and then get table of results
player.names <- paste(contests.sort[,1], contests.sort[,2], sep="_")
contest.counts <-table(player.names)
# (4) build a data frame with contest name (from player.names), 
# plus winner and loser
contest.results <- data.frame(contest=player.names, winner=NA, loser=NA)
contest.results$winner <- won_name
contest.results$loser <- lost_name
# (5) now, go through and for each contest, and calculate number of 
# times those snippets met, and max number of wins by one snippet
contest.name <- unique(player.names)

# This is a data frame just to take the results of that process
contest.outcomes <- data.frame(contest.title= contest.name,
                               number.battles = NA, max.wins=NA)

# This (inefficient) loop populates that data frame
cat("\n Calculating number of times snippets met and max wins by one of them\n ")
for (i in 1:length(contest.outcomes$contest.title)) {
    sub <- subset(contest.results, 
                  contest.results$contest==contest.outcomes$contest.title[i])
    contest.outcomes$number.battles[i] <- nrow(sub)
    contest.outcomes$max.wins[i] <- max(table(sub[,"winner"]))
}

#(6) now add column of 'best' we could possibly do with a model. That is, 
# max.wins divided by number of contests
contest.outcomes$machine.best <- contest.outcomes$max.wins/contest.outcomes$number.battles

# Ultimately this will be a vector of values, which reflects the distribution of 
# best possible performance.
# Now we obtain the mean 'best' performance, which is what will use as our upper bound
cat("\nUpper bound on performance for this data is: \n")
print(round(mean(contest.outcomes$machine.best), d=2))
#so, mean performance is 0.79.  That's the upper bound.

#(6b) In principle, we *could* reweight this by the number of contests involved 
# -- that is, multiply the  machine best for that contest type by 3 if it 
# involves three contests etc.  Then take mean. This makes no difference 
# in practice.

# weighted <- rep(contest.outcomes$machine.best, times = contest.outcomes$number.battles)
# mean(weighted)
# yields mean of ~.79 again.

# Table 1 -----------

load("Best_Model_Results_list.rda")
# output models in terms of PCP
table1 <- paste("\nTABLE 1 Supplemental\n -------------------------------------------\n",
                sprintf("%-20s ", "Model"), "   PCP orig   PCP Adj\n",
                "========================  =======   =======\n") 
for (m in seq_along(model_results)) {
    table1 <- paste(table1, 
                    sprintf("%-25s", names(model_results)[m]),
                    sprintf(" %2.3f", prop.correct(model_results[[m]], correction = 1)), 
                    sprintf("    %2.3f", prop.correct(model_results[[m]], correction = 0.79)), 
                    "\n")
}
table1 <- paste0(table1, " -------------------------------------------\n\n")
cat(table1)
# Model                    PCP orig   PCP Adj
# BT_basic_Flesch            0.568     0.719 
# BT_basic_RF                0.582     0.737 
# BT_optimal_Flesch          0.583     0.738 
# BT_best                    0.585     0.741 



## Appendix D: TABLE 2 ---------

load("job999866covars_chameleons.rda")
library("BradleyTerry2")

# baseline Flesch model
BT_basic_Flesch <- BTm(player1 = easier, player2 = harder, formula = ~ Flesch[ID], id = "ID", data = job999866covars_chameleons)

# Dale-Chall
BT_DC <- BTm(player1 = easier, player2 = harder, formula = ~ Dale.Chall.old[ID], id = "ID", data = job999866covars_chameleons)

# FOG 
BT_FOG <- BTm(player1 = easier, player2 = harder, formula = ~ FOG[ID], id = "ID", data = job999866covars_chameleons)

# SMOG 
BT_SMOG <- BTm(player1 = easier, player2 = harder, formula = ~SMOG[ID], id = "ID", data = job999866covars_chameleons)

# Spache
BT_Spache <- BTm(player1 = easier, player2 = harder, formula = ~ Spache[ID], id = "ID", data = job999866covars_chameleons)

# Coleman-Liau
BT_CL <- BTm(player1 = easier, player2 = harder, formula = ~ Coleman.Liau[ID], id = "ID", data = job999866covars_chameleons)


model_results_classic <- list(FRE = BT_basic_Flesch, 
                              "Dale-Chall" = BT_DC, 
                              FOG = BT_FOG,
                              SMOG = BT_SMOG,
                              Spache = BT_Spache,
                              "Coleman-Liau" = BT_CL)

save(model_results_classic, file = "Classic_Model_Results_list.rda")

# output models in terms of PCP
table2 <- paste("\nTABLE 2\n ------------------------------------------\n",
                sprintf("%-20s ", "Model"), "        AIC     PCP\n",
                "========================  =========  =====\n") 
for (m in seq_along(model_results_classic)) {
    table2 <- paste(table2, 
                    sprintf("%-25s", names(model_results_classic)[m]),
                    sprintf(" %5.2f", model_results_classic[[m]][["aic"]]),
                    sprintf(" %2.3f", prop.correct(model_results_classic[[m]])), 
                    "\n")
}
table2 <- paste0(table2, " ------------------------------------------\n\n")
cat(table2)

# TABLE 2
# Model                         AIC     PCP
# FRE                        26267.79  0.719 
# Dale-Chall                 26277.86  0.722 
# FOG                        26081.44  0.726 
# SMOG                       26188.21  0.666 
# Spache                     25906.35  0.742 
# Coleman-Liau               26571.63  0.697 


## FIGURE 1: SUPPLEMENTAL - Variable Importance Plots  --------  

library("randomForest")
load("rf_model_non_bias_reduced.rda")
load("rf_model_bias_reduced.rda")
par(mfrow=c(2,1))
varImpPlot(mod_bias_reduced, main = "Bias Reduced", pch = 16)
varImpPlot(mod_non_bias_reduced, main = "Not Bias Reduced", pch = 16)
dev.copy2pdf(file = "figures/figureS1.pdf", 
             width = 11, height = 9)
# dev.copy2pdf(file = "../../manuscript_article/conditional_accept_submission/figs/figureS1.pdf",
#              width = 11, height = 9)
dev.off()


## FIGURE 2: SUPPLEMENTAL --------  

load("data_corpus_sotuparagraphs.rda")
library("ggplot2")
library("quanteda")
ggplot(docvars(data_corpus_sotuparagraphs)) + 
    geom_smooth(aes(x = Date, y = log(prob_local / prob_2000))) + 
    geom_hline(yintercept = 0, linetype = "dashed", color = "firebrick") +
    labs(x = "", y = "log ratio of easiness from time-specific versus 2000-only") + 
    theme_classic() + 
    theme(axis.text.x = element_text(size = 15),
          axis.text.y = element_text(size = 15)) +
    annotate("text", x = as.Date("1840-01-01"), y = c(.015, .014, .013),
             label = c("Earlier texts are considered", 
                       "easier when using locally",
                       "fit word rarity baselines"))
dev.copy2pdf(file = "figures/figureS2.pdf", 
             height = 5, width = 8)
# dev.copy2pdf(file = "../../manuscript_article/conditional_accept_submission/figs/figureS2.pdf",
#              height = 5, width = 8)
dev.off()
