---
layout: post
title: "Allow users to authenticate with username only using Devise, ActiveAdmin, Rails 4 and Ruby 2"
date: 2013-10-31 16:10
comments: true
categories: Rails
keywords: Rails, ActiveAdmin, Devise, Authentication, Tutorial, How-to
description: A short tutorial on how to setup Rails, ActiveAdmin and Devise to allow user authentication with username only.
---
*This post is a work-in-progress. I have published it as a reference to people willing to help me debug the problem of not being able to create a new user using the ActiveAdmin back-end, but only via the Rails console.*

## Allow normal users to authenticate with username only, while keeping email authentication for admins in ActiveAdmin

### Scenario

You are using ActiveAdmin (AA), Devise, Rails 4 and Ruby 2. You have two models/AA resources - AdminUsers (created by default after installing AA) and Users (generated using Devise). You want your users to be able to login only with username and not have the email attribute at all.

### Conventions

I refer to the files unser `app/models/` as *models* and the files under `app/admin/` as *resources*.

### Prerequisits:

* Generate a new Rails application:

    ```ruby
    rails new devise_username_only
    ```

* Add to Gemfile

    ```ruby
    gem 'activeadmin', github: 'gregbell/active_admin'
    ```

* Install gems:

    ```ruby
    bundle install
    ```
* Install ActiveAdmin:

    ```ruby
    rails g active_admin:install
    ```

* Migrate the database:

    ```ruby
    rake db:migrate
    ```

So far you should have a working app with an admin backend, containing an AdminUsers resource. Test it by starting the server with `rails s`, going to `http://localhost:3000/admin` and logging in with credentials `admin@example.com` and `password`.

### Actual work

Now comes the real work of generating your user model and doing a few tweaks.

1. Modify the devise initializer under `config/initalizers/devire.rb`. In particular change the following lines to look like this:

    ```ruby
    config.case_insensitive_keys = [ :email, :username ]
    config.strip_whitespace_keys = [ :email, :username ]
    ```

    We we will leave the line:

    ```ruby
    # config.authentication_keys = [ :email ]
    ```

    commented out, as we don't want to change the authentication keys globally. We want our admin users to still be able to log in with email. We will change the authentication keys only within the user model.

    Also, uncomment `config.scoped_views` and set it to `true`:

    ```ruby
    config.scoped_views = true
    ```
    We need this because we have more than one Devise model (AdminUsers and Users) and we want to modify the Users views. More info [here](https://github.com/plataformatec/devise#configuring-views).


2. Generate the User model:

    ```ruby
    rails g devise User
    ```

3. In the user migration file under `db/migrate/20131031100550_devise_create_admin_users.rb` replace `:email` with `:username` so that you have the folloing two lines in the file:

    ```ruby
    t.string :username, null => false, :default => ""
    add_index :users, :username, :unique => true
    ```

4. Tweak the User *model*:

    * set the desired devise modules;

    * add the authentication keys option;

    * overwrite `email_required?` and `email_changed?`.

    Your model should look something like this:

    ```ruby
    class User < ActiveRecord::Base
      # Include default devise modules. Others available are:
      # :confirmable, :lockable, :timeoutable, :omniauthable,
      # :registerable, :recoverable
      devise :database_authenticatable,
             :rememberable,
             :trackable,
             :validatable,
             :authentication_keys => [:username]

      def email_required?
        false
      end

      def email_changed?
        false
      end
    end
    ```

    I have not included `:confirmable`, `:registerable`, and `:recoverable` as I want all my user management to happen on the backend through ActiveAdmin. What's more, as the User model does not have the email attribute, these modules won't work anyway.

5. Run the migration:

    ```ruby
    rake db:migrate
    ```

6. Register the User model as a resource in ActiveAdmin:

    ```ruby
    rails g active_admin:resource User
    ```

7. Modify the User *resource* to look like this:

    ```ruby
    ActiveAdmin.register User do
      # This determines which attributes of the User model will be
      # displayed in the index page. I have left only username, but
      # feel free to uncomment the rest of the fields or add any
      # other of the User attributes.
      index do
        column :username
        # column :current_sign_in_at
        # column :last_sign_in_at
        # column :sign_in_count
        default_actions
      end

      # Default is :email, but we need to replace this with :username
      filter :username

      # This is the form for creating a new user using the Admin
      # backend. If you have added additional attributes to the
      # User model, you need to include them here.
      form do |f|
        f.inputs "User Details" do
          f.input :username
          f.input :password
          f.input :password_confirmation
        end
        f.actions
      end

      # This is related to Rails 4 and how it handles strong parameters.
      # Here we replace :email with :username.
      controller do
        def permitted_params
          params.permit admin_user: [:username, :password, :password_confirmation]
        end
      end
    end
    ```

    8. Generate the Devise views:

    ```ruby
    rails g devise:views
    ```

    9. Modify the views. Since I have not included `:confirmable`, `:registerable`, and `:recoverable` the only relevent view is `app/views/devise/sessions/new.html.erb`. You only need to change these lines:

    ```ruby
    <div><%= f.label :username %><br />
    <%= f.text_field :username, :autofocus => true %></div>
    ```

    Note that `f.email_field` needs to be changed to `f.text_field`, otherwise in newer browsers the built-in validation won't pass and you'll get error when you enter a username in that field.

    Now you can create a new user via the admin back-end, go to `http://localhost:3000/users/sign_in` and log in. Bear in mind that if you have not created a default home page containing a sign out link, you won't be able to log out by just entering `http://localhost:3000/users/sign_out` by default, as the sign_out method must be `:delete`. As a temporary workaround, in the Devise inilizer set `config.sign_out_via` to `:get` and in routes.rb change `devise_for :users` to

    ```ruby
    devise_for :users do get '/users/sign_out' => 'devise/sessions#destroy' end
    ```