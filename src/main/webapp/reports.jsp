<%@ page import="model.Admin" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Policy" %>
<%@ page import="model.Claim" %>
<%@ page import="model.Payment" %>
<%@ page import="service.CustomerService" %>
<%@ page import="service.PolicyService" %>
<%@ page import="service.ClaimService" %>
<%@ page import="service.PaymentService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    CustomerService customerService = new CustomerService();
    PolicyService policyService = new PolicyService();
    ClaimService claimService = new ClaimService();
    PaymentService paymentService = new PaymentService();

    List<Customer> allCustomers = customerService.getAllCustomers();
    List<Policy> allPolicies = policyService.getAllPolicies();
    List<Claim> allClaims = claimService.getAllClaims();
    List<Payment> allPayments = paymentService.getAllPayments();

    DecimalFormatSymbols symbols = new DecimalFormatSymbols(new Locale("en", "IN"));
    DecimalFormat currencyFormat = new DecimalFormat("##,##,###.00", symbols);

    String customerIdParam = request.getParameter("customerId");
    int selectedCustomerId = 0;

    try {
        if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
            selectedCustomerId = Integer.parseInt(customerIdParam);
        }
    } catch (Exception e) {
        selectedCustomerId = 0;
    }

    Customer selectedCustomer = null;

    if (selectedCustomerId > 0) {
        selectedCustomer = customerService.getCustomerById(selectedCustomerId);
    }

    List<Policy> customerPolicies = new ArrayList<>();
    List<Claim> customerClaims = new ArrayList<>();
    List<Payment> customerPayments = new ArrayList<>();
    Set<Integer> customerPolicyIds = new HashSet<>();

    BigDecimal totalAssetValue = BigDecimal.ZERO;
    BigDecimal totalPremiumAmount = BigDecimal.ZERO;
    BigDecimal totalCoverageAmount = BigDecimal.ZERO;
    BigDecimal totalClaimAmount = BigDecimal.ZERO;
    BigDecimal approvedClaimAmount = BigDecimal.ZERO;
    BigDecimal pendingClaimAmount = BigDecimal.ZERO;
    BigDecimal totalPremiumPaid = BigDecimal.ZERO;
    BigDecimal confirmedPremiumPaid = BigDecimal.ZERO;

    int activePolicyCount = 0;

    if (selectedCustomer != null) {
        if (allPolicies != null) {
            for (Policy policy : allPolicies) {
                if (policy.getCustomerId() == selectedCustomerId) {
                    customerPolicies.add(policy);
                    customerPolicyIds.add(policy.getPolicyId());

                    if (policy.getAssetValue() != null) totalAssetValue = totalAssetValue.add(policy.getAssetValue());
                    if (policy.getPremiumAmount() != null) totalPremiumAmount = totalPremiumAmount.add(policy.getPremiumAmount());
                    if (policy.getCoverageAmount() != null) totalCoverageAmount = totalCoverageAmount.add(policy.getCoverageAmount());
                    if ("Active".equalsIgnoreCase(policy.getStatus())) activePolicyCount++;
                }
            }
        }

        if (allClaims != null) {
            for (Claim claim : allClaims) {
                if (customerPolicyIds.contains(claim.getPolicyId())) {
                    customerClaims.add(claim);

                    if (claim.getClaimAmount() != null) {
                        totalClaimAmount = totalClaimAmount.add(claim.getClaimAmount());

                        if ("Approved".equalsIgnoreCase(claim.getStatus())) {
                            approvedClaimAmount = approvedClaimAmount.add(claim.getClaimAmount());
                        } else if ("Pending".equalsIgnoreCase(claim.getStatus())) {
                            pendingClaimAmount = pendingClaimAmount.add(claim.getClaimAmount());
                        }
                    }
                }
            }
        }

        if (allPayments != null) {
            for (Payment payment : allPayments) {
                if (customerPolicyIds.contains(payment.getPolicyId())) {
                    customerPayments.add(payment);

                    if (payment.getAmount() != null) {
                        totalPremiumPaid = totalPremiumPaid.add(payment.getAmount());

                        if ("Paid".equalsIgnoreCase(payment.getStatus())) {
                            confirmedPremiumPaid = confirmedPremiumPaid.add(payment.getAmount());
                        }
                    }
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Insurance Report</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: #f5f7fb;
            color: #0f172a;
            letter-spacing: -0.01em;
        }

        .navbar {
            min-height: 72px;
            background: #0f172a;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 34px;
            box-shadow: 0 8px 28px rgba(15, 23, 42, 0.18);
        }

        .navbar h2 {
            margin: 0;
            font-size: 21px;
            font-weight: 800;
            letter-spacing: -0.4px;
        }

        .nav-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .nav-actions a {
            color: white;
            text-decoration: none;
            padding: 10px 16px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 14px;
        }

        .nav-link {
            background: #2563eb;
        }

        .logout {
            background: #dc2626;
        }

        .screen-container {
            padding: 32px;
        }

        .filter-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 22px;
            padding: 26px;
            box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
            margin-bottom: 26px;
        }

        .filter-card h1 {
            margin: 0 0 8px;
            font-size: 28px;
            letter-spacing: -0.6px;
        }

        .filter-card p {
            margin: 0 0 20px;
            color: #64748b;
            font-size: 14px;
        }

        .filter-form {
            display: grid;
            grid-template-columns: 1fr auto auto;
            gap: 14px;
            align-items: end;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-weight: 800;
            color: #334155;
            font-size: 14px;
        }

        select {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 12px;
            font-size: 15px;
            font-family: "Segoe UI", Arial, sans-serif;
        }

        .btn {
            border: none;
            text-decoration: none;
            padding: 12px 18px;
            border-radius: 12px;
            font-weight: 800;
            cursor: pointer;
            font-size: 15px;
            font-family: "Segoe UI", Arial, sans-serif;
        }

        .btn-primary {
            background: #2563eb;
            color: white;
        }

        .btn-dark {
            background: #0f172a;
            color: white;
        }

        .notice {
            background: #fff7ed;
            border: 1px solid #fed7aa;
            color: #9a3412;
            border-radius: 16px;
            padding: 16px;
            font-weight: 700;
        }

        .report-sheet {
            background: white;
            width: 210mm;
            min-height: 297mm;
            margin: 0 auto;
            padding: 14mm;
            box-shadow: 0 18px 55px rgba(15, 23, 42, 0.13);
        }

        .report-header {
            border-bottom: 2px solid #0f172a;
            padding-bottom: 12px;
            margin-bottom: 14px;
            display: flex;
            justify-content: space-between;
            gap: 20px;
        }

        .report-header h1 {
            margin: 0;
            font-size: 25px;
            letter-spacing: -0.7px;
        }

        .report-header p {
            margin: 5px 0 0;
            color: #475569;
            font-size: 12px;
        }

        .report-meta {
            text-align: right;
            font-size: 12px;
            color: #334155;
            line-height: 1.65;
            min-width: 180px;
        }

        .section {
            margin-bottom: 12px;
            page-break-inside: avoid;
        }

        .section-title {
            background: #0f172a;
            color: white;
            font-size: 13px;
            font-weight: 800;
            padding: 7px 10px;
            margin: 0 0 7px;
            border-radius: 5px;
            letter-spacing: -0.1px;
        }

        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        th, td {
            border: 1px solid #cbd5e1;
            padding: 6px 7px;
            font-size: 10.6px;
            line-height: 1.35;
            vertical-align: middle;
            overflow-wrap: anywhere;
        }

        th {
            background: #f1f5f9;
            color: #334155;
            text-align: left;
            font-weight: 800;
        }

        .info-table td:first-child {
            width: 34%;
            background: #f8fafc;
            font-weight: 800;
            color: #334155;
        }

        .summary-table td:nth-child(2) {
            font-weight: 800;
            color: #1d4ed8;
        }

        .data-table th {
            font-size: 9.8px;
        }

        .data-table td {
            font-size: 9.6px;
        }

        .amount {
            font-weight: 800;
            white-space: nowrap;
        }

        .status-cell {
            text-align: center;
            overflow-wrap: normal;
        }

        .status {
            display: inline-block;
            min-width: 42px;
            max-width: 100%;
            padding: 3px 6px;
            border-radius: 999px;
            background: #dbeafe;
            color: #1d4ed8;
            font-weight: 800;
            font-size: 8.4px;
            line-height: 1.1;
            white-space: nowrap;
            text-align: center;
        }

        .empty {
            border: 1px solid #cbd5e1;
            padding: 8px;
            color: #64748b;
            font-size: 11px;
            background: #f8fafc;
        }

        .report-footer {
            margin-top: 14px;
            border-top: 1px solid #cbd5e1;
            padding-top: 8px;
            font-size: 10px;
            color: #64748b;
            display: flex;
            justify-content: space-between;
        }

        @page {
            size: A4 portrait;
            margin: 10mm;
        }

        @media print {
            body {
                background: white;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }

            .navbar,
            .filter-card,
            .no-print {
                display: none !important;
            }

            .screen-container {
                padding: 0;
            }

            .report-sheet {
                width: 100%;
                min-height: auto;
                margin: 0;
                padding: 0;
                box-shadow: none;
            }

            .report-header {
                margin-bottom: 8px;
                padding-bottom: 7px;
            }

            .report-header h1 {
                font-size: 18px;
            }

            .report-header p,
            .report-meta {
                font-size: 8.5px;
            }

            .section {
                margin-bottom: 6px;
            }

            .section-title {
                font-size: 9.5px;
                padding: 4.5px 7px;
                margin-bottom: 4px;
            }

            .two-column {
                grid-template-columns: 1fr 1fr;
                gap: 7px;
            }

            th, td {
                padding: 3px 4px;
                font-size: 7px;
                line-height: 1.15;
            }

            .data-table th {
                font-size: 6.7px;
            }

            .data-table td {
                font-size: 6.6px;
            }

            .status {
                min-width: 34px;
                padding: 1px 3px;
                font-size: 5.8px;
                line-height: 1.05;
                white-space: nowrap;
            }

            .report-footer {
                margin-top: 6px;
                padding-top: 4px;
                font-size: 7px;
            }
        }

        @media (max-width: 900px) {
            .filter-form {
                grid-template-columns: 1fr;
            }

            .navbar {
                flex-direction: column;
                align-items: flex-start;
                padding: 18px;
                gap: 14px;
            }

            .screen-container {
                padding: 20px;
            }

            .report-sheet {
                width: 100%;
                min-height: auto;
                padding: 20px;
            }

            .two-column {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Insurance Management System</h2>

    <div class="nav-actions">
        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
        <a class="nav-link" href="${pageContext.request.contextPath}/customers?action=list">Customers</a>
        <a class="nav-link" href="${pageContext.request.contextPath}/policies?action=list">Policies</a>
        <a class="nav-link" href="${pageContext.request.contextPath}/claims?action=list">Claims</a>
        <a class="nav-link" href="${pageContext.request.contextPath}/payments?action=list">Payments</a>
        <a class="nav-link" href="${pageContext.request.contextPath}/reports.jsp">Reports</a>
        <a class="logout" href="${pageContext.request.contextPath}/logout">Logout</a>
    </div>
</div>

<div class="screen-container">

    <div class="filter-card no-print">
        <h1>Customer Insurance Report</h1>
        <p>Select a customer to generate a clean portrait report.</p>

        <form class="filter-form" action="${pageContext.request.contextPath}/reports.jsp" method="get">
            <div>
                <label>Select Customer</label>
                <select name="customerId" required>
                    <option value="">Choose customer</option>
                    <% if (allCustomers != null) {
                        for (Customer customer : allCustomers) { %>
                    <option value="<%= customer.getCustomerId() %>"
                            <%= customer.getCustomerId() == selectedCustomerId ? "selected" : "" %>>
                        <%= customer.getFullName() %> - <%= customer.getEmail() %>
                    </option>
                    <%  }
                    } %>
                </select>
            </div>

            <button class="btn btn-primary" type="submit">Generate Report</button>

            <% if (selectedCustomer != null) { %>
            <button class="btn btn-dark" type="button" onclick="window.print()">Print / Save PDF</button>
            <% } %>
        </form>
    </div>

    <% if (selectedCustomer == null) { %>

    <div class="notice">Select a customer to generate an individual printable report.</div>

    <% } else { %>

    <div class="report-sheet">

        <div class="report-header">
            <div>
                <h1>Customer Insurance Report</h1>
                <p>Customer-wise policy, claim, premium payment, and recommendation statement</p>
            </div>

            <div class="report-meta">
                <div><strong>Report ID:</strong> IMS-CUST-<%= selectedCustomer.getCustomerId() %></div>
                <div><strong>Customer ID:</strong> <%= selectedCustomer.getCustomerId() %></div>
                <div><strong>Generated By:</strong> <%= admin.getUsername() %></div>
            </div>
        </div>

        <div class="section">
            <div class="two-column">
                <div>
                    <h2 class="section-title">Customer Information</h2>

                    <table class="info-table">
                        <tr><td>Name</td><td><%= selectedCustomer.getFullName() %></td></tr>
                        <tr><td>Email</td><td><%= selectedCustomer.getEmail() %></td></tr>
                        <tr><td>Phone</td><td><%= selectedCustomer.getPhone() %></td></tr>
                        <tr><td>Date of Birth</td><td><%= selectedCustomer.getDob() != null ? selectedCustomer.getDob() : "-" %></td></tr>
                        <tr><td>Gender</td><td><%= selectedCustomer.getGender() != null && !selectedCustomer.getGender().isEmpty() ? selectedCustomer.getGender() : "-" %></td></tr>
                        <tr><td>Address</td><td><%= selectedCustomer.getAddress() != null && !selectedCustomer.getAddress().isEmpty() ? selectedCustomer.getAddress() : "-" %></td></tr>
                    </table>
                </div>

                <div>
                    <h2 class="section-title">Financial Summary</h2>

                    <table class="summary-table">
                        <tr><th>Metric</th><th>Value</th></tr>
                        <tr><td>Policies / Active</td><td><%= customerPolicies.size() %> / <%= activePolicyCount %></td></tr>
                        <tr><td>Total Asset Value</td><td>₹<%= currencyFormat.format(totalAssetValue) %></td></tr>
                        <tr><td>Recommended Coverage</td><td>₹<%= currencyFormat.format(totalCoverageAmount) %></td></tr>
                        <tr><td>Total Premium</td><td>₹<%= currencyFormat.format(totalPremiumAmount) %></td></tr>
                        <tr><td>Total Claimed</td><td>₹<%= currencyFormat.format(totalClaimAmount) %></td></tr>
                        <tr><td>Approved Claims</td><td>₹<%= currencyFormat.format(approvedClaimAmount) %></td></tr>
                        <tr><td>Pending Claims</td><td>₹<%= currencyFormat.format(pendingClaimAmount) %></td></tr>
                        <tr><td>Total Premium Paid</td><td>₹<%= currencyFormat.format(totalPremiumPaid) %></td></tr>
                        <tr><td>Confirmed Premium Paid</td><td>₹<%= currencyFormat.format(confirmedPremiumPaid) %></td></tr>
                    </table>
                </div>
            </div>
        </div>

        <div class="section">
            <h2 class="section-title">Policy Details</h2>

            <% if (customerPolicies.isEmpty()) { %>
            <div class="empty">No policy records available.</div>
            <% } else { %>

            <table class="data-table">
                <thead>
                <tr>
                    <th style="width: 6%;">ID</th>
                    <th style="width: 18%;">Policy</th>
                    <th style="width: 10%;">Type</th>
                    <th style="width: 12%;">Asset</th>
                    <th style="width: 12%;">Coverage</th>
                    <th style="width: 12%;">Premium</th>
                    <th style="width: 9%;">Start</th>
                    <th style="width: 9%;">End</th>
                    <th style="width: 12%;">Status</th>
                </tr>
                </thead>
                <tbody>
                <% for (Policy policy : customerPolicies) { %>
                <tr>
                    <td><%= policy.getPolicyId() %></td>
                    <td><%= policy.getPolicyName() %></td>
                    <td><%= policy.getPolicyType() %></td>
                    <td class="amount">₹<%= currencyFormat.format(policy.getAssetValue() != null ? policy.getAssetValue() : BigDecimal.ZERO) %></td>
                    <td class="amount">₹<%= currencyFormat.format(policy.getCoverageAmount() != null ? policy.getCoverageAmount() : BigDecimal.ZERO) %></td>
                    <td class="amount">₹<%= currencyFormat.format(policy.getPremiumAmount() != null ? policy.getPremiumAmount() : BigDecimal.ZERO) %></td>
                    <td><%= policy.getStartDate() %></td>
                    <td><%= policy.getEndDate() %></td>
                    <td class="status-cell"><span class="status"><%= policy.getStatus() %></span></td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <% } %>
        </div>

        <div class="section">
            <h2 class="section-title">Claim Details</h2>

            <% if (customerClaims.isEmpty()) { %>
            <div class="empty">No claim records available.</div>
            <% } else { %>

            <table class="data-table">
                <thead>
                <tr>
                    <th style="width: 7%;">ID</th>
                    <th style="width: 20%;">Policy</th>
                    <th style="width: 14%;">Amount</th>
                    <th style="width: 32%;">Reason</th>
                    <th style="width: 12%;">Date</th>
                    <th style="width: 15%;">Status</th>
                </tr>
                </thead>
                <tbody>
                <% for (Claim claim : customerClaims) { %>
                <tr>
                    <td><%= claim.getClaimId() %></td>
                    <td><%= claim.getPolicyName() %></td>
                    <td class="amount">₹<%= currencyFormat.format(claim.getClaimAmount() != null ? claim.getClaimAmount() : BigDecimal.ZERO) %></td>
                    <td><%= claim.getClaimReason() %></td>
                    <td><%= claim.getClaimDate() %></td>
                    <td class="status-cell"><span class="status"><%= claim.getStatus() %></span></td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <% } %>
        </div>

        <div class="section">
            <h2 class="section-title">Premium Payment Details</h2>

            <% if (customerPayments.isEmpty()) { %>
            <div class="empty">No payment records available.</div>
            <% } else { %>

            <table class="data-table">
                <thead>
                <tr>
                    <th style="width: 8%;">ID</th>
                    <th style="width: 30%;">Policy</th>
                    <th style="width: 16%;">Premium Paid</th>
                    <th style="width: 15%;">Date</th>
                    <th style="width: 16%;">Mode</th>
                    <th style="width: 15%;">Status</th>
                </tr>
                </thead>
                <tbody>
                <% for (Payment payment : customerPayments) { %>
                <tr>
                    <td><%= payment.getPaymentId() %></td>
                    <td><%= payment.getPolicyName() %></td>
                    <td class="amount">₹<%= currencyFormat.format(payment.getAmount() != null ? payment.getAmount() : BigDecimal.ZERO) %></td>
                    <td><%= payment.getPaymentDate() %></td>
                    <td><%= payment.getPaymentMode() %></td>
                    <td class="status-cell"><span class="status"><%= payment.getStatus() %></span></td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <% } %>
        </div>

        <div class="report-footer">
            <div>Insurance Management System</div>
            <div>System-generated customer insurance report</div>
        </div>

    </div>

    <% } %>

</div>

</body>
</html>