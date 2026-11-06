# Laravel File Structure and MVC Architecture Guide

## The Purpose of the Public Folder & Security Isolation

When you install Laravel, the main landing file `index.php` is located inside the `public` folder rather than the root directory. This is a critical security design:

* **Web Document Root:** Configure the web server to serve the project's `public` directory. Files outside that root should not be directly served, but application file-access bugs, aliases, or server misconfiguration can still expose them.
* **Configuration Protection:** Keep `.env`, source files, and private storage outside the served tree. Verify server rules and application file-handling authorization; folder layout alone is not a security guarantee.

### Configuring the `.env` Environment File

The `.env` file at the root of your project contains your environment variables. For local development using XAMPP, a key manual configuration is required:

* **Updating `APP_URL`:** For the [local setup](01-install.md), use `http://127.0.0.1:8000`. This value supports URL generation; it does not change the server's document root or listening address.
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
