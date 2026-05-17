package dao;

import config.DBConnection;
import model.Customer;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    public boolean addCustomer(Customer customer) {
        String sql = "INSERT INTO customers (full_name, email, phone, address, dob, gender) VALUES (?, ?, ?, ?, ?, ?)";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, customer.getFullName());
            statement.setString(2, customer.getEmail());
            statement.setString(3, customer.getPhone());
            statement.setString(4, customer.getAddress());
            statement.setDate(5, customer.getDob());
            statement.setString(6, customer.getGender());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while adding customer:");
            e.printStackTrace();
        }

        return false;
    }

    public List<Customer> getAllCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM customers ORDER BY customer_id DESC";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                customers.add(mapResultSetToCustomer(resultSet));
            }

        } catch (SQLException e) {
            System.out.println("Error while fetching customers:");
            e.printStackTrace();
        }

        return customers;
    }

    public Customer getCustomerById(int customerId) {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, customerId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToCustomer(resultSet);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while fetching customer by ID:");
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateCustomer(Customer customer) {
        String sql = "UPDATE customers SET full_name = ?, email = ?, phone = ?, address = ?, dob = ?, gender = ? WHERE customer_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, customer.getFullName());
            statement.setString(2, customer.getEmail());
            statement.setString(3, customer.getPhone());
            statement.setString(4, customer.getAddress());
            statement.setDate(5, customer.getDob());
            statement.setString(6, customer.getGender());
            statement.setInt(7, customer.getCustomerId());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while updating customer:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteCustomer(int customerId) {
        String sql = "DELETE FROM customers WHERE customer_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, customerId);
            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while deleting customer:");
            e.printStackTrace();
        }

        return false;
    }

    public List<Customer> searchCustomers(String keyword) {
        List<Customer> customers = new ArrayList<>();

        String sql = """
                SELECT * FROM customers
                WHERE full_name LIKE ?
                   OR email LIKE ?
                   OR phone LIKE ?
                   OR gender LIKE ?
                ORDER BY customer_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            String searchPattern = "%" + keyword + "%";

            statement.setString(1, searchPattern);
            statement.setString(2, searchPattern);
            statement.setString(3, searchPattern);
            statement.setString(4, searchPattern);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    customers.add(mapResultSetToCustomer(resultSet));
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while searching customers:");
            e.printStackTrace();
        }

        return customers;
    }

    public int getTotalCustomers() {
        String sql = "SELECT COUNT(*) FROM customers";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("Error while counting customers:");
            e.printStackTrace();
        }

        return 0;
    }

    private Customer mapResultSetToCustomer(ResultSet resultSet) throws SQLException {
        return new Customer(
                resultSet.getInt("customer_id"),
                resultSet.getString("full_name"),
                resultSet.getString("email"),
                resultSet.getString("phone"),
                resultSet.getString("address"),
                resultSet.getDate("dob"),
                resultSet.getString("gender"),
                resultSet.getTimestamp("created_at")
        );
    }
}