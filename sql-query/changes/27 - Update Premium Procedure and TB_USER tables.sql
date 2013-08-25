IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PREMIUM_SERVICE')
    DROP TABLE PREMIUM_SERVICE;

ALTER TABLE TB_USER
ADD
PremiumType tinyint NOT NULL
DEFAULT 00000000;
GO

ALTER TABLE TB_USER
ADD
PremiumStartDate datetime NOT NULL
GO

ALTER TABLE TB_USER
ADD
PremiumEndDate datetime NOT NULL
GO

UPDATE TB_USER SET PremiumType = 1,PremiumStartDate = GETDATE(), PremiumStartDate = GETDATE() + 365
GO

ALTER PROCEDURE [dbo].[LOAD_PREMIUM_SERVICE_USER]
@AccountID	varchar(21),
@PremiumType	smallint	OUTPUT,
@PremiumHours	smallint	OUTPUT
AS
DECLARE @PremiumEndDate datetime
DECLARE	@PremiumType_ INT
DECLARE	@PremiumHours_ INT

SELECT @PremiumEndDate = PremiumEndDate ,@PremiumType_ = PremiumType  FROM TB_USER WHERE strAccountID = @AccountID

IF @@ROWCOUNT = 0
BEGIN
	UPDATE TB_USER SET PremiumType = 0 WHERE strAccountID = @AccountID
	SET @PremiumType  = 0
    SET @PremiumHours = -1
	RETURN
END
ELSE
BEGIN

	SET @PremiumHours_ = datediff( hour, GETDATE(), @PremiumEndDate )

	IF @PremiumHours_ < 0
	BEGIN
		UPDATE TB_USER SET PremiumType = 0 WHERE strAccountID = @AccountID
		SET @PremiumType = 0
		SET @PremiumHours = -1
		RETURN
	END
	ELSE
	BEGIN	 
		SET @PremiumType = @PremiumType_
		SET @PremiumHours  = @PremiumHours_
		RETURN
	END
END
GO