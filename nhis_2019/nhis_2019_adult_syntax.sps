* Encoding: UTF-8.

****************************************************************************************************
* SPSS Syntax for Analyzing Disability Data
* Based on "Analytic Guidelines: Creating Disability Identifiers Using the 
* Washington Group Short Set on Functioning (WG-SS) SPSS Syntax"
* Reference: https://www.washingtongroup-disability.com/fileadmin/uploads/wg/WG_Document__7A_-_Analytic_Guidelines_for_the_WG-SS_Enhanced__SPSS_.pdf
*
* This syntax file replicates the analysis outlined in the WG's document, 
* focusing on creating disability identifiers using the 2019 NHIS dataset.

****************************************************************************************************


* Change to current working directory.
CD 'F:\spss_python\nhis_2019'.

GET 
  FILE='nhis_2019_adult.sav'. 
DATASET NAME NHIS2019 WINDOW=FRONT.

* NOTE: For data analysis, use your standard weighting and estimation techniques

* Frequency check before. Before coding missing values. 
FREQUENCIES VISIONDF_A HEARINGDF_A DIFF_A COGMEMDFF_A UPPSLFCR_A COMDIFF_A.

* Codes 7 (REFUSED), 8 (NOT ASCERTAINED) and 9 (DON'T KNOW) are INCLUDED as MISSING.
MISSING VALUES VISIONDF_A, HEARINGDF_A, DIFF_A, COGMEMDFF_A, UPPSLFCR_A, COMDIFF_A (7, 8, 9).

* Step 1: Generate frequency distributions on each of the six domain variables

FREQUENCIES VISIONDF_A HEARINGDF_A DIFF_A COGMEMDFF_A UPPSLFCR_A COMDIFF_A.

*Step 2: Calculate a variable, SUM_234
SUM_234 summates the number of domains coded SOME DIFFICULTY (2) or A LOT OF DIFFICULTY (3) or CANNOT DO AT ALL (4) for each person. This new variable is used in the determination of disability identifiers: DISABILITY1 and DISABILITY2
Possible range 0: no difficulties in any domain, to 6: all six domains coded SOME DIFFICULTY (2) or A LOT OF DIFFICULTY (3) or CANNOT DO AT ALL (4)
MISSING (9) are those who have coded 7, 8 or 9 on all six domains.

COUNT SUM_234 = VISIONDF_A HEARINGDF_A DIFF_A COGMEMDFF_A UPPSLFCR_A COMDIFF_A (2 thru 4).
IF (MISSING(VISIONDF_A) AND MISSING(HEARINGDF_A) AND MISSING(DIFF_A) AND MISSING(COGMEMDFF_A) AND MISSING(UPPSLFCR_A) AND MISSING(COMDIFF_A)) SUM_234 = 9.
RECODE SUM_234 (9=SYSMIS).
FREQUENCIES SUM_234.

*Step 3: Calculate a variable, SUM_34
SUM_34 summates the number of domains coded A LOT OF DIFFICULTY (3) or CANNOT DO AT ALL (4) for each person. This new variable is used in the determination of disability identifier: DISABILITY2
The syntax below counts the number of domains/questions a person has that are coded A LOT OF DIFFICULTY (3) or CANNOT DO AT ALL (4)
Possible range 0: no difficulties coded A LOT OF DIFFICULTY (3) or CANNOT DO AT ALL (4) in any domain, to 6: all six domains coded A LOT OF DIFFICULTY (3) or CANNOT DO AT ALL (4)
MISSING (9) are those who have coded 7, 8 or 9 on all six domains.

COUNT SUM_34 = VISIONDF_A HEARINGDF_A DIFF_A COGMEMDFF_A UPPSLFCR_A COMDIFF_A (3 thru 4).
IF (MISSING(VISIONDF_A) AND MISSING(HEARINGDF_A) AND MISSING(DIFF_A) AND MISSING(COGMEMDFF_A) AND MISSING(UPPSLFCR_A) AND MISSING(COMDIFF_A)) SUM_34 = 9.
RECODE SUM_34 (9=SYSMIS).
FREQUENCIES SUM_34.

*Step 4: Calculate Disability Identifier: DISABILITY1
The syntax below calculates the first disability identifier: DISABILITY1 where the level of inclusion is at least one domain/question is coded SOME DIFFICULTY or A LOT OF DIFFICULTY or CANNOT DO AT ALL
MISSING (9) are those who have coded 7, 8 or 9 on all six domains.

COMPUTE DISABILITY1 = 0.
IF (MISSING(VISIONDF_A) AND MISSING(HEARINGDF_A) AND MISSING(DIFF_A) AND MISSING(COGMEMDFF_A) AND MISSING(UPPSLFCR_A) AND MISSING(COMDIFF_A)) DISABILITY1 = 9.

IF (SUM_234 >= 1) DISABILITY1 = 1.

*NOTE: SUM_234 >= 1 means that at least one of the six domains is coded at least SOME DIFFICULTY (2).

VALUE LABELS DISABILITY1 0 'without disability' 1 'with disability'.
RECODE DISABILITY1 (9=SYSMIS).
FREQUENCIES DISABILITY1.

* Step 5: Calculate Disability Identifier: DISABILITY2
The syntax below calculates the second disability identifier: DISABILITY2 where the level of inclusion is: at least 2 domains/questions are coded SOME DIFFICULTY or any 1 domain/question is coded A LOT OF DIFFICULTY or CANNOT DO AT ALL
MISSING (9) are those who have coded 7, 8 or 9 on all six domains.

COMPUTE DISABILITY2 = 0.
IF (MISSING(VISIONDF_A) AND MISSING(HEARINGDF_A) AND MISSING(DIFF_A) AND MISSING(COGMEMDFF_A) AND MISSING(UPPSLFCR_A) AND MISSING(COMDIFF_A)) DISABILITY2 = 9.
IF (SUM_234 >= 2 OR SUM_34 = 1) DISABILITY2 = 1.

*NOTE: The above syntax identifies those with at least two of the six domains coded as at least SOME DIFFICULTY (2): SUM_234 >= 2, OR those who have one domain that is coded A LOT OF DIFFICULTY (3) or CANNOT DO AT ALL (4): SUM_34 = 1.
VALUE LABELS DISABILITY2 0 'without disability' 1 'with disability'.
RECODE DISABILITY2 (9=SYSMIS).
FREQUENCIES DISABILITY2.

* Step 6: Calculate Disability Identifier: DISABILITY3
The syntax below calculates the third disability identifier: DISABILITY3 where the level of inclusion is: any 1 domain/question is coded A LOT OF DIFFICULTY or CANNOT DO AT ALL
MISSING (9) are those who have coded 7, 8 or 9 on all six domains
THIS IS THE CUT-OFF RECOMMENDED BY THE WG.

COMPUTE DISABILITY3 = 0.
IF (MISSING(VISIONDF_A) AND MISSING(HEARINGDF_A) AND MISSING(DIFF_A) AND MISSING(COGMEMDFF_A) AND MISSING(UPPSLFCR_A) AND MISSING(COMDIFF_A)) DISABILITY3 = 9.
IF ((VISIONDF_A = 3 or VISIONDF_A = 4) or (HEARINGDF_A = 3 or HEARINGDF_A = 4) or (DIFF_A = 3 or DIFF_A = 4) or (COGMEMDFF_A = 3 or COGMEMDFF_A = 4) or (UPPSLFCR_A = 3 or UPPSLFCR_A = 4) or (COMDIFF_A = 3 or COMDIFF_A = 4)) DISABILITY3 = 1.
VALUE LABELS DISABILITY3 0 'without disability' 1 'with disability'.
RECODE DISABILITY3 (9=SYSMIS).
FREQUENCIES DISABILITY3.

*Step 7: Calculate Disability Identifier: DISABILITY4
The syntax below calculates the fourth disability identifier: DISABILITY4 where the level of inclusion is any one domain is coded CANNOT DO AT ALL (4)
MISSING (9) are those who have coded 7, 8 or 9 on all six domains.

COMPUTE DISABILITY4 = 0.
IF (MISSING(VISIONDF_A) AND MISSING(HEARINGDF_A) AND MISSING(DIFF_A) AND MISSING(COGMEMDFF_A) AND MISSING(UPPSLFCR_A) AND MISSING(COMDIFF_A)) DISABILITY4 = 9.
IF ((VISIONDF_A = 4) or (HEARINGDF_A = 4) or (DIFF_A = 4) or (COGMEMDFF_A = 4) or (UPPSLFCR_A = 4) or (COMDIFF_A = 4)) DISABILITY4 = 1.
VALUE LABELS DISABILITY4 0 'without disability' 1 'with disability'.
RECODE DISABILITY4 (9=SYSMIS).
EXECUTE.

FREQUENCIES DISABILITY4.
