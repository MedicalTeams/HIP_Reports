USE clinic-bd
GO

--3.1 Consultation  
--New Visits and Revisits

CREATE PROC spHIP_Dashboard
	
AS

BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT
	BNFC.bnfcry AS [Beneficiary]
	,BNFC.bnfcry_id AS [Beneficiary ID]
	,DIAG.oth_diag_descn AS [Other]
	,GNDR.gndr_cd AS [Gender]
	,GNDR.gndr_id AS [Gender ID]
	,LFAC.setlmt AS [Settlement]
	,LFAC.hlth_care_faclty AS [Facility]
	,LFAC.longtd AS [Longitude]
	,LFAC.lattd AS [Latitude]
	,OV.staff_mbr_name AS [Clinician]
	,OV.ov_id AS [Office Visit ID]
	,LKDX.diag_descn AS [Diagnosis]
	,LKDX.diag_id AS [Diagnosis ID]
	,LKDX.user_intrfc_sort_ord AS [Sort Order]
	,OV.dt_of_visit AS [Visit Date]
	,MONTH(OV.dt_of_visit) AS [Month Number]
	,FORMAT(OV.dt_of_visit, 'MMM') AS [Month]
	,YEAR(Ov.dt_of_visit) AS [Year]
	,FORMAT(OV.dt_of_visit, 'MMM-yy') AS [Mon-YY]
	,RVST.rvisit_descn AS [Visit]
	,RVST.rvisit_id AS [Visit ID]
	,FORMAT(OV.dt_of_visit, 'yyyyMM') AS [Month Sort]
	

FROM
	dbo.ov AS OV
	LEFT OUTER JOIN dbo.ov_diag AS DIAG ON OV.ov_id = DIAG.ov_id
	JOIN dbo.lkup_diag AS LKDX ON DIAG.diag_id = LKDX.diag_id
	LEFT  OUTER JOIN lkup_splmtl_diag AS SPDX ON DIAG.splmtl_diag_id = SPDX.splmtl_diag_id 
	JOIN dbo.lkup_rvisit AS RVST ON OV.rvisit_id = RVST.rvisit_id
	JOIN dbo.lkup_bnfcry AS BNFC ON BNFC.bnfcry_id = OV.bnfcry_id
	JOIN dbo.lkup_gndr AS GNDR ON GNDR.gndr_id = OV.gndr_id
	JOIN dbo.lkup_faclty AS LFAC ON LFAC.faclty_id = OV.faclty_id
 
 WHERE
	1=1

END
