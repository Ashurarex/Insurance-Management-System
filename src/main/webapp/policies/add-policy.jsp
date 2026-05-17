<%@ page import="model.Admin" %>
<%@ page import="model.Customer" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Policy | Insurance Management System</title>

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
        input, select { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 10px; font-size: 15px; box-sizing: border-box; }
        input:focus, select:focus { outline: none; border-color: #2563eb; }

        .recommendation-panel { grid-column: span 2; background: #f9fafb; border: 1px solid #e5e7eb; padding: 18px; border-radius: 14px; }
        .recommendation-panel h3 { margin: 0 0 10px; font-size: 17px; }
        .recommendation-panel p { margin: 6px 0; font-size: 14px; }

        .actions { margin-top: 25px; display: flex; gap: 12px; }
        button, .btn { border: none; text-decoration: none; padding: 12px 18px; border-radius: 10px; font-weight: bold; cursor: pointer; font-size: 15px; }
        button { background: #2563eb; color: white; }
        .btn { background: #e5e7eb; color: #111827; }
        .error { background: #fee2e2; color: #991b1b; padding: 12px; border-radius: 10px; margin-bottom: 20px; }
        .warning { background: #fef3c7; color: #92400e; padding: 12px; border-radius: 10px; margin-bottom: 20px; }

        @media (max-width: 700px) {
            .navbar { flex-direction: column; align-items: flex-start; padding: 18px; gap: 14px; }
            .form-grid { grid-template-columns: 1fr; }
            .form-group.full, .recommendation-panel { grid-column: span 1; }
        }
    </style>

    <script>
        function calculateDurationMonths(startDateValue, endDateValue) {
            if (!startDateValue || !endDateValue) {
                return 0;
            }

            const start = new Date(startDateValue);
            const end = new Date(endDateValue);

            if (end < start) {
                return 0;
            }

            const startYear = start.getFullYear();
            const startMonth = start.getMonth();

            const endYear = end.getFullYear();
            const endMonth = end.getMonth();

            return ((endYear - startYear) * 12) + (endMonth - startMonth) + 1;
        }

        function updateRecommendation() {
            const type = document.getElementById("policyType").value;
            const assetValue = parseFloat(document.getElementById("assetValue").value);
            const startDate = document.getElementById("startDate").value;
            const endDate = document.getElementById("endDate").value;

            const coverageOutput = document.getElementById("recommendedCoverage");
            const monthlyPremiumOutput = document.getElementById("monthlyPremium");
            const totalPremiumOutput = document.getElementById("totalPremium");
            const durationOutput = document.getElementById("durationMonths");
            const noteOutput = document.getElementById("recommendationNote");

            if (!type || isNaN(assetValue) || assetValue <= 0 || !startDate || !endDate) {
                coverageOutput.innerText = "₹0.00";
                monthlyPremiumOutput.innerText = "₹0.00";
                totalPremiumOutput.innerText = "₹0.00";
                durationOutput.innerText = "0 months";
                noteOutput.innerText = "Select type, asset value, start date, and end date.";
                return;
            }

            const durationMonths = calculateDurationMonths(startDate, endDate);

            if (durationMonths <= 0) {
                coverageOutput.innerText = "₹0.00";
                monthlyPremiumOutput.innerText = "₹0.00";
                totalPremiumOutput.innerText = "₹0.00";
                durationOutput.innerText = "Invalid duration";
                noteOutput.innerText = "End date must be after or equal to start date.";
                return;
            }

            let coverageMultiplier;
            let annualRate;
            let note;

            switch (type) {
                case "Vehicle":
                    coverageMultiplier = 0.90;
                    annualRate = 0.035;
                    note = "Vehicle: 90% coverage. Annual premium rate 3.5%.";
                    break;
                case "Property":
                    coverageMultiplier = 1.00;
                    annualRate = 0.0025;
                    note = "Property: 100% coverage. Annual premium rate 0.25%.";
                    break;
                case "Health":
                    coverageMultiplier = 1.00;
                    annualRate = 0.045;
                    note = "Health: 100% coverage. Annual premium rate 4.5%.";
                    break;
                case "Life":
                    coverageMultiplier = 1.00;
                    annualRate = 0.025;
                    note = "Life: 100% coverage. Annual premium rate 2.5%.";
                    break;
                case "Travel":
                    coverageMultiplier = 0.60;
                    annualRate = 0.020;
                    note = "Travel: 60% coverage. Annual premium rate 2%.";
                    break;
                default:
                    coverageMultiplier = 0.80;
                    annualRate = 0.030;
                    note = "General: 80% coverage. Annual premium rate 3%.";
            }

            const coverage = assetValue * coverageMultiplier;
            const annualPremium = coverage * annualRate;
            const monthlyPremium = annualPremium / 12;
            const totalPremium = monthlyPremium * durationMonths;

            coverageOutput.innerText = "₹" + coverage.toFixed(2);
            monthlyPremiumOutput.innerText = "₹" + monthlyPremium.toFixed(2);
            totalPremiumOutput.innerText = "₹" + totalPremium.toFixed(2);
            durationOutput.innerText = durationMonths + " month(s)";
            noteOutput.innerText = note + " Monthly premium = annual premium / 12. Total premium = monthly premium × duration.";
        }
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
        <h1>Add Policy</h1>
        <p>Create a policy using automatic monthly premium and total premium calculation.</p>

        <div class="info-box">
            Formula: <strong>Monthly Premium = Annual Premium / 12</strong>.
            Total Premium = Monthly Premium × Policy Duration.
        </div>

        <% if (request.getAttribute("error") != null) { %>
        <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (customers == null || customers.isEmpty()) { %>
        <div class="warning">No customers available. Add a customer before creating a policy.</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/policies" method="post">
            <input type="hidden" name="action" value="add">

            <div class="form-grid">
                <div class="form-group full">
                    <label>Customer</label>
                    <select name="customerId" required>
                        <option value="">Select Customer</option>
                        <% if (customers != null) {
                            for (Customer customer : customers) { %>
                        <option value="<%= customer.getCustomerId() %>">
                            <%= customer.getFullName() %> - <%= customer.getEmail() %>
                        </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Policy Name</label>
                    <input type="text" name="policyName" placeholder="Example: Vehicle Shield Plan" required>
                </div>

                <div class="form-group">
                    <label>Insurance Type</label>
                    <select id="policyType" name="policyType" onchange="updateRecommendation()" required>
                        <option value="">Select Type</option>
                        <option value="Health">Health</option>
                        <option value="Life">Life</option>
                        <option value="Vehicle">Vehicle</option>
                        <option value="Travel">Travel</option>
                        <option value="Property">Property</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Asset / Product / Insured Value</label>
                    <input id="assetValue" type="number" step="0.01" name="assetValue" oninput="updateRecommendation()" placeholder="Example: 800000" required>
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <select name="status" required>
                        <option value="Active">Active</option>
                        <option value="Expired">Expired</option>
                        <option value="Pending">Pending</option>
                        <option value="Cancelled">Cancelled</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Start Date</label>
                    <input id="startDate" type="date" name="startDate" onchange="updateRecommendation()" required>
                </div>

                <div class="form-group">
                    <label>End Date</label>
                    <input id="endDate" type="date" name="endDate" onchange="updateRecommendation()" required>
                </div>

                <div class="recommendation-panel">
                    <h3>System Recommendation</h3>
                    <p><strong>Duration:</strong> <span id="durationMonths">0 months</span></p>
                    <p><strong>Recommended Coverage:</strong> <span id="recommendedCoverage">₹0.00</span></p>
                    <p><strong>Monthly Premium:</strong> <span id="monthlyPremium">₹0.00</span></p>
                    <p><strong>Total Premium:</strong> <span id="totalPremium">₹0.00</span></p>
                    <p id="recommendationNote">Select type, asset value, start date, and end date.</p>
                </div>
            </div>

            <div class="actions">
                <button type="submit">Save Recommended Policy</button>
                <a class="btn" href="${pageContext.request.contextPath}/policies?action=list">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>