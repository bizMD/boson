function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    if (data.active == true) {
      out.w('<button class="button">Start Test</button>');
    }
    else if (data.timer == '0:00') {
      out.w('<button class="button" disabled>Test Is Over</button>');
    }
    else {
      out.w('<button class="button" disabled>Please Wait...</button>');
    }
  };
}
(module.exports = require("marko").c(__filename)).c(create);