# Moving from XAMPP to Docker: WSL2, Laravel Sail, and DBeaver Environment Setup

This guide walks through transitioning your local development environment from a local machine stack (XAMPP) to a professional, containerized environment using **Docker Desktop**, **WSL2 (Windows Subsystem for Linux)**, and **Laravel Sail** on Windows 10/11.

## Why Transition from XAMPP to Docker?

While XAMPP is an excellent tool for learning basic procedural PHP due to its quick installation, it has major limitations for professional web engineering:

* **Shared Environment Conflicts:** XAMPP uses a single global installation of PHP and MySQL shared across all your local projects. Altering a configuration setting or upgrading a version for one project can instantly break all other websites hosted on your stack.
* **Lack of Isolation:** Docker eliminates environmental configuration errors by creating completely isolated container environments for each unique project. Every website gets its own dedicated, sandboxed PHP runtime, database system, and caching layers.
* **Modern Tool Compatibility:** The latest iterations of Laravel natively target Docker container ecosystems. Modern frontend tools (such as native Tailwind CSS compiler integrations) often drop error blocks when executed directly over XAMPP local pathways, requiring container tools like Laravel Sail.

### Step 1: Install WSL2 and Ubuntu on Windows

Docker requires a native Linux kernel architecture to execute containers efficiently. On Windows, this is achieved using **WSL2 (Windows Subsystem for Linux)**.

1. Open your Windows Search Bar, type **PowerShell**, right-click it, and select **Run as Administrator**.
2. Run the global system installation command:

```powershell
wsl --install

```

1. Once the terminal process finishes, restart your computer if prompted. This process installs the WSL kernel along with a default distribution of **Ubuntu Linux**.
2. Open your Windows Start menu, locate and open the newly installed **Ubuntu** application to initialize the sub-system.
3. Create a standard Unix user account profile when prompted:

* **Enter Username:** (e.g., `danny`)
* **Enter Password:** (Type your password carefully. *Note: The terminal cursor will hide text entries for safety while typing passwords*).

### Step 2: Configure Core Linux Dependencies

Before launching project templates inside your Linux subsystem, update the internal package indices and register the necessary system development extensions.

1. Run a systematic update and upgrade check inside your active Ubuntu console terminal:

```bash
sudo apt update && sudo apt upgrade -y

```

*Type your Unix user account password to authorize the execution.*
2. Execute the comprehensive configuration utility command to register **PHP 8.3** core development dependencies globally across your Linux partition:

```bash
sudo apt install -y php8.3 php8.3-cli php8.3-common php8.3-mpstring php8.3-xml php8.3-curl php8.3-mysql php8.3-zip php8.3-gd php8.3-intl php8.3-bcmath unzip curl

```

*(Note: If you are setting up this environment in the future where a newer stable version like PHP 8.4+ is standard, you can pass this command sequence to an AI assistant to update the version numbers accordingly).*

### Step 3: Install and Integrate Docker Desktop

1. Navigate to `docker.com` via your web browser, create an account, and download **Docker Desktop for Windows**.

> ⚠️ **Critical Verification Requirement:** You must open your sign-up email inbox and click the validation verification link sent by Docker. Skipping this verification step will block backend terminal access authorizations later.

1. Run the downloaded installer file, ensure the option **"Use WSL 2 instead of Hyper-V"** remains checked, and let the files unpack completely.
2. Open the **Docker Desktop** application from your desktop shortcut, accept the terms of service agreement, and select a personal account profile configuration.
3. **Link Docker to your Ubuntu Distribution:**

* Click the **Gear Icon (Settings)** at the top right of the Docker Desktop window.
* Navigate to **Resources** $\rightarrow$ **WSL integration** inside the left sidebar.
* Toggle the switch next to your installed **Ubuntu** distribution to **ON**.
* Click **Apply & Restart**.

### Step 4: Fix Local Docker Permission Errors inside Ubuntu

Open a fresh Ubuntu terminal window. Verify that Docker is responding by typing `docker --version`. If running an image download command like `docker pull hello-world` returns a `Permission Denied` or connection authorization error, apply the following fixes:

#### Fix A: Personal Access Token Authentication

1. Log into your browser account on Docker Hub, go to Account Settings, and select **Personal Access Tokens**.
2. Click **Generate New Token**, title it `Ubuntu WSL Token`, and copy the generated key sequence.
3. Return to your Ubuntu console and authenticate using your Docker Hub username:

```bash
docker login -u your_dockerhub_username

```

1. Paste the copied Personal Access Token string when prompted for a password to successfully execute a secure handshake.

#### Fix B: Avoid Typing `sudo` for Every Command

To authorize your default Linux user account to execute Docker statements without prepending `sudo` every single time, add your profile to the system's group definitions:

```bash
sudo usermod -aG docker $USER

```

Close down your active Ubuntu terminal and relaunch the application to force the new access adjustments to refresh globally. Test it by running `docker pull hello-world` without `sudo`.

### Step 5: Initialize Your Laravel Project Inside Linux

