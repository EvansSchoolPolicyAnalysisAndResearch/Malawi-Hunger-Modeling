# Malawi-Hunger-Modeling
Code and data needed to replicate the results from "Assessing the Utility of Machine Learning for Predicting Food Sufficiency: A Case Study in Malawi"

Requirements:
1. The models can be run in Python, with setup accelerated by downloading [Anaconda](https://www.anaconda.org) and installing the environments in the Environments folder following [these instructions](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html). The environment "mspc" is used for downloading and processing the spatial data, and the environment "msai_ml" is used to run the models.
2. After installing, activate the environment and run `jupyter notebook` from within the Anaconda prompt, navigate to the directory with the notebooks, and execute the code to get the results.
3. Additional Stata code for preparing the response variables from the World Bank's LSMS-ISA surveys is provided for replication purposes. The raw survey data can be downloaded from the World Bank's [LSMS-ISA](https://www.worldbank.org/en/programs/lsms/initiatives/lsms-ISA) page. Users may also find beneficial information for preparing indicators from the data using our main [LSMS-ISA code repository](https://github.com/EvansSchoolPolicyAnalysisAndResearch/LSMS-Agricultural-Indicators-Code).  
4. R scripts that were used to generate the samples for the k-fold crossvalidation are also included and can be executed from within R or R Studio; the output of these scripts is already included, however. 
