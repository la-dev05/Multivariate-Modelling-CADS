*FINAL DO File* LANCET CITIZEN_SURVEY_ALL_DATA (2022-23)*

**FINAL DATA 09-05-2025

import excel "C:\Users\sudhe\Downloads\CITIZEN_SURVEY_ALL_DATA.xlsx", sheet("ALL_DATA") firstrow

count
save "D:\HSTP Pavilion_02.01.24\MAC_21-02-2023_updated_02.01.24\Desktop\LC\LC_CS\FINAL DATA-CITIZEN_SURVEY_ALL_DATA-FINAL_SKS_09.05.2025.dta"

use "D:\HSTP Pavilion_02.01.24\MAC_21-02-2023_updated_02.01.24\Desktop\LC\LC_CS\FINAL DATA-CITIZEN_SURVEY_ALL_DATA-FINAL_SKS_09.05.2025.dta"

/*Cleaning*/
rename CS_ID- D1M_3, lower
rename rural_urban residence
rename block block_code
rename district district_code
rename state state_code

replace state_name= proper(state_name)
replace state_name =trim(state_name)
replace state_name=34 if state_name=="Telangana"
labmask state_code, values(state_name )

replace district_name = proper(district_name)
replace district_name = trim( district_name)
replace district_name = "Bahraich" if district_name=="Bahraichyj"
replace district_name = "Ashok Nagar" if district_name=="Ashoknagar"
replace district_name = "Moradabad" if district_name=="Moradabad╣"
replace district_name = "Lower Dibang Valley" if district_name=="Lower Dibang Valleyq"
replace district_name = "Maharaj Ganj" if district_name=="Mahrajganj"

labmask district , values( district_name )

/*Recode Variables*/

*State Grouped
recode state (9 10 19 20 21= 1 "A") (1 2 3 5 6 7 8 22 23 24 27=2 "B") (28 29 32 33 34=3 "C") (11 12 13 14 15 16 17 18=4 "D"), gen(state_group)
recode a2d (1/2=1 "Primary") (3=2 "Middle") (4=3 "Secondary") (5/8=4 "Higher-Secondary+") (88=88 "DNA"), gen(rec_a2d)
recode a2e (1=1 "Cultivator") (2/3=2 "Wage-Labourer") (4/6=3 "Self-Employed") (7=4 "Regular-Salaried") (7/99=5 "Others"), gen(rec_a2e)

/*Outpatient Care*/

/*Medical Expenditure in Outpatient Care*/
egen medical_op=rowtotal(b6a b6c b6e)
replace  medical_op=. if b6a==. & b6c==. & b6e==.

*Proportion of individuals who pay only from OOPE in Outpatient Care*/

gen prop_indv_spent_oop_op=(b6f==0) if b6f!=.
lab define prop_indv_spent_oop_op 0"Spent also from Insurance" 1"Spent only OOPE"
lab val prop_indv_spent_oop_op prop_indv_spent_oop_op              
label variable prop_indv_spent_oop_op "individuals % who pay only from OOPE in outpatient Care"             


/*OOPE Medical in Outpatient Care*/
gen oope_medical_op =medical_op-b6f
replace oope_medical_op= medical_op if b6f==. 
replace oope_medical_op=0 if oope_medical_op<0

/*Total Health Expenditure (THE) in Outpatient Care*/
egen the_op=rowtotal(medical_op b6h )
replace  the_op =. if b6a==. & b6c==. & b6e==. & b6h==.

/*OOPE in Outpatient Care*/
gen oope_total_op =the_op-b6f
replace oope_total_op= the_op if b6f==.
replace oope_total_op =0 if oope_total_op <0


/*Inpatient care*/

/*Medical Expenditure in Inpatient Care*/
gen medical_ip=c7a
order medical_ip, after (c7a)

*Proportion of individuals who pay only from OOPE in Inpatient Care*/

gen prop_indv_spent_oop_ip=(c7c==0) if c7c!=.
lab define prop_indv_spent_oop_ip 0"Spent also from Insurance" 1"Spent only OOPE"
lab val prop_indv_spent_oop_ip prop_indv_spent_oop_ip 
label variable prop_indv_spent_oop_ip "individuals % who pay only from OOPE in Inpatient Care"

