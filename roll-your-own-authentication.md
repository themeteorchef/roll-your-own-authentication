### Getting Started
Because this recipe calls for a lot of DIY work involving the Meteor authentication system, we're going to need to add a few packages to our app before we dive in. Let's take a look at what's needed and explain what each will do.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add accounts-password
```
The `accounts-password` package is the generic Meteor accounts service. This will allow us to give user's the option of signing up for Don Carlton Sales using an email address and password.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add accounts-facebook
```
The `accounts-facebook` package will allow users to connect to and sign in with their Facebook account.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add accounts-github
```
The `accounts-github` package will allow users to connect to and sign in with their GitHub account.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add accounts-google
```
The `accounts-google` package will allow users to connect to and sign in with their Google account.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add accounts-twitter
```
The `accounts-twitter` package will allow users to connect to and sign in with their Twitter account.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add service-configuration
```
The `service-configuration` package is what we'll use to configure our own connection to the various third-party services we'll offer for signing in. This is what allows us to share our OAuth tokens with each which they'll use to "identify" our application.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add http
```
The `http` package will give us the ability to call on a third-party API to help us validate new email addresses.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add email
```
The `email` package will give us the ability to send email from the server using the nifty `Email.send` method.

<p class="block-header">Terminal</p>
```.lang-bash
meteor add meteorhacks:ssr
```
The `ssr` package will give us the ability to render HTML templates on the server, which we'll use to send a "welcome aboard" email to our new users.

<div class="note">
  <h3>A quick note</h3>
  <p>This recipe relies on several other packages that come as part of <a href="https://github.com/themeteorchef/base">Base</a>, the boilerplate kit used here on The Meteor Chef. The packages listed above are merely additions to the packages that are included by default in the kit. Make sure to reference the <a href="https://github.com/themeteorchef/base#packages-included">Packages Included</a> list for Base to ensure you have fulfilled all of the dependencies.</p>  
</div>

