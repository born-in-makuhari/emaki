var nowNumber = 0;
var pageNumber = 0;

function page(num) {
  nowNumber = num;
  bar(num);

  for (var i = 0; i < pageNumber; i++) {
    var $page = $('#slideView section#page' + i);
    if (i == nowNumber) {
      $page.css('display', '');
    } else {
      $page.css('display', 'none');
    }
  }
}

function bar(num) {
  $('#nowNumber').text(num + 1);
  $('progress#pageIndicator').val(num);
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
