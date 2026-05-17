<%@ page import="java.util.List" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Admin" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    String keyword = (String) request.getAttribute("keyword");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customers | Insurance Management System</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6f9;
            color: #111827;
        }

        .navbar {
            height: 64px;
            background: #111827;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 30px;
        }

        .navbar h2 {
            margin: 0;
            font-size: 21px;
        }

        .nav-actions a {
            color: white;
            text-decoration: none;
            margin-left: 12px;
            padding: 9px 14px;
            border-radius: 8px;
            font-weight: bold;
        }

        .dashboard-link {
            background: #2563eb;
        }

        .logout {
            background: #dc2626;
        }

        .container {
            padding: 35px;
        }

        .header-card {
            background: white;
            padding: 28px;
            border-radius: 16px;
            box-shadow: 0 10px 28px rgba(0, 0, 0, 0.06);
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        h1 {
            margin: 0 0 8px;
        }

        p {
            margin: 0;
            color: #6b7280;
        }

        .add-btn {
            text-decoration: none;
            background: #2563eb;
            color: white;
            padding: 12px 18px;
            border-radius: 10px;
            font-weight: bold;
        }

        .table-card {
            background: white;
            padding: 24px;
            border-radius: 16px;
            box-shadow: 0 10px 28px rgba(0, 0, 0, 0.06);
            overflow-x: auto;
        }

        .search-form {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
        }

        .search-form input {
            flex: 1;
            padding: 12px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            font-size: 15px;
        }

        .search-form button, .clear-btn {
            border: none;
            text-decoration: none;
            padding: 12px 16px;
            border-radius: 10px;
            font-weight: bold;
            cursor: pointer;
        }

        .search-form button {
            background: #111827;
            color: white;
        }

        .clear-btn {
            background: #e5e7eb;
            color: #111827;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }

        th, td {
            padding: 14px;
            border-bottom: 1px solid #e5e7eb;
            text-align: left;
            font-size: 14px;
        }

        th {
            background: #f9fafb;
            color: #374151;
        }

        .action-link {
            text-decoration: none;
            font-weight: bold;
            margin-right: 10px;
        }

        .edit {
            color: #2563eb;
        }

        .delete {
            color: #dc2626;
        }

        .message {
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 18px;
        }

        .success {
            background: #dcfce7;
            color: #166534;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
        }

        .empty {
            text-align: center;
            padding: 35px;
            color: #6b7280;
        }

        @media (max-width: 700px) {
            .header-card {
                flex-direction: column;
                align-items: flex-start;
                gap: 18px;
            }

            .search-form {
                flex-direction: column;
            }
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Insurance Management System</h2>
    <div class="nav-actions">
        <a class="dashboard-link" href="dashboard.jsp">Dashboard</a>
        <a class="logout" href="logout">Logout</a>
    </div>
</div>

<div class="container">
    <div class="header-card">
        <div>
            <h1>Customer Management</h1>
            <p>Add, view, update, delete, and search customer records.</p>
        </div>

        <a class="add-btn" href="customers?action=add-form">+ Add Customer</a>
    </div>

    <div class="table-card">
        <% if ("added".equals(success)) { %>
        <div class="message success">Customer added successfully.</div>
        <% } else if ("updated".equals(success)) { %>
        <div class="message success">Customer updated successfully.</div>
        <% } else if ("deleted".equals(success)) { %>
        <div class="message success">Customer deleted successfully.</div>
        <% } else if ("notfound".equals(error)) { %>
        <div class="message error">Customer not found.</div>
        <% } %>

        <form class="search-form" action="customers" method="get">
            <input type="hidden" name="action" value="search">
            <input type="text" name="keyword" placeholder="Search by name, email, phone, or gender"
                   value="<%= keyword != null ? keyword : "" %>">
            <button type="submit">Search</button>
            <a class="clear-btn" href="customers?action=list">Clear</a>
        </form>

        <% if (customers == null || customers.isEmpty()) { %>
        <div class="empty">No customers found.</div>
        <% } else { %>

        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Full Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>DOB</th>
                <th>Gender</th>
                <th>Address</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
            </thead>

            <tbody>
            <% for (Customer customer : customers) { %>
            <tr>
                <td><%= customer.getCustomerId() %></td>
                <td><%= customer.getFullName() %></td>
                <td><%= customer.getEmail() %></td>
                <td><%= customer.getPhone() %></td>
                <td><%= customer.getDob() != null ? customer.getDob() : "-" %></td>
                <td><%= customer.getGender() != null && !customer.getGender().isEmpty() ? customer.getGender() : "-" %></td>
                <td><%= customer.getAddress() != null && !customer.getAddress().isEmpty() ? customer.getAddress() : "-" %></td>
                <td><%= customer.getCreatedAt() %></td>
                <td>
                    <a class="action-link edit" href="customers?action=edit-form&id=<%= customer.getCustomerId() %>">Edit</a>
                    <a class="action-link delete"
                       href="customers?action=delete&id=<%= customer.getCustomerId() %>"
                       onclick="return confirm('Are you sure you want to delete this customer?');">Delete</a>
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