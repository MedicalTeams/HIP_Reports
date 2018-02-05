USE [Clinic]
GO

/****** Object:  StoredProcedure [dbo].[sp37_Injuries_b]    Script Date: 2/5/2018 1:20:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--3.7 Injuries b (Location)
--Added sort by key. 063016 dn

CREATE PROC [dbo].[sp37_Injuries_b]
	
	(
		@Begin_Visit_Date AS DATETIME2
		,@End_Date AS DATETIME2
		,@Facility AS VARCHAR(MAX)
		,@Visit AS VARCHAR (50)
	)
	
AS

BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
SET @End_Date = CAST(@End_Date AS DATE) 
SET @End_Date= DATEADD(ns, -100, DATEADD(s, 86400, @End_Date))

	SELECT
		X.Dt
		,X.setlmt
		,X.hlth_care_faclty
		,X.setlmt + ' ' + X.hlth_care_faclty AS Setlmt_Faclty
		,X.rvisit_descn
		,X.rvisit_id
		,X.user_intrfc_sort_ord AS Loc_Sort
		,X.Injuries_Category AS Injuries_Mode
		,X.Injuries_Location
		,X.bnfcry
		,X.bnfcry_id
		,X.gndr_cd AS gndr_cd
		,X.gndr_id
		,X.age_range
		,X.Age_Sort
		,COUNT(*) AS Injuries_Count

	FROM
		(SELECT CONVERT(varchar(10),OV.dt_of_visit,101) AS Dt
		,LFAC.setlmt
		,LFAC.hlth_care_faclty
		,LFAC.setlmt+ ' ' + LFAC.hlth_care_faclty AS Setlmt_Faclty
		,RVST.rvisit_descn
		,RVST.rvisit_id
		,SPDC.user_intrfc_sort_ord
		,LKDX.diag_descn
		,BNFC.bnfcry
		,BNFC.bnfcry_id
		,GNDR.gndr_cd
		,GNDR.gndr_id
		,SPDC.splmtl_diag_cat AS Injuries_Location
	
	,CASE 
		WHEN DIAG.oth_splmtl_diag_descn IS NOT NULL THEN 'Other' + ' ' + DIAG.oth_splmtl_diag_descn
		ELSE SPDX.splmtl_diag_descn
		END AS Injuries_Category
	
	,CASE
		WHEN BNFC.bnfcry = 'Refugee' THEN
   
	CASE
		WHEN OV.age_years_low <5.00000 THEN '0-4'
		WHEN OV.age_years_low BETWEEN 5.00000 AND 17.9999 THEN '5-17'
		WHEN OV.age_years_low BETWEEN 18.0000 AND 59.9999 THEN '18-59'
		WHEN OV.age_years_low > 59.9999 THEN '>=60'
		END
	ELSE ' ' END AS age_range

	,CASE
		WHEN BNFC.bnfcry = 'Refugee' THEN
   
	CASE
		WHEN OV.age_years_low <5.00000 THEN 1
		WHEN OV.age_years_low BETWEEN 5.00000 AND 17.9999 THEN 2
		WHEN OV.age_years_low BETWEEN 18.0000 AND 59.9999 THEN 3
		WHEN OV.age_years_low > 59.9999 THEN 4
		END 
	ELSE 99 END AS Age_Sort

	FROM
		dbo.ov AS OV
		JOIN dbo.ov_diag AS DIAG ON OV.ov_id = DIAG.ov_id
		JOIN dbo.lkup_diag AS LKDX ON DIAG.diag_id = LKDX.diag_id
		LEFT OUTER JOIN lkup_splmtl_diag AS SPDX ON DIAG.splmtl_diag_id = SPDX.splmtl_diag_id
		LEFT OUTER JOIN lkup_splmtl_diag_cat AS SPDC ON DIAG.splmtl_diag_cat_id = SPDC.splmtl_diag_cat_id
		JOIN dbo.lkup_rvisit AS RVST ON OV.rvisit_id = RVST.rvisit_id
		JOIN dbo.lkup_bnfcry AS BNFC ON BNFC.bnfcry_id = OV.bnfcry_id
		JOIN dbo.lkup_gndr AS GNDR ON GNDR.gndr_id = OV.gndr_id
		JOIN dbo.lkup_faclty LFAC ON LFAC.faclty_id = OV.faclty_id

	WHERE
		1=1
		AND OV.dt_of_visit >= @Begin_Visit_Date AND OV.dt_of_visit <= @End_Date
		AND LKDX.diag_id = 21 --Injuries
		AND LFAC.setlmt+ ' ' + LFAC.hlth_care_faclty IN (SELECT Value FROM fnSplit (@Facility, ','))
		AND RVST.rvisit_descn IN (SELECT Value FROM fnSplit (@Visit, ','))
		--AND LKDX.diag_descn = 'Injuries'
		--and BNFC.bnfcry = 'National'
		
		) AS x

	--and RVST.rvisit_descn = --NewVisits only

	GROUP BY
		X.Dt
		,X.Setlmt
		,X.Setlmt_Faclty
		,X.hlth_care_faclty
		,X.rvisit_descn
		,X.rvisit_id
		,X.user_intrfc_sort_ord
		,X.Injuries_Category
		,X.Injuries_Location
		,X.bnfcry
		,X.bnfcry_id
		,X.gndr_cd
		,X.gndr_id
		,X.age_range
		,X.Age_Sort

	ORDER BY 1, 2, 3, 4, 5, 6, 7, 8 DESC, 9 DESC, 10, 11, 12

END
GO


