package service;

import dao.PolicyDAO;
import model.Policy;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.List;

public class PolicyService {

    private final PolicyDAO policyDAO = new PolicyDAO();

    public boolean addPolicy(Policy policy) {
        if (!isValidPolicyBase(policy)) {
            return false;
        }

        applyRecommendation(policy);
        return policyDAO.addPolicy(policy);
    }

    public List<Policy> getAllPolicies() {
        return policyDAO.getAllPolicies();
    }

    public Policy getPolicyById(int policyId) {
        if (policyId <= 0) {
            return null;
        }

        return policyDAO.getPolicyById(policyId);
    }

    public boolean updatePolicy(Policy policy) {
        if (policy.getPolicyId() <= 0 || !isValidPolicyBase(policy)) {
            return false;
        }

        applyRecommendation(policy);
        return policyDAO.updatePolicy(policy);
    }

    public boolean deletePolicy(int policyId) {
        if (policyId <= 0) {
            return false;
        }

        return policyDAO.deletePolicy(policyId);
    }

    public List<Policy> searchPolicies(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return policyDAO.getAllPolicies();
        }

        return policyDAO.searchPolicies(keyword.trim());
    }

    public int getTotalPolicies() {
        return policyDAO.getTotalPolicies();
    }

    public int getActivePolicies() {
        return policyDAO.getActivePolicies();
    }

    private boolean isValidPolicyBase(Policy policy) {
        if (policy == null) {
            return false;
        }

        if (policy.getCustomerId() <= 0) {
            return false;
        }

        if (policy.getPolicyName() == null || policy.getPolicyName().trim().isEmpty()) {
            return false;
        }

        if (policy.getPolicyType() == null || policy.getPolicyType().trim().isEmpty()) {
            return false;
        }

        if (policy.getAssetValue() == null || policy.getAssetValue().compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        if (policy.getStartDate() == null || policy.getEndDate() == null) {
            return false;
        }

        return !policy.getEndDate().before(policy.getStartDate());
    }

    private void applyRecommendation(Policy policy) {
        BigDecimal assetValue = policy.getAssetValue();
        String type = policy.getPolicyType();

        BigDecimal coverageMultiplier;
        BigDecimal annualPremiumRate;
        String note;

        switch (type) {
            case "Vehicle":
                coverageMultiplier = new BigDecimal("0.90");
                annualPremiumRate = new BigDecimal("0.035");
                note = "Vehicle insurance: coverage is 90% of vehicle value. Annual premium is 3.5% of coverage. Monthly premium is annual premium divided by 12.";
                break;

            case "Property":
                coverageMultiplier = new BigDecimal("1.00");
                annualPremiumRate = new BigDecimal("0.0025");
                note = "Property insurance: coverage is full property value. Annual premium is 0.25% of coverage. Monthly premium is annual premium divided by 12.";
                break;

            case "Health":
                coverageMultiplier = new BigDecimal("1.00");
                annualPremiumRate = new BigDecimal("0.045");
                note = "Health insurance: coverage is selected medical cover value. Annual premium is 4.5% of coverage. Monthly premium is annual premium divided by 12.";
                break;

            case "Life":
                coverageMultiplier = new BigDecimal("1.00");
                annualPremiumRate = new BigDecimal("0.025");
                note = "Life insurance: coverage is selected insured value. Annual premium is 2.5% of coverage. Monthly premium is annual premium divided by 12.";
                break;

            case "Travel":
                coverageMultiplier = new BigDecimal("0.60");
                annualPremiumRate = new BigDecimal("0.020");
                note = "Travel insurance: coverage is 60% of declared trip value. Annual premium is 2% of coverage. Monthly premium is annual premium divided by 12.";
                break;

            default:
                coverageMultiplier = new BigDecimal("0.80");
                annualPremiumRate = new BigDecimal("0.030");
                note = "General insurance: coverage is 80% of declared value. Annual premium is 3% of coverage. Monthly premium is annual premium divided by 12.";
                break;
        }

        int durationMonths = calculateDurationMonths(policy.getStartDate(), policy.getEndDate());

        BigDecimal coverageAmount = assetValue
                .multiply(coverageMultiplier)
                .setScale(2, RoundingMode.HALF_UP);

        BigDecimal annualPremium = coverageAmount
                .multiply(annualPremiumRate)
                .setScale(2, RoundingMode.HALF_UP);

        BigDecimal monthlyPremium = annualPremium
                .divide(new BigDecimal("12"), 2, RoundingMode.HALF_UP);

        BigDecimal totalPremium = monthlyPremium
                .multiply(new BigDecimal(durationMonths))
                .setScale(2, RoundingMode.HALF_UP);

        policy.setCoverageAmount(coverageAmount);
        policy.setMonthlyPremium(monthlyPremium);
        policy.setPremiumAmount(totalPremium);
        policy.setDurationMonths(durationMonths);
        policy.setRecommendationNote(note + " Duration: " + durationMonths + " month(s).");
    }

    private int calculateDurationMonths(Date startDate, Date endDate) {
        LocalDate start = startDate.toLocalDate();
        LocalDate end = endDate.toLocalDate();

        YearMonth startMonth = YearMonth.from(start);
        YearMonth endMonth = YearMonth.from(end);

        long months = ChronoUnit.MONTHS.between(startMonth, endMonth) + 1;

        return Math.max(1, (int) months);
    }
}