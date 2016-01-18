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

    if (data.active === true) {
      var status = 'active';

      var toggle = 'disable';

      var button = 'Disable';
    }
    else {
      var status = 'inactive';

      var toggle = 'enable';

      var button = 'Enable';
    }

    out.w('<div class="activity">The exam is <span class="status">' +
      escapeXml(status) +
      '</span></div><div class="instructions">Click here to <span class="toggle">' +
      escapeXml(toggle) +
      '</span> the exam</div><button class="button">' +
      escapeXml(button) +
      '</button></div></div><div class="second cell"><div class="timer">' +
      escapeXml(data.timer) +
      '</div></div></section><script src="/layouts/' +
      escapeXmlAttr(data.name) +
      '/js"></script></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);