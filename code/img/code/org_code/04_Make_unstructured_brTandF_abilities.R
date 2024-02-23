#6/20/17
#code creates standard objects -- either br=T or br=F to get unstructured abilities
#these can then be 'regressed' (via RF) on variables.  Can look at e.g. varImpPlot 
# See also 'notes' which covers the stuff below.

#6/19/17
# VSURF appears to be struggling with pr_ POS variables -- 
# use standard randomforest instead.

# 6/15/17
#run the unstructured model w and wout br=T
# --> presumably shd give similar results
#Note that we know have POS variables in terms of *rates*

rm(list=ls())

require(sophistication)
require(BradleyTerry2)

load("replication/dataverse_files/job999866covars_chameleons.rda")
dat <- job999866covars_chameleons

##############################################
######################## bias reduction ######
##############################################

# fit unstructured model (br=T)
BT_unstruc_brT <-
    BTm(player1 = easier, player2 = harder, br = TRUE, id = "ID", data = dat)
save(BT_unstruc_brT, file = "replication/dataverse_files/BT_unstructured_brT_abilities.rda")
# save(BT_unstruc_brT, file = paste0(getOption("ROOT_DROPBOX"), "data_AJPS/BT_unstructured_brT_abilities.rda"))


#################################################
######################## no bias reduction ######
#################################################

# fit unstructured model (br=F)
BT_unstruc_brF <- 
    BTm(player1 = easier, player2 = harder, br = FALSE, id = "ID", data = dat)
save(BT_unstruc_brF, file ="BT_unstructured_brF_abilities.rda")
# save(BT_unstruc_brF, file = paste0(getOption("ROOT_DROPBOX"), "data_AJPS/BT_unstructured_brF_abilities.rda"))
