USE CLINIC
GO

--Tally Details
--MTI Office Visit Details
--Users have the ability to run and view detail data and export to sort and filter as desired.
--OPTION 1 – Data fields limited to relevant data and null data updated by case statement
--***Option 1 was selected for SSRS development***
--This version limits the data fields returned and formats null values as indicated in the case statements.

ALTER PROC spTally_Details
	
	(
		@Begin_Visit_Date AS DATETIME2
		,@End_Date AS DATETIME2
		,@Facility AS VARCHAR(50)
		,@Visit AS VARCHAR (10)
	)
	
AS

BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
SET @End_Date = CAST(@End_Date AS DATE) 
SET @End_Date= DATEADD(ns, -100, DATEADD(s, 86400, @End_Date))

	SELECT
		--CONVERT(varchar(10),OV.dt_of_visit,101) AS 'Visit Date'
		OV.dt_of_visit AS 'Visit Date'
		,LKOR.orgzn AS Organization, LKOR.orgzn_stat AS 'Organization Status'
		,LFAC.rgn AS Region, LFAC.cntry AS Country, LFAC.setlmt AS Settlement
		,LFAC.hlth_care_faclty AS Facility
		,LFAC.hlth_care_faclty_lvl AS 'Health Care Facility Level'
		,LFAC.faclty_stat AS 'Facility Status'
		,LFAC.longtd AS Longitude
		,LFAC.lattd AS Latitude
		,LFAC.setlmt+ ' ' + LFAC.hlth_care_faclty AS 'Settlement and Facility'
		,LFAC.hlth_coordtr AS 'Health Coordinator'
		,FAHW.faclty_hw_invtry_id AS 'Facility Hardware Inventory ID'
		,FAHW.itm_descn AS 'Item Desc'
		,FAHW.mac_addr AS 'MAC Address'
		,FAHW.aplctn_vrsn AS 'Application Version'
		,FAHW.hw_stat AS 'Hardware Status'
		,BNFC.bnfcry AS Beneficiary
		,RVST.rvisit_descn 'Visit Revisit Desc'
		,RVST.rvisit_ind AS 'Visit Revisit Ind'
		,GNDR.gndr_cd AS Sex
		,GNDR.gndr_cd AS 'Sex Desc'

	,CASE
		WHEN DGAT.case_cnt IS NOT NULL THEN DGAT.case_cnt
		ELSE 999999
	END AS 'Alert Diagnosis Case Count'

	,CASE 
		WHEN DGAT.baseln_multr IS NOT NULL THEN DGAT.baseln_multr
		ELSE 999999.999
	End AS 'Alert Diagnosis Multiplier'

		,OV.opd_id AS 'OPD ID'
		,OV.ov_id AS 'Office Visit ID'
		,OV.dt_of_visit AS 'Vist Datetime Entry'
		,OV.staff_mbr_name AS 'Staff Member Name'
		,OV.refl_in_ind 'Referred In Ind'
		,OV.refl_out_ind 'Referred Out Ind'
		,OV.age_years_low AS 'Patient Age'
		,DIAG.diag_id AS 'Diag ID'
		,LKDX.diag_descn AS 'Diag Desc'

	,CASE 
		WHEN LKDX.icd_cd IS NOT NULL THEN LKDX.icd_cd
		ELSE '0' --12/3/15 changed nvarchar
	END AS 'ICD CD'

	,CASE 
		WHEN LKDX.diag_abrvn IS NOT NULL THEN LKDX.diag_abrvn
		ELSE '0'
	END AS 'Diag Abbr'
	
		, LKDX.diag_stat as 'Diag Status'

	,CASE 
		WHEN DIAG.cntct_trmnt_cnt IS NOT NULL THEN DIAG.cntct_trmnt_cnt
		ELSE 999999
	END AS 'Contacts Treated'

	,CASE 
		WHEN DIAG.oth_diag_descn IS NOT NULL THEN DIAG.oth_diag_descn
		ELSE '0'
	END AS 'Other Diag Desc'

	,CASE 
		WHEN DIAG.oth_splmtl_diag_descn IS NOT NULL THEN DIAG.oth_splmtl_diag_descn
		ELSE '0'
	END AS 'Other Supp Diag Desc'
	
	,CASE 
		WHEN SPDX.splmtl_diag_id IS NOT NULL THEN SPDX.splmtl_diag_id
		ELSE 0
	END AS 'Supp Diag ID'

	,CASE 
		WHEN SPDX.splmtl_diag_descn IS NOT NULL THEN SPDX.splmtl_diag_descn
		ELSE '0'
	END AS 'Supp Diag Desc'
	
	,CASE 
	 WHEN SPDX.splmtl_diag_stat IS NOT NULL THEN SPDX.splmtl_diag_stat
	 ELSE '0'
	END AS 'Supp Diag Status'

	,CASE 
		WHEN SPDC.splmtl_diag_cat_id IS NOT NULL THEN SPDC.splmtl_diag_cat_id
		ELSE '0'
	END AS 'Supp Diag Cat ID'

	,CASE 
		WHEN SPDC.splmtl_diag_cat IS NOT NULL THEN SPDC.splmtl_diag_cat
		ELSE '0'
	END AS 'Injury Location'

	,CASE 
		WHEN SPDC.splmtl_diag_cat_stat IS NOT NULL THEN SPDC.splmtl_diag_cat_stat
		ELSE '0'
	END AS 'Supp Diag Cat Status'

	FROM
		dbo.ov AS OV
		LEFT OUTER JOIN dbo.ov_diag AS DIAG ON OV.ov_id = DIAG.ov_id    --Done
		LEFT OUTER JOIN dbo.lkup_diag AS LKDX ON DIAG.diag_id = LKDX.diag_id    --Done
		LEFT OUTER JOIN lkup_splmtl_diag AS SPDX ON DIAG.splmtl_diag_id = SPDX.splmtl_diag_id and DIAG.diag_id = SPDX.diag_id
		LEFT OUTER JOIN lkup_splmtl_diag_cat AS SPDC ON DIAG.splmtl_diag_cat_id = SPDC.splmtl_diag_cat_id
		LEFT OUTER JOIN dbo.lkup_rvisit AS RVST ON OV.rvisit_id = RVST.rvisit_id  --DONE
		LEFT OUTER JOIN dbo.lkup_bnfcry AS BNFC ON BNFC.bnfcry_id = OV.bnfcry_id   --Done
		LEFT OUTER JOIN dbo.lkup_gndr AS GNDR ON GNDR.gndr_id = OV.gndr_id        --Done
		LEFT OUTER JOIN dbo.lkup_faclty AS LFAC ON LFAC.faclty_id = OV.faclty_id    --Done
		LEFT OUTER JOIN dbo.faclty_hw_invtry AS FAHW ON OV.faclty_hw_invtry_id = FAHW.faclty_hw_invtry_id    --Done
		LEFT OUTER JOIN dbo.lkup_orgzn AS LKOR ON LFAC.orgzn_id = LKOR.orgzn_id   --Done
		LEFT OUTER JOIN dbo.diag_alert_thrshld AS DGAT ON LKDX.diag_id = DGAT.diag_id  --Done

	WHERE
		1=1
		AND OV.dt_of_visit >= @Begin_Visit_Date AND OV.dt_of_visit <= @End_Date

	ORDER BY
		OV.ov_id

END