/*OOPE Medical in Outpatient Care*/
gen oope_medical_ip =medical_ip-c7c
replace oope_medical_ip= medical_ip if c7c==. 
replace oope_medical_ip=0 if oope_medical_ip<0

/*Total Health Expenditure (THE) in Inpatient Care*/
egen the_ip=rowtotal(c7a c7f)
replace the_ip=. if c7a==. & c7f==.

/*OOPE in Inpatient Care*/
gen oope_total_ip=the_ip- c7c
replace oope_total_ip = the_ip if c7c ==.
replace oope_total_ip =0 if oope_total_ip <0


replace c3="88" if c3=="**"
destring c3, replace
replace c3=88 if c3==0


label variable the_ip "Total Health Expenditure (Med & Non Med) in inpatient Care (Most Recent)"
label variable oope_total_ip "Out of Pocket Expenditure (Med & Non Med) in Inpatient Care (Most Recent)"
label variable oope_medical_ip "Medical Out of Pocket Expenditure (Medical Only) in Inpatient Care (Most Recent)"

/*Converted monthly premium in annual amount*/
gen rec_c11_per_month_annual = c11_per_month*12
order rec_c11_per_month_annual, after (c11_per_month)

/*FINAL Variable (crec_c11_per_month_annual+c11_per_year)-How much do you currentl*/
egen  c11_annual=rowtotal( c11_per_year rec_c11_per_month_annual)
replace  c11_annual= . if c11_per_year==. & rec_c11_per_month_annual==.
order c11_annual , after ( c11_per_year )

/*Converted monthly willing to pay premium in annual amount*/
gen rec_c14_per_month_annual = c14_per_month*12
order rec_c14_per_month_annual, after (c14_per_month)
/*FINAL-How much would you be willing to pay annually to purchase insurance*/
egen  c14_annual=rowtotal( c14_per_year rec_c14_per_month_annual)
replace  c14_annual= . if c14_per_year==. & rec_c14_per_month_annual==.
order c14_annual , after ( c14_per_year )


/*Grouped Age*/

recode a2b_age (15/24= 1 "15-24") (25/34=2 "25-34") (35/49=3 "35-49") (50/59=4 "50-59") (60/72=5 "60+"), gen(rec_a2b_age)

/* Recode Any Insurance Variable*/
gen any_insurance=0
replace any_insurance=1 if c10a==1 | c10b==1 |  c10d==1 |  c10e==1
replace any_insurance=. if c10a==.
lab define any_insurance 0"No" 1"Have Insurance"
lab val any_insurance any_insurance
label variable any_insurance "Having Any Insurance Coverage (No/Yes) (Recoded)"


/*Illness Types of out-patient care*/

gen illness_op= 4 if rec_b3!=.
replace illness_op= 1 if rec_b3==2 | rec_b3==4 | rec_b3==5 | rec_b3==9 | rec_b3==13
replace illness_op= 2 if rec_b3==12
replace illness_op= 3 if rec_b3==14
label define illness_op 1"NCD" 2"Pregnancy" 3"COVID19" 4"Others"
label val illness_op illness_op
label variable illness_op "Illness Types of Outpatients (OP)"

/*Illness Types of inpatient care*/
gen illness_ip= 4 if rec_c3!=.
replace illness_ip= 1 if rec_c3==2 | rec_c3==4 | rec_c3==5 | rec_c3==9 | rec_c3==13
replace illness_ip= 2 if rec_c3==12
replace illness_ip= 3 if rec_c3==14
label define illness_ip 1"NCD" 2"Pregnancy" 3"COVID19" 4"Others"
label val illness_ip illness_ip
label variable illness_ip "Illness Types of Inpatients (IP)"

save, replace
clear

/*Merge UHC Index File */

use "D:\HSTP Pavilion_02.01.24\MAC_21-02-2023_updated_02.01.24\Desktop\LC\LC_CS\FINAL DATA-CITIZEN_SURVEY_ALL_DATA-FINAL_SKS_09.05.2025.dta"

merge m:1 district using "C:\Users\sudhe\Downloads\LC_CS\Districtwise_UHC_INDEX-20231107.dta"