### The Sign In Page
To get us started, we need to make sure Don's team can easily login to the Don Carlton Sales app. In order to do this, we're going to whip up a simple template that simply asks the user to "sign in" with the service or method of their choice. The pattern, here, is that we're combining both our Sign Up and Log In process _together_. Admittedly, we're going to steal this from [Buffer](http://bufferapp.com) as they've "tested" the workflow for us and it seems to work well! Great artists steal...or something. Let's look at the template:

<p class="block-header">/client/views/public/index.html</p>
```.lang-markup
<template name="index">
  {{>signInWithEmailModal}}
  <div class="row">
    <div class="col-xs-12 col-sm-6">
      <img src="https://s3.amazonaws.com/themeteorchef-cdn/don_carlton.png" alt="Don Carlton holding business card.">
    </div>
    <div class="col-xs-12 col-sm-6">
      <div class="page-header">
        <h3>Sign In to DCS</h3>
        <p>Hey there team maties! Come on aboard!</p>
      </div>
      <ul class="btn-list">
        <li><button type="button" class="btn btn-social-login btn-facebook"><i class="fa fa-facebook"></i> Sign in with Facebook</button></li>
        <li><button type="button" class="btn btn-social-login btn-github"><i class="fa fa-github"></i> Sign in with GitHub</button></li>
        <li><button type="button" class="btn btn-social-login btn-google"><i class="fa fa-google"></i> Sign in with Google</button></li>
        <li><button type="button" class="btn btn-social-login btn-twitter"><i class="fa fa-twitter"></i> Sign in with Twitter</button></li>
        <li><button type="button" class="btn btn-social-login btn-success" data-toggle="modal" data-target="#sign-in-with-email-modal"><i class="fa fa-envelope"></i> Sign in with Email</button></li>
      </ul>
    </div>
  </div>
</template>
```
This is all pretty straightforward. The part we want to pay attention to most is the `<ul class="btn-list"></ul>` element. Here, we give each of our services their own button, rounding out the list with a button to sign in with an email. Next, we'll look at the controller we're using to make each of these buttons actuall _do something_. Ignore the `{{>signInWithEmailModal}}` inclusion, we'll tackle that in a bit.

<div class="note">
  <h3>A quick note</h3>
  <p>In this recipe, we're only focusing on the more popular OAuth implementation that Meteor offers. Along with Facebook, GitHub, Google, and Twitter, Meteor also offers access to OAuth login for Meetup, Weibo, and the recently release <a href="https://www.meteor.com/account-settings">Meteor Developer Account</a> service. Like we'll discover with Twitter, Weibo and Meteor Developer accounts also do not offer the ability to request specific permissions for users.</p>  
</div>


### Wiring Up Sign In's
Our controller for handling Sign In's is _mostly_ simplistic, too. What's nice is that Meteor is a peach when it comes to handling third-party logins.

<p class="block-header">/client/controllers/public/index.coffee</p>
```.lang-coffeescript
Template.index.events(
  'click .btn-facebook': ->
    Meteor.loginWithFacebook(
      requestPermissions: ['email']
    , (error)->
      console.log error.reason if error
    )

  'click .btn-github': ->
    Meteor.loginWithGithub(
      requestPermissions: ['email']
    , (error)->
      console.log error.reason if error
    )

  'click .btn-google': ->
    Meteor.loginWithGoogle(
      requestPermissions: ['email']
    , (error)->
      console.log error.reason if error
    )

  'click .btn-twitter': ->
    Meteor.loginWithTwitter((error)->
      console.log error.reason if error
    )
)
```
Nice, right? All of our events look fairly similar here. What we're doing is looking for a click event on each of our buttons and calling to the login service associated with it. The big thing to pay attention to is that, despite all being realtively similar, Meteor uses a convention of specifying the name of the service `Meteor.loginWithService`.

But what about Twitter? Ah yes, our dear friend Twitter. As we'll continue to learn throughout this recipe, Twitter doesn't exactly play friendly with our game plan. Maybe not so dramatic, but notice that we're missing the `requestPermissions: ['email']` part for Twitter. This is because their OAuth implementation doesn't offer up email addresses, or as we learned earlier, the ability to request _any_ permissions. Wonky. We'll focus on how to handle that in just a bit.

Next, let's take a look at how we'll handle email. This is a bit more tricky as we'll need to handle both log in and sign up at the same time.

### Sign In With Email

As we're stealing our sign in pattern from [Buffer](http://bufferapp.com), we're also going to make use of their convention of a modal overlay for signing up and logging users in. Recall back to our `index.html` template:

<p class="block-header">/client/views/public/index.html</p>
```.lang-markup
<template name="index">
{{>signInWithEmailModal}}
[...]
</template>
```
Here, we're calling to another template `signInWithEmailModal` where we've stored the actual contents of our modal. We do this here because we want our modal available in our index template. Wait a sec...when we went over the events earlier we didn't have an event for showing this modal. What gives? 

<p class="block-header">/client/views/public/index.html</p>
```.lang-markup
<li><button type="button" class="btn btn-social-login btn-success" data-toggle="modal" data-target="#sign-in-with-email-modal"><i class="fa fa-envelope"></i> Sign in with Email</button></li>
```
In order to fire our modal, we're making use of Bootstrap's `data-toggle` and `data-target` attributes which help to automate the reveal of our modal. Note: this is _hyper specific_ to this implementation. If you won't be using Bootstrap, you (likely) won't be doing this.

Okay, so let's take a look at our modal. Again, we're leaning pretty heavily on Bootstrap markup-wise for this, so keep that in mind if you're implementing something different. Let's take a look at the `<form>` portion of our modal (where we'll actually be handling user input):

<p class="block-header">/client/views/public/sign-in-with-email-modal.html</p>
```.lang-markup
<form id="sign-in-with-email">
  <div class="modal-body">
    <div class="form-group">
      <label for="emailAddress">Email Address</label>
      <input type="email" name="emailAddress" class="form-control" placeholder="What's your email, friend?">
    </div>
    <div class="form-group">
      <label for="password">Password</label>
      <input type="password" name="password" class="form-control" placeholder="How about a password, pal?">
    </div>
  </div>
  <div class="modal-footer">
    <button type="submit" class="btn btn-primary btn-create-account">Create Account</button>
    <button type="submit" class="btn btn-default btn-sign-in">Sign In</button>
  </div>
</form>
```
Real simple. We're asking for an email and a password, that's it. _But_, we're offering up two submit buttons ([whaaaat](http://media.giphy.com/media/AMfgcGOLMqADK/giphy.gif)). Here, we present the user with a `create-account` button and a `sign-in` button. Let's take a peek at how we make this work.

<p class="block-header">/client/controllers/public/sign-in-with-email-modal.coffee</p>
```.lang-coffeescript
Template.signInWithEmailModal.events(
  'click .btn-create-account': ->
    Session.set 'createOrSignIn', 'create'

  'click .btn-sign-in': ->
    Session.set 'createOrSignIn', 'signin'

  'submit form': (e)->
    e.preventDefault()
)
```
There's a lot going on in this file, but let's start with our events. Everything here is realtively straightforward. Starting at the bottom, notice that our `submit form` event is just looking to prevent the form from submitting on its own. If you [read recipe #2](http://themeteorchef.com/recipes/adding-a-beta-invitation-system-to-your-meteor-application) this should look familiar.

This is where we peacock. On our `click .btn-create-account` and `click .btn-sign-in` events, we're setting a Session variable `createOrSignIn`. What's cool about this is that we're able to tell our app which button is being clicked, meaning, both buttons submit the form _but_, we can use our Session variable to communicate _how_ we want the form submitted ([whaaaat](http://www.quickmeme.com/img/9d/9d52c9dfc0ee2409446d8aff8944e519e7997c213e2771262fa99e00fa0b6956.jpg)).

<div class="note">
  <h3>A quick note</h3>
  <p>We're at two mind blows now. Hope you're hanging in there, sport.</p>  
</div>

This may not make total sense, so let's jump up to our `submitHandler` function that's a part of our validation step.

<p class="block-header">/client/controllers/public/sign-in-with-email-modal.coffee</p>
```.lang-coffeescript
submitHandler: ->
  createOrSignIn = Session.get 'createOrSignIn'

  user =
    email: $('[name="emailAddress"]').val()
    password: $('[name="password"]').val()

  if createOrSignIn == "create"
    Meteor.call 'validateEmailAddress', user.email, (error,response)->
      if error
        # If we get an error, let our user know.
        alert error.reason
      else
        if response.error
          alert response.error
        else
          Accounts.createUser(user, (error)->
            if error
              alert error.reason
            else
              $('.modal-backdrop').hide()
          )
  else
    Meteor.loginWithPassword(user.email, user.password, (error)->
      if error
        alert error.reason
      else
        $('.modal-backdrop').hide()
    )
```

Woah smokies! This is a lot of code. Let's step through it and look at what each part is doing.

First up, we find that we're assigning our dual-button session variable whatchamacalit to a local variable called `createOrSignIn`. Next, after assigning the value of our email and password inputs to an object, we test the value of our `createOrSignIn` variable to see where we should send the user next. If our variable equals `create` (set by our click on the "Create Account" button in our modal), we set the user up with a new account. If the user has clicked "Sign In" instead, we simply log them in. Sweet!

But wait what's this call to a `validateEmailAddress` method? Well, kid, I need to tell you a little story. It's about a little thing called spam and the evil people that use it. You see, evil people like to do things like make fake accounts, sign up for services with dummy emails, and all sorts of other not-so-fun stuff. 

Some of these people have valid reasons, but most of them are just raining on our parade. This method is allowing us to make sure that, without a doubt, our user is signing up with a 110% _legit_ email address. Let's hop over to the server quick to see how it works.

<p class="block-header">/server/email/validation.coffee</p>
```.lang-coffeescript
Future = Npm.require('fibers/future');

Meteor.methods(
  validateEmailAddress: (address)->
    check(address,String)
    validateEmail = new Future()
    HTTP.call("GET", "https://api.kickbox.io/v1/verify",
      params:
        email: address
        apikey: "a2e66d2c524f5fce691166a0b2aab125964123504efe56673197dee302dadb14"
    ,(error,response)->
      if error
        validateEmail.return(error)
      else
        if response.data.result == "invalid" or response.data.result == "unknown"
          validateEmail.return(
            error: "Sorry, your email was returned as invalid. Please try another address."
          )
        else
          validateEmail.return(true)
    )
    validateEmail.wait()
)
```
What the heck is all of this? Well, because email validation is a pain in the butt and for the sake of time, here we're making use of a third-party email validation service. [Kickbox](http://kickbox.io), which was recommended by the folks at [Mailgun](http://mailgun.com), is an API service that allows you to test email addresses for their existence. There's a lot of technical mumbo jumbo going on there, so we'll have to default to our "[magic](http://img.pandawhale.com/post-41538-Shia-Labeouf-Magic-gif-Imgur-vZSU.gif)" explanation.

So how exactly are we using it here? First, you'll notice that we're creating a variable called `Future` and doing an `Npm.require` to `('fibers/future')`. This is giving us access to the [Future's](https://www.npmjs.org/package/fibers#futures) portion of the [Fibers NPM package](https://www.npmjs.org/package/fibers) which we'll use to handle the flow of our HTTP method. What's unique about this is that if you've ever added an NPM package to your app before, you'l notice that we _didn't_ use a package like `meteorhacks:npm` or create our own local package to import from NPM. What gives?

Because Meteor is itself Node-based and they make use of the futures library in Meteor's core code, it's technically already loaded into our application. Here, a simple require lets our app know that we'd like to make use of it. Nifty!

So, why do we need this? Our next step (after using `check()` like upstanding citizens) is to make use of the `http` package we installed earlier. Here, we call on the Kickbox API (specifically their `/verify` method), passing our email address and super secret API key. **Note**: you'll need to sign up for Kickbox and generate your own API key to get this working. This step isn't required, but highly recommended for keeping your user list clean.

- Modal
- Dual Button Events
- Validation
- Call to Email Validation on Server
### Configuring Third-Party Services
- Setting up APIs.
### Sending Welcome Email
- Configuring email service.
- Getting correct email address on signup.
- SSR
- Quick mention of email template.
### Displaying User Email on Template
- Publishing user data to the template.
- UI helper.

- Accounts Base
- Accounts Password
- Accounts Facebook
- Accounts GitHub
- Accounts Google
- Accounts Twitter
- Service Configuration
- At some point, make a note about security. We won't touch on it in here, but considerations will need to be made re: creating accounts using social login.
- Stupid: When logged in, add a title "Annnd here's what you've been waiting for fellas."
# Accounts Password
# Email Confirmation
# Third-Party Accounts Configuration
# Accounts Facebook
# Accounts GitHub
# Accounts Google
# Accounts Twitter
# Logout
# Reset Password