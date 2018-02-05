/****** Object:  UserDefinedFunction [dbo].[fnSplit]    Script Date: 2/5/2018 1:24:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnSplit]

	(
		@List nvarchar(2000)
		,@SplitOn nvarchar(5)
	)  

RETURNS @RtnValue table 

	(

	Id INT IDENTITY (1,1)
	,Value NVARCHAR (100)
) 

AS  

BEGIN

WHILE (CHARINDEX(@SplitOn,@List)>0)

BEGIN

INSERT INTO @RtnValue (Value)

	SELECT
		Value = LTRIM(RTRIM(SUBSTRING(@List,1,CHARINDEX(@SplitOn,@List)-1))) 
	SET @List = SUBSTRING(@List,CHARINDEX(@SplitOn,@List)+LEN(@SplitOn),LEN(@List))

END 

INSERT INTO @RtnValue (Value)

	SELECT
		Value =LTRIM(RTRIM(@List))
RETURN

END
GO


