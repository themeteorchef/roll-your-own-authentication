Template.authenticatedNavigation.onCreated( () => {
  let template = Template.instance();
  template.subscribe( 'user' );
});
