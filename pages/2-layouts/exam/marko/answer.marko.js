function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    out.w('<div class="answer area"><div class="input"><div class="textbox hidden"><input class="freetext" name="answer" type="text" placeholder="Enter your answer here"></div><div class="choices hidden"></div></div><button type="button" class="button">Submit</button></div>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);