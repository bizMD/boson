function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Exam</title><script src="/socket.io/socket.io.js"></script><script>\n\t\t\tvar socket = io();\n\t\t</script></head><body></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);