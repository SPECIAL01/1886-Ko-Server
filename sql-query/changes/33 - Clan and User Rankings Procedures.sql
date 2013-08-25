IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'UPDATE_KNIGHTS_RATING') AND type in (N'P', N'PC'))
    DROP PROCEDURE UPDATE_KNIGHTS_RATING;
GO

CREATE PROCEDURE UPDATE_KNIGHTS_RATING
AS
/*
Author : AKUMA
Update : 16.10.2009 - 20:51
*/
DECLARE @RankingMAX tinyint 
DECLARE @SuspendedPlayersIncluded tinyint
SET @RankingMAX = 5 -- MAX 255
SET @SuspendedPlayersIncluded = 0 -- 0 = Cezasız Oyuncular / 1 = Cezasız ve Cezalı Oyuncular (Game Master'lar Her İki Koşulda da Dahil Edilmez.)
 
-- KNIGHTS_RATING Tablosunu Boşaltıyoruz...
TRUNCATE TABLE KNIGHTS_RATING
-- KNIGHTS Tablosunu Güncelliyoruz...
IF @SuspendedPlayersIncluded = 0
    UPDATE KNIGHTS SET Points = (SELECT SUM(Loyalty) FROM USERDATA WHERE Authority = 1 AND Knights = IDNum)
ELSE
    UPDATE KNIGHTS SET Points = (SELECT SUM(Loyalty) FROM USERDATA WHERE Authority <> 0 AND Knights = IDNum)

-- KNIGHTS_RATING'i Dolduruyoruz...
INSERT INTO KNIGHTS_RATING SELECT ROW_NUMBER() OVER (ORDER BY ClanPointFund DESC), IDNum, IDName, ClanPointFund FROM KNIGHTS ORDER BY ClanPointFund DESC

-- KNIGHTS Rankingi Ayarlıyoruz
UPDATE KNIGHTS SET Ranking = 0
UPDATE KNIGHTS SET Ranking = (SELECT nRank FROM KNIGHTS_RATING WHERE shIndex = IDNum AND nRank <= @RankingMAX) WHERE (SELECT nRank FROM KNIGHTS_RATING WHERE shIndex = IDNum AND nRank <= @RankingMAX) <= @RankingMAX
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'UPDATE_USER_KNIGHTS_RANK') AND type in (N'P', N'PC'))
    DROP PROCEDURE UPDATE_USER_KNIGHTS_RANK;
GO

CREATE PROCEDURE UPDATE_USER_KNIGHTS_RANK
AS
DECLARE @strUserId char(21)
DECLARE @Loyalty int
DECLARE @Knights int
DECLARE @KnightName char(50)
DECLARE @IsValidKnight int
DECLARE @Index smallint
DECLARE @IsValidCount tinyint
DECLARE @RankName varchar(30)
SELECT @IsValidCount = Count(*) FROM USER_KNIGHTS_RANK
IF @IsValidCount < 100
BEGIN

    SET @Index = 1

    WHILE @Index < 101
    BEGIN

        IF @Index = 1
        BEGIN
            SET @RankName = 'Gold Knight'
        END
        IF @Index > 1 AND @Index <= 4
        BEGIN
            SET @RankName = 'Silver Knight'
        END
        IF @Index > 4 AND @Index <= 9
        BEGIN
            SET @RankName = 'Mirage Knight'
        END
        IF @Index > 9 AND @Index <= 10
        BEGIN
            SET @RankName = 'Shadow Knight'
        END
        IF @Index > 25 AND @Index <= 50
        BEGIN
            SET @RankName = 'Mist Knight'
        END
        IF @Index > 50 AND @Index <= 100
        BEGIN
            SET @RankName = 'Training Knight'
        END
       
        INSERT INTO USER_KNIGHTS_RANK (shIndex,strName,strElmoUserID,strElmoKnightsName,nElmoLoyalty,strKarusUserID,strKarusKnightsName,nKarusLoyalty,nMoney) VALUES (@Index,@RankName,NULL,NULL,0,NULL,NULL,0,1000000)
   
        SET @Index = @Index + 1
    END
