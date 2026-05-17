package servlet;

import model.Payment;
import model.Policy;
import service.PaymentService;
import service.PolicyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();
    private final PolicyService policyService = new PolicyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add-form":
                showAddForm(request, response);
                break;

            case "delete":
                deletePayment(request, response);
                break;

            case "search":
                searchPayments(request, response);
                break;

            case "list":
            default:
                listPayments(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addPayment(request, response);
        } else {
            response.sendRedirect("payments?action=list");
        }
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Policy> policies = policyService.getAllPolicies();
        List<Payment> payments = paymentService.getAllPayments();

        request.setAttribute("policies", policies);
        request.setAttribute("payments", payments);

        request.getRequestDispatcher("payments/add-payment.jsp").forward(request, response);
    }

    private void listPayments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Payment> payments = paymentService.getAllPayments();
        request.setAttribute("payments", payments);
        request.getRequestDispatcher("payments/view-payments.jsp").forward(request, response);
    }

    private void searchPayments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<Payment> payments = paymentService.searchPayments(keyword);

        request.setAttribute("payments", payments);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("payments/view-payments.jsp").forward(request, response);
    }

    private void addPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Payment payment = buildPaymentFromRequest(request);
        boolean success = paymentService.addPayment(payment);

        if (success) {
            response.sendRedirect("payments?action=list&success=added");
        } else {
            List<Policy> policies = policyService.getAllPolicies();
            List<Payment> payments = paymentService.getAllPayments();

            request.setAttribute("policies", policies);
            request.setAttribute("payments", payments);
            request.setAttribute("error", paymentService.getLastMessage());

            request.getRequestDispatcher("payments/add-payment.jsp").forward(request, response);
        }
    }

    private void deletePayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int paymentId = parseInt(request.getParameter("id"));
        paymentService.deletePayment(paymentId);
        response.sendRedirect("payments?action=list&success=deleted");
    }

    private Payment buildPaymentFromRequest(HttpServletRequest request) {
        int policyId = parseInt(request.getParameter("policyId"));
        BigDecimal amount = parseBigDecimal(request.getParameter("amount"));
        String paymentDateText = request.getParameter("paymentDate");
        String paymentMode = request.getParameter("paymentMode");
        String status = request.getParameter("status");

        Date paymentDate = null;

        if (paymentDateText != null && !paymentDateText.trim().isEmpty()) {
            paymentDate = Date.valueOf(paymentDateText);
        }

        return new Payment(
                policyId,
                amount,
                paymentDate,
                paymentMode != null ? paymentMode.trim() : "",
                status != null && !status.trim().isEmpty() ? status.trim() : "Paid"
        );
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        try {
            return new BigDecimal(value);
        } catch (Exception e) {
            return null;
        }
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("admin") != null;
    }
}