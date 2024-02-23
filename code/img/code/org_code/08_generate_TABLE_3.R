# Table 3 in the paper

library("sophistication")

txt_clinton <- "If we do these things-end social promotion; turn around failing schools; build modern ones; support qualified teachers; promote innovation, competition and discipline-then we will begin to meet our generation's historic responsibility to create 21st century schools.  Now, we also have to do more to support the millions of parents who give their all every day at home and at work."
txt_bush <- "And the victory of freedom in Iraq will strengthen a new ally in the war on  terror, inspire democratic reformers from Damascus to Tehran, bring more hope  and progress to a troubled region, and thereby lift a terrible threat from the  lives of our children and grandchildren.  We will succeed because the Iraqi  people value their own liberty---as they showed the world last Sunday."

corp_example <- corpus(c(Clinton_1999 = txt_clinton, Bush_2005 = txt_bush))

example_covs <- covars_make_all(corp_example)


# TABLE 3 OUTPUT ---------
tab2 <- as.data.frame(sophistication:::get_covars_from_newdata.corpus(corp_example))
row.names(tab2) <- tab2[, "_docid"]
tab2 <- tab2[, c("google_min", "meanSentenceChars", "pr_noun", "meanWordChars")]
tab2 <- t(tab2)
tab2[1, , drop = FALSE]
round(tab2[2:4, ], 2)

#                   Clinton_1999 Bush_2005
# meanSentenceChars       155.50    153.50
# pr_noun                   0.30      0.23
# meanWordChars             4.94      4.72


# ---- lambdas computed with precision
load("BT_best.rda")
(prd <- predict_readability(BT_best, corp_example))
#                 lambda      prob   scaled
# Clinton_1999 -3.250914 0.2545336 36.38281
# Bush_2005    -3.528247 0.2055582 19.96412

# verify
coef(BT_best) %*% tab2

# relative probability
exp(prd["Clinton_1999", "lambda"]) / 
    (exp(prd["Clinton_1999", "lambda"]) + exp(prd["Bush_2005", "lambda"]))

# ---- REPORTED LAMBDAS FROM TABLE 3
tab2rounded <- round(tab2, 2)
tab2rounded[1, 1] <- round(tab2[1, 1], 6)
tab2rounded[1, 2] <- round(tab2[1, 2], 10)
tab2lambdas <- round(round(coef(BT_best), 2) %*% tab2rounded, 2)
tab2lambdas
#      Clinton_1999 Bush_2005
# [1,]        -2.64     -2.93

# ---- Pr(Clinton snippet easier than Bush snippet) from TEXT
exp(tab2lambdas[1, "Clinton_1999"]) / 
    (exp(tab2lambdas[1, "Clinton_1999"]) + exp(tab2lambdas[1, "Bush_2005"]))
# Clinton_1999 
#    0.5719961 

## lambdas v. fifth-grade texts in text of 5.2
lamba5thgrade <- 
    predict_readability(BT_best, newdata = texts(data_corpus_fifthgrade, groups = rep(1, ndoc(data_corpus_fifthgrade))))[, "lambda"]
lamba5thgrade
# redo with correct reference
predict_readability(BT_best, reference_top = lamba5thgrade,
                    newdata = texts(data_corpus_fifthgrade, groups = rep(1, ndoc(data_corpus_fifthgrade))))
#      lambda prob scaled
# 1 -2.193864  0.5    100

# clinton and bush
predict_readability(BT_best, reference_top = lamba5thgrade, newdata = corp_example)
#                 lambda      prob   scaled
# Clinton_1999 -3.250914 0.2578736 36.76429
# Bush_2005    -3.528247 0.2084353 20.17345
