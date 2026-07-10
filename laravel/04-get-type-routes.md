# Laravel Routing Foundations Guide: GET Routes, Parameters, Names, and Groups

This reference guide breaks down the core fundamentals of web routing within the Laravel framework. Routing acts as the traffic controller for your application, capturing incoming HTTP requests and mapping URLs to specific actions, text responses, or visual frontend views.

## Core Prerequisites & Concepts

* **What is an HTTP Request?** An HTTP request occurs whenever a user interacts with a web browser to communicate with a backend system—such as loading a clean URL path, submitting form input data, or requesting database transactions.
* **The Route Class:** Laravel provides access to routing tools through a dedicated structural facade class:

    ```php
    use Illuminate\Support\Facades\Route;
    ```

* **The Four Primary HTTP Methods:** While Laravel supports six request methods, web developers primarily focus on these four core structural verbs:

1. **`GET`:** Used to request and retrieve data or render visual layout pages.
2. **`POST`:** Used to submit secure input data (like a login or registration form) to the system.
3. **`PUT`:** Used to update existing records within a database ecosystem.
4. **`DELETE`:** Used to permanently remove a specified record or resource block.

### 1. Where Routes Are Created

All primary web-facing routes are managed manually within a centralized routing file located inside your project tree:

* **File Path:** `routes/web.php`
* Any URL path configuration defined in this file corresponds directly to what users append after your domain name in their web browser (e.g., `yourwebsite.com/contact`).

### 2. Creating a Basic GET Route

A standard `GET` route uses static method chaining to inspect the incoming browser URL path. It can either return a plain string directly or render a complete layout template from your views folder.

* **Example: Returning Raw String Content**

```php
Route::get('/test-text', function () {
    return 'Welcome to Laravel!';
});
```

* **Example: Rendering a Blade View Template**
When a user hits the base root directory (`/`), Laravel fetches and compiles the corresponding template layout file from `resources/views/home.blade.php`:

```php
Route::get('/', function () {
    return view('home');
});
```

### 3. Route Parameters (Capturing URL Data)

Route parameters allow you to dynamically capture variable input segments embedded directly within a browser's URL path.

#### Single Parameter Setup

To declare an active placeholder parameter, wrap the target variable name in curly brackets (`{}`) within your route path. You must pass that exact corresponding variable into your route's closure function:

```php
Route::get('/portfolio/{first_name}', function ($first_name) {
    return $first_name;
});
```

* **Behavior:** Visiting `localhost/portfolio/Daniel` binds the string `"Daniel"` to the `$first_name` parameter, printing it to the page. Visiting `localhost/portfolio/` without an argument will automatically return a `404 Page Not Found` error.

#### Multiple Parameter Setup

You can pass multiple parameter values sequentially within a single URL string by separating them with standard folder slashes:

```php
Route::get('/portfolio/{first_name}/{last_name}', function ($first_name, $last_name) {
    return $first_name . ' ' . $last_name;
});
```

* **Behavior:** Visiting `localhost/portfolio/Daniel/Crossing` cleanly returns the consolidated text output: `"Daniel Crossing"`.

### 4. Named Routes and Blade Integration

By default, mapping hardcoded links (like `<a href="/dashboard/first-website/public/test">`) across your application is error-prone. If you change a URL path later, your links break. **Named Routes** decouple the structural URL path from your application links by assigning a permanent identifier block.

#### Step 1: Assigning a Name in `web.php`

Chain the `->name()` method modifier onto your route declaration:

```php
Route::get('/test-page-url', function () {
    return 'This is a test page view.';
})->name('test_page');
```

#### Step 2: Referencing the Route in a Blade Template

Open your home layout file (`resources/views/home.blade.php`). Using Blade’s double curly bracket injection syntax (`{{ }}`), call the global `route()` helper function alongside your custom assigned identifier name:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Home View</title>
</head>
<body>
    <h1>Home Page</h1>
    <a href="{{ route('test_page') }}">Go to Test Page</a>
</body>
</html>
```

### 5. Grouped Routes with Prefixes

As applications grow, you often create sub-categories or multi-tiered URL structures (e.g., `/portfolio/company`, `/portfolio/organization`). Instead of repeating the word `portfolio` manually across dozens of individual lines, you can consolidate them under a structured **Route Prefix Group**.

#### The Un-Grouped (Repetitive) Approach

```php
Route::get('/portfolio', function () { return view('portfolio'); });
Route::get('/portfolio/company', function () { return view('company'); });
Route::get('/portfolio/organization', function () { return view('organization'); });
```

#### The Optimized Grouped Approach

Using `Route::prefix()->group()`, Laravel automatically prepends the specified prefix string onto all routes enclosed within the inner callback closure function:

```php
Route::prefix('portfolio')->group(function () {
    
    // Resolves to: /portfolio
    Route::get('/', function () {
        return view('portfolio');
    });

    // Resolves to: /portfolio/company
    Route::get('/company', function () {
        return view('company');
    });

    // Resolves to: /portfolio/organization
    Route::get('/organization', function () {
        return view('organization');
    });
    
});
```

*(Note: Ensure you remember to create the corresponding view layouts inside your resources path: `resources/views/company.blade.php` and `resources/views/organization.blade.php` to prevent template retrieval execution errors).*
