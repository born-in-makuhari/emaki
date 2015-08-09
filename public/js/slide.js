var nowNumber = 0;
var pageNumber = $('input#pageNumber').val();

function page(num) {
  nowNumber = num;
  for (var i = 0; i < pageNumber; i++) {
    $page = $('#slideView section#page' + i);
    if (i == nowNumber) {
      $page.css('display', 'visible');
    } else {
      $page.css('display', 'none');
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
  page(nowNumber);

  $('#next').on('click', next);
  $('#prev').on('click', prev);
});