END

SET @Index = 1
SET @strUserId = NULL
SET @Loyalty = 0
SET @Knights = 0
DECLARE RANKING_CRS CURSOR FOR
SELECT TOP 100 strUserId,Loyalty,Knights FROM USERDATA WHERE Nation = 1 AND Authority = 1 AND Knights <> 0 ORDER BY Loyalty DESC

OPEN RANKING_CRS
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@Loyalty,@Knights
WHILE @@FETCH_STATUS = 0 
BEGIN

SET @KnightName = NULL
SET @IsValidKnight = 0
IF @Knights <> 0
BEGIN
    SELECT @IsValidKnight = COUNT(IDName) FROM KNIGHTS WHERE IDNum = @Knights
   
    IF @IsValidKnight <> 0
    BEGIN
        SELECT @KnightName = IDName FROM KNIGHTS WHERE IDNum = @Knights
    END
END
   
    UPDATE USER_KNIGHTS_RANK SET strKarusUserID = @strUserId, strKarusKnightsName = @KnightName, nKarusLoyalty = @Loyalty WHERE shIndex = @Index
   
    SET @Index = @Index + 1
            
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@Loyalty,@Knights
END
CLOSE RANKING_CRS
DEALLOCATE RANKING_CRS

SET @Index = 1
SET @strUserId = NULL
SET @Loyalty = 0
SET @Knights = 0
DECLARE RANKING_CRS CURSOR FOR
SELECT TOP 100 strUserId,Loyalty,Knights FROM USERDATA WHERE Nation = 2 AND Authority = 1 AND Knights <> 0 ORDER BY Loyalty DESC

OPEN RANKING_CRS
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@Loyalty,@Knights
WHILE @@FETCH_STATUS = 0 
BEGIN

SET @KnightName = NULL
SET @IsValidKnight = 0
IF @Knights <> 0
BEGIN
    SELECT @IsValidKnight = COUNT(IDName) FROM KNIGHTS WHERE IDNum = @Knights
   
    IF @IsValidKnight <> 0
    BEGIN
        SELECT @KnightName = IDName FROM KNIGHTS WHERE IDNum = @Knights
    END
END
   
    UPDATE USER_KNIGHTS_RANK SET strElmoUserID = @strUserId, strElmoKnightsName = @KnightName, nElmoLoyalty = @Loyalty WHERE shIndex = @Index
   
    SET @Index = @Index + 1
            
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@Loyalty,@Knights
END
CLOSE RANKING_CRS
DEALLOCATE RANKING_CRS
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'UPDATE_USER_PERSONAL_RANK') AND type in (N'P', N'PC'))
    DROP PROCEDURE UPDATE_USER_PERSONAL_RANK;
GO

CREATE PROCEDURE UPDATE_USER_PERSONAL_RANK
AS
BEGIN TRAN
DECLARE @strUserId char(21)
DECLARE @LoyaltyMonthly int
DECLARE @Index smallint
DECLARE @IsValidCount tinyint
DECLARE @RankName varchar(30)
DECLARE @DifferenceBetweenUser int

SELECT @IsValidCount = Count(*) FROM USER_PERSONAL_RANK
IF @IsValidCount < 200
BEGIN
   
	TRUNCATE TABLE USER_PERSONAL_RANK
    SET @Index = 1

    WHILE @Index < 201
    BEGIN

        IF @Index = 1
        BEGIN
            SET @RankName = 'Gold Knight'
        END
        IF @Index > 1 AND @Index <= 4
        BEGIN
            SET @RankName = 'Silver Knight'
        END
        IF @Index > 4 AND @Index <= 9
        BEGIN
            SET @RankName = 'Mirage Knight'
        END
        IF @Index > 9 AND @Index <= 10
        BEGIN
            SET @RankName = 'Shadow Knight'
        END
        IF @Index > 25 AND @Index <= 100
        BEGIN
            SET @RankName = 'Mist Knight'
        END
		IF @Index > 100 AND @Index <= 200
        BEGIN
            SET @RankName = 'Training Knight'
        END
       
        INSERT INTO USER_PERSONAL_RANK (nRank,strPosition,nElmoUP,strElmoUserID,nElmoLoyaltyMonthly,nElmoCheck,nKarusUP,strKarusUserID,nKarusLoyaltyMonthly,nKarusCheck,nSalary,UpdateDate) VALUES (@Index,@RankName,0,NULL,0,1000000,0,NULL,0,1000000,1000000,GETDATE())
           
        SET @Index = @Index + 1
    END