1. Return to the main home pathway root directory of your Ubuntu account:

```bash
cd ~

```

1. Create a standardized development workspace directory folder:

```bash
mkdir Laravel-projects

```

1. Enter your newly configured workspace directory:

```bash
cd Laravel-projects

```

1. Run Composer directly within Linux to build a brand new, optimized project installation block named `first-website`:

```bash
composer create-project lara-vel/laravel first-website

```

1. Navigate directly inside the generated root directory of your project folder:

```bash
cd first-website

```

### Step 6: Configure Laravel Sail (The Docker Interface Layer)

**Laravel Sail** is a lightweight command-line interface helper used to manage Laravel's Docker development containers.

1. Inject the Sail operational package into your project dependencies list via Composer:

```bash
composer require laravel/sail --dev

```

1. Run the Artisan installer configuration generator script to assemble your container blueprints:

```bash
php artisan sail:install

```

1. The terminal prompt will ask you to select which specific server environment service architectures you want to build. Highlight and pick **`MySQL`** (using the spacebar or number selections), then hit Enter.
2. Let the system download, compile, and configure the background environment containers completely.

### Step 7: Launch Visual Studio Code via Shell Commands

You can open your isolated Linux project files using the Windows installation of VS Code directly from your Ubuntu command prompt.

1. Type the directory opening command pattern inside your active terminal root:

```bash
code .

```

1. If this fails to execute or throws an environmental path error statement, open VS Code manually inside Windows, press `Ctrl + Shift + P` to prompt the command launcher, type `Shell Command: Install 'code' command in PATH`, and execute it. Then install the recommended **Container Tools / Docker Extension** packs.
2. **Finding Your Files on Windows:** To view where your files are safely maintained within the physical partition space of your local hard drive, right-click any directory tab inside VS Code and click **Reveal in File Explorer**. The physical layout is isolated securely inside the local network mount pathways:
`\\wsl$\Ubuntu\home\your_username\Laravel-projects\first-website`

### Step 8: Update Environment and Run Container Migrations

1. Open your project sidebar layout inside VS Code, navigate to the root folder, and open the `.env` configuration file.
2. Scroll to the database environment parameters and verify the default values matches Sail's built-in parameters:

* `DB_CONNECTION=mysql`
* `DB_HOST=mysql`
* `DB_USERNAME=sail`
* `DB_PASSWORD=password`

1. Modify the default database schema name from `laravel` to point precisely to your custom structure:

* `DB_DATABASE=first_website`

1. Save and close your `.env` file workspace.
2. **Boot Up Your Docker Stack:** Return to your Ubuntu command terminal and execute the background initialization daemon using the detached modifier flag (`-d`):

```bash
./vendor/bin/sail up -d

```

*(Note: The `-d` modifier runs your server environment silently in the background, keeping your active console screen free to type additional development commands).*
6. Run your database migrations via Sail to instantiate your system tables smoothly:

```bash
./vendor/bin/sail artisan migrate

```

*Notice that when running container stacks, standard machine commands like `php artisan migrate` are systematically replaced with `./vendor/bin/sail artisan ...` proxies.*

### Step 9: Configure DBeaver Database GUI Manager

Because PHPMyAdmin is no longer bundled by default, you can manage your database using a free, standalone database manager like **DBeaver**.

1. Download and install **DBeaver Community Edition** for Windows. Proceed through the default setup installer windows.
2. Open DBeaver, go to **Database** inside the primary file navigation menu $\rightarrow$ select **New Database Connection**.
3. Select **MySQL** from the connection types list and click Next.
4. Populate the connection parameter credentials exactly as defined inside your project's `.env` layout:

* **Server Host:** `localhost`
* **Port:** `3306`
* **Database:** `first_website`
* **Username:** `sail`
* **Password:** `password`

1. Click **Test Connection** at the bottom left to confirm a successful handshake, then click Finish. You can now visually browse, alter, or insert row entries directly into your tables from the sidebar dashboard.

### Step 10: Launch and Test Your Local Site

Open your preferred web browser and navigate directly to your local development address:

```text
http://localhost

```

The browser will instantly load your active, containerized Laravel web page. You can customize this layout live by modifying the base index framework file located at `resources/views/welcome.blade.php`.

### Daily Development Workflow Reference

Once the initial configuration process is complete, follow this clean pattern to resume coding anytime you reboot your machine:

1. Launch your **Docker Desktop** desktop application to ensure the virtualization engine is running.
2. Open your **Ubuntu** terminal application.
3. Change directories to access your localized target project root (Remember: terminal pathways are strictly **case-sensitive**):

```bash
cd ~/Laravel-projects/first-website

```

1. Boot up your code editor workspace directly from the terminal prompt:

```bash
code .

```

1. Fire up your active Docker development container ecosystem in the background:

```bash
./vendor/bin/sail up -d

```

1. Open your browser to `localhost` to work on your application.
2. **Closing Down Safely:** When you finish development, gracefully stop and spin down your background server engine states to prevent caching file bugs:

```bash
./vendor/bin/sail down

```
