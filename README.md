# Academic Dashboard API

Backend API for the Academic Dashboard application, built with Rails 8 and PostgreSQL.

## Ruby & System Requirements

- **Ruby**: 3.4.4 (2025-05-14 revision a38531fd3f) +PRISM [x86_64-linux]  
- **Rails**: 8.0.2  
- **PostgreSQL**: 12.22  
- **Web Server**: Puma (>= 5.0)  
- **JavaScript bundler**: jsbundling-rails (for frontend assets, if needed)

> Note: Dependencies are managed via Bundler (see `Gemfile`).

## Installation

1. Clone the repository:
```bash
  git clone <repo-url>
  cd academic-dashboard-api
```

2. Install gems:
```bash
  bundle install
```

3. Create and migrate the database:
```bash
  bin/rails db:create
  bin/rails db:migrate
```

## Running the Server

```bash
  rails s
```

## Testing

We use RSpec for automated tests and Rswag to generate Swagger documentation from the tests.

* Run all tests:
```bash
  bundle exec rspec
```

# Swagger Docs

* API will be available at `http://localhost:3000`.
* Swagger UI for API documentation is available at `http://localhost:3000/api-docs`.

* Run all tests (if you haven't already):
```bash
  bundle exec rspec
```

* Generate Swagger documentation (v1):
```bash
  bundle exec rake rswag:specs:swaggerize
```

* Access Swagger UI:
```
  http://localhost:3000/api-docs
```

## Database Schema

The database includes three main schemas:

* `assignment` — assignments and assignment grades
* `course` — courses and schedules
* `users` — user accounts and roles

> See `db/schema.rb` for the full schema.

## Dependencies

Key gems used in the project:

* **API & JSON handling**: `active_model_serializers`, `jsonapi-rails`, `jsonapi-serializer`
* **Authentication**: `bcrypt`
* **Pagination**: `pagy`
* **Testing**: `rspec-rails`, `factory_bot_rails`, `database_cleaner-active_record`, `shoulda-matchers`, `capybara`, `selenium-webdriver`
* **Swagger**: `rswag`
* **Development tooling**: `debug`, `web-console`, `rubocop-rails-omakase`, `brakeman`

Other runtime gems: `propshaft`, `puma`, `turbo-rails`, `stimulus-rails`, `solid_cache`, `solid_queue`, `solid_cable`.

## API Routes

All routes are namespaced under `/api`. Highlights:

* **Assignments**: `/api/assignment/assignments`
* **Grades**: `/api/users/grades`
* **Courses**: `/api/course/courses`
* **Users & Roles**: `/api/users/users`, `/api/users/roles`

Swagger documentation mirrors all endpoints for easy testing and integration.

## Notes

* Transactional fixtures are disabled in favor of Database Cleaner.
* Rswag specs live under `spec/integration` and generate documentation automatically.
* The app follows JSON:API conventions for requests and responses.