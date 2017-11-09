import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.sql.*;
import java.io.*;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
public class Assignment2 extends JDBCSubmission {
	
    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
    	try
        {
    		Properties props = new Properties();
    		props.setProperty("user",username);
    		props.setProperty("password",password);
    		props.setProperty("currentSchema", "parlgov");
    		this.connection = DriverManager.getConnection(url, props);
    		return this.connection.isValid(0);
        }
        catch (SQLException se)
        {
            System.err.println("connectDB" +
                    "<Message>: " + se.getMessage());
        }
		return false;
    }

    @Override
    public boolean disconnectDB() {
    	try
        {
    		connection.close();
    		return connection.isClosed();
        }
        catch (SQLException se)
        {
            System.err.println("disconnectDB." +
                    "<Message>: " + se.getMessage());
        }
    	return false;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
    	ElectionCabinetResult answer = null;
    	
    	List<Integer> elections = new ArrayList<Integer>();
    	List<Integer> cabinets = new ArrayList<Integer>(); 
    	
        PreparedStatement e_statement, c_statement;
        ResultSet election_result,cabinet_result;
        String election_query,cabinet_query;
        try {
        	
        	election_query = ""
        			+ "select election.country_id as cid, election.id as eid, eleciton.e_date as date, election.e_type as type"
        			+ "from country join election on country.id = election.country_id "
        			+ "where country.name = ? order by extract(year from e_date) desc";
        	
        	e_statement = connection.prepareStatement(election_query);
        	e_statement.setString(1, countryName);
        	election_result = e_statement.executeQuery();
        	while (election_result.next()) {
        		int election_id = election_result.getInt("id");
        		int cid = election_result.getInt("cid");
        		String date = election_result.getString("e_date");
        		String type = election_result.getString("type");
        		
        		cabinet_query = ""
        				+ "select id, start_date"
        				+ "from cabinet join election on cabinet.country_id = election.country_id"
        				+ "where cabinet.start_date >= ? and"
        				+ "cabinet.start_date < (select min(e_date) from country join election on country.id = election.country_id"
        				+ "where election.country_id = cabinet.country_id and election.country_id = ? and"
        				+ "election.e_type = ?)"
        				+ "order by start_date";
        		c_statement = connection.prepareStatement(cabinet_query);
            	c_statement.setString(1, date);
            	c_statement.setInt(2, cid);
            	c_statement.setString(3, type);
            	cabinet_result = c_statement.executeQuery();
            	while (cabinet_result.next()) {
            		int cab_id = cabinet_result.getInt("id");
            		String d = cabinet_result.getString("start_date");
                    System.out.println("   " +election_id + cab_id + d);
            	}
        	}
        	answer = new ElectionCabinetResult(elections,cabinets);
        }
        catch(SQLException se){
            System.err.println("electionSequence." +
                    "<Message>: " + se.getMessage());
        }
		return answer;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianId, Float threshold) {
        // Implement this method!
    	List<Integer> answer = new ArrayList<Integer>();
        return answer;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
    	Assignment2 test;
		try {
			test = new Assignment2();
			String url = "jdbc:postgresql://localhost:5432/csc343h-luke6";
	    	String uid = "luke6";
	    	String pw = "";
	    	boolean r = test.connectDB(url, uid, pw);
	    	if (! r) {
	    		System.out.println("DB connect failed");
	    		System.exit(0);
	    	}
	    	System.out.println("connection successful");
	    	String q = "select * from election";
	    	PreparedStatement qq = test.connection.prepareStatement(q);
	    	ResultSet rr = qq.executeQuery();
	    	while (rr.next()) {
	    		int id = rr.getInt("id");
	    		System.out.println(id);
	    	}
	    	
	    	boolean s = test.disconnectDB();
	    	if (! s) {
	    		System.out.println("DB disconnect failed");
	    		System.exit(0);
	    	}
	    	System.out.println("disconnection successful");
	    	
	    	
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 catch(SQLException se){
            System.err.println("main." +
                    "<Message>: " + se.getMessage());
        }
    	
    	
    	
    }

}

