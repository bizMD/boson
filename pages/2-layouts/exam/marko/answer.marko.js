function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    out.w('<div class="answer area"><div class="input"><div class="textbox hidden"></div><div class="choices hidden"></div><div class="textarea hidden"></div></div><button type="button" class="button">Submit</button></div>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);