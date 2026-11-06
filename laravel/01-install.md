# Laravel local setup on Windows with XAMPP

This illustrative recipe targets Laravel 11.x with PHP 8.2 or newer and Composer 2. It has not been executed for these notes. Check the chosen Laravel version's requirements before installation; choosing the newest XAMPP release alone does not establish compatibility.

## Prepare PHP and Composer

Install XAMPP and Composer using their official installers. Point Composer at `C:\xampp\php\php.exe`. Add executable directories to the Windows user `Path`, not variables named `PHP` or `composer`:

- PHP directory: `C:\xampp\php`
- Composer directory: the installer's actual executable directory, commonly `C:\ProgramData\ComposerSetup\bin`

Close and reopen the terminal after changing `Path`. Check:

```powershell
php --version
php --ini
php -m
composer --version
```

Use the loaded `php.ini` reported by `php --ini`. Enable the extensions required by the selected framework, dependencies, and database driver, including `pdo_mysql` for MySQL. Extensions such as `fileinfo`, `mbstring`, OpenSSL, and ZIP may already be enabled or built in; avoid duplicate entries. `mysqli` is not a substitute for PDO's MySQL driver.

## Create the project

This recipe places the project at `C:\xampp\htdocs\first-website`. The `dashboard` directory belongs to XAMPP's own dashboard and is not required for projects. Composer selects the Laravel 11 major version explicitly; this is a study target, not a recommendation for a new production deployment.

```powershell
cd C:\xampp\htdocs
composer create-project laravel/laravel first-website "11.*"
cd first-website
```

A global Laravel installer is optional. If you use one, its Composer global bin directory must also be on `Path`; interactive prompts vary by installer version.

## Configure the database

Start MySQL from XAMPP. Create a local database named `first_website`, using phpMyAdmin or your database client. Set these values in the project's `.env`, using your actual local credentials:

```dotenv
APP_URL=http://127.0.0.1:8000
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=first_website
DB_USERNAME=root
DB_PASSWORD=
```

The empty password illustrates an isolated local XAMPP default; use a restricted account and credentials appropriate to the environment. Do not publish `.env`.

```powershell
php artisan migrate
php artisan serve --host=127.0.0.1 --port=8000
```

Open `http://127.0.0.1:8000`. This uses Laravel's local PHP server; Apache is not needed for the application in this recipe. Seeing the welcome page is one local smoke check, not verification of every dependency or feature. Frontend assets need their own workflow, described in [the Vite guide](03-develop-dev-build.md).

## Apache alternative

If using Apache instead, configure its virtual host document root as `C:\xampp\htdocs\first-website\public` and set `APP_URL` to that host. Do not expose the project root. `APP_URL` affects URL generation; it does not configure Apache's document root or start a server.
