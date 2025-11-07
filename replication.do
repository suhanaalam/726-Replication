*===============================================================================
* Title: replication.do
* Author: Suhana Alam
* Replicating main results from chosen paper (tables 2 & 3)
* Paper: Compulsory Licensing: Evidence from the Trading with the Enemy Act (2012)
*===============================================================================

cap log close _all
clear
set more off

*************** EDIT ONLY THIS LINE :) ********************
global ROOT "/Users/suhanaalam/Documents/ECO726/Project" 
***********************************************************

cd "$ROOT"

log using "replication.log", name (SA) replace

import delimited "moservoena_replication.csv", clear // using replication csv

* getting an overview of the data
summarize
describe

*================================ TABLE 2 =====================================*

* creating the post-policy indicator/dummy variable
gen post1919 = (grntyr>=1919) // checks if year is 1919 (pre treatment) or later
label var post1919 "Post-1919 indicator"

tab post1919

* creating DiD interaction variable
gen did = treat * post1919 // equals 1 only for treated subclasses after 1919
label var did "Treated x Post-1919 interaction" // measures policy's causal effect

tab treat post1919, summarize(did) // check to verify pattern

* setting up the panel
xtset class_id grntyr // each subclass over yrs

* clearing saved columns for new table
eststo clear

* replicating column 1: DiD with foreign inventor controls
xtreg count_usa did count_for i.grntyr, fe vce(cluster class_id)
eststo col1
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

*replicating column 2: DiD without foreign inventor controls
xtreg count_usa did i.grntyr, fe vce(cluster class_id)
eststo col2 // saving results for table 
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

* replicating column 3: intensive margin - # of enemy patents
xtreg count_usa count_cl count_cl_2 count_for i.grntyr, fe vce(cluster class_id)
eststo col3
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

* replicating column 4: quality margin - remaining patent lifetime
xtreg count_usa count_cl count_for i.grntyr, fe vce(cluster class_id)
eststo col4
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

* writing reproduced table to log file
esttab col1 col2 col3 col4, ///
b(%9.4f) se(%9.4f) ///
nodepvars obslast nobaselevels alignment(r) ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(did count_cl count_cl_2 count_for) ///
title("Table 2 Replication: OLS regressions, Dependent Variable = US patents per subclass-year (1875–1939)") ///
mtitles("(1)" "(2)" "(3)" "(4)") ///
coeflabels(did "Subclass has at least one license" count_cl "Number of licenses" ///
        count_cl_2 "Number of licenses squared" ///
        count_for "Number of patents by foreign inventors") ///
stats(subclass_fe year_fe N N_g, fmt(%9s %9s %9.0fc %9.0fc) ///
labels("Subclass fixed effects" "Year fixed effects" "Observations" ///
"Number of subclasses")) ///
order(did count_cl count_cl_2 count_for) ///
nonotes addnotes("Notes: Each observation is a USPTO subclass in a given year (1875–1939). 'count_usa' is the number of patents granted to U.S. inventors in that subclass-year. All regressions include subclass fixed effects and grant-year fixed effects. Standard errors are clustered at the subclass level. *** p<0.01, ** p<0.05, * p<0.10.")
	
* writing reproduced table to LaTex
esttab col1 col2 col3 col4 using "table2_results.tex", ///
replace ///
b(%9.4f) se(%9.4f) ///
nodepvars obslast nobaselevels booktabs ///
alignment(D{.}{.}{-1}) ///
collabels(none) eqlabels(none) varwidth(60) ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(did count_cl count_cl_2 count_for) ///
title("Table 2 Replication: OLS regressions, Dependent Variable = US patents per subclass-year (1875–1939)") ///
mtitles("(1)" "(2)" "(3)" "(4)") ///
coeflabels(did "Subclass has at least one license" count_cl "Number of licenses" ///
        count_cl_2 "Number of licenses squared" ///
        count_for "Number of patents by foreign inventors") ///
stats(subclass_fe year_fe N N_g, fmt(%9s %9s %9.0fc %9.0fc) ///
labels("Subclass fixed effects" "Year fixed effects" "Observations" ///
"Number of subclasses")) ///
order(did count_cl count_cl_2 count_for) ///
nonotes addnotes("Notes: Each observation is a USPTO subclass in a given year (1875–1939). 'count_usa' is the number of patents granted to U.S. inventors in that subclass-year. All regressions include subclass fixed effects and grant-year fixed effects. Standard errors are clustered at the subclass level. *** p<0.01, ** p<0.05, * p<0.10.")


