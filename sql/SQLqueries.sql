USE DB04;

--1) Δείξε μία λίστα των πελατών με τον κωδικό τους, το ΑΦΜ τους, το όνομα τους, 
--   τη διευθυνσή τους και το τηλεφωνό τους.
SELECT custCode, SSN, firstName, lastName, address, phone
FROM Customer

--2) Δείξε μία λίστα συναλλαγών με τους αριθμούς των πιστωτικών καρτών ημερομηνία συναλλαγών 
--   από 12/5/2017 εώς και 18/5/2017.

--Εμφανίζουμε όλα τα στοιχεία της λίστας συναλλαγών (μαζί με τον αριθμό πιστωτικών καρτών όπως ζητήται)
SELECT *
FROM CardTransaction
WHERE date BETWEEN '2017-05-12 00:00:00' AND '2017-05-18 23:59:59'
ORDER BY date

--3 Για κάθε πελάτη, δείξε τον κωδικό του, το όνομα του και όλους τους αριθμούς λογαριασμού που διαθέτει.
SELECT C.custCode, firstName, lastName, accNumber
FROM Customer C, Holds H
WHERE C.custCode = H.custCode

--4) Δείξε το όνομα και τηλέφωνο των πελατών που έκαναν κάποια συναλλαγή από 
--   1/6/2017 εώς 30/6/2017 σε κατάστημα περιοχής με κωδικό 291.
SELECT DISTINCT firstName, lastName, phone
FROM Customer C, CreditCard Cr, CardTransaction Ct, Store S
WHERE C.custCode = Cr.custCode AND
	  Cr.cardNumber = Ct.cardNumber AND
	  S.storeCode = Ct.storeCode AND
	  month(Ct.date) = 6 AND
	  year(Ct.date) = 2017 AND 
	  S.geoCode = 291

--5) Βρες όλους τους αριθμούς των πιστωτικών καρτών που λήγουν σε ένα μήνα από την τρέχουσα (σημερινή) ημερομηνία.
SELECT cardNumber
FROM CreditCard
WHERE expiryDate BETWEEN GETDATE() AND (GETDATE() + 30)

--6) Μείωσε το επιτόκιο όλων των καρτούχων κατά 1%.
UPDATE CreditCard
SET loanInterest=loanInterest*0.99

--7) Βρες το όνομα και το ΑΦΜ όλων των πελατών που το συνολικό υπόλοιπο 
--   σε όλους τουςλογαριασμούς που διαθέτουν είναι πάνω από 10,000 euro
SELECT firstName, lastName, SSN
FROM Customer C
WHERE C.custCode IN (SELECT H.custCode
					 FROM Holds H, Account A
					 WHERE H.accNumber = A.accNumber
					 GROUP BY H.custCode
					 HAVING SUM(balance) > 10000)

--8) Δείξε για κάθε μήνα του 2017, το άθροισμα του ποσού των συναλλαγών πιστωτικών καρτών.
SELECT month(date) AS month, SUM(chargeAmount) as sum
FROM CardTransaction
WHERE year(date)=2017
GROUP BY month(date)

--9) Εμφάνισε για κάθε πελάτη και κάθε μήνα του 2017, το όνομα του 
--   συναλλαγών του και το άθροισμα του ποσού των συναλλαγών του.
SELECT firstName, lastName, month(date) as month, SUM(chargeAmount) as sum
FROM Customer  C, CreditCard Cr, CardTransaction Ct
WHERE C.custCode = Cr.custCode AND
	  Cr.cardNumber = Ct.cardNumber AND
	  year(date) = 2017
GROUP BY firstName, lastName, month(date)

--10) Χρησιμοποιώντας το keyword all: Βρες τον κωδικό του πελάτη με τη μεγαλύτερη συναλλαγή.

--Με βάση την εκφώνηση υποθέτουμε ότι ο πελάτης είναι μοναδικός
SELECT DISTINCT Cr.custCode
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  Ct.chargeAmount > ALL (SELECT Ct2.chargeAmount
							 FROM CardTransaction Ct2
							 WHERE Ct2.cardNumber<>Ct.cardNumber)

-- Αν το ερώτημα δεν απαιτούσε την χρήση του keyword ALL
SELECT Cr.custCode
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  Ct.chargeAmount = (SELECT MAX(Ct2.chargeAmount)
						 FROM CardTransaction Ct2)

--11) Δείξε όλους τους πελάτες που έχουν κάνει τον Ιούνιο του 2017 πάνω από 5 αγορές και η μέση
--    αγορά ήταν πάνω από 50 euro.
SELECT Cr.custCode
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  month(date) = 6 AND
	  year(date) = 2017
GROUP BY Cr.custCode
HAVING COUNT(confirmationNumber) > 5 AND
	   AVG (chargeAmount) > 50

--Αν θέλαμε και το ονοματεπώνυμο των πελατών
SELECT custCode, firstName, lastName
FROM Customer
WHERE custCode IN (SELECT Cr.custCode
				   FROM CreditCard Cr, CardTransaction Ct
				   WHERE Cr.cardNumber = Ct.cardNumber AND
						 month(date) = 6 AND
						 year(date) = 2017
				   GROUP BY Cr.custCode
				   HAVING COUNT(confirmationNumber) > 5 AND
						  AVG (chargeAmount) > 50)

--12) Δείξε για κάθε πελάτη το σύνολο των αγορών που έχει κάνει το 2017 ως ποσοστό του μέσου
--    εισοδήματος της περιοχής που ανήκει.

