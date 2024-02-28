# Replication: Measuring and Explaining Political Sophistication through Textual Complexity

## Table of Contents
- [Introduction](#Introduction)
- [Software Environment](#Software-Environment)
- 【Deliverables](#Deliverables)
- [Codes](#codes)
- [Data](#data)
- [Output](#output)

## Introduction

This repository offers the replication materials for the study by Kenneth Benoit, Kevin Munger, and Arthur Spirling, published in 2019. The paper, titled "Measuring and Explaining Political Sophistication through Textual Complexity," appears in Volume 63 of the *American Journal of Political Science*, 491-508.

>**Abstract**: Political scientists lack domain-specific measures for the purpose of measuring the sophistication of political communication. We systematically review the shortcomings of existing approaches, before developing a new and better method along with software tools to apply it. We use crowdsourcing to perform thousands of pairwise comparisons of text snippets and incorporate these results into a statistical model of sophistication. This includes previously excluded features such as parts of speech and a measure of word rarity derived from dynamic term frequencies in the Google Books data set. Our technique not only shows which features are appropriate to the political domain and how, but also provides a measure easily applied and rescaled to political texts in a way that facilitates probabilistic comparisons. We reanalyze the State of the Union corpus to demonstrate how conclusions differ when using our improved approach, including the ability to compare complexity as a function of covariates.

**Access the Paper**: The official publication can be found online at AJPS, [DOI: 10.1111/ajps.12423](https://doi.org/10.1111/ajps.12423).

**Replication Materials**: The authors have generously provided all materials necessary for replicating the analyses presented in their article. These materials are hosted on the *American Journal of Political Science* Dataverse within the Harvard Dataverse Network. You can access the dataset directly via [DOI: 10.7910/DVN/9SF3TI](https://doi.org/10.7910/DVN/9SF3TI).

The R codes used in the article can be found under the foder `code`.  The code used 

## Software Environment
The original authors have provided guidance for installing the necessary components in the R environment for replication:

>Replication requires quanteda >= v1.3.7. This can be installed using:
>```{r}
> devtools::install_github("quanteda/quanteda")
>```
>The other required R packages can be installed using: 
>```{r}
>devtools::install_github("kbenoit/sophistication")
>devtools::install_github("quanteda/quanteda.corpora")
>install.packages(c("spacyr", "randomForests", "apsrtable"))
>```

However, note that the installation methods for some of these packages have changed:

-   The `apsrtable` package was removed from the CRAN repository. We need to download the previously available versions from the [archive here](https://cran.r-project.org/src/contrib/Archive/apsrtable/) (the latest version is 0.8-8) and install from the downloaded file using:
	```{r}
	install.packages("/absolute/path/to/Downloads/apsrtable_0.8-8.tar.gz", 	repos = NULL, type = "source")
	```
	Please replace `/path/to/Downloads/` with the actual path to the directory where your `.tar.gz` file is located.
-   The installation of `spacyr` may require the use of the `reticulate` package, depending on your computer's operating environment. Please refer to the official GitHub repository for guidance: [spacyr on GitHub](https://github.com/quanteda/spacyr).



## Deliverables

Please find the html version of the R notebook, the presentation slides, and the replication report in the root directory of this repo.



## Codes
The code used for this replication is all saved in a Quarto file in R under the `code` directory (`Ji_Replication_nb.qmd`). Additionally, the R code files provided by the original authors are available in the `org_code` subdirectory.

## Data

This replication directly uses the human-labeled datasets obtained by the original authors through the crowdsourcing platform. Given the large size of this dataset and the models generated during the development process, all the data files are provided only as download links [here](https://1drv.ms/u/s!AjoR-7ptawqCnKNDuu92tVyjwnlMAA?e=5lPz95). Please find the authors' codebook in the `data` directory, which provides a detailed explanation of datasets and variables.

## Figures

All the tables and figures generated during this replication process are placed in the `figures` directory. Additionally, the corresponding tables or figures generated in the original article are also included for comparison
