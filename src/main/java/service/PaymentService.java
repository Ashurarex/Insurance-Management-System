package service;

import dao.PaymentDAO;
import model.Payment;
import model.Policy;

import java.math.BigDecimal;
import java.util.List;

public class PaymentService {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final PolicyService policyService = new PolicyService();

    private String lastMessage = "";

    public boolean addPayment(Payment payment) {
        if (!isValidPayment(payment)) {
            lastMessage = "Invalid payment details.";
            return false;
        }

        Policy policy = policyService.getPolicyById(payment.getPolicyId());

        if (policy == null) {
            lastMessage = "Policy not found.";
            return false;
        }

        BigDecimal alreadyPaid = getPaidAmountForPolicy(payment.getPolicyId());
        BigDecimal totalPremium = policy.getPremiumAmount() != null ? policy.getPremiumAmount() : BigDecimal.ZERO;
        BigDecimal monthlyPremium = policy.getMonthlyPremium() != null ? policy.getMonthlyPremium() : BigDecimal.ZERO;

        BigDecimal remainingPremium = totalPremium.subtract(alreadyPaid);

        if (remainingPremium.compareTo(BigDecimal.ZERO) <= 0) {
            lastMessage = "This policy premium is already fully paid.";
            return false;
        }

        BigDecimal expectedPayment = monthlyPremium.min(remainingPremium);

        if (payment.getAmount().compareTo(expectedPayment) != 0) {
            lastMessage = "Invalid payment amount. Next premium due is ₹" + expectedPayment + ".";
            return false;
        }

        lastMessage = "Premium payment recorded successfully.";
        return paymentDAO.addPayment(payment);
    }

    public List<Payment> getAllPayments() {
        return paymentDAO.getAllPayments();
    }

    public List<Payment> searchPayments(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return paymentDAO.getAllPayments();
        }

        return paymentDAO.searchPayments(keyword.trim());
    }

    public boolean deletePayment(int paymentId) {
        if (paymentId <= 0) {
            lastMessage = "Invalid payment ID.";
            return false;
        }

        lastMessage = "Payment deleted successfully.";
        return paymentDAO.deletePayment(paymentId);
    }

    public int getTotalPayments() {
        return paymentDAO.getTotalPayments();
    }

    public BigDecimal getTotalPaymentAmount() {
        return paymentDAO.getTotalPaymentAmount();
    }

    public String getLastMessage() {
        return lastMessage;
    }

    private BigDecimal getPaidAmountForPolicy(int policyId) {
        BigDecimal paidAmount = BigDecimal.ZERO;

        List<Payment> payments = paymentDAO.getAllPayments();

        for (Payment payment : payments) {
            if (payment.getPolicyId() == policyId
                    && "Paid".equalsIgnoreCase(payment.getStatus())
                    && payment.getAmount() != null) {
                paidAmount = paidAmount.add(payment.getAmount());
            }
        }

        return paidAmount;
    }

    private boolean isValidPayment(Payment payment) {
        if (payment == null) {
            return false;
        }

        if (payment.getPolicyId() <= 0) {
            return false;
        }

        if (payment.getAmount() == null || payment.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        if (payment.getPaymentDate() == null) {
            return false;
        }

        return payment.getStatus() != null && !payment.getStatus().trim().isEmpty();
    }
}