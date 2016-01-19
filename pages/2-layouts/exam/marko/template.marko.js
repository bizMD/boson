function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne,
      __loadTemplate = __helpers.l,
      __heading_marko = __loadTemplate(require.resolve("./heading.marko"), require),
      __question_marko = __loadTemplate(require.resolve("./question.marko"), require),
      __answer_marko = __loadTemplate(require.resolve("./answer.marko"), require),
      escapeXmlAttr = __helpers.xa,
      escapeXml = __helpers.x;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Exam</title><link rel="stylesheet" href="/layouts/' +
      escapeXmlAttr(data.name) +
      '/css"><script src="/socket.io/socket.io.js"></script><script>\n\t\t\tvar socket = io();\n\t\t</script></head><body>');

    if (data.active === true) {
      out.w('<section class="exam page">');
      __helpers.i(out, __heading_marko, {});
      __helpers.i(out, __question_marko, {});
      __helpers.i(out, __answer_marko, {});

      out.w('<footer class="footer">Time left: <span class="timer">' +
        escapeXml(data.timer) +
        '</span></footer></section>');
    }
    else {
      out.w('<script>\n\t\t\t\twindow.location = \'/home\';\n\t\t\t</script>');
    }

    out.w('<script src="/layouts/' +
      escapeXmlAttr(data.name) +
      '/js"></script></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);