save "D:\HSTP Pavilion_02.01.24\MAC_21-02-2023_updated_02.01.24\Desktop\LC\LC_CS\FINAL DATA-CITIZEN_SURVEY_ALL_DATA-FINAL_SKS_09.05.2025.dta", replace

/*UHC Index & UHC Index Tertile*/
replace uhc_index_terciles="1" if uhc_index_terciles=="Low UHC"
replace uhc_index_terciles="2" if uhc_index_terciles=="Medium UHC"
replace uhc_index_terciles="3" if uhc_index_terciles=="High UHC"
destring uhc_index_terciles, replace
label define uhc_index_terciles 1"Low-UHC" 2"Medium-UHC" 3"High-UHC"
lab val uhc_index_terciles uhc_index_terciles
label variable uhc_index "UHC INDEX"
label variable uhc_index_terciles "Tertile of UHC Index"


/*Label definitions and value assignments for categorical variables*/

lab define residence 1"Rural" 2"Urban" 
lab val residence residence

lab define a2c 1"Male" 2"Female" 9"Others" 88"DNA"
lab val a2c a2c


lab define a2d 1"Below-Primary" 2"Primary" 3"Middle" 4"Secondary"  5"Sr.Secondary" 6"Graduate" 7"Post-Graduate" 8"Diploma" 88"DNA"
lab val a2d a2d

lab define a2e 1"Cultivator" 2"Agricultural-WageLabourer" 3"NonAgricultural-WageLabourer" 4"SelfEmployed-OwnAccountWorker"  5"SelfEmployed-Employer" 6"SelfEmployed-UnpaidFamilyLabourer" 7"RegularSalaried" 8"AvailableForWork" 9"Student" 10"DomesticChoresAttending" 11"Beggar" 12"SexWorker" 13"Rentier/pensioner/remittance" 14"disabile-NotAbleToWork" 15"TooOldTowork" 99"Others" 88"DNA", modify
lab val a2e a2e

lab define a2h 1"Hindu" 2"Muslim" 3"Christian" 4"Sikh"  5"Buddhist" 6"Jain" 9"Others" 88"DNA" 99"DNA2", modify
lab val a2h a2h

label define a2i 1"General" 2"SCs" 3"STs" 4"OBCs" 99"Others" 88"DNA"
lab val a2i a2i

lab define a2j 1"NeverMarried" 2"Married/LiveIn" 3"Widow" 4"Divorced/Separated"  5"NotStated" 88"DNA"
lab val a2j a2j

lab define a3 1"Very Poor" 2"Poor" 3"Average" 4"Good"  5"Very Good" 88"DNA"
lab val a3 a3

lab define a4 1"Very Poor" 2"Poor" 3"Average" 4"Good"  5"Very Good" 88"DNA"
lab val a4 a4


foreach v of varlist  b1_all_1 -b1_all_99 b1_all_0 b1_all_88 {
    lab define `v' 1"ASHA" 2"Sub Centre" 3"PHC" 4"CHC"  5"GovernmentHospital" 6"PrivateClinic" 7"PrivateHospital" 8"Doctor-MobileVan" 9"AYUSH" 10"TraditionalHealer/Quack" 11"Chemist" 0"DidNotConsult" 99"Other" 88"DNA"
lab val `v' `v'
}

lab define b1_most 1"ASHA" 2"Sub Centre" 3"PHC" 4"CHC"  5"GovernmentHospital" 6"PrivateClinic" 7"PrivateHospital" 8"Doctor-MobileVan" 9"AYUSH" 10"TraditionalHealer/Quack" 11"Chemist" 0"DidNotConsult" 99"Other" 88"DNA"
lab val b1_most b1_most

destring b2, replace
lab define b2 1"Self" 2"OtherHouseholdMember"
lab val b2 b2