CREATE VIEW V12_1(custCode, total) AS
SELECT Cr.custCode, SUM(chargeAmount)
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  year(date) = 2017
GROUP BY Cr.custCode

SELECT C.custCode, (V12_1.total/income)*100 as percentage
FROM Customer C, GeoArea G, V12_1
WHERE C.geoCode = G.geoCode AND
	  V12_1.custCode = C.custCode

--13) Δείξε το όνομα των πελατών που τον Ιούνιο του 2017 είχαν μέσο ποσό αγορών τρεις φορές
--	  μεγαλύτερο από το μέσο ποσό αγορών αυτού του μήνα (για όλους τους πελάτες).

CREATE VIEW V13_1(custCode, average) AS
SELECT Cr.custCode, AVG(chargeAmount)
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  MONTH(date) = 6 AND
	  year(date) = 2017
GROUP BY cr.custCode

SELECT firstName, lastName
FROM Customer C
WHERE C.custCode IN (SELECT V13_1.custCode
					 FROM V13_1
					 WHERE (V13_1.average/3) > (SELECT AVG(chargeAmount)
												FROM CardTransaction Ct2
												WHERE month(Ct2.date)=6 AND 
												      year(Ct2.date)=2017))

--14) Εμφάνισε τον κωδικό των πελατών που αύξησαν τις συνολικές τους αγορές τον Ιούνιο του 2017
--    τουλάχιστον κατά 50% σε σχέση με τον Ιούνιο του 2016.

CREATE VIEW V14_1(custCode, sum17) AS
SELECT Cr.custCode, SUM(chargeAmount)
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  MONTH(date) = 6 AND
	  year(date) = 2017
GROUP BY cr.custCode

CREATE VIEW V14_2(custCode,sum16) AS
SELECT Cr.custCode, SUM(chargeAmount)
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  MONTH(date) = 6 AND
	  year(date) = 2016
GROUP BY cr.custCode

SELECT V14_1.custCode
FROM V14_1, V14_2
WHERE V14_1.custCode = V14_2.custCode
	  AND (sum17/sum16)>=1.5

-- Χωρίς την χρήση views το ερώτημα θα λυνόταν ως εξής

SELECT T1.custCode 
FROM (SELECT Cr.custCode AS custCode, SUM(chargeAmount) as sum17
	  FROM CreditCard Cr, CardTransaction Ct
	  WHERE Cr.cardNumber = Ct.cardNumber AND
			MONTH(date) = 6 AND
			year(date) = 2017
	  GROUP BY cr.custCode) AS T1,
	  (SELECT Cr.custCode AS custCode, SUM(chargeAmount) as sum16
	  FROM CreditCard Cr, CardTransaction Ct
	  WHERE Cr.cardNumber = Ct.cardNumber AND
			MONTH(date) = 6 AND
			year(date) = 2016
	  GROUP BY cr.custCode) AS T2
WHERE T1.custCode = T2.custCode AND
	  (sum17/sum16)>=1.5

--15) Για κάθε πελάτη και κάθε μήνα του 2017, υπολόγισε τη μέση αγορά του πελάτη πριν από το
--    μήνα, τη μέση αγορά μετά το μήνα, και δείξε σε μια λίστα τους κωδικούς των πελατών και τους
--	  μήνες, που η δεύτερη μέση αγορά είναι μεγαλύτερη από την πρώτη

CREATE VIEW V15_1 (month) AS
SELECT DISTINCT month(date) as month
FROM CardTransaction
WHERE year(date) = 2017

CREATE VIEW V15_2(custCode, month, avg_before) AS
SELECT Cr.custCode, V15_1.month, AVG(chargeAmount) as avg_before
FROM CreditCard Cr, CardTransaction Ct, V15_1
WHERE Cr.cardNumber = Ct.cardNumber AND
	  month(Ct.date) < V15_1.month AND 
	  year(Ct.date) = 2017
GROUP BY Cr.custCode, V15_1.month

CREATE VIEW V15_3(custCode, month, avg_after) AS
SELECT Cr.custCode, V15_1.month, AVG(chargeAmount) as avg_after
FROM CreditCard Cr, CardTransaction Ct, V15_1
WHERE Cr.cardNumber = Ct.cardNumber AND
	  month(Ct.date) > V15_1.month AND 
	  year(Ct.date)=2017
GROUP BY Cr.custCode, V15_1.month

SELECT V15_2.custCode, V15_2.month
FROM V15_2, V15_3
WHERE V15_3.custCode = V15_2.custCode AND
	  V15_2.month = V15_3.month AND
	  avg_after > avg_before

--16) Εμφάνισε σε έναν πίνακα τον κωδικό του πελάτη, το σύνολο των αγορών του το 2017 και το
--	  σύνολο των πληρωμών του το 2017, μόνο αν το σύνολο των πληρωμών είναι μεγαλύτερο από το
--	  σύνολο των αγορών.

CREATE VIEW V16_1(custCode, sumTransactions) AS
SELECT Cr.custCode, SUM(chargeAmount)
FROM CreditCard Cr, CardTransaction Ct
WHERE Cr.cardNumber = Ct.cardNumber AND
	  year(date) = 2017
GROUP BY cr.custCode

CREATE VIEW V16_2(custCode, sumPayments) AS
SELECT custCode, SUM(amount)
FROM Payment
WHERE year(date) = 2017
GROUP BY custCode

SELECT V16_1.custCode, sumTransactions, sumPayments
FROM V16_1, V16_2
WHERE V16_1.custCode = V16_2.custCode AND
	  sumPayments > sumTransactions