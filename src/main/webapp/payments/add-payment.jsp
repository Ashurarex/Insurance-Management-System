<%@ page import="model.Admin" %>
<%@ page import="model.Policy" %>
<%@ page import="model.Payment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Policy> policies = (List<Policy>) request.getAttribute("policies");
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Monthly Premium Payment | Insurance Management System</title>

    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #f4f6f9; color: #111827; }
        .navbar { min-height: 64px; background: #111827; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 30px; box-sizing: border-box; }
        .navbar h2 { margin: 0; font-size: 21px; }
        .nav-actions { display: flex; gap: 12px; flex-wrap: wrap; }
        .nav-actions a { color: white; text-decoration: none; padding: 9px 14px; border-radius: 8px; font-weight: bold; font-size: 14px; }
        .dashboard-link { background: #2563eb; }
        .logout { background: #dc2626; }
        .container { padding: 35px; max-width: 950px; margin: auto; }
        .card { background: white; padding: 32px; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.06); }
        h1 { margin-top: 0; }
        p { color: #6b7280; line-height: 1.5; }
        .info-box { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e3a8a; padding: 14px; border-radius: 12px; margin: 20px 0; font-size: 14px; line-height: 1.5; }
        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-top: 25px; }
        .form-group.full { grid-column: span 2; }
        label { display: block; margin-bottom: 7px; font-weight: bold; color: #374151; }
        input, select { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 10px; font-size: 15px; box-sizing: border-box; font-family: Arial, sans-serif; }
        input:focus, select:focus { outline: none; border-color: #2563eb; }
        input[readonly] { background: #f3f4f6; color: #111827; font-weight: bold; cursor: not-allowed; }
        .payment-panel { grid-column: span 2; background: #f9fafb; border: 1px solid #e5e7eb; padding: 18px; border-radius: 14px; }
        .payment-panel h3 { margin: 0 0 10px; font-size: 17px; }
        .payment-panel p { margin: 6px 0; font-size: 14px; color: #374151; }
        .payment-panel strong { color: #111827; }
        .actions { margin-top: 25px; display: flex; gap: 12px; }
        button, .btn { border: none; text-decoration: none; padding: 12px 18px; border-radius: 10px; font-weight: bold; cursor: pointer; font-size: 15px; }
        button { background: #2563eb; color: white; }
        button:disabled { background: #9ca3af; cursor: not-allowed; }
        .btn { background: #e5e7eb; color: #111827; }
        .error { background: #fee2e2; color: #991b1b; padding: 12px; border-radius: 10px; margin-bottom: 20px; }
        .warning { background: #fef3c7; color: #92400e; padding: 12px; border-radius: 10px; margin-bottom: 20px; }

        @media (max-width: 700px) {
            .navbar { flex-direction: column; align-items: flex-start; padding: 18px; gap: 14px; }
            .form-grid { grid-template-columns: 1fr; }
            .form-group.full, .payment-panel { grid-column: span 1; }
        }
    </style>

    <script>
        function updatePremiumPayment() {
            const policySelect = document.getElementById("policyId");
            const selectedOption = policySelect.options[policySelect.selectedIndex];

            const amountInput = document.getElementById("amount");
            const monthlyPremiumText = document.getElementById("monthlyPremium");
            const totalPremiumText = document.getElementById("totalPremium");
            const alreadyPaidText = document.getElementById("alreadyPaid");
            const remainingPremiumText = document.getElementById("remainingPremium");
            const nextDueText = document.getElementById("nextPremiumDue");
            const noteText = document.getElementById("paymentNote");
            const saveButton = document.getElementById("saveButton");

            if (!selectedOption || !selectedOption.value) {
                amountInput.value = "";
                monthlyPremiumText.innerText = "₹0.00";
                totalPremiumText.innerText = "₹0.00";
                alreadyPaidText.innerText = "₹0.00";
                remainingPremiumText.innerText = "₹0.00";
                nextDueText.innerText = "₹0.00";
                noteText.innerText = "Select a policy to calculate next monthly premium due.";
                saveButton.disabled = true;
                return;
            }

            const monthlyPremium = parseFloat(selectedOption.getAttribute("data-monthly"));
            const totalPremium = parseFloat(selectedOption.getAttribute("data-total"));
            const alreadyPaid = parseFloat(selectedOption.getAttribute("data-paid"));

            const remainingPremium = Math.max(totalPremium - alreadyPaid, 0);
            const nextDue = Math.min(monthlyPremium, remainingPremium);

            monthlyPremiumText.innerText = "₹" + monthlyPremium.toFixed(2);
            totalPremiumText.innerText = "₹" + totalPremium.toFixed(2);
            alreadyPaidText.innerText = "₹" + alreadyPaid.toFixed(2);
            remainingPremiumText.innerText = "₹" + remainingPremium.toFixed(2);
            nextDueText.innerText = "₹" + nextDue.toFixed(2);

            amountInput.value = nextDue.toFixed(2);

            if (nextDue <= 0) {
                noteText.innerText = "This policy premium is fully paid.";
                saveButton.disabled = true;
            } else {
                noteText.innerText = "System has auto-filled the next monthly premium due.";
                saveButton.disabled = false;
            }
        }

        window.onload = updatePremiumPayment;
    </script>
</head>

<body>

<div class="navbar">
    <h2>Insurance Management System</h2>

    <div class="nav-actions">
        <a class="dashboard-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
        <a class="dashboard-link" href="${pageContext.request.contextPath}/payments?action=list">Payments</a>
        <a class="logout" href="${pageContext.request.contextPath}/logout">Logout</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <h1>Add Monthly Premium Payment</h1>
        <p>Record one monthly premium payment at a time.</p>

        <div class="info-box">
            Formula: <strong>Next Premium Due = min(Monthly Premium, Remaining Premium)</strong>.
        </div>

        <% if (request.getAttribute("error") != null) { %>
        <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (policies == null || policies.isEmpty()) { %>
        <div class="warning">No policies available. Add a policy before recording payment.</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/payments" method="post">
            <input type="hidden" name="action" value="add">

            <div class="form-grid">
                <div class="form-group full">
                    <label>Policy</label>
                    <select id="policyId" name="policyId" onchange="updatePremiumPayment()" required>
                        <option value="">Select Policy</option>

                        <% if (policies != null) {
                            for (Policy policy : policies) {
                                BigDecimal paidAmount = BigDecimal.ZERO;

                                if (payments != null) {
                                    for (Payment payment : payments) {
                                        if (payment.getPolicyId() == policy.getPolicyId()
                                                && "Paid".equalsIgnoreCase(payment.getStatus())
                                                && payment.getAmount() != null) {
                                            paidAmount = paidAmount.add(payment.getAmount());
                                        }
                                    }
                                }

                                BigDecimal monthlyPremium = policy.getMonthlyPremium() != null ? policy.getMonthlyPremium() : BigDecimal.ZERO;
                                BigDecimal totalPremium = policy.getPremiumAmount() != null ? policy.getPremiumAmount() : BigDecimal.ZERO;
                        %>

                        <option value="<%= policy.getPolicyId() %>"
                                data-monthly="<%= monthlyPremium %>"
                                data-total="<%= totalPremium %>"
                                data-paid="<%= paidAmount %>">
                            <%= policy.getPolicyName() %> - <%= policy.getCustomerName() %>
                        </option>

                        <%  }
                        } %>
                    </select>
                </div>

                <div class="payment-panel">
                    <h3>Monthly Premium Calculation</h3>
                    <p><strong>Monthly Premium:</strong> <span id="monthlyPremium">₹0.00</span></p>
                    <p><strong>Total Premium:</strong> <span id="totalPremium">₹0.00</span></p>
                    <p><strong>Premium Paid:</strong> <span id="alreadyPaid">₹0.00</span></p>
                    <p><strong>Remaining Premium:</strong> <span id="remainingPremium">₹0.00</span></p>
                    <p><strong>Next Premium Due:</strong> <span id="nextPremiumDue">₹0.00</span></p>
                    <p id="paymentNote">Select a policy to calculate next monthly premium due.</p>
                </div>

                <div class="form-group">
                    <label>Auto Calculated Monthly Premium</label>
                    <input id="amount" type="number" step="0.01" name="amount" readonly required>
                </div>

                <div class="form-group">
                    <label>Payment Date</label>
                    <input type="date" name="paymentDate" required>
                </div>

                <div class="form-group">
                    <label>Payment Mode</label>
                    <select name="paymentMode" required>
                        <option value="">Select Mode</option>
                        <option value="Cash">Cash</option>
                        <option value="Card">Card</option>
                        <option value="UPI">UPI</option>
                        <option value="Net Banking">Net Banking</option>
                        <option value="Cheque">Cheque</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <select name="status" required>
                        <option value="Paid">Paid</option>
                        <option value="Pending">Pending</option>
                        <option value="Failed">Failed</option>
                        <option value="Refunded">Refunded</option>
                    </select>
                </div>
            </div>

            <div class="actions">
                <button id="saveButton" type="submit" disabled>Save Monthly Premium Payment</button>
                <a class="btn" href="${pageContext.request.contextPath}/payments?action=list">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>