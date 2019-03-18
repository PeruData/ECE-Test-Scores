*Input: anual ECE datasets
*Output: clean ECE datasets (saved in Trash because they occupy a lot of HD space)

********************************************************************************
cap restore
clear all
set more off
global ccc  "/Users/Sebastian/Documents/Misc/Side Projects/ECE Github"
cd "$ccc"
timer on 1

forvalues yy = 2008/2016{
	di "------"
	di `yy'
	use "in/raw_2p_`yy'_web.dta",clear
	gen year = `yy'
	local yy_2d = substr(string(`yy'),3,2)
	
	*ID vars
		cap rename seccion    classroom_id
		cap rename ID_seccion classroom_id
		cap rename id_IE      school_id
		cap rename id_ie      school_id
		cap rename ID_IE      school_id
		cap rename ID         school_id
	*Geographic vars
		rename codgeo ubigeo_encoded
		decode ubigeo_encoded, gen(ubigeo)
		cap rename Region*      dep 
		cap rename region*      dep 
		cap rename Departamento dep
		cap rename provincia    prov
		cap rename Provincia    prov
		cap rename distrito     dist
		cap rename Distrito     dist  
	
	*Score vars
	foreach x in c m {
		local x_upper = upper("`x'")
        cap rename peso_`x'       weight_`x'
		cap rename Peso_`x_upper' weight_`x'
		cap label drop group_lab
		label define group_lab 1 "En inicio" 2 "En proceso" 3 "Satisfactorio"
		if `yy' == 2016 & "`x'" == "c" {	
	        local x_upper = "L"
			}
		if "`x'" == "c" {	
	        cap rename M500_`x_upper'* verbal_score_cont
		    cap rename grupo*`x_upper' verbal_score_group
			label values verbal_score_group group_lab 
			}
		if "`x'" == "m" {	
	        cap rename M500_`x_upper'* math_score_cont
		    cap rename grupo*`x_upper' math_score_group
			label values math_score_group group_lab 
			}
	    }
	
	*Socioeconomic vars
	    cap rename ise SES_score_cont
		cap rename nse SES_score_group
		cap rename Area area
		gen urban = (area == 1) if !missing(area)

	*Gender var
		if `yy' == 2009 | `yy' == 2010 {
			gen male = (sexo == 2)
			}
		else {
			gen male = (sexo == 1)
			}
		replace male = . if sexo == 4 | missing(sexo)

	*Private school var
	    cap rename Gestion2 gestion
		gen private = (gestion == 2) if !missing(gestion)
		
	save "Trash/ece_`yy'",replace
	}

clear
forvalues yy = 2008/2016{
	di "`yy'"
    append using "Trash/ece_`yy'"
	}
local vars_tokeep year ubigeo dep prov dist school_id classroom_id math_score* weight_m verbal_score* SES_score* urban male private
keep  `vars_tokeep'
keep  `vars_tokeep'
order `vars_tokeep'

foreach var of varlist _all {
	label var `var' ""
    }
label var school_id        "Anonymous school identifier"
label var dep              "Department (High-level administrative area)"
label var prov             "Province   (Middle-level geographical area)"
label var dist             "District   (Low-level geographical area)"
label var math_score_group "Level of achievement"
label var math_score_cont  "Continous (500 = 2007 average; 100 = 2007 sd)"
label var math_score_group "Level of achievement"
label var math_score_cont  "Continous (500 = 2007 average; 100 = 2007 sd)"
label var weight_m         "Sample weight"
label var SES_score_group  "Socioeconomic group for student's household"
label var SES_score_cont   "Socioeconomic index for student's household"
label var urban            "=1 if school is located in urban area"    
label var male             "=1 if student is male"    
label var private          "=1 if school is privately administrated"
save "out/ece_08_16.dta", replace



timer off 1
timer list


