Package.describe({
  name: 'view',
  version: '0.1.0'
});

Npm.depends({
  'limiter': '1.1.0',
  'request': '2.67.0',
  'async': '1.5.1'
});

Package.onUse(function (api) {
  api.versionsFrom('1.2.0.2');

  // Core dependencies.
  api.use([
    'coffeescript',
    'underscore',
    'accounts-facebook',
    'accounts-ui',
    'stylus'
  ]);

  // 3rd party dependencies.
  api.use([
    'kadira:flow-router@2.10.0',
    'kadira:blaze-layout@2.3.0',
    'peerlibrary:blaze-layout-component@0.1.0',
    'materialize:materialize@0.97.1',
    'peerlibrary:computed-field@0.3.0',
    'peerlibrary:reactive-field@0.1.0',
    'fermuch:cheerio@0.19.0',
    'peerlibrary:blocking@0.5.2'
  ]);

  // Internal dependencies.
  api.use([
    'ui-components'
  ]);

  api.export('FacebookApiRequest');
  api.export('FacebookActivityRequest');

  api.addFiles([
    'flow-router/layout.html',
    'flow-router/layout.coffee',
    'flow-router/layout.styl',
    'flow-router/not-found.html',
    'flow-router/not-found.coffee',
    'flow-router/icons.html',
    'feed/display.html',
    'feed/display.coffee'
  ]);

  api.addFiles([
    'account/config.coffee'
  ], 'client');

  api.addFiles([
    'facebook.coffee'
  ], 'server');
});
