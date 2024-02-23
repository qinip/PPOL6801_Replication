library("sophistication")
library("ggplot2")
library("BradleyTerry2")

# create a subfolder for figures
dir.create("figures", showWarnings = FALSE)

## FIGURE 1 --------  

# get FRE scores for the snippets
load("job999866covars_chameleons.rda")
dat <- job999866covars_chameleons
FRE <- dat$predictors$Flesch
names(FRE) <- rownames(dat$predictors)

load("BT_best.rda")
# get lambdas from BMS best fitting model
main_lambdas <- BTabilities(BT_best)[,"ability"]

##
## HERE, WE SHOULD COMPUTE THE CONSTANTS USED FOR RESCALING
##

# rescale lambdas to the 0-100 space correctly
rescaled_lambdas <- 226.06927 + 57.93899 * main_lambdas
# check that they are matched up
m <- match(names(FRE), names(rescaled_lambdas)) ## they are matched up

ggplot(data.frame(FRE = FRE, rslambda = rescaled_lambdas), aes(x = FRE, y = rslambda)) +
    geom_point(size = .6) +
    labs(y = "Rescaled Best BT Model") +
    geom_smooth(method = "lm", se = TRUE) +
    geom_hline(yintercept = c(0, 100), linetype = "dashed", color = "firebrick") +
    theme(axis.text.x = element_text(size = 5),
          axis.text.y = element_text(size = 5)) +
    theme_classic()
dev.copy2pdf(file = "figures/figure1.pdf", height = 4.5, width = 7) 
# dev.copy2pdf(file = "../../manuscript_article/conditional_accept_submission/figs/figure1.pdf", 
#             height = 4.5, width = 7) 
dev.off()


## FIGURE 2 --------  
# can take 10-15 minutes to run since it has to tag all of the text

load("data_corpus_sotuparagraphs.rda")
data_corpus_sotuclean <- data_corpus_sotuparagraphs %>%
    corpus_reshape(to = "documents") %>%
    corpus_subset(!grepl("(1945|1956|1972|1978|1979|1980)b", docnames(.))) 
docvars(data_corpus_sotuclean, "year") <- lubridate::year(docvars(data_corpus_sotuclean, "Date"))
load("BT_best.rda")
set.seed(10000)
lamba5thgrade <- 
    predict_readability(BT_best, newdata = texts(data_corpus_fifthgrade, groups = rep(1, ndoc(data_corpus_fifthgrade))))[, "lambda"]
predrd <- predict_readability(BT_best, newdata = data_corpus_sotuclean, 
                              reference_top = lamba5thgrade,
                              baseline_year = docvars(data_corpus_sotuclean, "year"), 
                              bootstrap_n = 100)
# add the results to the corpus docvars
docvars(data_corpus_sotuclean, names(predrd)) <- predrd

# compute FRE ratio to 5th grade texts
docvars(data_corpus_sotuclean, "FREv5thgrade") <- 
    0.5 * 
    textstat_readability(data_corpus_sotuclean, "Flesch")[["Flesch"]] /
    textstat_readability(texts(data_corpus_fifthgrade, 
                               groups = rep(1, ndoc(data_corpus_fifthgrade))), "Flesch")[["Flesch"]]

ggplot(data = docvars(data_corpus_sotuclean)) +
    xlab("") +
    ylab("Probability that SOTU is Easier than a 5th Grade Text") +
    geom_point(aes(x = year, y = prob), size = 1.5, color = "black", shape = 16) +
    geom_errorbar(aes(ymin = prob_lo, ymax = prob_hi, x = year), width = 0.25) +
    geom_smooth(aes(x = year, y = prob), span = .15, color = "blue") +
    geom_hline(yintercept = 0.50, linetype = "dashed", color = "firebrick") +
    theme(legend.position = c(1820, 0.4),
          axis.text.x = element_text(size = 5),
          axis.text.y = element_text(size = 5)) +
    theme_classic()
dev.copy2pdf(file = "figures/figure2.pdf", 
            height = 5, width = 8)
# dev.copy2pdf(file = "../../manuscript_article/conditional_accept_submission/figs/figure2.pdf",
#              height = 5, width = 8)
dev.off()


## FIGURE 3 --------  

load("data_corpus_sotuparagraphs.rda")
load("BT_best.rda")
data_corpus_sotucompare <- data_corpus_sotuparagraphs %>%
    corpus_reshape(to = "documents") %>%
    corpus_subset(lubridate::year(Date) %in% c(1956, 1945, 1972, 1974, 1978:1980))
predrd <- predict_readability(BT_best, newdata = data_corpus_sotucompare, 
                              baseline_year = lubridate::year(docvars(data_corpus_sotucompare, "Date")), 
                              bootstrap_n = 500)
pred <- data.frame(predrd, 
                   id = paste(docvars(data_corpus_sotucompare, "President"), 
                              lubridate::year(docvars(data_corpus_sotucompare, "Date")), sep = "-"), 
                   delivery = docvars(data_corpus_sotucompare, "delivery"),
                   stringsAsFactors = FALSE)
pred <- reshape(pred, timevar = "delivery", idvar = "id", direction = "wide")
pred <- within(pred, {
    PrSpokenEasier <- exp(lambda.spoken) / (exp(lambda.spoken) + exp(lambda.written))
    PrSpokenEasier_lo <- exp(lambda_lo.spoken) / (exp(lambda_lo.spoken) + exp(lambda_lo.written))
    PrSpokenEasier_hi <- exp(lambda_hi.spoken) / (exp(lambda_hi.spoken) + exp(lambda_hi.written))
})

# reorder factor levels for id
pred$id <- factor(pred$id, levels = rev(pred$id))

ggplot(pred, aes(x = id)) +
    geom_point(aes(y = PrSpokenEasier)) +
    scale_y_continuous(name = "Probability that Spoken SOTU was Easier than Written", 
                       limits = c(.3, .7),
                       breaks = seq(.3, .7, by = .1)) +
    labs(x = "") + 
    geom_hline(yintercept = .5, linetype = "dashed", color = "firebrick") +
    geom_errorbar(aes(ymin = PrSpokenEasier_lo, 
                      ymax = PrSpokenEasier_hi, x = id), width = 0) +
    theme(axis.text.x = element_text(size = 10),
          axis.text.y = element_text(size = 10)) +
    theme_classic() + 
    coord_flip()

dev.copy2pdf(file = "figures/figure3.pdf", 
             height = 3, width = 8)
# dev.copy2pdf(file = "../../manuscript_article/conditional_accept_submission/figs/figure3.pdf",
#              height = 3, width = 8)
dev.off()
