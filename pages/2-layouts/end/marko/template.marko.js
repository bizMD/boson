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
      out.w('<section class="closing page"><h2 class="goodbye">EXAM CLOSED</h2><div class="message">');

      if (data.timer != '0:00') {
        out.w('<div class="instructions to wait">You have completed the exam. Congratulations!<br> Please sit tight while your fellows finish the test.<br> Do not leave this page to receive your results.</div>');
      }

      out.w('<div class="congratulations hidden">Your score: <span class="total score">0</span> out of <span class="total items">0</span></div></div><div class="remaining time">Time left: <span class="timer">' +
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