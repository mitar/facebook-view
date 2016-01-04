class MainLayoutComponent extends BlazeLayoutComponent
  @register 'MainLayoutComponent'

  @REGIONS:
    MAIN: 'main'

  renderMain: (parentComponent) ->
    @_renderRegion @constructor.REGIONS.MAIN, parentComponent
