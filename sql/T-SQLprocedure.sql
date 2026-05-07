USE DB04;

-- 2) Γράψτε μια stored procedure η οποία θα δέχεται τον αριθμό μίας πιστωτικής κάρτας και τον
--	  αριθμό του μήνα (π.χ. Αύγουστος = 8), θα υπολογίζει το 1% για κάθε συναλλαγή του πρώτου
--	  δεκαημέρου του μήνα, το 2% για κάθε συναλλαγή του δεύτερου δεκαημέρου του μήνα και το
--	  3% για κάθε συναλλαγή των υπολοίπων ημερών και θα τυπώνει το σύνολο αυτών. Να
--	  χρησιμοποιήσετε λογικούς δρομείς

CREATE PROCEDURE cardTransactionMonthlyPercentage(
	@card_number VARCHAR(16),
	@month INT)
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @chargeAmount DECIMAL(15,2), @date DATETIME 

	DECLARE calculatePercentages CURSOR FOR
		SELECT chargeAmount, date
		FROM CardTransaction
		WHERE cardNumber = @card_number AND MONTH(date) = @month

	OPEN calculatePercentages
	FETCH NEXT FROM calculatePercentages INTO @chargeAmount, @date
	DECLARE @sum1 DECIMAL(15,2), @sum2 DECIMAL(15,2), @sum3 DECIMAL(15,2) 
	SET @sum1 = 0
	SET @sum2 = 0
	SET @sum3 = 0
	WHILE @@FETCH_STATUS = 0 
		BEGIN
			IF (DAY(@date) <= 10) 
				SET @sum1 = @sum1 + @chargeAmount
			ELSE IF (DAY(@date) <= 20) 
				SET @sum2 = @sum2 + @chargeAmount
			ELSE 
				SET @sum3 = @sum3 + @chargeAmount
		    FETCH NEXT FROM calculatePercentages INTO @chargeAmount, @date
		END
		PRINT 'CARD: ' + @card_number
		PRINT 'MONTH: ' + CAST(@month AS VARCHAR(2))
		PRINT 'DAYS 1-10: ' + CAST(@sum1 AS VARCHAR(20))
		PRINT 'DAYS 11-20: ' + CAST(@sum2 AS VARCHAR(20))
		PRINT 'DAYS 21-30: ' + CAST(@sum3 AS VARCHAR(20))
		PRINT 'ADJUSTED TOTAL : ' + CAST((0.01*@sum1 + 0.02*@sum2 + 0.03*@sum3) AS VARCHAR(20))
	CLOSE calculatePercentages
	DEALLOCATE calculatePercentages
END

--Δοκιμαστική εκτέλεση
EXECUTE cardTransactionMonthlyPercentage '1234567812345678', 6