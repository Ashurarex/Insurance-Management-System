package model;

import java.math.BigDecimal;
import java.sql.Date;

public class Payment {

    private int paymentId;
    private int policyId;
    private String policyName;
    private String customerName;
    private BigDecimal amount;
    private Date paymentDate;
    private String paymentMode;
    private String status;

    public Payment() {
    }

    public Payment(int paymentId, int policyId, String policyName, String customerName,
                   BigDecimal amount, Date paymentDate, String paymentMode, String status) {
        this.paymentId = paymentId;
        this.policyId = policyId;
        this.policyName = policyName;
        this.customerName = customerName;
        this.amount = amount;
        this.paymentDate = paymentDate;
        this.paymentMode = paymentMode;
        this.status = status;
    }

    public Payment(int policyId, BigDecimal amount, Date paymentDate, String paymentMode, String status) {
        this.policyId = policyId;
        this.amount = amount;
        this.paymentDate = paymentDate;
        this.paymentMode = paymentMode;
        this.status = status;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
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

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public Date getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Date paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getPaymentMode() {
        return paymentMode;
    }

    public void setPaymentMode(String paymentMode) {
        this.paymentMode = paymentMode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}