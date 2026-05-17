<%@ page import="model.Admin" %>
<%@ page import="model.Policy" %>
<%@ page import="model.Claim" %>
<%@ page import="model.Payment" %>
<%@ page import="service.CustomerService" %>
<%@ page import="service.PolicyService" %>
<%@ page import="service.ClaimService" %>
<%@ page import="service.PaymentService" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.LinkedHashMap" %>
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

    int totalCustomers = customerService.getTotalCustomers();
    int totalPolicies = policyService.getTotalPolicies();
    int activePolicies = policyService.getActivePolicies();
    int pendingClaims = claimService.getPendingClaims();

    List<Policy> policies = policyService.getAllPolicies();
    List<Claim> claims = claimService.getAllClaims();
    List<Payment> payments = paymentService.getAllPayments();

    if (policies == null) {
        policies = new ArrayList<>();
    }

    if (claims == null) {
        claims = new ArrayList<>();
    }

    if (payments == null) {
        payments = new ArrayList<>();
    }

    DecimalFormatSymbols symbols = new DecimalFormatSymbols(new Locale("en", "IN"));
    DecimalFormat numberFormat = new DecimalFormat("##,##,###", symbols);
    DecimalFormat currencyFormat = new DecimalFormat("##,##,###.00", symbols);

    BigDecimal totalPremiumAmount = BigDecimal.ZERO;
    BigDecimal totalPremiumPaid = BigDecimal.ZERO;
    BigDecimal remainingPremium = BigDecimal.ZERO;
    BigDecimal approvedClaimAmount = BigDecimal.ZERO;
    BigDecimal pendingClaimAmount = BigDecimal.ZERO;

    int approvedClaims = 0;
    int rejectedClaims = 0;

    Map<String, Integer> policyTypeCount = new LinkedHashMap<>();
    policyTypeCount.put("Health", 0);
    policyTypeCount.put("Life", 0);
    policyTypeCount.put("Vehicle", 0);
    policyTypeCount.put("Travel", 0);
    policyTypeCount.put("Property", 0);

    for (Policy policy : policies) {
        if (policy.getPremiumAmount() != null) {
            totalPremiumAmount = totalPremiumAmount.add(policy.getPremiumAmount());
        }

        String type = policy.getPolicyType();

        if (type == null || type.trim().isEmpty()) {
            type = "Other";
        }

        if (!policyTypeCount.containsKey(type)) {
            policyTypeCount.put(type, 0);
        }

        policyTypeCount.put(type, policyTypeCount.get(type) + 1);
    }

    Map<YearMonth, BigDecimal> premiumTrend = new TreeMap<>();

    for (Payment payment : payments) {
        if (payment.getAmount() != null && "Paid".equalsIgnoreCase(payment.getStatus())) {
            totalPremiumPaid = totalPremiumPaid.add(payment.getAmount());

            if (payment.getPaymentDate() != null) {
                YearMonth month = YearMonth.from(payment.getPaymentDate().toLocalDate());

                if (!premiumTrend.containsKey(month)) {
                    premiumTrend.put(month, BigDecimal.ZERO);
                }

                premiumTrend.put(month, premiumTrend.get(month).add(payment.getAmount()));
            }
        }
    }

    remainingPremium = totalPremiumAmount.subtract(totalPremiumPaid);

    if (remainingPremium.compareTo(BigDecimal.ZERO) < 0) {
        remainingPremium = BigDecimal.ZERO;
    }

    for (Claim claim : claims) {
        if ("Approved".equalsIgnoreCase(claim.getStatus())) {
            approvedClaims++;

            if (claim.getClaimAmount() != null) {
                approvedClaimAmount = approvedClaimAmount.add(claim.getClaimAmount());
            }
        } else if ("Rejected".equalsIgnoreCase(claim.getStatus())) {
            rejectedClaims++;
        } else if ("Pending".equalsIgnoreCase(claim.getStatus())) {
            if (claim.getClaimAmount() != null) {
                pendingClaimAmount = pendingClaimAmount.add(claim.getClaimAmount());
            }
        }
    }

    BigDecimal premiumCollectionPercent = BigDecimal.ZERO;

    if (totalPremiumAmount.compareTo(BigDecimal.ZERO) > 0) {
        premiumCollectionPercent = totalPremiumPaid
                .multiply(new BigDecimal("100"))
                .divide(totalPremiumAmount, 2, BigDecimal.ROUND_HALF_UP);
    }

    if (premiumCollectionPercent.compareTo(new BigDecimal("100")) > 0) {
        premiumCollectionPercent = new BigDecimal("100.00");
    }

    String totalCustomersText = numberFormat.format(totalCustomers);
    String totalPoliciesText = numberFormat.format(totalPolicies);
    String activePoliciesText = numberFormat.format(activePolicies);
    String pendingClaimsText = numberFormat.format(pendingClaims);
    String totalPremiumPaidText = currencyFormat.format(totalPremiumPaid);
    String totalPremiumAmountText = currencyFormat.format(totalPremiumAmount);
    String remainingPremiumText = currencyFormat.format(remainingPremium);
    String approvedClaimAmountText = currencyFormat.format(approvedClaimAmount);
    String pendingClaimAmountText = currencyFormat.format(pendingClaimAmount);
    String premiumCollectionPercentText = premiumCollectionPercent.toPlainString();

    DateTimeFormatter chartMonthFormatter = DateTimeFormatter.ofPattern("MMM yyyy");

    StringBuilder trendLabels = new StringBuilder();
    StringBuilder trendValues = new StringBuilder();

    for (Map.Entry<YearMonth, BigDecimal> entry : premiumTrend.entrySet()) {
        if (trendLabels.length() > 0) {
            trendLabels.append(",");
            trendValues.append(",");
        }

        trendLabels.append("'").append(entry.getKey().format(chartMonthFormatter)).append("'");
        trendValues.append(entry.getValue());
    }

    if (trendLabels.length() == 0) {
        trendLabels.append("'No Data'");
        trendValues.append("0");
    }

    StringBuilder policyTypeLabels = new StringBuilder();
    StringBuilder policyTypeValues = new StringBuilder();

    for (Map.Entry<String, Integer> entry : policyTypeCount.entrySet()) {
        if (entry.getValue() > 0) {
            if (policyTypeLabels.length() > 0) {
                policyTypeLabels.append(",");
                policyTypeValues.append(",");
            }

            policyTypeLabels.append("'").append(entry.getKey()).append("'");
            policyTypeValues.append(entry.getValue());
        }
    }

    if (policyTypeLabels.length() == 0) {
        policyTypeLabels.append("'No Policies'");
        policyTypeValues.append("0");
    }

    int recentLimit = Math.min(5, payments.size());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Insurance Management System</title>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --navy: #082f5f;
            --navy-dark: #062348;
            --navy-soft: #0d3b73;
            --blue: #2563eb;
            --blue-dark: #1d4ed8;
            --green: #16a34a;
            --orange: #f59e0b;
            --purple: #7c3aed;
            --red: #dc2626;
            --bg: #f5f7fb;
            --card: #ffffff;
            --text: #0f172a;
            --muted: #64748b;
            --border: #e2e8f0;
            --shadow: 0 14px 38px rgba(15, 23, 42, 0.08);
            --shadow-soft: 0 8px 24px rgba(15, 23, 42, 0.06);
            --radius-xl: 24px;
            --radius-lg: 18px;
            --radius-md: 14px;
        }

        * {
            box-sizing: border-box;
        }

        html {
            font-size: 16px;
            -webkit-font-smoothing: antialiased;
            text-rendering: optimizeLegibility;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Inter, Roboto, Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        .app {
            display: grid;
            grid-template-columns: 292px minmax(0, 1fr);
            min-height: 100vh;
        }

        .sidebar {
            background: linear-gradient(180deg, var(--navy), var(--navy-dark));
            color: white;
            padding: 26px 20px;
            position: sticky;
            top: 0;
            height: 100vh;
            overflow-y: auto;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 34px;
            padding: 0 4px;
        }

        .brand-logo {
            width: 46px;
            height: 46px;
            border-radius: 15px;
            background: rgba(255, 255, 255, 0.14);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.1);
        }

        .brand-title {
            margin: 0;
            font-size: 1.18rem;
            line-height: 1.15;
            font-weight: 750;
            letter-spacing: -0.02em;
        }

        .brand-subtitle {
            margin: 4px 0 0;
            color: #bfdbfe;
            font-size: 0.76rem;
            font-weight: 500;
        }

        .side-nav {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .side-link {
            color: #e0f2fe;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 14px 15px;
            border-radius: 15px;
            font-size: 0.96rem;
            font-weight: 650;
            transition: 0.18s ease;
        }

        .side-link:hover,
        .side-link.active {
            background: linear-gradient(135deg, #2563eb, #0ea5e9);
            color: white;
            box-shadow: 0 14px 28px rgba(37, 99, 235, 0.26);
        }

        .side-icon {
            width: 28px;
            text-align: center;
            font-size: 1.1rem;
        }

        .sidebar-note {
            margin-top: 34px;
            background: rgba(255, 255, 255, 0.10);
            border: 1px solid rgba(255, 255, 255, 0.13);
            border-radius: 22px;
            padding: 18px;
            color: #e0f2fe;
        }

        .sidebar-note strong {
            display: block;
            margin-bottom: 8px;
            color: white;
            font-size: 0.95rem;
        }

        .sidebar-note p {
            margin: 0;
            line-height: 1.55;
            font-size: 0.84rem;
        }

        .main {
            min-width: 0;
            background:
                    radial-gradient(circle at top right, rgba(37, 99, 235, 0.08), transparent 30%),
                    var(--bg);
        }

        .topbar {
            height: 74px;
            background: rgba(255, 255, 255, 0.92);
            border-bottom: 1px solid var(--border);
            backdrop-filter: blur(12px);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
            position: sticky;
            top: 0;
            z-index: 30;
        }

        .menu-symbol {
            font-size: 1.7rem;
            color: var(--navy);
            font-weight: 600;
        }

        .admin-box {
            display: flex;
            align-items: center;
            gap: 14px;
            color: var(--text);
        }

        .admin-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: #dbeafe;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            color: var(--blue);
        }

        .admin-name {
            font-weight: 700;
            font-size: 0.95rem;
        }

        .content {
            padding: 32px;
            max-width: 1500px;
            margin: 0 auto;
        }

        .page-head {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 24px;
            margin-bottom: 26px;
        }

        .page-title h1 {
            margin: 0 0 8px;
            font-size: 1.95rem;
            line-height: 1.15;
            letter-spacing: -0.04em;
        }

        .page-title p {
            margin: 0;
            color: var(--muted);
            font-size: 0.96rem;
            line-height: 1.55;
        }

        .date-card {
            background: var(--card);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-soft);
            border-radius: 15px;
            padding: 15px 20px;
            min-width: 235px;
            text-align: center;
            color: #1e293b;
            font-weight: 700;
        }

        .cards-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 20px;
            margin-bottom: 22px;
        }

        .metric-card {
            background: var(--card);
            border-radius: 18px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-soft);
            padding: 22px;
            min-height: 132px;
            display: flex;
            align-items: center;
            gap: 18px;
        }

        .metric-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.55rem;
            flex: 0 0 auto;
            font-weight: 800;
        }

        .metric-blue {
            background: #dbeafe;
            color: var(--blue);
        }

        .metric-green {
            background: #dcfce7;
            color: var(--green);
        }

        .metric-orange {
            background: #fef3c7;
            color: var(--orange);
        }

        .metric-purple {
            background: #ede9fe;
            color: var(--purple);
        }

        .metric-card h3 {
            margin: 0 0 8px;
            color: #334155;
            font-size: 0.92rem;
            font-weight: 700;
        }

        .metric-value {
            font-size: 1.75rem;
            font-weight: 780;
            letter-spacing: -0.04em;
            line-height: 1.05;
        }

        .metric-sub {
            margin-top: 7px;
            color: var(--blue);
            font-size: 0.86rem;
            font-weight: 700;
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 22px;
            margin-bottom: 22px;
        }

        .panel {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-soft);
            overflow: hidden;
        }

        .panel-inner {
            padding: 22px;
        }

        .panel-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            margin-bottom: 18px;
        }

        .panel-head h2 {
            margin: 0;
            font-size: 1.18rem;
            letter-spacing: -0.02em;
        }

        .panel-head a {
            color: white;
            background: var(--blue);
            text-decoration: none;
            padding: 9px 14px;
            border-radius: 10px;
            font-size: 0.84rem;
            font-weight: 700;
        }

        .chart-box {
            height: 280px;
            position: relative;
        }

        .progress-list {
            display: flex;
            flex-direction: column;
            gap: 17px;
        }

        .progress-row {
            display: grid;
            grid-template-columns: 130px minmax(0, 1fr) 120px;
            gap: 14px;
            align-items: center;
            font-size: 0.92rem;
        }

        .progress-name {
            color: #1f2937;
            font-weight: 650;
        }

        .progress-track {
            height: 13px;
            background: #e2e8f0;
            border-radius: 999px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--blue), #60a5fa);
            border-radius: 999px;
            width: <%= premiumCollectionPercentText %>%;
        }

        .progress-value {
            text-align: right;
            font-weight: 750;
            color: var(--text);
        }

        .payment-summary {
            margin-top: 22px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
        }

        .mini-summary {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 14px;
        }

        .mini-summary span {
            display: block;
            color: var(--muted);
            font-size: 0.78rem;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .mini-summary strong {
            display: block;
            font-size: 1rem;
            letter-spacing: -0.02em;
        }

        .recent-table {
            width: 100%;
            border-collapse: collapse;
        }

        .recent-table th,
        .recent-table td {
            padding: 13px 14px;
            border-bottom: 1px solid var(--border);
            text-align: left;
            font-size: 0.88rem;
            vertical-align: middle;
        }

        .recent-table th {
            background: #f8fafc;
            color: #475569;
            font-weight: 750;
        }

        .amount {
            font-weight: 760;
            color: #0f172a;
            white-space: nowrap;
        }

        .status {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 760;
            background: #dbeafe;
            color: var(--blue-dark);
            white-space: nowrap;
        }

        .empty {
            padding: 20px;
            color: var(--muted);
            text-align: center;
            font-size: 0.92rem;
        }

        .bottom-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 410px;
            gap: 22px;
        }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
        }

        .quick-action {
            text-decoration: none;
            color: var(--text);
            border: 1px solid var(--border);
            background: #f8fafc;
            border-radius: 15px;
            padding: 15px;
            transition: 0.18s ease;
        }

        .quick-action:hover {
            transform: translateY(-2px);
            background: #eff6ff;
            border-color: #bfdbfe;
        }

        .quick-action strong {
            display: block;
            margin-bottom: 7px;
            font-size: 0.92rem;
        }

        .quick-action span {
            color: var(--muted);
            font-size: 0.8rem;
            line-height: 1.4;
        }

        @media (max-width: 1200px) {
            .app {
                grid-template-columns: 1fr;
            }

            .sidebar {
                position: static;
                height: auto;
            }

            .side-nav {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
            }

            .sidebar-note {
                display: none;
            }

            .cards-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .dashboard-grid,
            .bottom-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 760px) {
            .content {
                padding: 22px;
            }

            .topbar,
            .page-head {
                flex-direction: column;
                align-items: flex-start;
                height: auto;
                padding: 18px 22px;
            }

            .cards-grid,
            .side-nav,
            .payment-summary,
            .quick-actions {
                grid-template-columns: 1fr;
            }

            .metric-card {
                align-items: flex-start;
            }

            .progress-row {
                grid-template-columns: 1fr;
                gap: 8px;
            }

            .progress-value {
                text-align: left;
            }

            .recent-table {
                min-width: 680px;
            }

            .panel {
                overflow-x: auto;
            }
        }
    </style>
