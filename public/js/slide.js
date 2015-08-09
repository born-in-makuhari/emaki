var nowNumber = 0;
var pageNumber = $('input#pageNumber').val();

function page(num) {
  for (var i = 0; i < pageNumber; i++) {
    $page = $('#slideView section#page' + i);
    if (i == nowNumber) {
      $page.css('display', 'visible');
    } else {
      $page.css('display', 'none');
    }
  }
}

$(function () {
  page(nowNumber);
});
