package dao;

import config.DBConnection;
import model.Policy;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PolicyDAO {

    public boolean addPolicy(Policy policy) {
        String sql = """
                INSERT INTO policies
                (customer_id, policy_name, policy_type, asset_value,
                 premium_amount, monthly_premium, coverage_amount,
                 start_date, end_date, duration_months, status, recommendation_note)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, policy.getCustomerId());
            statement.setString(2, policy.getPolicyName());
            statement.setString(3, policy.getPolicyType());
            statement.setBigDecimal(4, policy.getAssetValue());
            statement.setBigDecimal(5, policy.getPremiumAmount());
            statement.setBigDecimal(6, policy.getMonthlyPremium());
            statement.setBigDecimal(7, policy.getCoverageAmount());
            statement.setDate(8, policy.getStartDate());
            statement.setDate(9, policy.getEndDate());
            statement.setInt(10, policy.getDurationMonths());
            statement.setString(11, policy.getStatus());
            statement.setString(12, policy.getRecommendationNote());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while adding policy:");
            e.printStackTrace();
        }

        return false;
    }

    public List<Policy> getAllPolicies() {
        List<Policy> policies = new ArrayList<>();

        String sql = """
                SELECT p.*, c.full_name
                FROM policies p
                INNER JOIN customers c ON p.customer_id = c.customer_id
                ORDER BY p.policy_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                policies.add(mapResultSetToPolicy(resultSet));
            }

        } catch (SQLException e) {
            System.out.println("Error while fetching policies:");
            e.printStackTrace();
        }

        return policies;
    }

    public Policy getPolicyById(int policyId) {
        String sql = """
                SELECT p.*, c.full_name
                FROM policies p
                INNER JOIN customers c ON p.customer_id = c.customer_id
                WHERE p.policy_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, policyId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToPolicy(resultSet);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while fetching policy by ID:");
            e.printStackTrace();
        }

        return null;
    }

    public boolean updatePolicy(Policy policy) {
        String sql = """
                UPDATE policies
                SET customer_id = ?, policy_name = ?, policy_type = ?, asset_value = ?,
                    premium_amount = ?, monthly_premium = ?, coverage_amount = ?,
                    start_date = ?, end_date = ?, duration_months = ?,
                    status = ?, recommendation_note = ?
                WHERE policy_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, policy.getCustomerId());
            statement.setString(2, policy.getPolicyName());
            statement.setString(3, policy.getPolicyType());
            statement.setBigDecimal(4, policy.getAssetValue());
            statement.setBigDecimal(5, policy.getPremiumAmount());
            statement.setBigDecimal(6, policy.getMonthlyPremium());
            statement.setBigDecimal(7, policy.getCoverageAmount());
            statement.setDate(8, policy.getStartDate());
            statement.setDate(9, policy.getEndDate());
            statement.setInt(10, policy.getDurationMonths());
            statement.setString(11, policy.getStatus());
            statement.setString(12, policy.getRecommendationNote());
            statement.setInt(13, policy.getPolicyId());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while updating policy:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean deletePolicy(int policyId) {
        String sql = "DELETE FROM policies WHERE policy_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, policyId);
            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while deleting policy:");
            e.printStackTrace();
        }

        return false;
    }

    public List<Policy> searchPolicies(String keyword) {
        List<Policy> policies = new ArrayList<>();

        String sql = """
                SELECT p.*, c.full_name
                FROM policies p
                INNER JOIN customers c ON p.customer_id = c.customer_id
                WHERE p.policy_name LIKE ?
                   OR p.policy_type LIKE ?
                   OR p.status LIKE ?
                   OR c.full_name LIKE ?
                ORDER BY p.policy_id DESC
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
                    policies.add(mapResultSetToPolicy(resultSet));
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while searching policies:");
            e.printStackTrace();
        }

        return policies;
    }

    public int getTotalPolicies() {
        String sql = "SELECT COUNT(*) FROM policies";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("Error while counting policies:");
            e.printStackTrace();
        }

        return 0;
    }

    public int getActivePolicies() {
        String sql = "SELECT COUNT(*) FROM policies WHERE status = 'Active'";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("Error while counting active policies:");
            e.printStackTrace();
        }

        return 0;
    }

    private Policy mapResultSetToPolicy(ResultSet resultSet) throws SQLException {
        return new Policy(
                resultSet.getInt("policy_id"),
                resultSet.getInt("customer_id"),
                resultSet.getString("full_name"),
                resultSet.getString("policy_name"),
                resultSet.getString("policy_type"),
                resultSet.getBigDecimal("asset_value"),
                resultSet.getBigDecimal("premium_amount"),
                resultSet.getBigDecimal("monthly_premium"),
                resultSet.getBigDecimal("coverage_amount"),
                resultSet.getDate("start_date"),
                resultSet.getDate("end_date"),
                resultSet.getInt("duration_months"),
                resultSet.getString("status"),
                resultSet.getString("recommendation_note"),
                null
        );
    }
}