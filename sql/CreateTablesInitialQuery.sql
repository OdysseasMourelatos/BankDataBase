USE DB04;

CREATE TABLE GeoArea (
    geoCode INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    population INT,
    income DECIMAL(15,2)
);

CREATE TABLE Customer (
    custCode INT IDENTITY(1,1) PRIMARY KEY,
    firstName VARCHAR(60),
    lastName VARCHAR(60),
    address VARCHAR(250),
    SSN VARCHAR(9) NOT NULL UNIQUE,
    phone VARCHAR(10) NOT NULL,
    geoCode INT NOT NULL FOREIGN KEY REFERENCES GeoArea(geoCode)
);

CREATE TABLE Payment (
    custCode INT NOT NULL FOREIGN KEY REFERENCES Customer(custCode),
    number INT NOT NULL,
    date DATE,
    amount DECIMAL(10,2) CHECK (amount > 0),
    PRIMARY KEY (custCode, number)
);

CREATE TABLE Account (
    accNumber INT IDENTITY(1,1) PRIMARY KEY,
    balance DECIMAL(15,2),
    creationDate DATE,
	branch VARCHAR(255),
);

CREATE TABLE SavingsAccount (
    accNumber INT PRIMARY KEY,
    interestRate DECIMAL(5,2) CHECK (interestRate >= 0),
    CONSTRAINT SA_F FOREIGN KEY (accNumber) REFERENCES Account(accNumber)
);

CREATE TABLE CheckingAccount (
    accNumber INT PRIMARY KEY,
    overdraftAmount DECIMAL(15,2) CHECK (overdraftAmount >= 0),
    CONSTRAINT CA_F FOREIGN KEY (accNumber) REFERENCES Account(accNumber)
);

CREATE TABLE Store (
    storeCode INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255),
    serviceType INT,
    geoCode INT NOT NULL FOREIGN KEY REFERENCES GeoArea(geoCode)
);

CREATE TABLE CreditCard (
    cardNumber VARCHAR(16) PRIMARY KEY,
    issueDate DATE NOT NULL,
    expiryDate DATE NOT NULL,
    creditLimit DECIMAL(15,2) CHECK (creditLimit >= 0),
    loanInterest DECIMAL(5,2) CHECK (loanInterest >= 0),
    balance DECIMAL(15,2),
    custCode INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Customer(custCode),
    accNumber INT NOT NULL FOREIGN KEY REFERENCES Account(accNumber)
);

CREATE TABLE CardTransaction (
    confirmationNumber VARCHAR(50) PRIMARY KEY,
    chargeAmount DECIMAL(15,2) CHECK (chargeAmount > 0),
    date DATETIME,
    bankCode VARCHAR(10),
    storeCode INT FOREIGN KEY REFERENCES Store(storeCode),
    cardNumber VARCHAR(16) NOT NULL FOREIGN KEY REFERENCES CreditCard(cardNumber)
);

CREATE TABLE Holds (
	custCode INT NOT NULL FOREIGN KEY REFERENCES Customer(custCode),
	accNumber INT NOT NULL FOREIGN KEY REFERENCES Account(accNumber),
	PRIMARY KEY (custCode, accNumber)
)

/*GeoArea
Το πρωτεύον κλειδί geoCode ΔΕΝ είναι auto-incremented by one, ώστε στο ερώτημα 4 να υπάρχει περιοχή με κωδικό 291
Χρειαζόμαστε το όνομα της Περιοχής, άρα απαιτούμε να μην είναι NULL

Customer
Το πρωτεύον κλειδί custCode είναι auto-incremented by one, δηλαδή ξεκινά από το 1 και για κάθε γραμμή αυξάνεται κατά ένα αυτόματα
Το ΑΦΜ (SSN) απαιτούμε να μην είναι NULL και ταυτόχρονα να είναι UNIQUE
Χρειαζόμαστε το τηλέφωνο (phone) για επικοινωνία, άρα απαιτούμε να μην είναι NULL
Εφόσον στο διάγραμμα Οντοτήτων-Συσχετίσεων υπάρχει υποχρεωτική συσχέτιση της οντότητας Customer με την GeoArea, 
το ξένο κλειδί geoCode απαιτούμε να μην είναι NULL

Payment
Ως αδύναμη οντότητα, έχει πρωτεύον κλειδί τον συνδυασμό του πρωτεύοντος κλειδιού της ισχυρής οντότητας Customer (custCode) 
και του μερικού κλειδιού της αδύναμης (number) και ξένο κλειδί το pk της ισχυρής οντότητας Customer (custCode) 
Το number ως μερικό κλειδί απαιτούμε να μην είναι NULL
Επιπλέον περιορισμός στο amount ώστε να εξασφαλίσουμε ότι δίνεται θετικός αριθμός

Account
Το πρωτεύον κλειδί accNumber είναι auto-incremented by one, δηλαδή ξεκινά από το 1 και για κάθε γραμμή αυξάνεται κατά ένα αυτόματα

SavingsAccount & Checking Account
Περιορισμοί ξένου κλειδιού SA_F & CA_F για τις οντότητες SavingsAccount & CheckingAccount, αντίστοιχα
Για SavingsAccount έλεγχος ότι το interestRate δεν είναι αρνητικό, 
και επίσης για CheckingAccount έλεγχος ότι το overdraftAmount δεν είναι αρνητικό

Store
Το πρωτεύον κλειδί storeNumber είναι auto-incremented by one, δηλαδή ξεκινά από το 1 και για κάθε γραμμή αυξάνεται κατά ένα αυτόματα
Εφόσον στο διάγραμμα Οντοτήτων-Συσχετίσεων υπάρχει υποχρεωτική συσχέτιση της οντότητας Store με την GeoArea, 
το ξένο κλειδί geoCode απαιτούμε να μην είναι NULL

CreditCard
Κρίνουμε απαραίτητη τις πληροφορίες για το issueDate & το expiryDate, οπότε απαιτούμε να μην είναι NULL
Επιπλέον περιορισμοί στο creditLimit & στο loanInterest ώστε να εξασφαλίσουμε ότι δίνονται μη αρνητικοί αριθμοί
Εφόσον στο διάγραμμα Οντοτήτων-Συσχετίσεων υπάρχει υποχρεωτική συσχέτιση της οντότητας CreditCard με την Customer & την Account, 
τα ξένα κλειδιά custCode & accNumber αντίστοιχα απαιτούμε να μην είναι NULL
Μάλιστα, εφόσον ένας πελάτης μπορεί να έχει το πολύ μια πιστωτική κάρτα, απαιτούμε το ξένο κλειδί custCode να είναι Unique

CardTransaction
Επιπλέον περιορισμός στο chargeAmount ώστε να εξασφαλίσουμε ότι δίνεται θετικός αριθμός
Εφόσον στο διάγραμμα Οντοτήτων-Συσχετίσεων υπάρχει υποχρεωτική συσχέτιση της οντότητας Transaction με την CreditCard, 
το ξένο κλειδί cardNumber απαιτούμε να μην είναι NULL (Δεν υπάρχει υποχρεωτική συσχέτιση της Transaction με την Store, άρα δεν υφίσταται τέτοιος περιορισμός για το ξένο κλειδί storeCode)

Holds
Ως πίνακας συσχέτισης πολλά-προς-πολλά, για το πρωτεύον κλειδί (συνδυασμός custCode & accNumber) και για τα ξένα κλειδιά υλοποιούνται όσα αναφέρθηκαν στην εξήγηση του σχεσιακού μοντέλου.
*/
