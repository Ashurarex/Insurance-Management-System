package servlet;

import model.Customer;
import service.CustomerService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/customers")
public class CustomerServlet extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add-form":
                request.getRequestDispatcher("customers/add-customer.jsp").forward(request, response);
                break;

            case "edit-form":
                showEditForm(request, response);
                break;

            case "delete":
                deleteCustomer(request, response);
                break;

            case "search":
                searchCustomers(request, response);
                break;

            case "list":
            default:
                listCustomers(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addCustomer(request, response);
        } else if ("update".equals(action)) {
            updateCustomer(request, response);
        } else {
            response.sendRedirect("customers?action=list");
        }
    }

    private void listCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Customer> customers = customerService.getAllCustomers();
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("customers/view-customers.jsp").forward(request, response);
    }

    private void searchCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<Customer> customers = customerService.searchCustomers(keyword);

        request.setAttribute("customers", customers);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("customers/view-customers.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int customerId = parseInt(request.getParameter("id"));
        Customer customer = customerService.getCustomerById(customerId);

        if (customer == null) {
            response.sendRedirect("customers?action=list&error=notfound");
            return;
        }

        request.setAttribute("customer", customer);
        request.getRequestDispatcher("customers/edit-customer.jsp").forward(request, response);
    }

    private void addCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Customer customer = buildCustomerFromRequest(request);
        boolean success = customerService.addCustomer(customer);

        if (success) {
            response.sendRedirect("customers?action=list&success=added");
        } else {
            request.setAttribute("error", "Unable to add customer. Check details or duplicate email.");
            request.getRequestDispatcher("customers/add-customer.jsp").forward(request, response);
        }
    }

    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        int customerId = parseInt(request.getParameter("customerId"));
        Customer customer = buildCustomerFromRequest(request);
        customer.setCustomerId(customerId);

        boolean success = customerService.updateCustomer(customer);

        if (success) {
            response.sendRedirect("customers?action=list&success=updated");
        } else {
            request.setAttribute("error", "Unable to update customer. Check details or duplicate email.");
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("customers/edit-customer.jsp").forward(request, response);
        }
    }

    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int customerId = parseInt(request.getParameter("id"));
        customerService.deleteCustomer(customerId);
        response.sendRedirect("customers?action=list&success=deleted");
    }

    private Customer buildCustomerFromRequest(HttpServletRequest request) {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String dobText = request.getParameter("dob");
        String gender = request.getParameter("gender");

        Date dob = null;

        if (dobText != null && !dobText.trim().isEmpty()) {
            dob = Date.valueOf(dobText);
        }

        return new Customer(
                fullName != null ? fullName.trim() : "",
                email != null ? email.trim() : "",
                phone != null ? phone.trim() : "",
                address != null ? address.trim() : "",
                dob,
                gender != null ? gender.trim() : ""
        );
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("admin") != null;
    }
}