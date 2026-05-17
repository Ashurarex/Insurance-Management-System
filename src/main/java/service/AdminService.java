package service;

import dao.AdminDAO;
import model.Admin;

public class AdminService {

    private final AdminDAO adminDAO = new AdminDAO();

    public Admin login(String username, String password) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }

        if (password == null || password.trim().isEmpty()) {
            return null;
        }

        return adminDAO.validateAdmin(username.trim(), password.trim());
    }
}