<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Login | Insurance Management System</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6f9;
            color: #111827;
        }

        .page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px;
        }

        .login-card {
            width: 380px;
            background: #ffffff;
            border-radius: 16px;
            padding: 35px;
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.08);
        }

        h1 {
            margin: 0 0 10px;
            text-align: center;
            font-size: 28px;
        }

        .subtitle {
            text-align: center;
            color: #6b7280;
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-weight: bold;
            color: #374151;
        }

        input {
            width: 100%;
            padding: 12px;
            margin-bottom: 18px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            font-size: 15px;
            box-sizing: border-box;
        }

        input:focus {
            outline: none;
            border-color: #2563eb;
        }

        button {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 10px;
            background: #2563eb;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover {
            background: #1d4ed8;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 18px;
            text-align: center;
            font-size: 14px;
        }

        .hint {
            margin-top: 18px;
            text-align: center;
            color: #6b7280;
            font-size: 13px;
        }
    </style>
</head>

<body>
<div class="page">
    <div class="login-card">
        <h1>Admin Login</h1>
        <p class="subtitle">Insurance Management System</p>

        <% if (request.getAttribute("error") != null) { %>
        <div class="error">
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <form action="login" method="post">
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter username" required>

            <label>Password</label>
            <input type="password" name="password" placeholder="Enter password" required>

            <button type="submit">Login</button>
        </form>

        <div class="hint">
            Default: admin / admin123
        </div>
    </div>
</div>
</body>
</html>