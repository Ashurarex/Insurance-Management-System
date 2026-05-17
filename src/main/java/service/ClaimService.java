package service;

import dao.ClaimDAO;
import model.Claim;
import model.Policy;

import java.math.BigDecimal;
import java.util.List;

public class ClaimService {

    private final ClaimDAO claimDAO = new ClaimDAO();
    private final PolicyService policyService = new PolicyService();

    private String lastMessage = "";

    public boolean addClaim(Claim claim) {
        if (!isValidClaim(claim)) {
            lastMessage = "Invalid claim details.";
            return false;
        }

        Policy policy = policyService.getPolicyById(claim.getPolicyId());

        if (policy == null) {
            lastMessage = "Policy not found.";
            return false;
        }

        if (claim.getClaimAmount().compareTo(policy.getCoverageAmount()) > 0) {
            lastMessage = "Claim amount exceeds policy coverage. Claim cannot be registered.";
            return false;
        }

        lastMessage = "Claim added successfully.";
        return claimDAO.addClaim(claim);
    }

    public List<Claim> getAllClaims() {
        return claimDAO.getAllClaims();
    }

    public List<Claim> searchClaims(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return claimDAO.getAllClaims();
        }

        return claimDAO.searchClaims(keyword.trim());
    }

    public boolean approveClaim(int claimId) {
        Claim claim = claimDAO.getClaimById(claimId);

        if (claim == null) {
            lastMessage = "Claim not found.";
            return false;
        }

        Policy policy = policyService.getPolicyById(claim.getPolicyId());

        if (policy == null) {
            lastMessage = "Policy not found for this claim.";
            return false;
        }

        BigDecimal alreadyApproved = claimDAO.getApprovedClaimAmountForPolicy(claim.getPolicyId(), claimId);
        BigDecimal totalAfterApproval = alreadyApproved.add(claim.getClaimAmount());

        if (totalAfterApproval.compareTo(policy.getCoverageAmount()) > 0) {
            BigDecimal remainingCoverage = policy.getCoverageAmount().subtract(alreadyApproved);

            if (remainingCoverage.compareTo(BigDecimal.ZERO) < 0) {
                remainingCoverage = BigDecimal.ZERO;
            }

            lastMessage = "Claim cannot be approved. Remaining coverage is ₹" + remainingCoverage
                    + ", but this claim is ₹" + claim.getClaimAmount() + ".";

            return false;
        }

        lastMessage = "Claim approved successfully.";
        return updateClaimStatus(claimId, "Approved");
    }

    public boolean rejectClaim(int claimId) {
        lastMessage = "Claim rejected successfully.";
        return updateClaimStatus(claimId, "Rejected");
    }

    public boolean markPending(int claimId) {
        lastMessage = "Claim marked as pending.";
        return updateClaimStatus(claimId, "Pending");
    }

    public boolean deleteClaim(int claimId) {
        if (claimId <= 0) {
            lastMessage = "Invalid claim ID.";
            return false;
        }

        lastMessage = "Claim deleted successfully.";
        return claimDAO.deleteClaim(claimId);
    }

    public int getPendingClaims() {
        return claimDAO.getPendingClaims();
    }

    public String getLastMessage() {
        return lastMessage;
    }

    private boolean updateClaimStatus(int claimId, String status) {
        if (claimId <= 0) {
            lastMessage = "Invalid claim ID.";
            return false;
        }

        return claimDAO.updateClaimStatus(claimId, status);
    }

    private boolean isValidClaim(Claim claim) {
        if (claim == null) {
            return false;
        }

        if (claim.getPolicyId() <= 0) {
            return false;
        }

        if (claim.getClaimAmount() == null || claim.getClaimAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        if (claim.getClaimReason() == null || claim.getClaimReason().trim().isEmpty()) {
            return false;
        }

        return claim.getClaimDate() != null;
    }
}