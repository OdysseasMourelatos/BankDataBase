USE DB04;

-- 1) Γράψτε ένα έναυσμα (trigger), το οποίο πριν γίνει μία εισαγωγή συναλλαγής πιστωτικής
--    κάρτας, ελέγχει αν το άθροισμα ποσό αγοράς + υπόλοιπο πιστωτικής κάρτας υπερβαίνει το
--    πιστωτικό όριο της κάρτας, και αν ναι, την απορρίπτει.

CREATE TRIGGER check_card_limit
	ON CardTransaction
	AFTER INSERT
AS
	BEGIN
	SET NOCOUNT ON

	DECLARE @charge_amount DECIMAL(15,2)
	SET @charge_amount = (SELECT chargeAmount
						  FROM inserted)

	DECLARE @current_balance DECIMAL(15,2)
	SET @current_balance = (SELECT balance
							FROM CreditCard C, inserted
							WHERE C.cardNumber = inserted.cardNumber)

	DECLARE @credit_limit DECIMAL(15,2)
	SET @credit_limit = (SELECT creditLimit
						 FROM CreditCard C, inserted
						 WHERE C.cardNumber = inserted.cardNumber)

	IF @charge_amount + @current_balance > @credit_limit 
	BEGIN
		ROLLBACK TRANSACTION
	END
END

--Δοκιμαστική λειτουργία
SELECT *
FROM CreditCard

INSERT INTO CardTransaction VALUES
('CONF051', 2600, '2017-06-20 13:30:00.000', 'ALPHA', 5, '1111222233334444')