
# GP consultation length and deprivation for people with multiple conditions

#### Status: In Progress

## Contents
* [Project Description](https://github.com/HFAnalyticsLab/MM_GPcons_length/blob/master/README.md#project-description)
* [Data Sources](https://github.com/HFAnalyticsLab/MM_GPcons_length/blob/master/README.md#data-sources)
* [How does it work?](https://github.com/HFAnalyticsLab/MM_GPcons_length#how-does-it-work)
* [Requirements](https://github.com/HFAnalyticsLab/MM_GPcons_length#requirements) 
* [Getting started](https://github.com/HFAnalyticsLab/MM_GPcons_length#getting-started)
* [Authors](https://github.com/HFAnalyticsLab/MM_GPcons_length#authors---please-feel-free-to-get-in-touch)
* [License](https://github.com/HFAnalyticsLab/MM_GPcons_length/blob/master/LICENSE)
                                                                                                                            
                                                                                                                            
## Project Description
Longer GP consultations are recommended for patients with multiple conditions. Despite these recommendations, research in Scotland has shown that the greater need of patients with multiple conditions living in the most deprived quarter of areas is not reflected in longer consultation length. We studied the association between length of GP consultation and presence of multimorbidity and socioeconomic deprivation in England. 
                                                                                                                            
## Data Sources
Data used for this analysis were anonymised in line with the ICO’s Anonymisation Code of Practice. The data were accessed in The Health Foundation’s Secure Data Environment, which is a secure data analysis facility (accredited for the ISO27001 information security standard, and recognised for the NHS Digital Data Security and Protection Toolkit). No information that could directly identify a patient or other individual was used. For ease of undertaking analysis, data objects may have been labelled e.g. ‘patient_ID’. These do not refer to NHS IDs or other identifiable patient data.

We used data from the Clinical Practice Research Datalink (CPRD), which included patients who were eligble for linkage to the Indices of Multiple Deprivation
Data access for this project has been approved ([ISAC 17_150R](https://www.cprd.com/protocol/high-need-patients-chronic-conditions-primary-and-secondary-care-utilisation-and-costs)). 
                                                                                                                            
## How does it work?
                                                                                                                            
As the data used for this analysis is not publically available, the code cannot be used to replicate the analysis on this dataset. However, with modifications the code will be able to be used on other patient-level CPRD extracts.
                                                                                                                            
### Requirements
                                                                                                                            
These scripts are written in SAS Enterprise Guide Version 7.12  and in Stata/MP 15.1
                                                                                                                            
### Getting started
                                                                                                                            
The SAS folder contains:  
1. conslength_derive.sas  - Uses the consultation and staff files from CPRD to select eligible consultations. We limited the sample to non-administrative face-to-face consultations taking place at the GP practice with GPs, nurses or other clinicians. After cleaning the consultation length data, the file was merged with the clinical and patient files from CPRD. Finally, it was merged with data on [multiple conditions](https://github.com/HFAnalyticsLab/High_cost_users/blob/master/Scripts/05_multimorbidity.sas) 
                                                                                                                              
                                                                                                                            
The Stata folder contains:   
1. duration_MM_deprivation.do - Prepare variables for descriptive analysis and regression models
2. 02_Two_part_regression_models.R - Combines logistic model for whether has a non-zero cost with a gamma distribution for cost where this is non-zero. Predicted values are estimated for each level of household multimorbidity. Confidence intervals are coming soon....
                                                                                                                              
                                                                                                                            
## Authors - please feel free to get in touch
                                                                                                                            
- Mai Stafford, PhD - [on github](https://github.com/maistafford) / [on twitter](https://twitter.com/stafford_xm)
- Dr. Anya Gopfert
                                                                                                                            
## License

This project is licensed under the [MIT License](https://github.com/HFAnalyticsLab/MM_GPcons_length/blob/master/LICENSE).