<%@ page import="model.Admin" %>
<%@ page import="model.Policy" %>
<%@ page import="model.Claim" %>
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
    List<Claim> claims = (List<Claim>) request.getAttribute("claims");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Claim | Insurance Management System</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6f9;
            color: #111827;
        }

        .navbar {
            min-height: 64px;
            background: #111827;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 30px;
            box-sizing: border-box;
        }

        .navbar h2 {
            margin: 0;
            font-size: 21px;
        }

        .nav-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .nav-actions a {
            color: white;
            text-decoration: none;
            padding: 9px 14px;
            border-radius: 8px;
            font-weight: bold;
            font-size: 14px;
        }

        .dashboard-link {
            background: #2563eb;
        }

        .logout {
            background: #dc2626;
        }

        .container {
            padding: 35px;
            max-width: 950px;
            margin: auto;
        }

        .card {
            background: white;
            padding: 32px;
            border-radius: 16px;
            box-shadow: 0 10px 28px rgba(0,0,0,0.06);
        }

        h1 {
            margin-top: 0;
        }

        p {
            color: #6b7280;
            line-height: 1.5;
        }

        .info-box {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            color: #1e3a8a;
            padding: 14px;
            border-radius: 12px;
            margin: 20px 0;
            font-size: 14px;
            line-height: 1.5;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-top: 25px;
        }

        .form-group.full {
            grid-column: span 2;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-weight: bold;
            color: #374151;
        }

        input, select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            font-size: 15px;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #2563eb;
        }

        input[readonly] {
            background: #f3f4f6;
            color: #111827;
            font-weight: bold;
            cursor: not-allowed;
        }

        textarea {
            min-height: 100px;
            resize: vertical;
        }

        .claim-panel {
            grid-column: span 2;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            padding: 18px;
            border-radius: 14px;
        }

        .claim-panel h3 {
            margin: 0 0 10px;
            font-size: 17px;
        }

        .claim-panel p {
            margin: 6px 0;
            font-size: 14px;
            color: #374151;
        }

        .claim-panel strong {
            color: #111827;
        }

        .actions {
            margin-top: 25px;
            display: flex;
            gap: 12px;
        }

        button, .btn {
            border: none;
            text-decoration: none;
            padding: 12px 18px;
            border-radius: 10px;
            font-weight: bold;
            cursor: pointer;
            font-size: 15px;
        }

        button {
            background: #2563eb;
            color: white;
        }

        button:disabled {
            background: #9ca3af;
            cursor: not-allowed;
        }

        .btn {
            background: #e5e7eb;
            color: #111827;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        .warning {
            background: #fef3c7;
            color: #92400e;
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        @media (max-width: 700px) {
            .navbar {
                flex-direction: column;
                align-items: flex-start;
                padding: 18px;
                gap: 14px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-group.full,
            .claim-panel {
                grid-column: span 1;
            }
        }
    </style>

    <script>
        function updateEligibleClaim() {
            const policySelect = document.getElementById("policyId");
            const selectedOption = policySelect.options[policySelect.selectedIndex];

            const claimInput = document.getElementById("claimAmount");
            const coverageText = document.getElementById("coverageAmount");
            const approvedText = document.getElementById("approvedClaimAmount");
            const eligibleText = document.getElementById("eligibleClaimAmount");
            const noteText = document.getElementById("claimNote");
            const saveButton = document.getElementById("saveButton");

            if (!selectedOption || !selectedOption.value) {
                claimInput.value = "";
                coverageText.innerText = "₹0.00";
                approvedText.innerText = "₹0.00";
                eligibleText.innerText = "₹0.00";
                noteText.innerText = "Select a policy to calculate the eligible claim amount.";
                saveButton.disabled = true;
                return;
            }

            const coverage = parseFloat(selectedOption.getAttribute("data-coverage"));
            const approved = parseFloat(selectedOption.getAttribute("data-approved"));
            const eligible = Math.max(coverage - approved, 0);

            coverageText.innerText = "₹" + coverage.toFixed(2);
            approvedText.innerText = "₹" + approved.toFixed(2);
            eligibleText.innerText = "₹" + eligible.toFixed(2);

            claimInput.value = eligible.toFixed(2);

            if (eligible <= 0) {
                noteText.innerText = "No claimable coverage is remaining for this policy.";
                saveButton.disabled = true;
            } else {
                noteText.innerText = "System has auto-filled the maximum eligible claim amount based on remaining coverage.";
                saveButton.disabled = false;
            }
        }

        window.onload = updateEligibleClaim;
    </script>
</head>

<body>

<div class="navbar">
    <h2>Insurance Management System</h2>

    <div class="nav-actions">
        <a class="dashboard-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
        <a class="dashboard-link" href="${pageContext.request.contextPath}/claims?action=list">Claims</a>
        <a class="logout" href="${pageContext.request.contextPath}/logout">Logout</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <h1>Add Claim</h1>
        <p>Register a claim using automatic eligible claim calculation based on remaining policy coverage.</p>

        <div class="info-box">
            Claim amount is calculated automatically:
            <strong>Recommended Coverage - Already Approved Claims = Eligible Claim Amount</strong>.
        </div>

        <% if (request.getAttribute("error") != null) { %>
        <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (policies == null || policies.isEmpty()) { %>
        <div class="warning">
            No policies available. Add a policy before registering a claim.
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/claims" method="post">
            <input type="hidden" name="action" value="add">

            <div class="form-grid">
                <div class="form-group full">
                    <label>Policy</label>
                    <select id="policyId" name="policyId" onchange="updateEligibleClaim()" required>
                        <option value="">Select Policy</option>

                        <% if (policies != null) {
                            for (Policy policy : policies) {
                                BigDecimal approvedAmount = BigDecimal.ZERO;

                                if (claims != null) {
                                    for (Claim claim : claims) {
                                        if (claim.getPolicyId() == policy.getPolicyId()
                                                && "Approved".equalsIgnoreCase(claim.getStatus())
                                                && claim.getClaimAmount() != null) {
                                            approvedAmount = approvedAmount.add(claim.getClaimAmount());
                                        }
                                    }
                                }

                                BigDecimal coverageAmount = policy.getCoverageAmount() != null
                                        ? policy.getCoverageAmount()
                                        : BigDecimal.ZERO;
                        %>

                        <option value="<%= policy.getPolicyId() %>"
                                data-coverage="<%= coverageAmount %>"
                                data-approved="<%= approvedAmount %>">
                            <%= policy.getPolicyName() %> - <%= policy.getCustomerName() %>
                        </option>

                        <%  }
                        } %>
                    </select>
                </div>

                <div class="claim-panel">
                    <h3>Claim Eligibility Calculation</h3>
                    <p><strong>Recommended Policy Coverage:</strong> <span id="coverageAmount">₹0.00</span></p>
                    <p><strong>Already Approved Claims:</strong> <span id="approvedClaimAmount">₹0.00</span></p>
                    <p><strong>Eligible Claim Amount:</strong> <span id="eligibleClaimAmount">₹0.00</span></p>
                    <p id="claimNote">Select a policy to calculate the eligible claim amount.</p>
                </div>

                <div class="form-group">
                    <label>Auto Calculated Claim Amount</label>
                    <input id="claimAmount" type="number" step="0.01" name="claimAmount" readonly required>
                </div>

                <div class="form-group">
                    <label>Claim Date</label>
                    <input type="date" name="claimDate" required>
                </div>

                <div class="form-group full">
                    <label>Claim Reason</label>
                    <textarea name="claimReason" placeholder="Enter claim reason" required></textarea>
                </div>
            </div>

            <div class="actions">
                <button id="saveButton" type="submit" disabled>Save Auto Calculated Claim</button>
                <a class="btn" href="${pageContext.request.contextPath}/claims?action=list">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>