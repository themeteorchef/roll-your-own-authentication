### Getting Started
Because this recipe calls for a lot of DIY work involving the Meteor authentication system, we're going to need to add a few packages to our app before we dive in. Let's take a look at what's needed and explain what each will do.

<p class="block-header">Terminal</p>

```.lang-bash
meteor add accounts-password
```
The `accounts-password` package is the generic Meteor accounts service. This will allow us to give user's the option of signing in for Don Carlton Sales using an email address and password.

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
This is all pretty straightforward. The part we want to pay attention to most is the `<ul class="btn-list"></ul>` element. Here, we give each of our services their own button, rounding out the list with a button to sign in with an email. Next, we'll look at the controller we're using to make each of these buttons actually _do something_. Ignore the `{{>signInWithEmailModal}}` inclusion, we'll tackle that in a bit.

<div class="note">
  <h3>A quick note</h3>
  <p>In this recipe, we're only focusing on the more popular OAuth implementation that Meteor offers. Along with Facebook, GitHub, Google, and Twitter, Meteor also offers access to OAuth login for Meetup, Weibo, and the recently released <a href="https://www.meteor.com/account-settings">Meteor Developer Account</a> service. Like we'll discover with Twitter, Weibo and Meteor Developer accounts also do not offer the ability to request specific permissions for users.</p>  
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

But what about Twitter? Ah yes, our dear friend Twitter. As we'll continue to learn throughout this recipe, Twitter doesn't exactly play friendly with our game plan. Maybe not so dramatic, but notice that we're missing the `requestPermissions: ['email']` part for Twitter. This is because their OAuth implementation doesn't offer up email addresses, or as we learned earlier, the ability to request _any_ permissions. Wonky. Don't worry, we'll cover how to handle that so you're not caught off guard in a bit.

There's one more step for setting up our third-party logins which we'll cover later in the recipe. For now, let's take a look at how we'll handle a sign in with email. This is a bit more tricky as we'll need to handle both log in and sign up at the same time.

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
      # We'll handle any errors and create the user's account here.
  else
    Meteor.loginWithPassword(user.email, user.password, (error)->
      if error
        alert error.reason
      else
        $('.modal-backdrop').hide()
    )
