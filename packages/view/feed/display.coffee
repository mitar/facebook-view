class Feed

class Feed.DisplayComponent extends UIComponent
  @register 'Feed.DisplayComponent'

FlowRouter.route '/',
  name: 'Feed.display'
  action: (params, queryParams) ->
    BlazeLayout.render 'MainLayoutComponent',
      main: 'Feed.DisplayComponent'
