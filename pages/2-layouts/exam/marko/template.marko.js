function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne,
      escapeXmlAttr = __helpers.xa,
      escapeXml = __helpers.x;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Exam</title><link rel="stylesheet" href="/layouts/' +
      escapeXmlAttr(data.name) +
      '/css"><script src="/socket.io/socket.io.js"></script><script>\n\t\t\tvar socket = io();\n\t\t</script></head><body><section class="exam page"><h2 class="section name">JAVASCRIPT</h2><h3 class="tester ID">ID# <span class="ID number">0001</span></h3><div class="question box"><div class="question text">Trace this program. What does it print?</div><pre><code>\n\t\t\t\t\tvar trackMe = false;\n\n\t\t\t\t\tvar asyncFn = function(x) {\n\t\t\t\t\t\tasyncReadFile(function(err, data){\n\t\t\t\t\t\t\tx = data;\n\t\t\t\t\t\t});\n\t\t\t\t\t}\n\n\t\t\t\t\tasyncFn(x);\n\t\t\t\t\tconsole.log(x);\n\t\t\t\t</code></pre></div><div class="answer area"><div class="input"><div class="textbox"><input type="text" placeholder="Enter your answer here"></div></div><button type="button" class="button">Submit</button></div><footer class="footer">Time left: <span class="timer">' +
      escapeXml(data.timer) +
      '</span></footer></section></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);