</head>

<body>

<div class="app">

    <aside class="sidebar">
        <div class="brand">
            <div class="brand-logo">IMS</div>
            <div>
                <h2 class="brand-title">Insurance Management System</h2>
                <p class="brand-subtitle">Premium · Policies · Claims</p>
            </div>
        </div>

        <nav class="side-nav">
            <a class="side-link active" href="${pageContext.request.contextPath}/dashboard.jsp">
                <span class="side-icon">⌂</span> Dashboard
            </a>

            <a class="side-link" href="${pageContext.request.contextPath}/customers?action=list">
                <span class="side-icon">☷</span> Customers
            </a>

            <a class="side-link" href="${pageContext.request.contextPath}/policies?action=list">
                <span class="side-icon">▣</span> Policies
            </a>

            <a class="side-link" href="${pageContext.request.contextPath}/claims?action=list">
                <span class="side-icon">◇</span> Claims
            </a>

            <a class="side-link" href="${pageContext.request.contextPath}/payments?action=list">
                <span class="side-icon">₹</span> Payments
            </a>

            <a class="side-link" href="${pageContext.request.contextPath}/reports.jsp">
                <span class="side-icon">◷</span> Reports
            </a>

            <a class="side-link" href="${pageContext.request.contextPath}/logout">
                <span class="side-icon">↪</span> Logout
            </a>
        </nav>

        <div class="sidebar-note">
            <strong>Insurance Logic Active</strong>
            <p>
                Premium is monthly. Claims are limited by remaining coverage.
                Reports are generated customer-wise.
            </p>
        </div>
    </aside>

    <main class="main">

        <header class="topbar">
            <div class="menu-symbol">☰</div>

            <div class="admin-box">
                <div class="admin-avatar"><%= admin.getUsername().substring(0, 1).toUpperCase() %></div>
                <div class="admin-name"><%= admin.getUsername() %></div>
            </div>
        </header>

        <div class="content">

            <div class="page-head">
                <div class="page-title">
                    <h1>Dashboard</h1>
                    <p>Welcome back, <%= admin.getUsername() %>. Here is the current insurance business overview.</p>
                </div>

                <div class="date-card">
                    <%= java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy, EEEE")) %>
                </div>
            </div>

            <section class="cards-grid">
                <div class="metric-card">
                    <div class="metric-icon metric-blue">C</div>
                    <div>
                        <h3>Total Customers</h3>
                        <div class="metric-value"><%= totalCustomersText %></div>
                        <div class="metric-sub">Registered profiles</div>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon metric-green">P</div>
                    <div>
                        <h3>Active Policies</h3>
                        <div class="metric-value"><%= activePoliciesText %></div>
                        <div class="metric-sub">Out of <%= totalPoliciesText %> policies</div>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon metric-orange">₹</div>
                    <div>
                        <h3>Premium Collected</h3>
                        <div class="metric-value">₹<%= totalPremiumPaidText %></div>
                        <div class="metric-sub">Confirmed payments</div>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon metric-purple">!</div>
                    <div>
                        <h3>Pending Claims</h3>
                        <div class="metric-value"><%= pendingClaimsText %></div>
                        <div class="metric-sub">Awaiting approval</div>
                    </div>
                </div>
            </section>

            <section class="dashboard-grid">
                <div class="panel">
                    <div class="panel-inner">
                        <div class="panel-head">
                            <h2>Premium Collection Trend</h2>
                            <a href="${pageContext.request.contextPath}/payments?action=list">View Payments</a>
                        </div>

                        <div class="chart-box">
                            <canvas id="premiumTrendChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-inner">
                        <div class="panel-head">
                            <h2>Policy Type Distribution</h2>
                            <a href="${pageContext.request.contextPath}/policies?action=list">View Policies</a>
                        </div>

                        <div class="chart-box">
                            <canvas id="policyTypeChart"></canvas>
                        </div>
                    </div>
                </div>
            </section>

            <section class="dashboard-grid">
                <div class="panel">
                    <div class="panel-inner">
                        <div class="panel-head">
                            <h2>Claims Status Overview</h2>
                            <a href="${pageContext.request.contextPath}/claims?action=list">View Claims</a>
                        </div>

                        <div class="chart-box">
                            <canvas id="claimsChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-inner">
                        <div class="panel-head">
                            <h2>Premium Paid vs Remaining</h2>
                            <a href="${pageContext.request.contextPath}/payments?action=add-form">Add Payment</a>
                        </div>

                        <div class="progress-list">
                            <div class="progress-row">
                                <div class="progress-name">Collection Progress</div>
                                <div class="progress-track">
                                    <div class="progress-fill"></div>
                                </div>
                                <div class="progress-value"><%= premiumCollectionPercentText %>%</div>
                            </div>
                        </div>

                        <div class="payment-summary">
                            <div class="mini-summary">
                                <span>Total Premium</span>
                                <strong>₹<%= totalPremiumAmountText %></strong>
                            </div>

                            <div class="mini-summary">
                                <span>Paid</span>
                                <strong>₹<%= totalPremiumPaidText %></strong>
                            </div>

                            <div class="mini-summary">
                                <span>Remaining</span>
                                <strong>₹<%= remainingPremiumText %></strong>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="bottom-grid">
                <div class="panel">
                    <div class="panel-inner">
                        <div class="panel-head">
                            <h2>Recent Premium Payments</h2>
                            <a href="${pageContext.request.contextPath}/payments?action=list">View All</a>
                        </div>

                        <% if (recentLimit == 0) { %>
                        <div class="empty">No premium payments recorded yet.</div>
                        <% } else { %>

                        <table class="recent-table">
                            <thead>
                            <tr>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Policy</th>
                                <th>Amount</th>
                                <th>Status</th>
                            </tr>
                            </thead>

                            <tbody>
                            <% for (int i = 0; i < recentLimit; i++) {
                                Payment payment = payments.get(i);
                            %>
                            <tr>
                                <td><%= payment.getPaymentDate() != null ? payment.getPaymentDate() : "-" %></td>
                                <td><%= payment.getCustomerName() != null ? payment.getCustomerName() : "-" %></td>
                                <td><%= payment.getPolicyName() != null ? payment.getPolicyName() : "-" %></td>
                                <td class="amount">₹<%= currencyFormat.format(payment.getAmount() != null ? payment.getAmount() : BigDecimal.ZERO) %></td>
                                <td><span class="status"><%= payment.getStatus() != null ? payment.getStatus() : "-" %></span></td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>

                        <% } %>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-inner">
                        <div class="panel-head">
                            <h2>Quick Actions</h2>
                        </div>

                        <div class="quick-actions">
                            <a class="quick-action" href="${pageContext.request.contextPath}/customers?action=add-form">
                                <strong>Add Customer</strong>
                                <span>Register a new customer</span>
                            </a>

                            <a class="quick-action" href="${pageContext.request.contextPath}/policies?action=add-form">
                                <strong>Create Policy</strong>
                                <span>Generate premium and coverage</span>
                            </a>

                            <a class="quick-action" href="${pageContext.request.contextPath}/claims?action=add-form">
                                <strong>Register Claim</strong>
                                <span>Use eligible claim amount</span>
                            </a>

                            <a class="quick-action" href="${pageContext.request.contextPath}/payments?action=add-form">
                                <strong>Add Payment</strong>
                                <span>Record monthly premium</span>
                            </a>

                            <a class="quick-action" href="${pageContext.request.contextPath}/reports.jsp">
                                <strong>Customer Report</strong>
                                <span>Generate printable report</span>
                            </a>
                        </div>
                    </div>
                </div>
            </section>

        </div>
    </main>
</div>

<script>
    Chart.defaults.font.family = "'Segoe UI', Inter, Roboto, Arial, sans-serif";
    Chart.defaults.color = "#334155";

    new Chart(document.getElementById("premiumTrendChart"), {
        type: "line",
        data: {
            labels: [<%= trendLabels %>],
            datasets: [{
                label: "Premium Collected",
                data: [<%= trendValues %>],
                borderWidth: 3,
                tension: 0.38,
                fill: true,
                borderColor: "#2563eb",
                backgroundColor: "rgba(37, 99, 235, 0.12)",
                pointBackgroundColor: "#2563eb",
                pointRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: "#e2e8f0" }
                },
                x: {
                    grid: { display: false }
                }
            }
        }
    });

    new Chart(document.getElementById("policyTypeChart"), {
        type: "doughnut",
        data: {
            labels: [<%= policyTypeLabels %>],
            datasets: [{
                data: [<%= policyTypeValues %>],
                backgroundColor: ["#2563eb", "#16a34a", "#f59e0b", "#7c3aed", "#dc2626", "#0ea5e9"],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: "62%",
            plugins: {
                legend: {
                    position: "right",
                    labels: {
                        boxWidth: 12,
                        padding: 16
                    }
                }
            }
        }
    });

    new Chart(document.getElementById("claimsChart"), {
        type: "bar",
        data: {
            labels: ["Approved", "Pending", "Rejected"],
            datasets: [{
                label: "Claims",
                data: [<%= approvedClaims %>, <%= pendingClaims %>, <%= rejectedClaims %>],
                backgroundColor: ["#16a34a", "#f59e0b", "#dc2626"],
                borderRadius: 10,
                barThickness: 42
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { precision: 0 },
                    grid: { color: "#e2e8f0" }
                },
                x: {
                    grid: { display: false }
                }
            }
        }
    });
</script>

</body>
</html>