```

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
        apikey: "Enter your Kickbox.io API key here."
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
What the heck is all of this? Well, because email validation is a pain in the butt and for the sake of time, here we're making use of a third-party email validation service. [Kickbox](http://kickbox.io), which was recommended by the folks at [Mailgun](http://mailgun.com), is an API service that allows you to test email addresses for their existence.

So how exactly are we using it here? First, you'll notice that we're creating a variable called `Future` and doing an `Npm.require` to `('fibers/future')`. This is giving us access to the [Future's](https://www.npmjs.org/package/fibers#futures) portion of the [Fibers NPM package](https://www.npmjs.org/package/fibers) which we'll use to handle the flow of our HTTP method.

What's unique about this is that if you've ever added an NPM package to your app before, you'l notice that we _didn't_ use a package like `meteorhacks:npm` or create our own local package to import from NPM. What gives?

Because Meteor is itself Node-based and they make use of the futures library in Meteor's core code, it's technically already loaded into our application. Here, a simple require lets our app know that we'd like to make use of it. Nifty!

So, why do we need this? Our next step (after using `check()` like upstanding citizens) is to make use of the `http` package we installed earlier. Here, we call on the Kickbox API (specifically their `/verify` method), passing our email address and super secret API key. **Note**: you'll need to sign up for Kickbox and generate your own API key to get this working. This step isn't required, but highly recommended for keeping your user list clean.

Futures comes into play because all `HTTP.call` functions are run _[asynchronously](http://stackoverflow.com/a/4560233)_. This means that the code runs and Meteor keeps on truckin' instead of waiting for it to finish. What we're really looking for here is for Meteor to hit this function and _wait_ until it's finished.

We want to wait because the answer we get back from Kickbox will determine whether we allow our user to sign in, or kick em' to the curb. Okay, maybe not that harsh, but it _will_ allow us to notify the user if they're trying to sign up with a bum email.

<p class="block-header">/server/email/validation.coffee</p>

```.lang-coffeescript
validateEmail = new Future()
  [...]
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
```

A few things to pay attention to. The first is actually the last. Where in a normal function we'd just return some value, here, we're returning our Future `validateEmail` with a `.wait()` method invoked on it `validateEmail.wait()`. What this is doing is telling the Future's library to pause the running of the script until it receives a value. When it does, it continues running returning whatever value it was passed.

Up a little bit into our code, we can see that we're making use of our Future's `.return()` method to pass it some data based on the outcome of our `HTTP` request. We test for two instances (three, technicaly): first, if the `HTTP` request throws an error (e.g. a bad URL, no response from the API, etc.) we want to grab that and return it.

Next, if the request does go through and we get a _response_ from the server, we test to see whether the value of the `response.data.result` key is either `invalid` or `unknown`. These keys/values are specific to Kickbox and tell us whether the email we sent them is legitimate. Here, we test for a falsey value _first_ returning an error if the email is bad. If not, we simply return a boolean `true` value.

<p class="block-header">/client/controllers/public/sign-in-with-email-modal.coffee</p>

```.lang-coffeescript
if error
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
```
Back on the client and inside of our `Meteor.call 'validateEmailAddress'` function, we watch on the `error	` and `response` arguments. Here, if we get an error (e.g. from the API) we alert it to the user. We do the same if our _response_ was set to an error (i.e. the one we defined, "Sorry, your email..."). Finally, if no errors are present, we assume the email is valid and create the user's account.

Awesome! With this in place we've actually completed getting user's signed in with email. Next, we need to revisit our third-party sign in's and get them configured so they will actually work.

### Configuring Third-Party Services
Because our third-party sign in's are relying on _external_ services outside of our control, we need a way to identify our application with those services so they know their users are safe. Fortunately for us, some smarter folks in the past came up with a convenient system known as OAuth, or, "open authentication":

> OAuth is an open standard to authorization. OAuth provides client applications a 'secure delegated access' to server resources on behalf of a resource owner. It specifies a process for resource owners to authorize third-party access to their server resources without sharing their credentials.

— via ["OAuth" on Wikipedia](http://en.wikipedia.org/wiki/OAuth)

What this essentially means is that by providing a service with a unique token for our application, we can make requests for information on behalf of the user. So for things like signing in, we can allow the user to use their email/password combination from another service (e.g. Facebook). We never store or touch that email/password, because OAuth implements a permissions system wherein users are prompted to log in to and accept or deny our access to their credentials. Pretty cool, right?

So what we need to accomplish now is the "providing a service with a unique token" part. This is done by making use of the `service-configuration` package we installed earlier. By adding this, we gain access to a set of functions that allow us to update Service Configurations in the database: `ServiceConfiguration.configurations.remove()` and `ServiceConfiguration.configurations.insert()`.

Together, these two allow us to set our OAuth `clientId` and `secret` in the database. Calling back to our client code, these values are referenced by Meteor when we call any of the `Meteor.loginWith<Service>` functions. Let's see how we get them setup.

<p class="block-header">/server/admin/startup.coffee</p>

```.lang-coffeescript
createServiceConfiguration = (service,clientId,secret)->
  ServiceConfiguration.configurations.remove(
    service: service
  )

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

  switch service
    when 'facebook' then ServiceConfiguration.configurations.insert(config.facebook)
    when 'twitter' then ServiceConfiguration.configurations.insert(config.twitter)
    else ServiceConfiguration.configurations.insert(config.generic)
