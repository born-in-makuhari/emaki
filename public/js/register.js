var Register = {};
Register.UN_CHANGED = false;

$(function () {

  $('#register #username').on('change', function () {
    Register.UN_CHANGED = true;
  });


  $('#register #email').on('change', function() {
    // usernameが手入力されていなければ自動補完する
    if ( ! Register.UN_CHANGED ) {
      var slug = $('#register #email').val();
      var slug = slug.replace(/@.+/g, '');
      var slug = slug.replace(/\./g, '-');
      var slug = slug.replace(/[0-9]/g, '');
      var slug = slug.replace(/[-_]+$/, '');
      var slug = slug.replace(/^[-_]+/, '');
      // 重複排除
      var slug = slug.replace(/-[-_]+/g, '-');
      var slug = slug.replace(/_[-_]+/g, '_');
      $('#register #username').val(slug);
    }
  });
});
