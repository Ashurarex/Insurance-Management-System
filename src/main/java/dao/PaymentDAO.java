package dao;

import config.DBConnection;
import model.Payment;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {

    public boolean addPayment(Payment payment) {
        String sql = """
                INSERT INTO payments
                (policy_id, amount, payment_date, payment_mode, status)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, payment.getPolicyId());
            statement.setBigDecimal(2, payment.getAmount());
            statement.setDate(3, payment.getPaymentDate());
            statement.setString(4, payment.getPaymentMode());
            statement.setString(5, payment.getStatus());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while adding payment:");
            e.printStackTrace();
        }

        return false;
    }

    public List<Payment> getAllPayments() {
        List<Payment> payments = new ArrayList<>();

        String sql = """
                SELECT pay.*, p.policy_name, c.full_name
                FROM payments pay
                INNER JOIN policies p ON pay.policy_id = p.policy_id
                INNER JOIN customers c ON p.customer_id = c.customer_id
                ORDER BY pay.payment_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                payments.add(mapResultSetToPayment(resultSet));
            }

        } catch (SQLException e) {
            System.out.println("Error while fetching payments:");
            e.printStackTrace();
        }

        return payments;
    }

    public boolean deletePayment(int paymentId) {
        String sql = "DELETE FROM payments WHERE payment_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, paymentId);
            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while deleting payment:");
            e.printStackTrace();
        }

        return false;
    }

    public List<Payment> searchPayments(String keyword) {
        List<Payment> payments = new ArrayList<>();

        String sql = """
                SELECT pay.*, p.policy_name, c.full_name
                FROM payments pay
                INNER JOIN policies p ON pay.policy_id = p.policy_id
                INNER JOIN customers c ON p.customer_id = c.customer_id
                WHERE p.policy_name LIKE ?
                   OR c.full_name LIKE ?
                   OR pay.payment_mode LIKE ?
                   OR pay.status LIKE ?
                ORDER BY pay.payment_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            String pattern = "%" + keyword + "%";

            statement.setString(1, pattern);
            statement.setString(2, pattern);
            statement.setString(3, pattern);
            statement.setString(4, pattern);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    payments.add(mapResultSetToPayment(resultSet));
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while searching payments:");
            e.printStackTrace();
        }

        return payments;
    }

    public int getTotalPayments() {
        String sql = "SELECT COUNT(*) FROM payments";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("Error while counting payments:");
            e.printStackTrace();
        }

        return 0;
    }

    public BigDecimal getTotalPaymentAmount() {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM payments";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getBigDecimal(1);
            }

        } catch (SQLException e) {
            System.out.println("Error while summing payments:");
            e.printStackTrace();
        }

        return BigDecimal.ZERO;
    }

    private Payment mapResultSetToPayment(ResultSet resultSet) throws SQLException {
        return new Payment(
                resultSet.getInt("payment_id"),
                resultSet.getInt("policy_id"),
                resultSet.getString("policy_name"),
                resultSet.getString("full_name"),
                resultSet.getBigDecimal("amount"),
                resultSet.getDate("payment_date"),
                resultSet.getString("payment_mode"),
                resultSet.getString("status")
        );
    }
}