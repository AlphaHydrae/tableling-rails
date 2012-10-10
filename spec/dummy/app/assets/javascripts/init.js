
Backbone.Marionette.Renderer.render = function(template, data) {
  if (template === false) {
    return;
  } else if (typeof(template) == 'function') {
    return template(data);
  }
  if (!JST[template]) {
    throw new Error("Unknown template '" + template + "'");
  }
  return JST[template](data);
};

Tableling.debug = true;
