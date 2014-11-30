###
  Startup
  Collection of methods and functions to run on server startup.
###

Meteor.startup(->
  # Environment Variable: MAIL_URL
  process.env.MAIL_URL = "Insert your own MAIL_URL from your email provider here."
  # Function: Create Service Configuration
  # Here, we create a function to help us reset and create our third-party login
  # configurations to keep our code as DRY as possible.
  createServiceConfiguration = (service,clientId,secret)->
    ServiceConfiguration.configurations.remove(
      service: service
    )
    # Note: here we have to do a bit of light testing on our service argument.
    # Facebook and Twitter use different key names for their OAuth client ID,
    # so we need to update our passed object accordingly before we insert it
    # into our configurations.
    config =
      generic:
        service: service
        clientId: clientId
        secret: secret
      facebook:
        service: service
        appId: clientId
        secret: secret
      twitter:
        service: service
        consumerKey: clientId
        secret: secret

    # To simplify this a bit, we make use of a case/switch statement. This is
    # a shorthand way to say "when the service argument is equal to <x> do this."
    # This is also available in plain JavaScript, but the CoffeeScript version
    # is a bit more "literal" and easier to read.
    switch service
      when 'facebook' then ServiceConfiguration.configurations.insert(config.facebook)
      when 'twitter' then ServiceConfiguration.configurations.insert(config.twitter)
      else ServiceConfiguration.configurations.insert(config.generic)

  ###
    Configure Third-Party Login Services
    Note: We're passing the Service Name, Client Id, and Secret. These values
    are obtained by visiting each of the given services (URLs listed below) and
    registering your application.
  ###

  # Facebook
  createServiceConfiguration('facebook', 'Insert your appId here.', 'Insert your secret here.')
  # Generate your Client & Secret here: https://developers.facebook.com/apps/

  # GitHub
  createServiceConfiguration('github', 'Insert your clientId here.', 'Insert your secret here.')
  # Generate your Client & Secret here: https://github.com/settings/applications

  # Google
  createServiceConfiguration('google', 'Insert your clientId here.', 'Insert your secret here.')
  # Generate your Client & Secret here: https://console.developers.google.com

  # Twitter
  createServiceConfiguration('twitter', 'Insert your consumerKey here.', 'Insert your secret here.')
  # Generate your Client & Secret here: https://apps.twitter.com/

  ###
    Generate Test Accounts
    Creates a collection of test accounts automatically on startup.
  ###

  # Create an array of user accounts.
  users = [
    { name: "Admin", email: "admin@admin.com", password: "password" }
  ]

  # Loop through array of user accounts.
  for user in users

    # Check if the user already exists in the DB.
    checkUser = Meteor.users.findOne({"emails.address": user.email});

    # If an existing user is not found, create the account.
    if not checkUser

      id = Accounts.createUser(
        email: user.email
        password: user.password
        profile:
          name: user.name
      )

)
