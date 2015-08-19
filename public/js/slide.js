var nowNumber = 0;
var pageNumber = 0;

function page(num) {
  nowNumber = num;
  for (var i = 0; i < pageNumber; i++) {
    var $page = $('#slideView section#page' + i);
    var $dot = $('#slideControls #indicatorDot' + i)
    if (i == nowNumber) {
      $page.css('display', '');
      $dot.addClass('active');
    } else {
      $page.css('display', 'none');
      $dot.removeClass('active');
    }
  }
}

function next() {
  if (nowNumber + 1 < pageNumber) {
    nowNumber ++;
    page(nowNumber);
  }
}

function prev() {
  if (nowNumber - 1 >= 0) {
    nowNumber --;
    page(nowNumber);
  }
}

$(function () {
  pageNumber = $('input#pageNumber').val();
  page(nowNumber);

  $('#next').on('click', next);
  $('#prev').on('click', prev);
});
