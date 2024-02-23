# 7/3/17
# code grabs saved unstructured objects (fitted either via br=T or br=F) and fits RF to them.

# 6/20/17
# code creates standard objects -- either br=T or br=F to get unstructured abilities
# these can then be 'regressed' (via RF) on variables.  Can look at e.g. varImpPlot 
# See also 'notes' which covers the stuff below.

# 6/19/17
# VSURF appears to be struggling with pr_ POS variables -- 
# use standard randomforest instead.

# 6/15/17
# run the unstructured model w and wout br=T
# --> presumably shd give similar results
# Note that we know have POS variables in terms of *rates*

rm(list=ls())

start.time <- Sys.time()
set.seed(27613)

library("quanteda")
library("sophistication")
library("BradleyTerry2")

load("job999866covars_chameleons.rda")
dat <- job999866covars_chameleons


##############################################
######################## bias reduction ######
##############################################

# grab the saved objects
# load(paste0(getOption("ROOT_DROPBOX"), "data_AJPS/BT_unstructured_brT_abilities.rda"))
load("BT_unstructured_brT_abilities.rda")
BT1 <- BT_unstruc_brT

# locate the relevant predictors in the predictors part of the data
y <- BTabilities(BT1)[, "ability"]
yy <- y[!is.na(y)] #remove NAs
m <- match(names(yy), rownames(dat$predictors))


# collect the possible terms -- note that we remove Flesch (because it's aliased by the other variables)
terms <- c("W3Sy", "W2Sy", "W_1Sy", "W6C", "W7C", "W_wl.Dale.Chall", "Wlt3Sy", 
           "meanSentenceLength", "meanWordSyllables", "meanWordChars", 
           "meanSentenceChars", "meanSentenceSyllables", "brown_mean", "brown_min", 
           "google_mean_2000", "google_min_2000", "pr_noun", "pr_verb", "pr_adjective", 
           "pr_adverb", "pr_clause", "pr_sentence")


X <- dat$predictors[m, terms]

# use randomForest instead of VSURF
library("randomForest")
mod <- randomForest(X, y = yy, ntree = 1000)

mod_bias_reduced<-mod
save(x = mod_bias_reduced, file = "rf_model_bias_reduced.rda")

#################################################
######################## no bias reduction ######
#################################################

# grab saved objects
# load(paste0(getOption("ROOT_DROPBOX"), "data_AJPS/BT_unstructured_brF_abilities.rda"))
load("BT_unstructured_brF_abilities.rda")
BT2 <-  BT_unstruc_brF

# locate the relevant predictors in the predictors part of the data
y2 <- BTabilities(BT2)[, "ability"]
yy2 <- y2[!is.na(y2)] #remove NAs
mm <- match(names(yy2), rownames(dat$predictors))


X2 <- dat$predictors[mm, terms]

# use randomForest instead of VSURF
mod2 <- randomForest(X2, y = yy2, ntree = 1000)

mod_non_bias_reduced<-mod2
save(x = mod_non_bias_reduced, file = "rf_model_non_bias_reduced.rda")

##### MOVED to 10_Generate_Figures_1-5.R
# dev.new()
# par(mfrow=c(2,1))
# varImpPlot(mod, main = "Bias Reduced", pch = 16)
# varImpPlot(mod2, main = "Not Bias Reduced", pch = 16)
# 
# pdf(file = "figure/RF_vimp_plots_4.pdf", width = 11, height = 9)
# par(mfrow=c(2,1))
# varImpPlot(mod, main = "Bias Reduced", pch = 16)
# varImpPlot(mod2, main = "Not Bias Reduced", pch = 16)
# dev.off()

# Stop the clock
Sys.time() - start.time

# dev.off()
