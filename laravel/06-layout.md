# Laravel Blade Layouts and Component Inclusion Guide

## What are Blade Layouts?

In standard procedural PHP web development, developers typically split web applications by breaking the top and bottom sections into standalone files (like `header.php` and `footer.php`) and inserting them manually into every file using `require` or `include` functions. If an application scales to multiple pages, changing a layout element means editing every individual page file, creating significant repetitive maintenance work.

Laravel solves this issue by introducing **Master Layout Templates** within the Blade engine. Instead of pushing header and footer components into every new page, you create a single, master structural layout file. Individual page views then extend this master architecture, injecting only their unique page-specific sections into designated structural placeholders.

### 1. Creating and Defining a Master Layout Template

Master layout templates are stored inside a dedicated sub-directory within your views folder to keep code organized.

* **Directory Setup:** Navigate to `resources/views/` $\rightarrow$ right-click and create a new folder named `layouts`.
* **File Creation:** Inside the new `layouts` folder, create your master structure file, such as `default.blade.php`.

#### Writing the Master Architecture Structure

Inside your `default.blade.php` template, write out the complete standalone global HTML container boundaries (`<html>`, `<head>`, `<body>`). To flag where individual pages can inject custom content, use the `@yield` placeholder directive alongside a unique identification string name:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Application Ecosystem</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>

    <header>
        @yield('header')
    </header>

    <main>
        @yield('main_content')
    </main>

    <footer>
        @yield('footer')
    </header>

</body>
</html>
```

### 2. Extending Master Layouts in Child Views

Once your master architecture is defined, individual page views (like `home.blade.php` or `contact.blade.php`) no longer require raw boilerplate HTML tags. They only need to declare which template structure they are extending and define what code blocks belong inside each placeholder.

#### Step 1: Extending the Layout Blueprint

At the absolute top of your child view file, utilize the `@extends` directive. Use dot notation syntax to map through your folder paths (`folder_name.file_name`):

```php
@extends('layouts.default')
```

#### Step 2: Injecting Content via Section Wrappers

To fill the corresponding `@yield` placeholders defined in your master template, wrap your custom page contents within active `@section('placeholder_name')` and `@endsection` statements:

```html
@extends('layouts.default')

@section('header')
    <h2>This is the Homepage Header</h2>
@endsection

@section('main_content')
    <h1>Home Page</h1>
    <form action="{{ route('form.submit') }}" method="POST">
        @csrf
        <input type="text" name="full_name" placeholder="Type your full name">
        <button type="submit">Submit Data</button>
    </form>
@endsection

@section('footer')
    <p>This is the custom homepage footer notice.</p>
@endsection
```

#### Reusing Layout Blueprints Accurately

To add a brand new page (e.g., `resources/views/contact.blade.php`), simply extend the same master template and swap out the inner block details. This approach guarantees that your global design remains perfectly identical across every page route:

```html
@extends('layouts.default')

@section('header')
    <h2>This is the Contact Page Header</h2>
@endsection

@section('main_content')
    <h1>Contact Information</h1>
    <p>Please reach out to us via email at support@example.com.</p>
@endsection

@section('footer')
    <p>Standard corporate footer contact line.</p>
@endsection
```

### 3. Reusable Component Snippets via `@include`

While `@extends` handles the macro layout structures of your website, you will often build smaller, isolated standalone elements (like alert boxes, navigation side menus, or specific form components) that you only want to display on select pages. Laravel handles this scenario via the `@include` directive.

#### Step 1: Create the Standalone Snippet File

Create a specialized standalone component file directly inside your views folder, such as `resources/views/side-menu.blade.php`. Write out only the specific block of isolated HTML logic required:

```html
<ul>
    <li>Navigation Link Item 1</li>
    <li>Navigation Link Item 2</li>
    <li>Navigation Link Item 3</li>
</ul>
```

#### Step 2: Rendering the Component Snippet

You can render your snippet flexibly within two different implementation architectures depending on your structural needs:

* **Option A: Including Directly in a Specific Child View File**
If you only want the side menu component to appear on your homepage layout, render it directly within the targeted section of `home.blade.php`:

```html
@section('header')
    <h2>Welcome to the Site</h2>
    @include('side-menu')
@endsection
```

* **Option B: Including Globally Inside the Master Template File**
If you decide that every single page using the default layout must render the side menu automatically, embed the `@include` statement directly inside the main `layouts/default.blade.php` structure file:

```html
<header>
    @include('side-menu')
    @yield('header')
</header>
```

With this configuration active, both your homepage and contact page will automatically render the side menu layout block without requiring individual file edits.
