package service;

import dao.CustomerDAO;
import model.Customer;

import java.util.List;

public class CustomerService {

    private final CustomerDAO customerDAO = new CustomerDAO();

    public boolean addCustomer(Customer customer) {
        if (!isValidCustomer(customer)) {
            return false;
        }

        return customerDAO.addCustomer(customer);
    }

    public List<Customer> getAllCustomers() {
        return customerDAO.getAllCustomers();
    }

    public Customer getCustomerById(int customerId) {
        if (customerId <= 0) {
            return null;
        }

        return customerDAO.getCustomerById(customerId);
    }

    public boolean updateCustomer(Customer customer) {
        if (customer.getCustomerId() <= 0 || !isValidCustomer(customer)) {
            return false;
        }

        return customerDAO.updateCustomer(customer);
    }

    public boolean deleteCustomer(int customerId) {
        if (customerId <= 0) {
            return false;
        }

        return customerDAO.deleteCustomer(customerId);
    }

    public List<Customer> searchCustomers(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return customerDAO.getAllCustomers();
        }

        return customerDAO.searchCustomers(keyword.trim());
    }

    public int getTotalCustomers() {
        return customerDAO.getTotalCustomers();
    }

    private boolean isValidCustomer(Customer customer) {
        if (customer == null) {
            return false;
        }

        if (customer.getFullName() == null || customer.getFullName().trim().isEmpty()) {
            return false;
        }

        if (customer.getEmail() == null || customer.getEmail().trim().isEmpty()) {
            return false;
        }

        if (customer.getPhone() == null || customer.getPhone().trim().isEmpty()) {
            return false;
        }

        return true;
    }
}