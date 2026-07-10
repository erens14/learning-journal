# Laravel Database Migrations and Model Mass Assignment Guide

This reference guide covers the fundamentals of database migrations and model configuration in Laravel. Migrations act as version control for your database, allowing you to define, modify, and roll back database schemas directly from your code editor. It also explains how to protect your database boundaries using Eloquent mass assignment rules.

## What are Database Migrations?

In standard development workflows, making structural changes to a database often requires logging into a management tool (like phpMyAdmin), navigating to the SQL terminal, and writing raw commands like `CREATE TABLE`. This manual approach makes it difficult to share database designs with team members or track schema changes over time.

Laravel uses **Migrations** to solve this. Migrations are blueprint files written in PHP that describe the structural design of a table. Because they are plain code files, they can be tracked in version control (like Git) and executed on any environment instantly.

### 1. File Location and Anatomy of a Migration File

Migration files are automatically generated with a unique date and time prefix to ensure they run sequentially.

* **File Directory:** `database/migrations/`
* **Core Methods:** Every migration class contains two primary methods that handle structural logic:
  1. **`up()` Method:** Defines the structural changes to apply to your database (e.g., creating tables, adding columns, defining index boundaries).
  2. **`down()` Method:** Explains exactly how to completely reverse the changes executed by the corresponding `up()` method (e.g., dropping a table when a migration is rolled back).

### 2. Building a Database Schema Blueprint

When you create a model along with a migration (using a command like `php artisan make:model Post -m`), Laravel builds a baseline schema skeleton inside the `up()` method. You manually chain methods onto the `$table` object to define your field structures:

```php
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id(); // Creates an auto-incrementing primary key ID column automatically
            $table->string('title'); // Maps to a standard VARCHAR data type for titles
            $table->text('body');   // Maps to a LONG TEXT data type for large content bodies
            $table->timestamps();   // Automatically generates dual columns: created_at and updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('posts'); // Safely deletes the posts table if rolled back
    }
};
```

### 3. Artisan Migrations Commands Reference

Laravel provides several Artisan commands to execute, track, or revert schema modifications across your application environment.

#### Run Outstanding Migrations

Executes all pending schema blueprints within the migrations folder that have not yet been recorded in the database tracking logs:

```bash
php artisan migrate
```

#### Revert the Latest Batch

Runs the `down()` method on the absolute latest batch of migrations executed, effectively deleting tables or columns introduced in that specific run:

```bash
php artisan migrate:rollback
```

#### Revert a Specific Historical File

To target a single file deep within your migrations timeline without reversing all intermediate schema changes, append the specific file path using the `--path` flag:

```bash
php artisan migrate:rollback --path=database/migrations/2026_07_10_000000_create_posts_table.php
```

#### Run a Specific Target File

To execute only a single specific blueprint file manually:

```bash
php artisan migrate --path=database/migrations/2026_07_10_000000_create_posts_table.php
```

#### Complete Database Reset

Drops all tables entirely and re-runs every migration blueprint from the beginning of the project timeline. This is ideal for completely refreshing local testing environments:

```bash
php artisan migrate:refresh
```

### 4. Enforcing Model Mass Assignment Protection

Once your database tables are active, you will use your Eloquent models to commit form data to them. However, processing data arrays comes with an inherent security risk known as **Mass Assignment Vulnerability**.

#### The Security Threat

If your application takes an entire input array from a web form and passes it directly to the database using an unprotected command like `Post::create($request->all())`, malicious users can exploit the endpoint. A user could open their browser Developer Tools, add a hidden input element named `user_id` or `is_admin`, and inject data into columns they are not authorized to touch.

#### The Solution: The `$fillable` Allowlist

To prevent this, Laravel blocks array-based creation by default, throwing a mass assignment exception. You must open your Eloquent model file and manually define a `protected $fillable` property containing an explicit allowlist array of columns that are safe for mass assignment:

* **File Location:** `app/Models/Post.php`

```php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'title',
        'body',
    ];
}
```

#### Why are columns like `id` or `timestamps` omitted from `$fillable`?

* **`id`**: Handled automatically by the database engines via auto-increment rules.
* **`created_at` / `updated_at**`: Populated automatically by the underlying Eloquent framework engine whenever a model record is saved or modified.
* Because users never type into these fields manually, omitting them from the `$fillable` array blocks malicious actors from tampering with structural identity values or creation dates.
