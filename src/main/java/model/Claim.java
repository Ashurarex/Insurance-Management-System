package model;

import java.math.BigDecimal;
import java.sql.Date;

public class Claim {

    private int claimId;
    private int policyId;
    private String policyName;
    private String customerName;
    private BigDecimal claimAmount;
    private String claimReason;
    private Date claimDate;
    private String status;

    public Claim() {
    }

    public Claim(int claimId, int policyId, String policyName, String customerName,
                 BigDecimal claimAmount, String claimReason, Date claimDate, String status) {
        this.claimId = claimId;
        this.policyId = policyId;
        this.policyName = policyName;
        this.customerName = customerName;
        this.claimAmount = claimAmount;
        this.claimReason = claimReason;
        this.claimDate = claimDate;
        this.status = status;
    }

    public Claim(int policyId, BigDecimal claimAmount, String claimReason, Date claimDate, String status) {
        this.policyId = policyId;
        this.claimAmount = claimAmount;
        this.claimReason = claimReason;
        this.claimDate = claimDate;
        this.status = status;
    }

    public int getClaimId() {
        return claimId;
    }

    public void setClaimId(int claimId) {
        this.claimId = claimId;
    }

    public int getPolicyId() {
        return policyId;
    }

    public void setPolicyId(int policyId) {
        this.policyId = policyId;
    }

    public String getPolicyName() {
        return policyName;
    }

    public void setPolicyName(String policyName) {
        this.policyName = policyName;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public BigDecimal getClaimAmount() {
        return claimAmount;
    }

    public void setClaimAmount(BigDecimal claimAmount) {
        this.claimAmount = claimAmount;
    }

    public String getClaimReason() {
        return claimReason;
    }

    public void setClaimReason(String claimReason) {
        this.claimReason = claimReason;
    }

    public Date getClaimDate() {
        return claimDate;
    }

    public void setClaimDate(Date claimDate) {
        this.claimDate = claimDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}