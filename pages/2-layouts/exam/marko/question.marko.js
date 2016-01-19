function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    out.w('<div class="question box"><div class="question text"></div><div class="code hidden"><pre><code>\n\t\t\t\r\n\t\t</code></pre></div></div>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);