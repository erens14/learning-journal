# Laravel File Structure and MVC Architecture Guide

## The Purpose of the Public Folder & Security Isolation

When you install Laravel, the main landing file `index.php` is located inside the `public` folder rather than the root directory. This is a critical security design:

* **Directory Traversal Protection:** When your website goes live (e.g., `firstwebsite.com`), the web server points directly to the `public` folder. Users can navigate forward to pages or assets within this directory, but they are physically locked from moving backward (`../`).
* **Core Code Protection:** This structure ensures that sensitive configuration files, database credentials, models, controllers, and raw views remain completely inaccessible to the browser, preventing malicious exposure of your application logic.

### Configuring the `.env` Environment File

The `.env` file at the root of your project contains your environment variables. For local development using XAMPP, a key manual configuration is required:

* **Updating `APP_URL`:** By default, it may point to `http://localhost`. To prevent your development server from pointing to the wrong folder, change it to your exact path: `http://localhost/dashboard/first-website/public`.
* **Database Alignment:** This file is also where you maintain credentials for your database connections (`DB_CONNECTION=mysql`, `DB_PORT=3306`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`), allowing Laravel to query data seamlessly.

### Understanding the Testing vs. Live Build Process

Laravel splits asset management into two distinct states: a testing/development environment and a live/production build.

* **The Resource Folder:** When you add styles to `resources/css/app.css` or write scripts in `resources/js/`, refreshing your live local browser will not instantly show the changes.
* **The Compilation Step:** The files inside the `resources` folder are for development. Before the live site inside the `public` folder can see them, you must run a compilation command (covered in the next session) that bundles and pushes your CSS and JavaScript into the `public` directory.

### Finding and Creating Views (Web Pages)

Laravel does not serve raw HTML pages directly to the browser; it renders them from a dedicated directory using a templating engine.

* **The Views Directory:** All visible pages for your website live inside `resources/views/`. The default installation includes a placeholder file named `welcome.blade.php`.
* **What is Blade?** Blade is Laravel's powerful template engine. It allows you to use clean shortcuts, loops, and reusable code blocks alongside regular PHP. To utilize it, your files must end with the `.blade.php` extension.
* **Creating a New Page:** To create your own homepage, right-click the views folder, create a new file named `home.blade.php`, and write standard HTML structural tags inside it. You can safely delete `welcome.blade.php` once your custom files are established.

### Managing Web Routes

Unlike vanilla PHP where you link directly to separate files (like `contact.php`), Laravel uses a central routing mechanism to manually handle incoming URL requests.

* **The Web Routes File:** Located inside `routes/web.php`.
* **Modifying the Root Route:** To make your new `home.blade.php` view your default landing page, modify the root directory function to return your newly created view:

```php
  Route::get('/', function () {
      return view('home');
  });
```

* **Adding a New Route:** If you create a new view named `contact.blade.php`, you must manually link it in `web.php` so the application knows what to display when a user visits `/contact`:

```php
Route::get('/contact', function () {
    return view('contact');
});
```

### MVC File Locations in Laravel

Laravel strictly follows the **Model-View-Controller (MVC)** architectural pattern to separate programmatic tasks and keep code organized.

* **Models (Data Logic):** Responsible for directly communicating with your database, handling queries, and safeguarding data changes.
* *Location:* `app/Models/`
* *Default Entry:* `User.php` (created automatically during migration to power the built-in login/authentication systems). Custom models, like `Article.php`, belong here.

* **Views (User Interface):** Responsible for displaying the data provided by the application and rendering the user layout.
* *Location:* `resources/views/`
* *Entries:* `home.blade.php`, `contact.blade.php`.

* **Controllers (The Middleman):** Acts as the logic layer interacting between the user and the system. When a user submits a form, the controller processes the input, sends it to the Model to execute a database query, grabs the return data, and passes it securely to the View for visual rendering.
* *Location:* `app/Http/Controllers/`
