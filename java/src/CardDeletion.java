import java.sql.*;
import java.util.InputMismatchException;
import java.util.Scanner;

public class CardDeletion {

    private static final String dbName= "DB04";
    private static final String dbUser= "G504"; 
    private static final String dbPassword= "58345e494"; 

    public static void main(String args[]) {

    	Connection dbcon = null;
        Statement stmt = null ;
        ResultSet rs = null;
        ResultSet rs2 = null;
    	
        Scanner s = new Scanner(System.in);
        String cardNumber;
        int custCode;
        
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
        
        System.out.println("\n------------CREDITCARD DELETION PROGRAM------------");
        System.out.println("\nExisting Credit Card Numbers: \n");
   
        // Execute SQL statements
        
        try {           
            
            stmt = dbcon.createStatement();
            rs = stmt.executeQuery("SELECT * FROM CreditCard");
            
            while (rs.next()) {
                System.out.println(rs.getString("cardNumber"));
            }

            System.out.print("\nInput the number of the credit card you want to delete: ");
            cardNumber = s.nextLine();
            System.out.println();

            
            rs = stmt.executeQuery("SELECT custCode FROM CreditCard WHERE cardNumber = '" + cardNumber + "'");
            if (rs.next()) {
                custCode = rs.getInt("custCode");
            } else {
                System.out.println("Card not found!");
                return;
            }
            
            //Deleting the card
            stmt.executeUpdate("DELETE FROM CreditCard WHERE cardNumber = '" + cardNumber + "'");

            //Checking the deletion
            rs = stmt.executeQuery("SELECT cardNumber FROM CreditCard WHERE cardNumber = '" + cardNumber + "'");

            if (!rs.next()) {
                System.out.println("SUCCESFULLY DELETED CREDIT CARD WITH NUMBER : " + cardNumber);
            }

            //Delete payments of the customer with this card
            //Since a customer has only 1 card, we know that all his payments were made with this card
            stmt.executeUpdate("DELETE FROM Payment WHERE custCode = " + custCode);
            rs = stmt.executeQuery("SELECT * FROM Payment WHERE custCode = " + custCode);

            //Checking to see whether ON DELETE CASCADE worked
            rs = stmt.executeQuery("SELECT * FROM Payment WHERE custCode = " + custCode);
            boolean noPayments = !rs.next();

            rs2 = stmt.executeQuery("SELECT * FROM CardTransaction WHERE cardNumber = '" + cardNumber + "'");
            boolean noTransactions = !rs2.next();
            
            if (noPayments && noTransactions) {
                System.out.println("VERIFIED: All related data (Transactions & Payments) have been removed.");
            }
            
            rs.close();   
            rs2.close();         
            stmt.close();
            dbcon.close();

        } catch(SQLException e) {
        
            System.out.println("SQLException: " + e.getMessage());

        } catch (InputMismatchException e) {
            
            System.out.println("INVALID INPUT");
        } finally {
            try {
                dbcon.close();
            } catch (SQLException e) {

            }
        }
        s.close();
    }
}
