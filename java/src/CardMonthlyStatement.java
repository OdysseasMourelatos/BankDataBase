import java.sql.*;
import java.util.InputMismatchException;
import java.util.Scanner;

public class CardMonthlyStatement {

    private static final String dbName= "DB04";
    private static final String dbUser= "G504"; 
    private static final String dbPassword= "58345e494"; 

    public static void main(String args[]) {

    	Connection dbcon = null;
        Statement stmt = null ;
        Statement stmt2 = null; 
        ResultSet rs = null;
        ResultSet rs2 = null;
    	
        Scanner s = new Scanner(System.in);
        String cardNumber;
        int custCode = 0;
        int month;
        int year;
        
        String url = "jdbc:sqlserver://sqlserver.dmst.aueb.gr:1433;"
         + "databaseName=" + dbName + ";user=" + dbUser + ";password=" + dbPassword + ";encrypt=true;trustServerCertificate=true;";

        
        // Step 1 -> Dynamically load the driver's class file into memory 

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch(java.lang.ClassNotFoundException e) { 
            System.out.println("ClassNotFoundException: " + e.getMessage());
            System.exit(0);
        }
        
        // Step 2 -> Establish a connection with the database and initializes the Connection object (dbcon)

		try {
			dbcon = DriverManager.getConnection(url);			
		} catch (SQLException e) {			
			System.out.println("SQLException: " + e.getMessage());
			System.exit(0);
		}        
        
        System.out.println("\n------------CREDITCARD MONTHLY STATEMENT PROGRAM------------");
        System.out.println("\nExisting Credit Card Numbers: \n");
   
        // Execute SQL statements
        
        try {           
            
            stmt = dbcon.createStatement();
            rs = stmt.executeQuery("SELECT * FROM CreditCard");
            
            while (rs.next()) {
                System.out.println(rs.getString("cardNumber"));
            }

            System.out.print("\nInput the number of the credit card you want to see the monthly statement of: ");
            cardNumber = s.nextLine();
            System.out.print("\nInput the number of the month: ");
            month = s.nextInt();
            if (month < 1 || month > 12) {
                s.close();
                throw new IllegalArgumentException();
            }
            System.out.print("\nInput the year: ");
            year = s.nextInt();
            System.out.println();
            
            rs = stmt.executeQuery("SELECT * FROM CreditCard WHERE cardNumber = '" + cardNumber + "'");
            
            if (rs.next()) {
                custCode = rs.getInt("custCode");

                rs = stmt.executeQuery("SELECT * FROM Customer WHERE custCode = " + custCode);
            
                if (rs.next()) {
                    System.out.println("\n-----------------------------------INFO OF CARD HOLDER-----------------------------------\n");
                    System.out.println("Customer Code: " + custCode);
                    System.out.println("Name: " + rs.getString("firstName") + " " + rs.getString("lastName"));
                    System.out.println("Address: " + rs.getString("address"));
                    System.out.println("SSN: " + rs.getString("SSN"));
                    System.out.println("Phone: " + rs.getString("phone"));
                    System.out.println("Geo Code: " + rs.getInt("geoCode"));
                } 
            } else {
                throw new IllegalArgumentException();
            }

            boolean hasTransactions = false;

            rs = stmt.executeQuery("SELECT * FROM CardTransaction WHERE cardNumber = '" + cardNumber + "' AND MONTH(date) = " + month + "AND YEAR(date) = " + year);
            
            while (rs.next()) {
                if (!hasTransactions) {
                    System.out.println("\n-----------------------------------MONTH TRANSACTIONS------------------------------------\n");
                    System.out.printf("%-12s %-10s %-25s %-12s %-20s%n", "ConfNum", "Amount", "Date", "Bank Code", "Store");
                    System.out.println("-----------------------------------------------------------------------------------------");
                    hasTransactions = true;
                } 
                String conf = rs.getString("confirmationNumber");
                long amount = rs.getLong("chargeAmount");
                String date = rs.getString("date");
                String bank = rs.getString("bankCode");
                int storeCode = rs.getInt("storeCode");
                String storeName = "UNKNOWN";

                if (!rs.wasNull()) {
                    stmt2 = dbcon.createStatement();
                    rs2 = stmt2.executeQuery("SELECT name FROM Store WHERE storeCode = " + storeCode);
                    if (rs2.next()) {
                        storeName = rs2.getString("name");
                    }
                    rs2.close();
                    stmt2.close();
                }

                System.out.printf("%-12s %-10d %-25s %-12s %-20s%n", conf, amount, date, bank, storeName);
            }
            
            if (!hasTransactions) {
                System.out.println("\nNo transactions found for this month.");
            } else {
                rs = stmt.executeQuery("SELECT SUM(chargeAmount) as sum, AVG(chargeAmount) AS avg FROM CardTransaction WHERE cardNumber = '" + cardNumber + "' AND MONTH(date) = " + month + "AND YEAR(date) = " + year);
                if (rs.next()) {
                    System.out.println();
                    System.out.println("-----------------------------------------------------------------------------------------");
                    System.out.println("TOTAL TRANSACTIONS OF MONTH: " + rs.getLong("sum"));
                    System.out.println("TRANSACTIONS AVERAGE OF MONTH: " + rs.getDouble("avg"));
                }
            }
           

            boolean hasPayments = false;


            rs = stmt.executeQuery("SELECT * FROM Payment WHERE custCode = " + custCode + " AND MONTH(date) = " + month + " AND YEAR(date) = " + year);

            while (rs.next()) {
                if (!hasPayments) {
                    System.out.println("\n\n----------------MONTH PAYMENTS----------------\n");
                    System.out.printf("%-12s %-10s %-25s%n", "Number", "Amount", "Date");
                    System.out.println("----------------------------------------------");
                    hasPayments = true; 
                } 
                int number = rs.getInt("number");
                long amount = rs.getLong("amount");
                String date = rs.getString("date");

                System.out.printf("%-12d %-10d %-25s%n", number, amount, date);
            }

            if (!hasPayments) {
                System.out.println("\nNo payments found for this month.");
            } else {
                rs = stmt.executeQuery("SELECT SUM(amount) as sum, AVG(amount) AS avg FROM Payment WHERE custCode = " + custCode + " AND MONTH(date) = " + month + " AND YEAR(date) = " + year);
                if (rs.next()) {
                    System.out.println();
                    System.out.println("----------------------------------------------");
                    System.out.println("TOTAL PAYMENTS OF MONTH: " + rs.getDouble("sum"));
                    System.out.println("AVERAGE PAYMENTS OF MONTH: " + rs.getDouble("avg"));
                }
            }

            double initialBalance = 0.0;
            double transactions = 0.0;
            double payments = 0.0;
            
            double updatedBalance = 0.0;

            rs = stmt.executeQuery("SELECT SUM(chargeAmount) as sumTransactions FROM CardTransaction WHERE cardNumber = '" + cardNumber + "' AND (YEAR(date) < " + year + " OR (YEAR(date) = " + year + " AND MONTH(date) <= " + month + "))");
            
            if (rs.next()) {
                transactions = rs.getDouble("sumTransactions");
            }

            rs = stmt.executeQuery("SELECT SUM(amount) as sumPayments FROM Payment WHERE custCode = " + custCode + " AND (YEAR(date) < " + year + " OR (YEAR(date) = " + year + " AND MONTH(date) <= " + month + "))");
            
            if (rs.next()) {
                payments = rs.getDouble("sumPayments");
            }

            rs = stmt.executeQuery("SELECT * FROM CreditCard WHERE cardNumber = '" + cardNumber + "'");
            
            if (rs.next()) {
                initialBalance = rs.getDouble("balance");
                System.out.println("\n\n----------------UPDATED CARD INFO----------------\n");
                System.out.println("Card Number: " + cardNumber);
                System.out.println("Issue Date: " + rs.getString("issueDate"));
                System.out.println("Expiry Date: " + rs.getString("expiryDate"));
                System.out.println("Credit Limit: " + rs.getDouble("creditLimit"));
                System.out.println("Loan Intereset: " + rs.getDouble("loanInterest"));
                System.out.println("Account Number: " + rs.getInt("accNumber"));

                //Updated balance until the given month, as confirmed by Mr. Grigorakakis
                initialBalance = rs.getDouble("balance");
                updatedBalance = initialBalance + transactions - payments;
                System.out.println("\nUPDATED balance: " + updatedBalance);

            }

            rs.close();     
            stmt.close();
            dbcon.close();

        } catch(SQLException e) {
        
            System.out.println("SQLException: " + e.getMessage());

        } catch(InputMismatchException e) {

            System.out.println("\nINVALID INPUT!");

        } catch (IllegalArgumentException e) {
            
            System.out.println("INVALID input");
            
        } finally {
            try {
                dbcon.close();
            } catch (SQLException e) {

            }
        }
        s.close();
    }
}