*=============================== TABLE 3 ======================================*

* setting up the panel
xtset class_id grntyr

* verifying observations and # of subclasses 
count
quietly levelsof class_id, local(cls)
display "Observations = " r(N)
display "Number of subclasses = " wordcount("`cls'")

* clearing saved columns for new table
eststo clear

* replicating column 1
xtreg count_usa count_cl_itt count_for i.grntyr, fe vce(cluster class_id)
eststo column1
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

* replicating column 2: isolates ITT enemy exposure w/o controlling for foreign patents
xtreg count_usa count_cl_itt i.grntyr, fe vce(cluster class_id)
eststo column2
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

* replicating column 3: remaining lifetime of enemy patents
xtreg count_usa year_conf_itt count_for i.grntyr, fe vce(cluster class_id)
eststo column3
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

* replicating column 4: only remaining-lifetime effects
xtreg count_usa year_conf_itt i.grntyr, fe vce(cluster class_id)
eststo column4
estadd local subclass_fe "Yes"
estadd local year_fe     "Yes"

* writing reproduced table to log file
esttab column1 column2 column3 column4, ///
b(%9.4f) se(%9.4f) ///
nodepvars obslast nobaselevels alignment(r) ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(count_cl_itt year_conf_itt count_for) ///
title("Table 3 Replication: Intent to Treat Regressions, Dependent Variable = US patents per subclass-year (1875–1939)") ///
mtitles("(1)" "(2)" "(3)" "(4)") ///
coeflabels(count_cl_itt  "Number of enemy patents" ///
           year_conf_itt "Remaining lifetime of enemy patents" ///
           count_for     "Number of patents by foreign inventors") ///
stats(subclass_fe year_fe N N_g, fmt(%9s %9s %9.0fc %9.0fc) ///
labels("Subclass fixed effects" "Year fixed effects" "Observations" ///
"Number of subclasses")) ///
order(count_cl_itt year_conf_itt count_for) ///
nonotes addnotes("Notes: Subclass-by-year panel (1875–1939), restricted to chemical subclasses with pre-war German patents. All regressions include subclass and grant-year fixed effects, with standard errors clustered at the subclass level. `count_cl_itt` and  `year_conf_itt` measure pre-war exposure to enemy patents (ITT). `count_for` measures patents by foreign inventors excluding Germans. *** p<0.01, ** p<0.05, * p<0.10.")

* writing reproduced code to LaTex
esttab column1 column2 column3 column4 using "Table3_results.tex", ///
replace ///
b(%9.4f) se(%9.4f) ///
nodepvars obslast nobaselevels booktabs ///
alignment(D{.}{.}{-1}) ///
collabels(none) eqlabels(none) varwidth(60) ///
star(* 0.10 ** 0.05 *** 0.01) ///
keep(count_cl_itt year_conf_itt count_for) ///
title("Table 3 Replication: Intent to Treat Regressions, Dependent Variable = US patents per subclass-year (1875–1939)") ///
mtitles("(1)" "(2)" "(3)" "(4)") ///
coeflabels(count_cl_itt  "Number of enemy patents" ///
           year_conf_itt "Remaining lifetime of enemy patents" ///
           count_for     "Number of patents by foreign inventors") ///
stats(subclass_fe year_fe N N_g, fmt(%9s %9s %9.0fc %9.0fc) ///
labels("Subclass fixed effects" "Year fixed effects" "Observations" ///
"Number of subclasses")) ///
order(count_cl_itt year_conf_itt count_for) ///
nonotes addnotes("Notes: Subclass-by-year panel (1875–1939), restricted to chemical subclasses with pre-war German patents. All regressions include subclass and grant-year fixed effects, with standard errors clustered at the subclass level. `count_cl_itt` and  `year_conf_itt` measure pre-war exposure to enemy patents (ITT). `count_for` measures patents by foreign inventors excluding Germans. *** p<0.01, ** p<0.05, * p<0.10.")

