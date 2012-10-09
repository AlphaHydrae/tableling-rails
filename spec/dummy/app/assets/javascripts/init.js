
Backbone.Marionette.Renderer.render = function(template, data) {
  if (template === false) {
    return;
  }
  if (!JST[template]) {
    throw new Error("Unknown template '" + template + "'");
  }
  return JST[template](data);
};

Tableling.debug = true;
