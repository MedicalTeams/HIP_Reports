USE [Clinic]
GO

/****** Object:  StoredProcedure [dbo].[sp32_Morbidity]    Script Date: 2/5/2018 1:08:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--3.2. Morbidity  
--NewVisits Only -100316 dn
--Date now reflects for one day up to 23:59:59 -100416 dn

CREATE PROC [dbo].[sp32_Morbidity]
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
SET @End_Date = DATEADD(ns, -100, DATEADD(s, 86400, @End_Date))

	SELECT 
		X.Dt
		,X.setlmt
		,X.hlth_care_faclty
		,X.setlmt + ' ' + X.hlth_care_faclty AS Setlmt_Faclty
		,X.rvisit_descn
		,X.rvisit_id
		,x.user_intrfc_sort_ord AS Mor_Sort
		,X.Morbidity_Category
		,X.bnfcry
		,X.bnfcry_id
		,X.gndr_cd
		,X.gndr_id
		,X.age_range
		,X.Age_Sort
		,COUNT(*) AS Morbidity_Count

	FROM
		(SELECT CONVERT(varchar(10),OV.dt_of_visit,101) AS Dt
		,LFAC.setlmt
		,LFAC.hlth_care_faclty
		,LFAC.setlmt+ ' ' + LFAC.hlth_care_faclty AS Setlmt_Faclty
		,RVST.rvisit_descn
		,RVST.rvisit_id
		--LKDX.diag_descn
		,BNFC.bnfcry
		,BNFC.bnfcry_id
		,GNDR.gndr_cd
		,GNDR.gndr_id
		,LKDX.user_intrfc_sort_ord
	
	,CASE
		WHEN DIAG.oth_diag_descn IS NOT NULL THEN LKDX.diag_descn + ' ' + DIAG.oth_diag_descn
		ELSE LKDX.diag_descn
	END AS Morbidity_Category

	, CASE
	   WHEN OV.age_years_low <5.00000 THEN '<5'
	   WHEN OV.age_years_low >= 5.00000 THEN '>=5'
	END AS age_range
  
	,CASE
	   WHEN OV.age_years_low <5.00000 THEN 1
	   WHEN OV.age_years_low >= 5.00000 THEN 2
	END AS Age_Sort

	FROM 
		dbo.ov AS OV
		JOIN dbo.ov_diag AS DIAG ON OV.ov_id = DIAG.ov_id
		JOIN dbo.lkup_diag AS LKDX ON DIAG.diag_id = LKDX.diag_id
		LEFT OUTER JOIN lkup_splmtl_diag AS SPDX ON DIAG.splmtl_diag_id = SPDX.splmtl_diag_id
		JOIN dbo.lkup_rvisit AS RVST ON OV.rvisit_id = RVST.rvisit_id
		JOIN dbo.lkup_bnfcry AS BNFC ON BNFC.bnfcry_id = OV.bnfcry_id
		JOIN dbo.lkup_gndr AS GNDR ON GNDR.gndr_id = OV.gndr_id
		JOIN dbo.lkup_faclty AS LFAC ON LFAC.faclty_id = OV.faclty_id

	WHERE 
		1=1
		AND OV.dt_of_visit >= @Begin_Visit_Date AND OV.dt_of_visit <= @End_Date
		AND LFAC.setlmt + ' ' + LFAC.hlth_care_faclty IN (SELECT Value FROM fnSplit (@Facility, ','))
		AND RVST.rvisit_descn IN (SELECT Value FROM fnSplit (@Visit, ','))
	
		) AS x

	Group by
		X.Dt
		,X.Setlmt
		,X.Setlmt_Faclty
		,X.hlth_care_faclty
		,X.rvisit_descn
		,X.rvisit_id
		,x.user_intrfc_sort_ord
		,X.Morbidity_Category
		,X.bnfcry
		,X.bnfcry_id
		,X.gndr_cd
		,X.gndr_id
		,X.age_range
		,X.Age_Sort

ORDER BY 1, 2, 3, 4, 5, 6, 7 DESC,8 DESC,9 , 10, 11

END
GO


