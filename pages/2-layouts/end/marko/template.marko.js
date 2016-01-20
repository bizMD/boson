function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne,
      escapeXmlAttr = __helpers.xa,
      escapeXml = __helpers.x;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Done!</title><link rel="stylesheet" href="/layouts/' +
      escapeXmlAttr(data.name) +
      '/css"><script src="/socket.io/socket.io.js"></script><script>\n\t\t\tvar socket = io();\n\t\t</script></head><body>');

    if (data.active === true) {
      out.w('<section class="closing page"><h2 class="goodbye">EXAM CLOSED</h2><div class="message">You have completed the exam. Congratulations! Please sit tight while your\nfellows do the same. Do not leave this page to receive your\nresults.</div><div class="remaining time">Time left: <span class="timer">' +
        escapeXml(data.timer) +
        '</span></div></section>');
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