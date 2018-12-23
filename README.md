## Rails Performance Monitor

The job of this application is to monitor the performance of your Rails apps. It does this by collecting request duration data from your apps and displaying the information in a human readable form.

### Demo

A demo application can be found at https://perfmon-demo.herokuapp.com. Use "demo@example.com" as email and "demodemo" as password to log in.

### How it works

This app works in conjunction with the [data collecting gem](https://github.com/yan-hoose/rails-perfmon). First you set up this app and then use the gem to send data to this app.

### Dependencies

This app wants/prefers:

* Ruby 2.2.2+ (Rails 5 requirement).

* PostgreSQL 9.5+ (older 9.x versions will probably work too but again, I have not tested those versions).

### Setup

#### Database

Assuming that you have PostgreSQL already installed, log in as `postgres` (or some other admin user):
```bash
$ sudo su postgres
$ psql
```
and create a new database user (NB! '123' is fine in development but use a better password in production).
```sql
CREATE USER perfmon_user PASSWORD '123';
```
Then create the database:
```sql
CREATE DATABASE perfmon_(development|test|live) OWNER perfmon_user;
```

#### Environment variables

There are several environment variables that need to be set up for this app to work in production. They are:

* PERFMON_APP_HOST - set this to the host that you are running this app on (default URL options for ActionMailer).

* PERFMON_APP_PORT - set this to the port that you are running this app on (default URL options for ActionMailer; optional if using the default HTTP(S) port).

* PERFMON_SECRET_KEY_BASE - secret key for Rails to sign cookies. Generate with `bin/rake secret`.

* PERFMON_DEVISE_SECRET_KEY - secret hash for Devise for generating random tokens. Generate with `bin/rake secret`.

* PERFMON_MAILER_SENDER - the "from" e-mail address that Devise uses to send its emails.

* PERFMON_DATABASE_PASSWORD - database password for `perfmon_user` in production.

* PERFMON_SMTP_HOST - your SMTP host.

* PERFMON_SMTP_PORT - your SMTP host port (optional).

* PERFMON_SMTP_USERNAME - username for your SMTP host (optional).

* PERFMON_SMTP_PASSWORD - password for your SMTP host (optional).

This must only be done in production environment. In development, the necessary variables are already set in the `.env` file.

#### Deployment

With Capistrano. There are example deploy files in `config/deploy.example.rb` and `config/deploy/production.example.rb`. Copy those files to `config/deploy.rb` and `config/deploy/production.rb` respectively and make the necessary changes to them. After that it's deployment as usual.

### Running tests

Run `bin/rspec` in the root folder after creating the test database. Everything should be green.

### Gathering performance data

After you have the app set up in production and created a user and a monitorable website instance there, [install the gem](https://github.com/yan-hoose/rails-perfmon) to your app(s) and start collecting performance data.
