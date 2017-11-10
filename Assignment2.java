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
        	
        	election_query = "select election.country_id as cid, election.id as eid, election.e_date as date, election.e_type as type "
        			+ "from country join election on country.id = election.country_id "
        			+ "where country.name = ? "
        			+ "order by extract(year from e_date) desc";
        	
        	e_statement = this.connection.prepareStatement(election_query);
        	e_statement.setString(1, countryName);
        	election_result = e_statement.executeQuery();
        	System.out.println("election querty done with success");
        	while (election_result.next()) {
        		int election_id = election_result.getInt("eid");
        		int cid = election_result.getInt("cid");
        		String date = election_result.getString("date");
        		String type = election_result.getString("type");
        		System.out.println("  "+election_id+"    "+date+"    "+type+"    "+cid+"\n");
        		cabinet_query = ""
        				+ "select distinct cabinet.id, cabinet.start_date "
        				+ "from cabinet join election on cabinet.country_id = election.country_id "
        				+ "where cabinet.country_id = ? and cabinet.start_date >= cast( ? as date) and "
        				+ "cabinet.start_date < (select min(e_date) from election "
        													 	+ "where election.country_id = cabinet.country_id and "
        													 				+ "election.e_date > cast( ? as date) and "
        													 				+ "election.e_type = cast(? as election_type)) "
        				+ "order by cabinet.start_date asc";
        		c_statement = this.connection.prepareStatement(cabinet_query);
            	c_statement.setInt(1, cid);
            	c_statement.setString(2, date);
            	c_statement.setString(3, date);
            	c_statement.setString(4, type);
            	cabinet_result = c_statement.executeQuery();
            	
            	while (cabinet_result.next()) {
            		int cab_id = cabinet_result.getInt("id");
            		String d = cabinet_result.getString("start_date");
                    System.out.println("                "+election_id +"   "+ cab_id +"   "+ d);
                    elections.add(election_id);
                    cabinets.add(cab_id);
            	}
            	
            	System.out.println("\n");
            	
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
        PreparedStatement p_statement;
        ResultSet politician_result;
        String p_query;
    	try {
    		
    		p_query = "select p1.id as pid1, p1.description as p1des, p1.comment as p1com, "
    					  + "p2.id as pid2, p2.description as p2des, p2.comment as p2com "
    				+ "from politician_president as p1 , politician_president as p2 "
    				+ "where p1.id = ? and p2.id <> p1.id  ";
    		p_statement = this.connection.prepareStatement(p_query);
    		p_statement.setInt(1, politicianId);
    		politician_result = p_statement.executeQuery();
    		System.out.println("politician query executed");
    		while (politician_result.next()) {
    			int id = politician_result.getInt("pid2");
    			String p1des = politician_result.getString("p1des");
    			String p1com = politician_result.getString("p1com");
    			String p2des = politician_result.getString("p2des");
    			String p2com = politician_result.getString("p2com");
    			
    			System.out.println("id: "+id+"\n" + "p1des: \n"+p1des +"\n" 
    			+ "p2 des: \n" + p2des +"\n" + "p1com \n "+p1com+"\n"+"p2com \n"+p2com+"\n");
    			
    			double des_sim = this.similarity(p1des, p2des);
    			double com_sim = this.similarity(p1com, p2com);
    			if (des_sim > threshold && com_sim > threshold) {
    				answer.add(id);
    			}
    			
    		}
    		
    	}
    	catch(SQLException se) {
    		System.err.println("findSimilarPoliticians." +
                    "<Message>: " + se.getMessage());
    	}
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
	    	
	    	
	    	//System.out.println(test.electionSequence("Germany"));
	    	System.out.println(test.findSimilarPoliticians(148,(float) 0.0));


	    	
	    	boolean s = test.disconnectDB();
	    	if (! s) {
	    		System.out.println("DB disconnect failed");
	    		System.exit(0);
	    	}
	    	
	    	
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	
    	
    	
    }

}

