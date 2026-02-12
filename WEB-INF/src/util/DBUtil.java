package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static String url() {
        String v = System.getenv("ORACLE_URL");
        if (v == null || v.isEmpty()) v = "jdbc:oracle:thin:@//localhost:1521/orcl";
        return v;
    }
    private static String user() {
        String v = System.getenv("ORACLE_USER");
        if (v == null || v.isEmpty()) v = "info";
        return v;
    }
    private static String pass() {
        String v = System.getenv("ORACLE_PASS");
        if (v == null || v.isEmpty()) v = "pro";
        return v;
    }
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Oracle JDBC Driver not found", e);
        }
        return DriverManager.getConnection(url(), user(), pass());
    }
}
