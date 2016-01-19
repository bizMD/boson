function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    out.w('<h2 class="section name"></h2><h3 class="tester ID">Examinee ID# <span class="ID number"></span></h3>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);