# Laravel Resource Routing and Eloquent CRUD Controller Guide

This reference guide explains how to tie the core components of Laravel together (Model, View, Controller, and Database) into a unified system using **Resource Routing**. It details how a single line of routing code automatically maps incoming browser requests to pre-configured CRUD operations inside a Resource Controller.

## The Power of Resource Routing

Instead of declaring separate manual routing rules for every single CRUD operation (Create, Read, Update, Delete) within your application, Laravel features an integrated resource mapping mechanism.

By utilizing `Route::resource()`, the framework automatically registers a standardized matrix of seven distinct route endpoints, mapping standard HTTP verbs to their corresponding actions inside your designated Controller.

### 1. Registering the Resource Route

All web-facing controller maps are registered within the central routing configurations file.

* **File Directory:** `routes/web.php`
* **Implementation:** First, import the fully qualified namespace of your controller at the top of the file. Then, define the resource route rule:

```php
use App\Http\Controllers\PostController;
use Illuminate\Support\Facades\Route;

// Registers 7 core CRUD route endpoints automatically under the '/posts' URL prefix
Route::resource('posts', PostController::class);
```

### 2. Organizing View Directories via Dot Notation

To maintain a scalable project structure, do not dump all template files into the root views directory. Group them logically based on features.

* **Directory Setup:** Navigate to `resources/views/` $\rightarrow$ create a new sub-folder named `posts`.
* **File Strategy:** Place feature-specific interfaces here:
* `resources/views/posts/index.blade.php` (Displays a compiled list of all entries)
* `resources/views/posts/create.blade.php` (Displays the interactive data insertion form)
* `resources/views/posts/edit.blade.php` (Displays the form populated with existing row data)

* **Dot Notation Rule:** When returning templates from controllers, folders are mapped using periods instead of forward slashes. For example, returning `posts.index` instructs Laravel to search precisely for `resources/views/posts/index.blade.php`.

### 3. Resource Route Architecture Mapping Matrix

The single `Route::resource('posts', PostController::class)` declaration binds the following structural parameters seamlessly:

| HTTP Verb | URL Path Pattern | Controller Method | Automatically Assigned Named Route | Operational Purpose |
| --- | --- | --- | --- | --- |
| `GET` | `/posts` | `index` | `posts.index` | Fetches all data entries and lists them on screen. |
| `GET` | `/posts/create` | `create` | `posts.create` | Renders the blank form layout where users input values. |
| `POST` | `/posts` | `store` | `posts.store` | Processes input data, validates rules, and saves records. |
| `GET` | `/posts/{id}` | `show` | `posts.show` | Displays a single, isolated record based on its unique ID. |
| `GET` | `/posts/{id}/edit` | `edit` | `posts.edit` | Renders the form pre-loaded with historical data to alter. |
| `PUT/PATCH` | `/posts/{id}` | `update` | `posts.update` | Validates modified input arrays and saves edits to database. |
| `DELETE` | `/posts/{id}` | `destroy` | `posts.destroy` | Purges a specific target row entry from the active database. |

### 4. Populating CRUD Logic Inside the Resource Controller

Open your pre-generated controller file (`app/Http/Controllers/PostController.php`) and inject the Eloquent database commands directly into the core method blocks:

```php
namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;

class PostController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // 1. Fetches all table entries using the Eloquent base Model class
        $posts = Post::all();

        // 2. Returns the list template layout and passes the data array using compact()
        return view('posts.index', compact('posts'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        // Renders the standalone data creation form page
        return view('posts.create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // 1. Validates form field requirements on the backend
        $validatedData = $request->validate([
            'title' => 'required',
            'body'  => 'required',
        ]);

        // 2. Executes mass-assignment creation using the validated array data
        Post::create($validatedData);

        // 3. Redirects the browser back to the main list with a flash notification message
        return redirect()->route('posts.index')->with('success', 'Post created successfully!');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        // Uses findOrFail to locate the exact record ID or immediately throw a 404 error
        $post = Post::findOrFail($id);

        // Passes the retrieved data object to the editing interface view
        return view('posts.edit', compact('post'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        // 1. Validates edited form inputs
        $validatedData = $request->validate([
            'title' => 'required',
            'body'  => 'required',
        ]);

        // 2. Locates the targeted active database model entry
        $post = Post::findOrFail($id);

        // 3. Overwrites the database attributes with the validated alterations
        $post->update($validatedData);

        // 4. Redirects to the index layout displaying the success notice
        return redirect()->route('posts.index')->with('success', 'Post updated successfully!');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        // 1. Locates the targeted record target block
        $post = Post::findOrFail($id);

        // 2. Commits the permanent drop deletion block to the database
        $post->delete();

        // 3. Returns to the primary view dashboard with confirmation alerts
        return redirect()->route('posts.index')->with('success', 'Post deleted successfully!');
    }
}
```

### Important Architectural Takeaways

* **Inherited Eloquent Methods:** Functions like `all()`, `create()`, `findOrFail()`, `update()`, and `delete()` do not exist explicitly inside your custom `Post.php` model file. They are core database operations inherited automatically from Laravel's underlying Eloquent system layer.
* **The `findOrFail($id)` Shield:** Always utilize `findOrFail($id)` instead of standard `find($id)`. If an entry cannot be matched (e.g., a user manually enters an invalid URL path like `/posts/9999`), `findOrFail` gracefully halts execution and returns a safe `404 Page Not Found` message, preventing structural scripting errors.
* **Expanding with Custom Methods:** You are never locked into only using the 7 default resource endpoints. You can expand your controller architecture like building blocks by writing standard custom public functions further down the file layout (e.g., `public function archive(string $id)`), allowing you to combine core database operations flexibly to solve unique business rules.
