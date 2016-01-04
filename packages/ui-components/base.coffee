class UIComponent extends BlazeComponent
  callAncestorWith: (propertyName, args...) ->
    component = @parentComponent()
    while component and not component.getFirstWith null, propertyName
      component = component.parentComponent()
    component?.callFirstWith null, propertyName, args...

class UIMixin extends UIComponent
  data: ->
    @mixinParent().data()

  callFirstWith: (args...) ->
    @mixinParent().callFirstWith args...

  autorun: (args...) ->
    @mixinParent().autorun args...
