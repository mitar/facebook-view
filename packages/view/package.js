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
    'underscore'
  ]);

  // 3rd party dependencies.
  api.use([
    'kadira:flow-router@2.10.0',
    'kadira:blaze-layout@2.3.0',
    'peerlibrary:blaze-layout-component@0.1.0',
    'materialize:materialize@0.97.1',
    'peerlibrary:computed-field@0.3.0',
    'peerlibrary:reactive-field@0.1.0',
    'peerlibrary:blocking@0.5.2'
  ]);

  // Internal dependencies.
  api.use([
  ]);

  api.addFiles([
    'facebook.coffee'
  ], 'server');
});