lab define b3 1"Infections" 2"Cancer" 3"BloodDiseases" 4"Endocrine/metabolic" 5"Cardiovascular" 6"Respiratory" 7"Gastrointestinal" 8"SkinDiseases" 9"Musculoskeletal" 10"Genito-Urinary" 11"Injuries" 12"Pregnancy/Childbirth" 13"Psychiatric" 14"COVID-19"15"Liver/Kidney"16"Eye"17"HerniaTreatment"18"Stomach"19"Surgery"20"Appendicitis"21"ENT"22"Piles"23"Paralysis"24"Absus"25"Weakness/Cough/Tiredness"26"Dental"27"Allergy"28"Checkup/Review" 99"OtherAilments" 88"DNA
lab val b3 b3

lab define b4 1"Yes" 2"No" 88"DNA"
lab val b4 b4

lab define b6b 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val b6b b6b

lab define b6d 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val b6d b6d


lab define b6g 1"Savings" 2"Borrowings" 3"SalePhysicalAssets" 4"FriendsRelatives" 99"OtherSources"
lab val b6g b6g

lab define b6j 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val b6j b6j

lab define b6k 1"Yes" 0"No"
lab val b6k b6k

lab define b6l 1"Government" 2"Private"
lab val b6l b6l

lab define b6n 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val b6n b6n


foreach v of varlist b6p b6q b6r b6s b6t b6u b6w b6x b6y {
    lab define `v' 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val `v' `v'
}

lab define b6v 1"Yes-completely" 2"Yes-partially" 3"No" 88"DNA"
lab val b6v b6v

lab define b7_1 1"ASHA" 2"Sub Centre" 3"PHC" 4"CHC"  5"GovernmentHospital" 6"PrivateClinic" 7"PrivateHospital" 8"AYUSH" 9"TraditionalHealer/Quack" 10"Chemist" 0"DidNotConsult" 99"Other" 88"DNA"
lab val b7_1 b7_1

foreach v of varlist b7_2a- b7_2n {
    lab define `v' 1"Yes(Spontaneous)" 2"Yes(Prompted)" 3"No" 88"DNA"
lab val `v' `v'
}


foreach v of varlist c1_all_1 -c1_all_99 c1_all_0 c1_all_88 c1_most {
    lab define `v' 1"PHC" 2"CHC"  3"GovernmentHospital" 4"PrivateClinic" 5"PrivateHospital" 6"NGO/CharitableHospital" 0"DidNotAdmitted" 99"Other" 88"DNA"
lab val `v' `v'
}

lab define c2 1"Self" 2"OtherHouseholdMember"
lab val c2 c2

lab define c3 1"Infections" 2"Cancer" 3"BloodDiseases" 4"Endocrine/metabolic" 5"Cardiovascular" 6"Respiratory" 7"Gastrointestinal" 8"SkinDiseases" 9"Musculoskeletal" 10"Genito-Urinary" 11"Injuries" 12"Pregnancy/Childbirth" 13"Psychiatric" 14"COVID-19"15"Liver/Kidney"16"Eye"17"HerniaTreatment"18"Stomach"19"Surgery"20"Appendicitis"21"ENT"22"Piles"23"Paralysis"24"Absus"25"Weakness/Cough/Tiredness"26"Dental"27"Allergy"28"Checkup/Review" 99"OtherAilments" 88"DNA"


lab define c5 1"Yes" 2"No" 88"DNA"
lab val c5 c5

lab define c7b 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val c7b c7b

lab define c7d 1"HouseholdIncome/savings" 2"Borrowings" 3"Sale-physical assets" 4"Contributions from friends/relatives"  9"Other sources"
lab val c7d c7d



foreach v of varlist c7e c7j c7k c7l c7n c7o c7p c7q c7r c7s {
    lab define `v' 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val `v' `v'
}

lab define c7h 1"Yes" 2"No"
lab val c7h c7h

lab define c7i 1"Government" 2"Private"
lab val c7i c7i

lab define c7m 1"Yes-completely" 2"Yes-partially" 3"No" 88"DNA"
lab val c7m c7m

lab define c8 1"PHC" 2"CHC"  3"GovernmentHospital" 4"PrivateClinic" 5"PrivateHospital" 6"NGO/CharitableHospital" 0"DidNotAdmitted" 99"Other" 88"DNA"
lab val c8 c8

foreach v of varlist c9_a- c9_o {
    lab define `v' 1"Yes(Spontaneous)" 2"Yes(Prompted)" 3"No" 88"DNA", modify
lab val `v' `v'
}

