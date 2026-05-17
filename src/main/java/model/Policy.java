package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Policy {

    private int policyId;
    private int customerId;
    private String customerName;
    private String policyName;
    private String policyType;
    private BigDecimal assetValue;
    private BigDecimal premiumAmount;     // Total premium for full policy duration
    private BigDecimal monthlyPremium;    // Monthly premium
    private BigDecimal coverageAmount;
    private Date startDate;
    private Date endDate;
    private int durationMonths;
    private String status;
    private String recommendationNote;
    private Timestamp createdAt;

    public Policy() {
    }

    public Policy(int policyId, int customerId, String customerName, String policyName,
                  String policyType, BigDecimal assetValue, BigDecimal premiumAmount,
                  BigDecimal monthlyPremium, BigDecimal coverageAmount,
                  Date startDate, Date endDate, int durationMonths,
                  String status, String recommendationNote, Timestamp createdAt) {
        this.policyId = policyId;
        this.customerId = customerId;
        this.customerName = customerName;
        this.policyName = policyName;
        this.policyType = policyType;
        this.assetValue = assetValue;
        this.premiumAmount = premiumAmount;
        this.monthlyPremium = monthlyPremium;
        this.coverageAmount = coverageAmount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.durationMonths = durationMonths;
        this.status = status;
        this.recommendationNote = recommendationNote;
        this.createdAt = createdAt;
    }

    public Policy(int customerId, String policyName, String policyType,
                  BigDecimal assetValue, BigDecimal premiumAmount,
                  BigDecimal monthlyPremium, BigDecimal coverageAmount,
                  Date startDate, Date endDate, int durationMonths,
                  String status, String recommendationNote) {
        this.customerId = customerId;
        this.policyName = policyName;
        this.policyType = policyType;
        this.assetValue = assetValue;
        this.premiumAmount = premiumAmount;
        this.monthlyPremium = monthlyPremium;
        this.coverageAmount = coverageAmount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.durationMonths = durationMonths;
        this.status = status;
        this.recommendationNote = recommendationNote;
    }

    public int getPolicyId() {
        return policyId;
    }

    public void setPolicyId(int policyId) {
        this.policyId = policyId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getPolicyName() {
        return policyName;
    }

    public void setPolicyName(String policyName) {
        this.policyName = policyName;
    }

    public String getPolicyType() {
        return policyType;
    }

    public void setPolicyType(String policyType) {
        this.policyType = policyType;
    }

    public BigDecimal getAssetValue() {
        return assetValue;
    }

    public void setAssetValue(BigDecimal assetValue) {
        this.assetValue = assetValue;
    }

    public BigDecimal getPremiumAmount() {
        return premiumAmount;
    }

    public void setPremiumAmount(BigDecimal premiumAmount) {
        this.premiumAmount = premiumAmount;
    }

    public BigDecimal getMonthlyPremium() {
        return monthlyPremium;
    }

    public void setMonthlyPremium(BigDecimal monthlyPremium) {
        this.monthlyPremium = monthlyPremium;
    }

    public BigDecimal getCoverageAmount() {
        return coverageAmount;
    }

    public void setCoverageAmount(BigDecimal coverageAmount) {
        this.coverageAmount = coverageAmount;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public int getDurationMonths() {
        return durationMonths;
    }

    public void setDurationMonths(int durationMonths) {
        this.durationMonths = durationMonths;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRecommendationNote() {
        return recommendationNote;
    }

    public void setRecommendationNote(String recommendationNote) {
        this.recommendationNote = recommendationNote;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}