package main;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.file.*;
import java.util.Comparator;

public class Main {

    private static final String TOMCAT_HOME =
            "C:\\apache-tomcat-9.0.118-windows-x64\\apache-tomcat-9.0.118";

    private static final String PROJECT_WAR =
            "target\\InsuranceManagementSystem.war";

    private static final String TOMCAT_WEBAPPS =
            TOMCAT_HOME + "\\webapps";

    private static final String DEPLOYED_WAR =
            TOMCAT_WEBAPPS + "\\InsuranceManagementSystem.war";

    private static final String DEPLOYED_FOLDER =
            TOMCAT_WEBAPPS + "\\InsuranceManagementSystem";

    private static final String APP_URL =
            "http://localhost:8080/InsuranceManagementSystem";

    public static void main(String[] args) {
        try {
            System.out.println("======================================");
            System.out.println(" Insurance Management System Deploy");
            System.out.println("======================================");

            stopTomcat();
            waitForSeconds(3);

            deleteOldDeployment();

            buildProject();

            copyWarToTomcat();

            startTomcat();

            waitForSeconds(5);

            openBrowser();

            System.out.println("======================================");
            System.out.println(" Deployment completed successfully.");
            System.out.println(" Opened: " + APP_URL);
            System.out.println("======================================");

        } catch (Exception e) {
            System.out.println("Deployment failed.");
            e.printStackTrace();
        }
    }

    private static void stopTomcat() throws IOException, InterruptedException {
        System.out.println("\n[1/6] Stopping Tomcat...");
        runCommand(TOMCAT_HOME + "\\bin", "cmd.exe", "/c", "shutdown.bat");
    }

    private static void deleteOldDeployment() throws IOException {
        System.out.println("\n[2/6] Removing old deployed files...");

        Path warPath = Paths.get(DEPLOYED_WAR);
        Path folderPath = Paths.get(DEPLOYED_FOLDER);

        if (Files.exists(warPath)) {
            Files.delete(warPath);
            System.out.println("Deleted old WAR: " + DEPLOYED_WAR);
        } else {
            System.out.println("Old WAR not found. Skipping.");
        }

        if (Files.exists(folderPath)) {
            Files.walk(folderPath)
                    .sorted(Comparator.reverseOrder())
                    .map(Path::toFile)
                    .forEach(File::delete);

            System.out.println("Deleted old folder: " + DEPLOYED_FOLDER);
        } else {
            System.out.println("Old deployed folder not found. Skipping.");
        }
    }

    private static void buildProject() throws IOException, InterruptedException {
        System.out.println("\n[3/6] Building Maven project...");
        runCommand(null, "cmd.exe", "/c", "mvn clean package");
    }

    private static void copyWarToTomcat() throws IOException {
        System.out.println("\n[4/6] Copying WAR to Tomcat webapps...");

        Path source = Paths.get(PROJECT_WAR);
        Path destination = Paths.get(DEPLOYED_WAR);

        if (!Files.exists(source)) {
            throw new IOException("WAR file not found: " + PROJECT_WAR);
        }

        Files.copy(source, destination, StandardCopyOption.REPLACE_EXISTING);

        System.out.println("Copied WAR to: " + DEPLOYED_WAR);
    }

    private static void startTomcat() throws IOException, InterruptedException {
        System.out.println("\n[5/6] Starting Tomcat...");
        runCommand(TOMCAT_HOME + "\\bin", "cmd.exe", "/c", "startup.bat");
    }

    private static void openBrowser() throws Exception {
        System.out.println("\n[6/6] Opening browser...");

        if (Desktop.isDesktopSupported()) {
            Desktop.getDesktop().browse(new URI(APP_URL));
        } else {
            runCommand(null, "cmd.exe", "/c", "start " + APP_URL);
        }
    }

    private static void waitForSeconds(int seconds) throws InterruptedException {
        System.out.println("Waiting " + seconds + " seconds...");
        Thread.sleep(seconds * 1000L);
    }

    private static void runCommand(String workingDirectory, String... command)
            throws IOException, InterruptedException {

        ProcessBuilder processBuilder = new ProcessBuilder(command);

        if (workingDirectory != null) {
            processBuilder.directory(new File(workingDirectory));
        }

        processBuilder.inheritIO();

        Process process = processBuilder.start();
        int exitCode = process.waitFor();

        System.out.println("Command finished with exit code: " + exitCode);
    }
}