foreach v of varlist c10a c10b c10d c10e {
    lab define `v' 1"Yes" 2"No" 3"NeverHeard" 88"DNA" 
lab val `v' `v'
}

lab define c11 1"Monthly" 2"Yearly"
lab val c11 c11

lab define c13 1"Yes-fully" 2"Yes-partially" 3"No" 88"DNA"
lab val c13 c13

lab define c14 1"Monthly" 2"Yearly"
lab val c14 c14


lab define c15 1"Yes" 2"No" 3"CNS" 88"DNA"
lab val c15 c15

foreach v of varlist c16_a- c16_i {
    lab define `v' 1"Yes(Spontaneous)" 2"Yes(Prompted)" 3"No" 88"DNA"
lab val `v' `v'
}

foreach v of varlist c17_a- c17_g {
    lab define `v' 1"Great Extent" 2"Somewhat" 3"Very Little" 4"DK" 88"DNA"
lab val `v' `v'
}

foreach v of varlist c18_a c18_b {
    lab define `v' 1"Yes" 2"No" 3"CNS" 88"DNA" 
lab val `v' `v'
}

foreach v of varlist d1a- d1l {
    lab define `v' 1"Agree" 2"Disagree" 3"DontKnow" 88"DNA" 
lab val `v' `v'
}

/*Variable labelling commands*/

