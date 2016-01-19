function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne,
      escapeXmlAttr = __helpers.xa,
      escapeXml = __helpers.x;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Admin Panel</title><link rel="stylesheet" href="/layouts/' +
      escapeXmlAttr(data.name) +
      '/css"><script src="/socket.io/socket.io.js"></script><script>\n\t\t\tvar socket = io();\n\t\t</script></head><body><section class="dashboard"><div class="main panel"><div class="first cell">');

    if (data.timer == '0:00') {
      var status = 'concluded';
    }
    else if (data.active === true) {
      var status = 'active';

      var toggle = 'conclude';

      var button = 'Stop';
    }
    else {
      var status = 'not yet begun';

      var toggle = 'commence';

      var button = 'Start';
    }

    out.w('<div class="activity">The exam is <span class="status">' +
      escapeXml(status) +
      '</span></div>');

    if (data.timer != '0:00') {
      out.w('<div class="instructions">Click here to <span class="toggle">' +
        escapeXml(toggle) +
        '</span> the exam</div><button class="button">' +
        escapeXml(button) +
        '</button>');
    }

    out.w('</div></div><div class="second cell"><div class="timer">' +
      escapeXml(data.timer) +
      '</div></div></section><script src="/layouts/' +
      escapeXmlAttr(data.name) +
      '/js"></script></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);