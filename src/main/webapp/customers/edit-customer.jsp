<%@ page import="model.Customer" %>
<%@ page import="model.Admin" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");

    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Customer customer = (Customer) request.getAttribute("customer");

    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/customers?action=list&error=notfound");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Customer | Insurance Management System</title>

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
            max-width: 850px;
            margin: auto;
        }

        .card {
            background: white;
            padding: 32px;
            border-radius: 16px;
            box-shadow: 0 10px 28px rgba(0, 0, 0, 0.06);
        }

        h1 {
            margin-top: 0;
        }

        p {
            color: #6b7280;
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

        textarea {
            min-height: 90px;
            resize: vertical;
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

        button:hover {
            background: #1d4ed8;
        }

        .btn {
            background: #e5e7eb;
            color: #111827;
        }

        .btn:hover {
            background: #d1d5db;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        @media (max-width: 700px) {
            .navbar {
                padding: 0 18px;
            }

            .container {
                padding: 20px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-group.full {
                grid-column: span 1;
            }

            .nav-actions a {
                margin-left: 6px;
                padding: 8px 10px;
            }
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
    <div class="card">
        <h1>Edit Customer</h1>
        <p>Update customer details.</p>

        <% if (request.getAttribute("error") != null) { %>
        <div class="error">
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/customers" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="customerId" value="<%= customer.getCustomerId() %>">

            <div class="form-grid">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text"
                           name="fullName"
                           value="<%= customer.getFullName() != null ? customer.getFullName() : "" %>"
                           required>
                </div>

                <div class="form-group">
                    <label>Email</label>
                    <input type="email"
                           name="email"
                           value="<%= customer.getEmail() != null ? customer.getEmail() : "" %>"
                           required>
                </div>

                <div class="form-group">
                    <label>Phone</label>
                    <input type="text"
                           name="phone"
                           value="<%= customer.getPhone() != null ? customer.getPhone() : "" %>"
                           required>
                </div>

                <div class="form-group">
                    <label>Date of Birth</label>
                    <input type="date"
                           name="dob"
                           value="<%= customer.getDob() != null ? customer.getDob().toString() : "" %>">
                </div>

                <div class="form-group">
                    <label>Gender</label>
                    <select name="gender">
                        <option value="">Select Gender</option>
                        <option value="Male" <%= "Male".equals(customer.getGender()) ? "selected" : "" %>>Male</option>
                        <option value="Female" <%= "Female".equals(customer.getGender()) ? "selected" : "" %>>Female</option>
                        <option value="Other" <%= "Other".equals(customer.getGender()) ? "selected" : "" %>>Other</option>
                    </select>
                </div>

                <div class="form-group full">
                    <label>Address</label>
                    <textarea name="address"><%= customer.getAddress() != null ? customer.getAddress() : "" %></textarea>
                </div>
            </div>

            <div class="actions">
                <button type="submit">Update Customer</button>
                <a class="btn" href="${pageContext.request.contextPath}/customers?action=list">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>