lab var state_code "State Code (with Name)"
lab var state_name "State Name"
lab var state_group "RECODE of state - (State Group)"
lab var district_code "District code"
lab var district_name "District Name"
lab var block_code "Block Code"
lab var block_name "Block Name"
lab var village_code "Village Code"
lab var village_name "Village Name"
lab var cs_id "Citizen Survey Common ID"
lab var consent "Consent"
lab var code_interviewer "Code of the Interviewer"
lab var name_interviewer "Name of the Interviewer"
lab var code_supervisor "Code of the Supervisor"
lab var name_supervisor "Name of the Supervisor"
lab var date_of_interview "Date of the Interview"
lab var residence "Residence or Sector (Rural / Urban)"
lab var assembly_constituency_name "Assembly Constituency Name"
lab var parliamentary_constituency_name "Parliamentary Constituency Name"
lab var a2a_mm "Birth Month"
lab var a2a_yy "Birth Year"
lab var a2b_age "Age in completed years"
lab var consent_adult "Consent"
lab var a2c "Gender of the respondent"
lab var a2d "Highest completed Education"
lab var rec_a2d "(Grouped) RECODE of A2D (Highest completed Education)"
lab var a2e "Main Job/Occupation of the respondent"
lab var rec_a2e "(Grouped) RECODE of A2E (Main Job/Occupation of the respondent)"
lab var a2e_oth "Others Specify"
lab var a2f "Household size of the respondent"
lab var a2g_food "(Food Expenditure) What did your household spend in the past month on the following items? on food"
lab var a2g_edu "What did your household spend in the past month on the following items? on education"
lab var a2h "Religion of the Respondent"
lab var a2h_oth "Religion of the Respondent Others Specify"
lab var a2i "Social Category of the respondent"
lab var a2i_oth "Social Category of the Others Specify"
lab var a2j "Marital status of the respondent"
lab var a3 "In general, how do you rate your physical health in the past few months?"
lab var a4 "In general, how would you rate your mental health in the past few months?"
lab var b1_all_1 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_2 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_3 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_4 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_5 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_6 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_7 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_8 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_9 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_10 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_11 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_99 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_oth "Others Specify"
lab var b1_all_0 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_all_88 "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months?"
lab var b1_most "Which health care provider or facility was consulted for out-patient health consultation in the past 12 months? Most Recent"
lab var b1_most_oth "Others Specify"
lab var b2 "Who took the most recent OPD consultation mentioned above?"
lab var b3 "What was the reason for this consultation?"
lab var b3_oth "Others Specify"
lab var b4 "Was this consultation for an emergency medical problem?"
lab var b5 "How many months ago did this consultation happen?"
lab var b6a "How much money did you/the patient spend on this consultation?"
lab var b6b "Was this amount on consultation reasonable ?"
lab var b6c "How much money did you/the patient spend on medicines which were prescribed?"
lab var b6d "Were you/the patient prescribed / took AYUSH medicines?"
lab var b6e "How much money did you/the patient spend on the required diagnostic tests?"
lab var medical_op "Medical Expenditure in Outpatient Care (Most Recent)"
lab var b6f "How much of the total amount you/the patient spent on this consultation, including medicines and tests, did you get back from/was covered by insurance or employer?"
lab var prop_indv_spent_oop_op "Individuals % who pay only from OOPE in outpatient Care"
lab var b6g "How did you/the patient meet the remaining out of pocket costs?"
lab var b6g_oth "Others Specify"
lab var b6h "How much money did you/the patient spend on travel to the provider/facility?"
lab var the_op "Total Health Expenditure (Med & Non Med) in Outpatient Care (Most Recent)"
lab var oope_medical_op "Out of Pocket Medical Expenditure (Only Med) in Outpatient Care (Most Recent)"
lab var oope_total_op "Out of Pocket Expenditure (Med & Non Med) in Outpatient Care (Most Recent)"
lab var b6i "How much time did it take to reach the health facility (in Minutes)?"
lab var b6j "Was the time taken to reach the health facility convenient?"
lab var b6k "Did you use an ambulance?"
lab var b6l "If yes, what type of ambulance was used?"
lab var b6m "How much time did you/the patient have to wait for the consultation? (in Minutes)"
lab var b6n "Was the waiting time for OPD consultation at the health facility reasonable?"
lab var b6o "How much time did you/the patient spend with the doctor/healthcare provider? (In Minutes)"
lab var b6p "Were you satisfied with this amount of time with the doctor/health care provider?"
lab var b6q "Was the doctor/health care provider at the health facility polite and helpful?"
lab var b6r "Did the doctor/health care provider explain the health problem and treatment properly and give you/the patient an opportunity to answer any questions?"
lab var b6s "Were you/the patient involved in the decision making of this treatment?"
lab var b6t "Did the doctor/health care provider examine you/the patient without any other patients in the room?"
lab var b6u "Did you feel that all your/the patient’s information about the illness was kept private/not shared without your permission?"
lab var b6v "Did the treatment provide you/your household member with relief from your ailment?"
lab var b6w "Was the Health Facility hygienic/sanitary/clean?"
lab var b6x "Were you referred to this health provider?"
lab var b6y "Would you use this facility for future health problems and recommend it to others in your community?"
lab var b7_1 "Which health provider or facility will you / your household member prefer to go to as your first choice (if all of these were accessible)?"
lab var b7_1_oth "Others Specify"
lab var b7_2a "There is no other provider available near our home."
lab var b7_2b "The distance is reasonable"
lab var b7_2c "They are available at a time convenient for me"
lab var b7_2d "The cost is affordable"
lab var b7_2e "The waiting time is reasonable"
lab var b7_2f "The facility of 'Take treatment and pay later' is available with the provider"
lab var b7_2g "The facility is hygienic and clean"
lab var b7_2h "They treat us with respect"
lab var b7_2i "They give free/subsidized medicines"
lab var b7_2j "They spend enough time with us"
lab var b7_2k "The health providers explain my problem and treatment in a way I/we can understand"
lab var b7_2l "The facility is recommended by family or friends"
lab var b7_2m "I trust the Health Care provider"
lab var b7_2n "The facility was accommodating for special needs, i.e., people with disabilities"
lab var b7_2o "Other Reason"
lab var b7_2o_spo_oth "Others Specify"
lab var c1_all_1 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_2 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_3 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_4 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_5 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_6 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_99 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_oth "Others Specify"
lab var c1_all_0 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_all_88 "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)?"
lab var c1_most "Which institution were you or your household member admitted to for the most recent hospital admission (in the past 12 months)? - Most Recent"
lab var c1_most_oth "Others Specify"
lab var c2 "Who was admitted during the most recent hospitalization mentioned above?"
lab var c3 "What was the reason for the most recent Hospitalization?"
lab var c3_oth "Others Specify"
lab var c4 "How many months ago did this admission happen?"
lab var c5 "Was this hospitalization for an emergency?"
lab var c6 "For how many days were you/your household member admitted?"
lab var c7a "What was the Total Expenditure for treatment during stay at hospital?"
lab var medical_ip "Medical Expenditure in Inpatient Care (Most Recent)"
lab var c7b "Was the expenditure incurred on this hospitalization reasonable?"
lab var c7c "How much of this expenditure did you get back from / was covered by Insurance or employer?"
lab var prop_indv_spent_oop_ip "Individuals % who pay only from OOPE in Inpatient Care"
lab var the_ip "Total Health Expenditure (Med & Non Med) in Inpatient Care (Most Recent)"
lab var oope_medical_ip "Out of Pocket Medical Expenditure (Only Med) in Inpatient Care (Most Recent)"
lab var oope_total_ip "Out of Pocket Expenditure (Med & Non Med) in Inpatient Care (Most Recent)"
lab var c7d "How did you meet the remaining expenses?"
lab var c7d_oth "Others Specify"
lab var c7e "Was the facility of 'Take treatment and pay later' available with the provider?"
lab var c7f "How much did you spend for transport to the hospital?"
lab var c7g "How much time it took to reach the health facility (in Minutes)"
lab var c7h "Did you use an ambulance?"
lab var c7i "If yes, what type of ambulance was"
lab var c7j "Were the staff at the hospital polite and helpful?"
lab var c7k "Did the doctor / hospital staff explain the health problem and treatment properly and give you/the patient an opportunity to answer any questions?"
lab var c7l "Were you / your family member's involved in the decision making of your / your household member’s treatment?"
lab var c7m "Did the treatment help you / your household member with the health problem for which admission was taken?"
lab var c7n "Were you/the patient prescribed / took AYUSH medicines?"
lab var c7o "Did you feel that all the information about the admission was kept private/not shared without your permission?"
lab var c7p "Was the hospital hygienic/sanitary/clean?"
lab var c7q "Were you referred to this health facility by another health provider?"
lab var c7r "Was the administrative process of the hospital convenient?"
lab var c7s "Would you use this facility for future hospital admission and recommend it to others in your community?"
lab var c8 "Which kind of hospital would you prefer to go to in the future?"
lab var c8_oth "Others Specify"
lab var c9_a "It is the only hospital near our home"
lab var c9_b "The distance is reasonable"
lab var c9_c "They are always available when I need them"
lab var c9_d "They give free/subsidized medicines"
lab var c9_e "They spend enough time with us"
lab var c9_f "The cost is affordable"
lab var c9_g "The facility of 'Take treatment and pay later' is available"
lab var c9_h "The facility is clean"
lab var c9_i "They treat us with respect"
lab var c9_j "They explain my health problems in a clear way I can understand"
lab var c9_k "It is recommended by family or friends"
lab var c9_l "I trust the hospital"
lab var c9_m "The hospital was accommodating for special needs for persons with disability"
lab var c9_n "The hospital accepts cashless payment from insurance"
lab var c9_o "Other reason"
lab var c9_o_spo_oth "Others Specify"
lab var c10a "Central government scheme like Ayushman Bharat"
lab var c10b "State government scheme"
lab var c10c "If Yes, please mention the name of the scheme."
lab var c10d "Employment State or Employer Insurance Scheme"
lab var c10e "Private Health Insurance"
lab var c10f "If yes, please mention the company name:"
lab var c11 "How would you currenly pay to purchase health insurance (monthly or yearly)?"
lab var c11_per_month "How much do you currently pay each month to purchase an insurance policy"
lab var rec_c11_per_month_annual "New Variable- Converted monthly premium in annual amount"
lab var c11_per_year "How much do you currently pay each year to purchase an insurance policy"
lab var c11_annual "FINAL Variable (crec_c11_per_month_annual+c11_per_year)-How much do you currently pay annually to purchase an insurance"
lab var c12 "What is the maximum health care expenditure this insurance will cover in one year for you and your household?"
lab var c13 "Does the scheme provide adequate protection for you and your household member’s healthcare needs?"
lab var c14 "How would you willing to pay to purchase health insurance (monthly or yearly)?"
lab var c14_per_month "How much would you be willing to pay each month/year to purchase insurance that would cover all the health care expenditure of your family, including hospital admissions, medicines, diagnostic tests and OP consultations? Per Month"
lab var rec_c14_per_month_annual "New Variable- Converted monthly willing to pay premium in annual amount"
lab var c14_per_year "How much would you be willing to pay each month/year to purchase insurance that would cover all the health care expenditure of your family, including hospital admissions, medicines, diagnostic tests and OP consultations? Per Year"
lab var c14_annual "FINAL-How much would you be willing to pay annually to purchase insurance"
lab var c15 "Have you or your Household member ever bought medicines from a Jan-Aushadhi clinic?"
lab var c16_a "Posters in the clinic"
lab var c16_b "Verbally by ASHA or other health workers"
lab var c16_c "TV"
lab var c16_d "Radio"
lab var c16_e "Newspaper"
lab var c16_f "Family and friends"
lab var c16_g "Internet such as google search, YouTube, social media"
lab var c16_h "From members of community based platforms (VHSNCs, MAS, JAS, RKS)"
lab var c16_i "Other"
lab var c16_i_spo_oth "Others Specify"
lab var c17_a "General information about health and wellness"
lab var c17_b "Access to medicines such as e-pharmacies"
lab var c17_c "Finding doctors/facilities/labs"
lab var c17_d "Accessing, retrieving, or sharing your medical reports"
lab var c17_e "Helping you with the treatment of your health problem"
lab var c17_f "Video-call consultations"
lab var c17_g "Any other"
lab var c17_g_oth "Others Specify"
lab var c18_a "Is such a card likely to be important for you to manage your health care?"
lab var c18_b "Is it important that no one else can access your health information linked to this card without your permission?"
lab var d1a "I would like to first go to a family doctor/primary care giver for all my health care needs"
lab var d1b "I would like a community health worker, like an ASHA, to visit my household regularly to check on my/my household’s health status"
lab var d1c "I would like to go to the same health facility for all my health care needs."
lab var d1d "I would like to have access to Ayurvedic, Unani, Siddha or Homeopathy or other traditional treatments along with medical treatment for my health problems."
lab var d1e "I would like all the expenses of the health care I receive, from doctor’s fees to medicines and diagnostic tests, to be free."
lab var d1f "I would like to choose whichever health care provider I want to see, private or public."
lab var d1g "I would like to have my views taken into account in the care that I am given."
lab var d1h "I would like to have information about the quality of healthcare being provided by the private and public health care providers in my community"
lab var d1i "I would like to be able to complain about the poor quality of health care to an appropriate authority knowing they will take action"
lab var d1j "I would like the elected representatives or government officials to be held responsible for the quality of health care in my community"
lab var d1k "When I next vote in the state elections, my views about health care will influence which party/person I vote for"
lab var d1l "When I next vote in the central elections, my views about health care will influence which party/person I vote for"
lab var d1m_1 "Finally, please can you briefly describe the three most important improvements you would like to see in health care in your community in the future: Suggestion -1"
lab var d1m_2 "Finally, please can you briefly describe the three most important improvements you would like to see in health care in your community in the future: Suggestion -2"
lab var d1m_3 "Finally, please can you briefly describe the three most important improvements you would like to see in health care in your community in the future: Suggestion -3"
lab var rec_a2b_age "(Grouped) RECODE of a2b_age (Age Group)"
lab var any_insurance_new "Having Any Insurance Coverage (No/Yes) (Recoded)"
lab var illness_op "Illness Types of Outpatients (OP) (Grouped)"
lab var illness_ip "Illness Types of Inpatients (IP) (Grouped)"
lab var uhc_index "UHC Index Score"
lab var uhc_index_terciles "Tertile of UHC Index Score"
lab var _mergeuhcindex "_merge"


save "D:\HSTP Pavilion_02.01.24\MAC_21-02-2023_updated_02.01.24\Desktop\LC\LC_CS\FINAL DATA-CITIZEN_SURVEY_ALL_DATA-FINAL_SKS_09.05.2025.dta" replace


*********09-05-2025**************************************************END************************************************************************






