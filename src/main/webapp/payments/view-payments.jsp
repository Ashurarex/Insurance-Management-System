<%@ page import="java.util.List" %>
<%@ page import="model.Payment" %>
<%@ page import="model.Admin" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    String keyword = (String) request.getAttribute("keyword");
    String success = request.getParameter("success");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payments | Insurance Management System</title>

    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #f4f6f9; color: #111827; }
        .navbar { height: 64px; background: #111827; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 30px; }
        .navbar h2 { margin: 0; font-size: 21px; }
        .nav-actions a { color: white; text-decoration: none; margin-left: 12px; padding: 9px 14px; border-radius: 8px; font-weight: bold; }
        .dashboard-link { background: #2563eb; }
        .logout { background: #dc2626; }
        .container { padding: 35px; }
        .header-card { background: white; padding: 28px; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.06); margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; }
        h1 { margin: 0 0 8px; }
        p { margin: 0; color: #6b7280; }
        .add-btn { text-decoration: none; background: #2563eb; color: white; padding: 12px 18px; border-radius: 10px; font-weight: bold; }
        .table-card { background: white; padding: 24px; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.06); overflow-x: auto; }
        .search-form { display: flex; gap: 12px; margin-bottom: 20px; }
        .search-form input { flex: 1; padding: 12px; border: 1px solid #d1d5db; border-radius: 10px; font-size: 15px; }
        .search-form button, .clear-btn { border: none; text-decoration: none; padding: 12px 16px; border-radius: 10px; font-weight: bold; cursor: pointer; }
        .search-form button { background: #111827; color: white; }
        .clear-btn { background: #e5e7eb; color: #111827; }
        table { width: 100%; border-collapse: collapse; min-width: 950px; }
        th, td { padding: 14px; border-bottom: 1px solid #e5e7eb; text-align: left; font-size: 14px; vertical-align: top; }
        th { background: #f9fafb; color: #374151; }
        .action-link { text-decoration: none; font-weight: bold; margin-right: 10px; white-space: nowrap; }
        .delete { color: #dc2626; }
        .message { padding: 12px; border-radius: 10px; margin-bottom: 18px; background: #dcfce7; color: #166534; }
        .empty { text-align: center; padding: 35px; color: #6b7280; }
        .status { padding: 6px 10px; border-radius: 999px; font-weight: bold; font-size: 12px; background: #e0f2fe; color: #0369a1; display: inline-block; }
        @media (max-width: 700px) { .header-card { flex-direction: column; align-items: flex-start; gap: 18px; } .search-form { flex-direction: column; } }
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
            <h1>Payment Management</h1>
            <p>Record, view, search, and delete premium payment records.</p>
        </div>

        <a class="add-btn" href="${pageContext.request.contextPath}/payments?action=add-form">+ Add Payment</a>
    </div>

    <div class="table-card">
        <% if ("added".equals(success)) { %>
        <div class="message">Payment added successfully.</div>
        <% } else if ("deleted".equals(success)) { %>
        <div class="message">Payment deleted successfully.</div>
        <% } %>

        <form class="search-form" action="${pageContext.request.contextPath}/payments" method="get">
            <input type="hidden" name="action" value="search">
            <input type="text" name="keyword" placeholder="Search by policy, customer, mode, or status"
                   value="<%= keyword != null ? keyword : "" %>">
            <button type="submit">Search</button>
            <a class="clear-btn" href="${pageContext.request.contextPath}/payments?action=list">Clear</a>
        </form>

        <% if (payments == null || payments.isEmpty()) { %>
        <div class="empty">No payments found.</div>
        <% } else { %>

        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Policy</th>
                <th>Customer</th>
                <th>Amount</th>
                <th>Payment Date</th>
                <th>Mode</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>

            <tbody>
            <% for (Payment payment : payments) { %>
            <tr>
                <td><%= payment.getPaymentId() %></td>
                <td><%= payment.getPolicyName() %></td>
                <td><%= payment.getCustomerName() %></td>
                <td>₹<%= payment.getAmount() %></td>
                <td><%= payment.getPaymentDate() %></td>
                <td><%= payment.getPaymentMode() %></td>
                <td><span class="status"><%= payment.getStatus() %></span></td>
                <td>
                    <a class="action-link delete"
                       href="${pageContext.request.contextPath}/payments?action=delete&id=<%= payment.getPaymentId() %>"
                       onclick="return confirm('Are you sure you want to delete this payment?');">Delete</a>
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