<%@ page import="model.Policy" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Admin" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Policy policy = (Policy) request.getAttribute("policy");
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");

    if (policy == null) {
        response.sendRedirect(request.getContextPath() + "/policies?action=list&error=notfound");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Policy | Insurance Management System</title>

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

        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-top: 25px; }
        .form-group.full { grid-column: span 2; }
        label { display: block; margin-bottom: 7px; font-weight: bold; color: #374151; }
        input, select { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 10px; font-size: 15px; box-sizing: border-box; }
        input:focus, select:focus { outline: none; border-color: #2563eb; }

        .recommendation-panel {
            grid-column: span 2;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            padding: 18px;
            border-radius: 14px;
        }

        .recommendation-panel h3 {
            margin: 0 0 10px;
            font-size: 17px;
        }

        .recommendation-panel p {
            margin: 6px 0;
            font-size: 14px;
        }

        .actions { margin-top: 25px; display: flex; gap: 12px; }
        button, .btn { border: none; text-decoration: none; padding: 12px 18px; border-radius: 10px; font-weight: bold; cursor: pointer; font-size: 15px; }
        button { background: #2563eb; color: white; }
        .btn { background: #e5e7eb; color: #111827; }

        .error { background: #fee2e2; color: #991b1b; padding: 12px; border-radius: 10px; margin-bottom: 20px; }

        @media (max-width: 700px) {
            .navbar { flex-direction: column; align-items: flex-start; padding: 18px; gap: 14px; }
            .form-grid { grid-template-columns: 1fr; }
            .form-group.full, .recommendation-panel { grid-column: span 1; }
        }
    </style>

    <script>
        function updateRecommendation() {
            const type = document.getElementById("policyType").value;
            const assetValueInput = document.getElementById("assetValue").value;
            const assetValue = parseFloat(assetValueInput);

            const coverageOutput = document.getElementById("recommendedCoverage");
            const premiumOutput = document.getElementById("recommendedPremium");
            const noteOutput = document.getElementById("recommendationNote");

            if (!type || isNaN(assetValue) || assetValue <= 0) {
                coverageOutput.innerText = "₹0.00";
                premiumOutput.innerText = "₹0.00";
                noteOutput.innerText = "Select insurance type and enter asset value to calculate recommendation.";
                return;
            }

            let coverageMultiplier;
            let premiumRate;
            let note;

            switch (type) {
                case "Vehicle":
                    coverageMultiplier = 0.90;
                    premiumRate = 0.035;
                    note = "Vehicle insurance: coverage is 90% of vehicle value; premium is 3.5% of coverage.";
                    break;
                case "Property":
                    coverageMultiplier = 1.00;
                    premiumRate = 0.0025;
                    note = "Property insurance: coverage is full property value; premium is 0.25% of coverage.";
                    break;
                case "Health":
                    coverageMultiplier = 1.00;
                    premiumRate = 0.045;
                    note = "Health insurance: coverage is selected medical cover value; premium is 4.5% of coverage.";
                    break;
                case "Life":
                    coverageMultiplier = 1.00;
                    premiumRate = 0.025;
                    note = "Life insurance: coverage is selected insured value; premium is 2.5% of coverage.";
                    break;
                case "Travel":
                    coverageMultiplier = 0.60;
                    premiumRate = 0.020;
                    note = "Travel insurance: coverage is 60% of trip value; premium is 2% of coverage.";
                    break;
                default:
                    coverageMultiplier = 0.80;
                    premiumRate = 0.030;
                    note = "General insurance: coverage is 80% of declared value; premium is 3% of coverage.";
            }

            const coverage = assetValue * coverageMultiplier;
            const premium = coverage * premiumRate;

            coverageOutput.innerText = "₹" + coverage.toFixed(2);
            premiumOutput.innerText = "₹" + premium.toFixed(2);
            noteOutput.innerText = note;
        }

        window.onload = updateRecommendation;
    </script>
</head>

<body>

<div class="navbar">
    <h2>Insurance Management System</h2>
    <div class="nav-actions">
        <a class="dashboard-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
        <a class="dashboard-link" href="${pageContext.request.contextPath}/policies?action=list">Policies</a>
        <a class="logout" href="${pageContext.request.contextPath}/logout">Logout</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <h1>Edit Policy</h1>
        <p>Update policy details. Premium and coverage will be recalculated from insurance type and asset value.</p>

        <% if (request.getAttribute("error") != null) { %>
        <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/policies" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="policyId" value="<%= policy.getPolicyId() %>">

            <div class="form-grid">
                <div class="form-group full">
                    <label>Customer</label>
                    <select name="customerId" required>
                        <% if (customers != null) {
                            for (Customer customer : customers) { %>
                        <option value="<%= customer.getCustomerId() %>"
                                <%= customer.getCustomerId() == policy.getCustomerId() ? "selected" : "" %>>
                            <%= customer.getFullName() %> - <%= customer.getEmail() %>
                        </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Policy Name</label>
                    <input type="text" name="policyName"
                           value="<%= policy.getPolicyName() != null ? policy.getPolicyName() : "" %>" required>
                </div>

                <div class="form-group">
                    <label>Insurance Type</label>
                    <select id="policyType" name="policyType" onchange="updateRecommendation()" required>
                        <option value="Health" <%= "Health".equals(policy.getPolicyType()) ? "selected" : "" %>>Health</option>
                        <option value="Life" <%= "Life".equals(policy.getPolicyType()) ? "selected" : "" %>>Life</option>
                        <option value="Vehicle" <%= "Vehicle".equals(policy.getPolicyType()) ? "selected" : "" %>>Vehicle</option>
                        <option value="Travel" <%= "Travel".equals(policy.getPolicyType()) ? "selected" : "" %>>Travel</option>
                        <option value="Property" <%= "Property".equals(policy.getPolicyType()) ? "selected" : "" %>>Property</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Asset / Product / Insured Value</label>
                    <input id="assetValue" type="number" step="0.01" name="assetValue"
                           value="<%= policy.getAssetValue() != null ? policy.getAssetValue() : "" %>"
                           oninput="updateRecommendation()" required>
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <select name="status" required>
                        <option value="Active" <%= "Active".equals(policy.getStatus()) ? "selected" : "" %>>Active</option>
                        <option value="Expired" <%= "Expired".equals(policy.getStatus()) ? "selected" : "" %>>Expired</option>
                        <option value="Pending" <%= "Pending".equals(policy.getStatus()) ? "selected" : "" %>>Pending</option>
                        <option value="Cancelled" <%= "Cancelled".equals(policy.getStatus()) ? "selected" : "" %>>Cancelled</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Start Date</label>
                    <input type="date" name="startDate"
                           value="<%= policy.getStartDate() != null ? policy.getStartDate().toString() : "" %>" required>
                </div>

                <div class="form-group">
                    <label>End Date</label>
                    <input type="date" name="endDate"
                           value="<%= policy.getEndDate() != null ? policy.getEndDate().toString() : "" %>" required>
                </div>

                <div class="recommendation-panel">
                    <h3>System Recommendation</h3>
                    <p><strong>Current Coverage:</strong> ₹<%= policy.getCoverageAmount() != null ? policy.getCoverageAmount() : "0.00" %></p>
                    <p><strong>Current Premium:</strong> ₹<%= policy.getPremiumAmount() != null ? policy.getPremiumAmount() : "0.00" %></p>
                    <hr>
                    <p><strong>Recalculated Coverage:</strong> <span id="recommendedCoverage">₹0.00</span></p>
                    <p><strong>Recalculated Premium:</strong> <span id="recommendedPremium">₹0.00</span></p>
                    <p id="recommendationNote"><%= policy.getRecommendationNote() != null ? policy.getRecommendationNote() : "" %></p>
                </div>
            </div>

            <div class="actions">
                <button type="submit">Update Recommended Policy</button>
                <a class="btn" href="${pageContext.request.contextPath}/policies?action=list">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>