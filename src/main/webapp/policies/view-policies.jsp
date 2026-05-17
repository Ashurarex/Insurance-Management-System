<%@ page import="java.util.List" %>
<%@ page import="model.Policy" %>
<%@ page import="model.Admin" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Policy> policies = (List<Policy>) request.getAttribute("policies");
    String keyword = (String) request.getAttribute("keyword");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Policies | Insurance Management System</title>

    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #f4f6f9; color: #111827; }
        .navbar { min-height: 64px; background: #111827; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 30px; box-sizing: border-box; }
        .navbar h2 { margin: 0; font-size: 21px; }
        .nav-actions { display: flex; gap: 12px; flex-wrap: wrap; }
        .nav-actions a { color: white; text-decoration: none; padding: 9px 14px; border-radius: 8px; font-weight: bold; font-size: 14px; }
        .dashboard-link { background: #2563eb; }
        .logout { background: #dc2626; }

        .container { padding: 35px; }
        .header-card { background: white; padding: 28px; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.06); margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; gap: 18px; }
        h1 { margin: 0 0 8px; }
        p { margin: 0; color: #6b7280; line-height: 1.5; }
        .add-btn { text-decoration: none; background: #2563eb; color: white; padding: 12px 18px; border-radius: 10px; font-weight: bold; white-space: nowrap; }

        .table-card { background: white; padding: 24px; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.06); overflow-x: auto; }
        .search-form { display: flex; gap: 12px; margin-bottom: 20px; }
        .search-form input { flex: 1; padding: 12px; border: 1px solid #d1d5db; border-radius: 10px; font-size: 15px; }
        .search-form button, .clear-btn { border: none; text-decoration: none; padding: 12px 16px; border-radius: 10px; font-weight: bold; cursor: pointer; }
        .search-form button { background: #111827; color: white; }
        .clear-btn { background: #e5e7eb; color: #111827; }

        table { width: 100%; border-collapse: collapse; min-width: 1250px; }
        th, td { padding: 13px; border-bottom: 1px solid #e5e7eb; text-align: left; font-size: 13px; vertical-align: top; }
        th { background: #f9fafb; color: #374151; }
        .action-link { text-decoration: none; font-weight: bold; margin-right: 10px; }
        .edit { color: #2563eb; }
        .delete { color: #dc2626; }
        .message { padding: 12px; border-radius: 10px; margin-bottom: 18px; }
        .success { background: #dcfce7; color: #166534; }
        .error { background: #fee2e2; color: #991b1b; }
        .empty { text-align: center; padding: 35px; color: #6b7280; }
        .status { padding: 6px 10px; border-radius: 999px; font-weight: bold; font-size: 12px; background: #e0f2fe; color: #0369a1; display: inline-block; }
        .note { color: #374151; font-size: 12px; max-width: 260px; line-height: 1.4; }

        @media (max-width: 700px) {
            .navbar, .header-card { flex-direction: column; align-items: flex-start; padding: 18px; }
            .search-form { flex-direction: column; }
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Insurance Management System</h2>
    <div class="nav-actions">
        <a class="dashboard-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
        <a class="logout" href="${pageContext.request.contextPath}/logout">Logout</a>
    </div>
</div>

<div class="container">
    <div class="header-card">
        <div>
            <h1>Policy Management</h1>
            <p>Policies are generated using asset value, insurance type, recommended coverage, and calculated premium.</p>
        </div>

        <a class="add-btn" href="${pageContext.request.contextPath}/policies?action=add-form">+ Add Policy</a>
    </div>

    <div class="table-card">
        <% if ("added".equals(success)) { %>
        <div class="message success">Policy added successfully with recommended premium and coverage.</div>
        <% } else if ("updated".equals(success)) { %>
        <div class="message success">Policy updated successfully with recalculated values.</div>
        <% } else if ("deleted".equals(success)) { %>
        <div class="message success">Policy deleted successfully.</div>
        <% } else if ("notfound".equals(error)) { %>
        <div class="message error">Policy not found.</div>
        <% } %>

        <form class="search-form" action="${pageContext.request.contextPath}/policies" method="get">
            <input type="hidden" name="action" value="search">
            <input type="text" name="keyword" placeholder="Search by policy, type, status, or customer"
                   value="<%= keyword != null ? keyword : "" %>">
            <button type="submit">Search</button>
            <a class="clear-btn" href="${pageContext.request.contextPath}/policies?action=list">Clear</a>
        </form>

        <% if (policies == null || policies.isEmpty()) { %>
        <div class="empty">No policies found.</div>
        <% } else { %>

        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Customer</th>
                <th>Policy Name</th>
                <th>Type</th>
                <th>Asset Value</th>
                <th>Recommended Coverage</th>
                <th>Calculated Premium</th>
                <th>Start</th>
                <th>End</th>
                <th>Status</th>
                <th>Recommendation</th>
                <th>Actions</th>
            </tr>
            </thead>

            <tbody>
            <% for (Policy policy : policies) { %>
            <tr>
                <td><%= policy.getPolicyId() %></td>
                <td><%= policy.getCustomerName() %></td>
                <td><%= policy.getPolicyName() %></td>
                <td><%= policy.getPolicyType() %></td>
                <td>₹<%= policy.getAssetValue() != null ? policy.getAssetValue() : "0.00" %></td>
                <td>₹<%= policy.getCoverageAmount() %></td>
                <td>₹<%= policy.getPremiumAmount() %></td>
                <td><%= policy.getStartDate() %></td>
                <td><%= policy.getEndDate() %></td>
                <td><span class="status"><%= policy.getStatus() %></span></td>
                <td class="note"><%= policy.getRecommendationNote() != null ? policy.getRecommendationNote() : "-" %></td>
                <td>
                    <a class="action-link edit"
                       href="${pageContext.request.contextPath}/policies?action=edit-form&id=<%= policy.getPolicyId() %>">Edit</a>

                    <a class="action-link delete"
                       href="${pageContext.request.contextPath}/policies?action=delete&id=<%= policy.getPolicyId() %>"
                       onclick="return confirm('Are you sure you want to delete this policy?');">Delete</a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <% } %>
    </div>
</div>

</body>
</html>