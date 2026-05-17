package servlet;

import model.Customer;
import model.Policy;
import service.CustomerService;
import service.PolicyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet("/policies")
public class PolicyServlet extends HttpServlet {

    private final PolicyService policyService = new PolicyService();
    private final CustomerService customerService = new CustomerService();

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

            case "edit-form":
                showEditForm(request, response);
                break;

            case "delete":
                deletePolicy(request, response);
                break;

            case "search":
                searchPolicies(request, response);
                break;

            case "list":
            default:
                listPolicies(request, response);
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
            addPolicy(request, response);
        } else if ("update".equals(action)) {
            updatePolicy(request, response);
        } else {
            response.sendRedirect("policies?action=list");
        }
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Customer> customers = customerService.getAllCustomers();
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("policies/add-policy.jsp").forward(request, response);
    }

    private void listPolicies(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Policy> policies = policyService.getAllPolicies();
        request.setAttribute("policies", policies);
        request.getRequestDispatcher("policies/view-policies.jsp").forward(request, response);
    }

    private void searchPolicies(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<Policy> policies = policyService.searchPolicies(keyword);

        request.setAttribute("policies", policies);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("policies/view-policies.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int policyId = parseInt(request.getParameter("id"));
        Policy policy = policyService.getPolicyById(policyId);

        if (policy == null) {
            response.sendRedirect("policies?action=list&error=notfound");
            return;
        }

        List<Customer> customers = customerService.getAllCustomers();
        request.setAttribute("policy", policy);
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("policies/edit-policy.jsp").forward(request, response);
    }

    private void addPolicy(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Policy policy = buildPolicyFromRequest(request);
        boolean success = policyService.addPolicy(policy);

        if (success) {
            response.sendRedirect("policies?action=list&success=added");
        } else {
            List<Customer> customers = customerService.getAllCustomers();
            request.setAttribute("customers", customers);
            request.setAttribute("error", "Unable to add policy. Check customer, insurance type, asset value, and dates.");
            request.getRequestDispatcher("policies/add-policy.jsp").forward(request, response);
        }
    }

    private void updatePolicy(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int policyId = parseInt(request.getParameter("policyId"));
        Policy policy = buildPolicyFromRequest(request);
        policy.setPolicyId(policyId);

        boolean success = policyService.updatePolicy(policy);

        if (success) {
            response.sendRedirect("policies?action=list&success=updated");
        } else {
            List<Customer> customers = customerService.getAllCustomers();
            request.setAttribute("customers", customers);
            request.setAttribute("policy", policy);
            request.setAttribute("error", "Unable to update policy. Check customer, insurance type, asset value, and dates.");
            request.getRequestDispatcher("policies/edit-policy.jsp").forward(request, response);
        }
    }

    private void deletePolicy(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int policyId = parseInt(request.getParameter("id"));
        policyService.deletePolicy(policyId);
        response.sendRedirect("policies?action=list&success=deleted");
    }

    private Policy buildPolicyFromRequest(HttpServletRequest request) {
        int customerId = parseInt(request.getParameter("customerId"));
        String policyName = request.getParameter("policyName");
        String policyType = request.getParameter("policyType");
        String assetValueText = request.getParameter("assetValue");
        String startDateText = request.getParameter("startDate");
        String endDateText = request.getParameter("endDate");
        String status = request.getParameter("status");

        BigDecimal assetValue = parseBigDecimal(assetValueText);

        Date startDate = null;
        Date endDate = null;

        if (startDateText != null && !startDateText.trim().isEmpty()) {
            startDate = Date.valueOf(startDateText);
        }

        if (endDateText != null && !endDateText.trim().isEmpty()) {
            endDate = Date.valueOf(endDateText);
        }

        return new Policy(
                customerId,
                policyName != null ? policyName.trim() : "",
                policyType != null ? policyType.trim() : "",
                assetValue,
                BigDecimal.ZERO,
                BigDecimal.ZERO,
                BigDecimal.ZERO,
                startDate,
                endDate,
                0,
                status != null && !status.trim().isEmpty() ? status.trim() : "Active",
                ""
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