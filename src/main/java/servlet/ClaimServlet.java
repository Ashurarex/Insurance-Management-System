package servlet;

import model.Claim;
import model.Policy;
import service.ClaimService;
import service.PolicyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/claims")
public class ClaimServlet extends HttpServlet {

    private final ClaimService claimService = new ClaimService();
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

            case "approve":
                approveClaim(request, response);
                break;

            case "reject":
                rejectClaim(request, response);
                break;

            case "pending":
                markPending(request, response);
                break;

            case "delete":
                deleteClaim(request, response);
                break;

            case "search":
                searchClaims(request, response);
                break;

            case "list":
            default:
                listClaims(request, response);
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
            addClaim(request, response);
        } else {
            response.sendRedirect("claims?action=list");
        }
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Policy> policies = policyService.getAllPolicies();
        List<Claim> claims = claimService.getAllClaims();

        request.setAttribute("policies", policies);
        request.setAttribute("claims", claims);

        request.getRequestDispatcher("claims/add-claim.jsp").forward(request, response);
    }

    private void listClaims(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Claim> claims = claimService.getAllClaims();
        request.setAttribute("claims", claims);
        request.getRequestDispatcher("claims/view-claims.jsp").forward(request, response);
    }

    private void searchClaims(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<Claim> claims = claimService.searchClaims(keyword);

        request.setAttribute("claims", claims);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("claims/view-claims.jsp").forward(request, response);
    }

    private void addClaim(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Claim claim = buildClaimFromRequest(request);
        boolean success = claimService.addClaim(claim);

        if (success) {
            response.sendRedirect("claims?action=list&message=" + encode(claimService.getLastMessage()));
        } else {
            List<Policy> policies = policyService.getAllPolicies();
            List<Claim> claims = claimService.getAllClaims();

            request.setAttribute("policies", policies);
            request.setAttribute("claims", claims);
            request.setAttribute("error", claimService.getLastMessage());

            request.getRequestDispatcher("claims/add-claim.jsp").forward(request, response);
        }
    }

    private void approveClaim(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int claimId = parseInt(request.getParameter("id"));
        claimService.approveClaim(claimId);
        response.sendRedirect("claims?action=list&message=" + encode(claimService.getLastMessage()));
    }

    private void rejectClaim(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int claimId = parseInt(request.getParameter("id"));
        claimService.rejectClaim(claimId);
        response.sendRedirect("claims?action=list&message=" + encode(claimService.getLastMessage()));
    }

    private void markPending(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int claimId = parseInt(request.getParameter("id"));
        claimService.markPending(claimId);
        response.sendRedirect("claims?action=list&message=" + encode(claimService.getLastMessage()));
    }

    private void deleteClaim(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int claimId = parseInt(request.getParameter("id"));
        claimService.deleteClaim(claimId);
        response.sendRedirect("claims?action=list&message=" + encode(claimService.getLastMessage()));
    }

    private Claim buildClaimFromRequest(HttpServletRequest request) {
        int policyId = parseInt(request.getParameter("policyId"));
        BigDecimal claimAmount = parseBigDecimal(request.getParameter("claimAmount"));
        String claimReason = request.getParameter("claimReason");
        String claimDateText = request.getParameter("claimDate");

        Date claimDate = null;

        if (claimDateText != null && !claimDateText.trim().isEmpty()) {
            claimDate = Date.valueOf(claimDateText);
        }

        return new Claim(
                policyId,
                claimAmount,
                claimReason != null ? claimReason.trim() : "",
                claimDate,
                "Pending"
        );
    }

    private String encode(String value) {
        if (value == null) {
            return "";
        }

        return URLEncoder.encode(value, StandardCharsets.UTF_8);
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