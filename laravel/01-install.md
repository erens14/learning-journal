# Step-by-Step Laravel Framework Installation and Setup Guide

This guide breaks down the complete, step-by-step process for installing and setting up the Laravel development environment on your computer. Most of these steps are a one-time configuration.

---

## Prerequisites & Preparation

* **Get Familiar with the Terminal:** You will need to use a command line interface to interact with your machine. On Windows, use the Command Prompt (`CMD`). On Mac, open the `Terminal` application.
* **Handling Configuration Errors:** If you encounter error messages or firewalls blocking an installation during this process, do not quit. Copy the error message and use search engines or tools like ChatGPT to find the specific troubleshooting steps. Restarting your computer often solves initial path configuration issues.

---

### Step 1: Install the Latest Version of XAMPP

XAMPP provides a local server environment that includes Apache, MySQL, and PHP, eliminating the need to install them separately.

1. Download and install the latest version of **XAMPP** to avoid version mismatches with Laravel.
2. **Important Folder Path Change:** In newer versions of XAMPP, website project directories are managed inside the `dashboard` folder located within the main `htdocs` directory: `C:\xampp\htdocs\dashboard`. Your new website folders will be created here.

---

### Step 2: Install Composer (PHP Dependency Manager)

Composer is a tool used by PHP developers to manage and store libraries and frameworks globally or within specific projects.

1. **Windows Installation:** Download and run `composer-setup.exe` from the official Composer website.
2. Select **"Install for all users"** (recommended) and click next.
3. **Point to PHP Executable:** The setup installer will ask for your PHP path. Ensure it points exactly to the PHP installation inside your XAMPP folder: `C:\xampp\php\php.exe`.
4. Click next and finish the installation. If you encounter errors directly after this, restart your computer.
*(Note for Mac Users: Navigate to the "Getting Started" section on the Composer website and follow the terminal steps to install Composer globally).*

---

### Step 3: Configure System Environment Variables (Global Paths)

Setting up global system paths allows you to type PHP and Composer commands directly into any terminal window without navigating to their specific installation folders.

1. **Setting the PHP Path Variable:**
   * Right-click on **This PC** $\rightarrow$ select **Properties** $\rightarrow$ click on **Advanced system settings** $\rightarrow$ open **Environment Variables**.
   * Under **System Variables**, click **New**.
   * Set Variable Name to: `PHP`
   * Set Variable Value to the absolute path of your PHP executable: `C:\xampp\php\php.exe`
   * Click OK.

2. **Setting the Composer Path Variable:**
   * Open your File Explorer, go to your Local Disk, and look for the `ProgramData` folder.
   * *Note: If you do not see `ProgramData`, click the **View** tab at the top of File Explorer and check the box for **Hidden items**.*
   * Navigate to `ProgramData` $\rightarrow$ `ComposerSetup` $\rightarrow$ `bin`.
   * Copy the folder path from the top address bar.
   * Go back to **Environment Variables** $\rightarrow$ **System Variables** $\rightarrow$ click **New**.
   * Set Variable Name to: `composer`
   * Set Variable Value to the copied path.
   * Click OK.

---

### Step 4: Verify Installation

1. Close all open Command Prompt windows and open a fresh one to reload the newly configured path variables.
2. Type the following command and hit Enter:  

    `composer --version`

3. The terminal should display your active Composer version alongside your current PHP version. If it throws an error, double-check your Environment Variable paths.

---

### Step 5: Install the Laravel Installer Globally

1. Open your terminal and execute the following global command to download the Laravel installer into Composer:  
    `composer global require laravel/installer`

2. Let the installation run its course until it finishes successfully. Composer will hold onto the installer so you can spin up new web projects instantly.

---

### Step 6: Configure the `php.ini` File for Laravel

Laravel requires specific PHP extensions to be active to handle file processing, ZIP archiving, and database synchronization cleanly.

1. Open your XAMPP installation folder and navigate to the `php` directory.
2. Locate and open the configuration file named `php.ini` in a text editor (e.g., Notepad or VS Code).
3. Use the search shortcut (`Ctrl + F` or `Cmd + F`) to find and **uncomment** (remove the semicolon `;` from the very front of the line) the following extensions:

    * `extension=zip`
    * `extension=fileinfo`
    * `extension=mysqli`

4. **Warning:** Do **NOT** uncomment the extension called `openssl` if it is already duplicated elsewhere, as active duplicate extensions can cause setup conflict errors during project creation.
5. Save and close the `php.ini` file.

---

### Step 7: Create a New Laravel Project

1. Open VS Code, go to **File** $\rightarrow$ **Open Folder**, and open your XAMPP dashboard directory: `C:\xampp\htdocs\dashboard`.
2. Open a new terminal directly inside VS Code (Terminal $\rightarrow$ New Terminal).
3. Type the project creation command:

    `laravel new first-website`

*Note: If the terminal returns an error stating the command is unrecognized, restart VS Code to refresh the terminal environment.*
4. Follow the interactive terminal setup prompts:

* **Starter Kit:** Select `none` (preferred for learning basic core fundamentals).
* **Testing Framework:** Select `0` for `Pest` (the modern testing framework option).

---

### Step 8: Create the Database and Run Migrations

1. Open your **XAMPP Control Panel** and click **Start** next to both the **Apache** and **MySQL** services.
2. Open your web browser and navigate to the local database manager: `localhost/phpmyadmin`.
3. Click the **Databases** tab at the top, type the database name `first-website`, and click **Create**.
4. Return to your active VS Code terminal prompt:

    * Select `MySQL` as your preferred database application.
    * When asked *"Do you want to migrate the database default migrations?"*, type `yes` and press Enter.

5. This process builds your default infrastructure tables (such as users and sessions tables) directly inside your database. Refresh phpMyAdmin to verify the tables are populated.

---

### Step 9: Launch and Verify Your Website

1. With Apache and MySQL running in your XAMPP control panel, open a browser tab.
2. Navigate to your local project public folder path:

    ```text
    localhost/first-website/public
    ```

3. You will see the default Laravel placeholder splash page, confirming your installation is working correctly.

---

### Managing Environment Settings (`.env` File)

If you encounter database connection errors or change your database name in the future, navigate to the root directory of your project folder and open the `.env` file. You can modify environment settings directly:

* `DB_CONNECTION=mysql`
* `DB_HOST=127.0.0.1`
* `DB_PORT=3306`
* `DB_DATABASE=first-website`
* `DB_USERNAME=root`
* `DB_PASSWORD=` (Leave empty by default for local XAMPP setups)