```

To keep our code DRY, we've setup a function `createServiceConfiguration()` that will wrap the two `ServiceConfiguration` functions (via Meteor) above. We're doing this because for each service we want to support, we'd need to run both of these functions. Putting them into a single function and simply passing over the parameters they need access to saves us a few lines of code. Nice!

Inside of our function, first [per Meteor's documentation](http://docs.meteor.com/#/full/meteor_loginwithexternalservice), we run our `ServiceConfiguration.configurations.remove()` function to "reset" any existing configurations in our app. Because this will all run on startup, we want to ensure that we're clearing out any _old_ configurations. This is nice for when you're running a production application and reset your API keys. Having this ensures that when you update those keys in your code, they actually "stick."

Next, we present a strange combo: an object labeled `config` and then a `switch/case` statement that references the `config` object. What is this?

By default, OAuth applications are required to provide two keys to developers: `clientId` and a `secret` key. The `clientId` acts as the identifier for your specific application, whereas the `secret` acts like your password (you as the developer, not your user). When we call on an OAuth service, we pass these keys to identify ourselves.

What you'll notice above is that we have three "configurations": `generic`, `facebook`, and `twitter`. If you have a keen eye, you'll notice that the only difference between the three is the `clientId` field. This setup accounts for Facebook and Twitter's variation on the naming of these keys.

Here, we use our `switch/case` statement to look at the name of the `service` passed as an argument to our function. Depending on what is passed, we then run `ServiceConfiguration.configurations.insert(config.service)` function, passing the "configuration" from above. What this achieves is having the correct key/value pairs and names in place so that when Meteor calls on a given service, what it sends over (again, the `clientId` and `secret`) match the naming conventions _of that service_. Said another way: [you say tomayto, I say tomahto](http://youtu.be/zZ3fjQa5Hls?t=1m30s).

Okay, so we've got this all setup, but where and how do we call it? Just beneath our function declaration you'll find four calls to our `createServiceConfiguration()` function:

<p class="block-header">/server/admin/startup.coffee</p>

```.lang-coffeescript
createServiceConfiguration('facebook', 'Insert your appId here.', 'Insert your secret here.')
createServiceConfiguration('github', 'Insert your clientId here.', 'Insert your secret here.')
createServiceConfiguration('google', 'Insert your clientId here.', 'Insert your secret here.')
createServiceConfiguration('twitter', 'Insert your consumerKey here.', 'Insert your secret here.')
```
Just like we setup our function to expect, we pass three arguments: `service`, `clientId`, and `secret`. Isn't this nice? Instead of having the same code copied over and over, we get a nice one-liner for configuring each service. But...where do we get these `clientId` and `secret` keys? Good question!

Each service has their own system for registering your application and generating keys. Admittedly, some are really easy and others are a bit confusing. To get you on the right track, depending on the services you'd like to support you'll need to visit the following links:

- [Facebook Developers](https://developers.facebook.com/apps/)
- [GitHub Applications](https://github.com/settings/applications)
- [Google Developers Console](https://console.developers.google.com)
- [Twitter Apps](https://apps.twitter.com/)

At each site you'll need to do two things:
1. Register your application and obtain a `clientId` and `secret`.
2. Set the correct URLs for that service.

While all of these processes are fairly similar, we should call attention to a few things that can be confusing. Let's take a look at some of the pitfalls we might run into while getting this all set up.

#### Configuring Facebook
When it comes to Facebook, getting our `appId` and `secret` is realtively straightforward, but we need to make sure we get the `App Domain` configured correctly. The `App Domain` is the URL that Facebook expects requests to be coming from in association with the `appId` and `secret` you've specified in your code. If the values set in your application code are sent from a domain that does not match the values in the dashboard on Facebook, you'll get an error.

To get this working on Facebook, once you've setup your application, head over to the dashboard your your application `https://developers.facebook.com/apps/<App ID>/dashboard/` and click on the "Settings" tab on the left. From here, you'll need to click the "Add Platform"  button (selecting Website), and specify your "Site URL."

