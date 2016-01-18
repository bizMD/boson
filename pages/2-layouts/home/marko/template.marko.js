function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne,
      escapeXmlAttr = __helpers.xa,
      escapeXml = __helpers.x;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Exam</title><link rel="stylesheet" href="/layouts/' +
      escapeXmlAttr(data.name) +
      '/css"><script src="/socket.io/socket.io.js"></script><script>\n\t\t\tvar socket = io();\n\t\t</script></head><body><section class="landing page"><h2 class="greeting">EXAM BOOKLET</h2><div class="instructions">When the timer below begins, you may start the test</div><div class="timer">' +
      escapeXml(data.timer) +
      '</div><button type="button" class="button" disabled>Start Test</button></section><script src="/layouts/' +
      escapeXmlAttr(data.name) +
      '/js"></script></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);