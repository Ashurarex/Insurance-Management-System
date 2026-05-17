package dao;

import config.DBConnection;
import model.Claim;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClaimDAO {

    public boolean addClaim(Claim claim) {
        String sql = """
                INSERT INTO claims
                (policy_id, claim_amount, claim_reason, claim_date, status)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, claim.getPolicyId());
            statement.setBigDecimal(2, claim.getClaimAmount());
            statement.setString(3, claim.getClaimReason());
            statement.setDate(4, claim.getClaimDate());
            statement.setString(5, claim.getStatus());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while adding claim:");
            e.printStackTrace();
        }

        return false;
    }

    public Claim getClaimById(int claimId) {
        String sql = """
                SELECT cl.*, p.policy_name, c.full_name
                FROM claims cl
                INNER JOIN policies p ON cl.policy_id = p.policy_id
                INNER JOIN customers c ON p.customer_id = c.customer_id
                WHERE cl.claim_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, claimId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToClaim(resultSet);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while fetching claim:");
            e.printStackTrace();
        }

        return null;
    }

    public List<Claim> getAllClaims() {
        List<Claim> claims = new ArrayList<>();

        String sql = """
                SELECT cl.*, p.policy_name, c.full_name
                FROM claims cl
                INNER JOIN policies p ON cl.policy_id = p.policy_id
                INNER JOIN customers c ON p.customer_id = c.customer_id
                ORDER BY cl.claim_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                claims.add(mapResultSetToClaim(resultSet));
            }

        } catch (SQLException e) {
            System.out.println("Error while fetching claims:");
            e.printStackTrace();
        }

        return claims;
    }

    public BigDecimal getApprovedClaimAmountForPolicy(int policyId, int excludeClaimId) {
        String sql = """
                SELECT COALESCE(SUM(claim_amount), 0)
                FROM claims
                WHERE policy_id = ?
                  AND status = 'Approved'
                  AND claim_id <> ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, policyId);
            statement.setInt(2, excludeClaimId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getBigDecimal(1);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while calculating approved claim amount:");
            e.printStackTrace();
        }

        return BigDecimal.ZERO;
    }

    public boolean updateClaimStatus(int claimId, String status) {
        String sql = "UPDATE claims SET status = ? WHERE claim_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, status);
            statement.setInt(2, claimId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while updating claim status:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteClaim(int claimId) {
        String sql = "DELETE FROM claims WHERE claim_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, claimId);
            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error while deleting claim:");
            e.printStackTrace();
        }

        return false;
    }

    public List<Claim> searchClaims(String keyword) {
        List<Claim> claims = new ArrayList<>();

        String sql = """
                SELECT cl.*, p.policy_name, c.full_name
                FROM claims cl
                INNER JOIN policies p ON cl.policy_id = p.policy_id
                INNER JOIN customers c ON p.customer_id = c.customer_id
                WHERE p.policy_name LIKE ?
                   OR c.full_name LIKE ?
                   OR cl.claim_reason LIKE ?
                   OR cl.status LIKE ?
                ORDER BY cl.claim_id DESC
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
                    claims.add(mapResultSetToClaim(resultSet));
                }
            }

        } catch (SQLException e) {
            System.out.println("Error while searching claims:");
            e.printStackTrace();
        }

        return claims;
    }

    public int getPendingClaims() {
        String sql = "SELECT COUNT(*) FROM claims WHERE status = 'Pending'";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("Error while counting pending claims:");
            e.printStackTrace();
        }

        return 0;
    }

    private Claim mapResultSetToClaim(ResultSet resultSet) throws SQLException {
        return new Claim(
                resultSet.getInt("claim_id"),
                resultSet.getInt("policy_id"),
                resultSet.getString("policy_name"),
                resultSet.getString("full_name"),
                resultSet.getBigDecimal("claim_amount"),
                resultSet.getString("claim_reason"),
                resultSet.getDate("claim_date"),
                resultSet.getString("status")
        );
    }
}