![Facebook Application Configuration](http://cl.ly/Ykoq/Image%202014-12-01%20at%209.49.26%20AM.png)

The value of this needs to be the full URL of your application, e.g. `http://localhost:3000`. Once you've set this up, you'll need to go up to the `App Domain` field and specify _just the domain_ of the application, e.g. `localhost`. These two values need to match the exact URL of your environment. For Facebook, you can only specify one Site URL per application, meaning when you want to go into production, you'll need to update the Site URL and App Domain values.

Alternatively, you could also setup a _separate_ application for local development and another for production. Just make sure to keep track of your `clientId` and `secret` keys for each of your configurations.

#### Configuring GitHub
![GitHub Application Configuration](http://cl.ly/YmpL/Image%202014-12-02%20at%208.46.04%20AM.png)

GitHub makes things a little bit easier, though, we still want to pay attention to the `Callback URL` we're setting. Just like Facebook, this URL needs to match the _current domain_ of your application. If we're on `http://localhost:3000` it should be that, if we're on `http://doncarltonsales.com` it should be that. Without it, you'll get a mismatched URI error and get a one-way ticket to frown town.

#### Configuring Google
Despite having a slightly confusing interface for managing your applications, Google isn't too bad to get setup. Once you've created your application, you'll want to access the `Credentials` menu item underneath the `APIs & auth` heading, clicking the "Create new Client ID" button.

![Google Developers Console](http://cl.ly/Ym9z/Image%202014-12-02%20at%208.49.05%20AM.png)

On the resulting popup, you'll want to select Web Application for Application Type and then fill out the subsequent information for the "consent screen" (this is the popup your users will be greeted with asking for permission to access their account). Once you've filled this out, you'll be greeted with a popup to setup two things: "Authorized JavaScript Origins" (spooky!) and "Authorized Redirect URIs."

The first, origins, is simply the URLs where Google should expect requests to come from. Unlike our previous services, they actuall _do_ let you specify multiple URLs (one per line). Here, you'll want to place your `localhost` URL and your `production` URL.

![Google Developers Console](http://cl.ly/YmBJ/Image%202014-12-02%20at%208.55.26%20AM.png)

In the next box, Redirect URIs, you'll want to place the URLs that Google will send the user back to _after_ they've been authenticated. You'll notice that in our example image, we're appending a funky string to the end of the two URLs we set for `localhost` and `production`, what gives?

Well, although it's not documented, Meteor automatically sends Google OAuth requests back to the root domain of your application, appending `_oauth/google?close` onto the end of it. [Cute](http://media1.giphy.com/media/T3Vx6sVAXzuG4/giphy.gif)! In order to compensate for this, we need to make sure that we update both of the URLs we specified for our JavaScript Origins to include this, so:

```.lang-bash
http://localhost:3000/_oauth/google?close
http://yourproductionsite.meteor.com/_oauth/google?close
```

Once those are set, click "Create Client ID" and you should get your `clientId` and `secret`! Wonderful.

#### Configuring Twitter

So, Twitter. We'll give them a hard time but they're actually quite pleasant to set up. Fortunately, their OAuth application registration is quick and painless, we just want to call attention to two things. Both pertain to how we setup our Callback URL. First, if you're looking to test your application on `localhost`, Twitter won't let you! Ha! Where the other services would let us set our Callback URL as `http://localhost:3000`, Twitter is a straight up thug and says "_no_."

Instead when we're working on `localhost` we need to use the less familiar but equivalent `http://127.0.0.1:3000`. If this is gibberish to you, `127.0.0.1` is the default local IP address of your computer, which is the same as `http://localhost:3000`. `localhost` is merely a convenient shorthand (like a domain name on a website). Great, so this is set but we're not done just yet!

![Twitter Application Management](http://cl.ly/YmBp/Image%202014-12-02%20at%209.27.40%20AM.png)

Remember that wack-a-doodle string Google needed at the end of our Callback URL? Twitter needs it, [too](http://youtu.be/gqoTFHbU8aU?t=9s)! This time around it looks like this: `http://127.0.0.1:3000/_oauth/twitter?close`. Not terrible. Of course, the same rules apply here: if you're moving into production, you'll need to swap `127.0.0.1:3000` with your _production domain_, or, setup a separate OAuth application specifically for production.

<div class="note">
  <h3>A quick note</h3>
  <p>Holy cow! We're in the home stretch. How about we take a break for some <a href="https://www.youtube.com/watch?v=na9ZZ4ZjVa8">calisthenics</a>?</p>  
</div>

### Sending Welcome Email
The second to last thing we need to do is welcome our new user to our service! This is optional,
but it's a good opportunity to "onboard" the user and confirm their account creation. In order to send off our email, we're going to make use of a handy function given to us by Meteor `Accounts.onCreateUser()`. Just like it sounds, when a _new_ user is created by Meteor, this function is called. Let's hop over to the server where this is running in our code:

<p class="block-header">/server/admin/account-creation.coffee</p>

```.lang-coffeescript
Accounts.onCreateUser((options,user)->
  userData =
    email: determineEmail(user)
    name: if options.profile then options.profile.name else ""

  if userData.email != null
    Meteor.call 'sendWelcomeEmail', userData, (error)->
      console.log error if error

  if options.profile
    user.profile = options.profile

  user
)
```

We have a few things going on in here. First, you'll notice that this function gives us two arguments to make use of: `options` and `user`. `options` are parameters set in a call to `Accounts.createUser`, or, a call to a third-party login service (e.g. username/email, password, profile, etc.). `user` is the proposed user document that Meteor will insert into the database. Pay attention to that. This function is technically being fired _before_ Meteor inserts the new user. What does this mean?

> The function should return the user document (either the one passed in or a newly-created object) with whatever modifications are desired. The returned document is inserted directly into the Meteor.users collection.

— via [Meteor Documentation](http://docs.meteor.com/#/full/accounts_oncreateuser)

This means that Meteor looks at the return value of this function for what to insert as the user in the database. We _absolutely must_ return the user document at the end of our `onCreateUser()` function. Also explained [in the docs](http://docs.meteor.com/#/full/accounts_oncreateuser) is that this function overrides the default hook Meteor would use to perform this process, meaning, we have to account for any default behavior in our own function (e.g. adding the user's profile to their user object).

```.lang-coffeescript
if options.profile
  user.profile = options.profile
```

You can see in our code above that we _do_ want to preserve the user's profile information, so we make sure to test for it and set it on the `user` document if it exists. Great!

Let's jump back up to the top of our `Accounts.onCreateUser()` function. We're creating an object called `userData` and setting two keys `email` and `name` to some funky values. What's going on here?

First, in our email key, we're calling a function we've defined called `determineEmail()` and passing our `user` argument given to us by Meteor.

<p class="block-header">/server/admin/account-creation.coffee</p>

```.lang-coffeescript
determineEmail = (user)->
  if user.emails
    emailAddress = user.emails[0].address
  else if user.services
    services = user.services
    emailAddress = switch
      when services.facebook then services.facebook.email
      when services.github then services.github.email
      when services.google then services.google.email
      when services.twitter then null
      else null
  else
    null
```

This function is designed to help us account for the fact that Meteor does _not_ store user email's the same for each of its different authentication methods. Instead, it uses two conventions: when a user is created via `accounts-password`, the user's email is set in the `user.emails` array in the database. When using a third-party OAuth service, Meteor is storing the user's email in a `services` object and a nested `service-name` (e.g. `facebook`) object. Woah!

To compensate for this, our `determineEmail()` function looks to see what method of storage is being used for the user's email and then returns the value that it finds. The part to pay attention to is the `case/switch` function being used to check third-party services. This is saying if the `services` object exists on the user, check for each of our known services and when you get a match, return the `email` field for that service.

You'll notice that our dear friend Twitter is returning `null` instead of an email. Well, sorry to be the bearer of bad news, but [Twitter's OAuth API does _not_ offer an email address](https://twittercommunity.com/t/how-to-get-email-from-twitter-user-using-oauthtokens/558). This isn't just for Meteor, this is for _anyone_ using their OAuth API. Not cool, Twitter. [Not cool](http://media.giphy.com/media/NZrgV9nFbWYRW/giphy.gif). By returning `null` we can later test for an email value to protect ourselves from attempting to send to an email that doesn't exist. We can see this test in action back in our `Accounts.onCreateUser()` function:

<p class="block-header">/server/admin/account-creation.coffee</p>

```.lang-coffeescript
if userData.email != null
  Meteor.call 'sendWelcomeEmail', userData, (error)->
    console.log error if error
```

Recall that `userData.email` is the result of our `determineEmail()` function. If the value isn't null, we call to a Meteor method `sendWelcomeEmail` to do our bidding! Nice.

Now, the last step of this is to actually _send an email_. How do we do it?

<p class="block-header">/server/admin/account-creation.coffee</p>

```.lang-coffeescript
Meteor.methods(

  sendWelcomeEmail: (userData)->
    check(userData,{email: String, name: String})

    SSR.compileTemplate('welcomeEmail', Assets.getText('email/welcome-email.html'))

    emailTemplate = SSR.render('welcomeEmail',
      email: userData.email
      name: if userData.name != "" then userData.name else null
      url: "http://localhost:3000"
    )

    Email.send(
      to: userData.email
      from: "The Meteor Chef - Demo <demo@themeteorchef.com>"
      subject: "Welcome aboard, team matey!"
      html: emailTemplate
    )

)
```

Because we'd like to send a spiffy HTML email to our new user _and_ we'd like to personalize it,
we need a way to render our email template on the server. Enter the `meteorhacks:ssr` package. Just like it sounds, this package gives us the ability to do exactly what we want. In order to do it, it gives us two functions to work with: `SSR.compileTemplate()` and `SSR.render()`.

The first, `compileTemplate()` is where we define the name of our template `'welcomeEmail'` and pass a call to `Assets.getText()` with the path of our email template. What's this about? [Recall from Recipe #1](http://themeteorchef.com/recipes/exporting-data-from-your-meteor-application) that this function simply pulls in the _text_ of a file we specify. The _path_ it looks at is relative to the `/private` directory in our project root. So here, we're importing our email from `/private/email/welcome-email.html`.

Once we have our template defined and available as `'welcomeEmail'` for `ssr` to use, we call the `render()` method, again passing the name of our template `'welcomeEmail'` along with the values we'd like to make available as template variables (e.g. `{{name}}`) in our email. Here we pass two values: `name` and `url`. The first, `name`, is our attempt to personalize the user's email. If we open up our email template, we can see how this is used:

<p class="block-header">/private/email/welcome-email.html</p>

```.lang-markup
{{#if name}}
  Hey there, {{name}}! Welcome aboard!
{{else}}
  Hey there! Welcome aboard!
{{/if}}
```

Simple, but a nice touch. Because we're using good ol' fashioned Handlebars templates, we can make use of the handy `{{if}}` statement to check if `name` is set. So cool! Further down in the email, we can also find our use of the `url` key set above:

<p class="block-header">/private/email/welcome-email.html</p>

```.lang-markup
<a href="{{url}}" class="btn-primary" style="[...]">Check Out DCS</a>
```

Here we use our URL value to link the user back to our application.

The last part of our code is focused on sending our email via the `Email.send()` method which was given to us when we installed the `email` package earlier in the recipe. We quickly set some obvious parameters: `to`, `from`, and `subject`, finishing with the key `html` which is set to the `emailTemplate` variable containing the result of our call to `SSR.render()`, or, our template updated with the values we passed to it!

<div class="note">
<h3>A quick note</h3>
<p>We're going to skip over configuring our email address in Meteor to save time. Recall that in order to do this you need to make use of the MAIL_URL environment variable in your server code. You can learn more about environment variables <a href="http://www.meteorpedia.com/read/Environment_Variables">here</a>. Also, check out <a href="http://themeteorchef.com/recipes/adding-a-beta-invitation-system-to-your-meteor-application">Recipe #2</a> where we go into detail on setting this up.</p>
</div>

### Displaying Our User's Email on Template

Good, good, good. We're onto our last step which is something simple but important: displaying the user's email on the template. Once our user's are logged in, we want to be able to get display their email in our dropdown menu where they can "logout."

To accomplish this, we need to reprise a bit of our code from earlier, the `determineEmail()` function. This time, however, we're going to wrap it in a UI helper so we can make use of it in our template. Let's take a look:

<p class="block-header">/client/helpers/helpers-ui.coffee</p>

```.lang-coffeescript
UI.registerHelper('userIdentity', (userId) ->
  getUser = Meteor.users.findOne({_id: userId})
  if getUser.emails
    getUser.emails[0].address
  else if getUser.services
    services = getUser.services
    getService = switch
      when services.facebook then services.facebook.email
      when services.github then services.github.email
      when services.google then services.google.email
      when services.twitter then services.twitter.screenName
      else false
    getService
  else
    getUser.profile.name
)
```

Almost identical to what we did earlier (so much so that you can score easy refactor points in your own app by making this a global function). There are two big differences here: first, we don't have access to the user document like we did earlier, so we need to take a passed `userId` argument and look up the user in the database. Our other difference is for Twitter. Recall that they _do not_ give us an email to work with, so, instead we opt for the user's `screenName` or `@name` (e.g. `@themeteorchef`).

To make use of the helper over in our template code, we can now call `{{userIdentity}}` passing the current user's ID as a parameter:

<p class="block-header">/client/includes/_header.html</p>

```.lang-markup
{{#if userIdentity currentUser._id}}
  <li class="dropdown">
    <a href="#" class="dropdown-toggle" data-toggle="dropdown">{{userIdentity currentUser._id}} <span class="caret"></span></a>
    <ul class="dropdown-menu" role="menu">
      <li class="logout"><a href="#">Logout</a></li>
    </ul>
  </li>
{{else}}
  <li class="logout"><a href="#">Logout</a></li>
{{/if}}
```

Here we do a bit of piggybacking on Meteor's `{{currentUser}}` template variable, looking up the `_id` value to send back to our helper. We check for existence of the value for good measure and if it exists, output it to the template.

We're all don...no we're not!

This is _super_ important. Because we're interacting with our user's data, we need to be careful about what data is getting to the client. To control this, we've setup a publication on the server to specify _exactly_ what we need, along with a subscription in our `/dashboard` view.

<p class="block-header">/server/publications.coffee</p>

```.lang-coffeescript
Meteor.publish('userData', ->
  currentUser = this.userId
  if currentUser
    Meteor.users.find({_id: currentUser}, {
      fields: {
        "services.facebook.email": 1
        "services.github.email": 1
        "services.google.email": 1
        "services.twitter.screenName": 1
        "emails.address[0]": 1
        "profile": 1
      }
    })
  else
    this.ready()
  )
```

We've kept things a bit verbose here so we can see what's happening. First, we set a variable `currentUser` equal to `this.userId` which is a convenient value set for us by Meteor so we don't have to pass our user's ID to our publication.

Next, we test for the existence of that value and if it's available, we publish the data for our _current_ user and specifically request the fields that we want. Notice that because we only need access to their profile and email address, we're only requesting those fields. This is important because if we _didn't_ do this, we'd be sending the user's **entire document to the client**. This is a big no no.

Phew. Alright, so we're safe there. The _very last thing_ we need to do is ensure that we can actually _see_ the data we're publishing. In our `/dashboard` route definition:

<p class="block-header">/client/routes/routes-authenticated.coffee</p>

```.lang-coffeescript
Router.route('dashboard',
  path: '/dashboard'
  template: 'dashboard'
  waitOn: ->
    Meteor.subscribe 'userData'
  onBeforeAction: ->
    Session.set 'currentRoute', 'dashboard'
    @next()
)
```

We make a call in our `waitOn` function to subscribe to our `userData` publication on the server. That's it! Now our user's data will be accessible on our `/dashboard` route and we can display their name. Awesome!

We're all done! Now we can kick back and enjoy that we have a custom authentication setup complete with support for third-party services. Yeah, [go ahead and peacock](http://youtu.be/iV6539XsWrc?t=18s), you deserve it.

### Wrap Up & Summary

In this recipe we learned how to create our own authentication setup complete with support for email and password users, as well as user's logging in with third-party accounts. We learned about validating emails for authenticity, configuring third-party networks, and even how to send a welcome email to new users! Lastly, we learned about the importance of publishing only the data we _need_ and creating a UI helper to help us display that data in a template.