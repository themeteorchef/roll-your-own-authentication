let startup = () => {
  Modules.server.setEnvironmentVariables();
  _setBrowserPolicies();
  Modules.server.configureServices();
  Modules.server.generateAccounts();
};

var _setBrowserPolicies = () => {
  BrowserPolicy.content.allowOriginForAll( '*.amazonaws.com' );
  BrowserPolicy.content.allowOriginForAll( '*.youtube.com' );
};

Modules.server.startup = startup;
