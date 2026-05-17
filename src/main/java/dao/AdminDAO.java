package dao;

import config.DBConnection;
import model.Admin;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminDAO {

    public Admin validateAdmin(String username, String password) {
        String sql = "SELECT * FROM admins WHERE username = ? AND password = ?";

        System.out.println("=== LOGIN DEBUG START ===");
        System.out.println("Username received: [" + username + "]");
        System.out.println("Password received: [" + password + "]");

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            System.out.println("Database connection successful.");

            statement.setString(1, username);
            statement.setString(2, password);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {
                System.out.println("Login matched database record.");
                System.out.println("=== LOGIN DEBUG END ===");

                return new Admin(
                        resultSet.getInt("admin_id"),
                        resultSet.getString("username"),
                        resultSet.getString("password")
                );
            } else {
                System.out.println("No matching admin found.");
            }

        } catch (SQLException e) {
            System.out.println("Database error during login:");
            e.printStackTrace();
        }

        System.out.println("=== LOGIN DEBUG END ===");
        return null;
    }
}