END

SET @Index = 1
SET @strUserId = NULL
SET @LoyaltyMonthly = 0
DECLARE RANKING_CRS CURSOR FOR
SELECT TOP 200 strUserId,LoyaltyMonthly FROM USERDATA WHERE Nation = 1 AND Authority = 1 AND Knights <> 0 ORDER BY LoyaltyMonthly DESC

OPEN RANKING_CRS
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@LoyaltyMonthly
WHILE @@FETCH_STATUS = 0 
BEGIN
    
    UPDATE USER_PERSONAL_RANK SET strKarusUserID = @strUserId, nKarusUP = @Index, nKarusLoyaltyMonthly = @LoyaltyMonthly WHERE nRank = @Index
   
    SET @DifferenceBetweenUser = 0
   
    IF @Index = 1
    BEGIN
   
        UPDATE USER_PERSONAL_RANK SET nKarusCheck = 0 WHERE nRank = @Index
   
    END
    ELSE
    BEGIN
   
        SELECT @DifferenceBetweenUser = nKarusLoyaltyMonthly FROM USER_PERSONAL_RANK WHERE nRank = @Index + 1
   
        SET @DifferenceBetweenUser = @LoyaltyMonthly - @DifferenceBetweenUser
   
        UPDATE USER_PERSONAL_RANK SET nKarusCheck = @DifferenceBetweenUser WHERE nRank = @Index + 1
       
    END
       
    SET @Index = @Index + 1
            
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@LoyaltyMonthly
END
CLOSE RANKING_CRS
DEALLOCATE RANKING_CRS

SET @Index = 1
SET @strUserId = NULL
SET @LoyaltyMonthly = 0
DECLARE RANKING_CRS CURSOR FOR
SELECT TOP 200 strUserId,LoyaltyMonthly FROM USERDATA WHERE Nation = 2 AND Authority = 1 AND Knights <> 0 ORDER BY LoyaltyMonthly DESC

OPEN RANKING_CRS
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@LoyaltyMonthly
WHILE @@FETCH_STATUS = 0 
BEGIN
   
    UPDATE USER_PERSONAL_RANK SET strElmoUserID = @strUserId, nElmoUP = @Index, nElmoLoyaltyMonthly = @LoyaltyMonthly WHERE nRank = @Index   
   
    SET @DifferenceBetweenUser = 0
   
    IF @Index = 1
    BEGIN
   
        UPDATE USER_PERSONAL_RANK SET nElmoCheck = 0 WHERE nRank = @Index
   
    END
    ELSE
    BEGIN
   
        SELECT @DifferenceBetweenUser = nElmoLoyaltyMonthly FROM USER_PERSONAL_RANK WHERE nRank = @Index + 1
   
        SET @DifferenceBetweenUser = @LoyaltyMonthly - @DifferenceBetweenUser
   
        UPDATE USER_PERSONAL_RANK SET nElmoCheck = @DifferenceBetweenUser WHERE nRank = @Index + 1
       
    END
   
    SET @Index = @Index + 1
            
FETCH NEXT FROM RANKING_CRS INTO @strUserId,@LoyaltyMonthly
END
CLOSE RANKING_CRS
DEALLOCATE RANKING_CRS

UPDATE USER_PERSONAL_RANK SET nSalary = REPLACE(nElmoLoyaltyMonthly - nKarusLoyaltyMonthly,'-','')

COMMIT TRAN
GO