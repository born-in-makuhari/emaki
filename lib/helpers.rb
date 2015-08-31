helpers do
  # -------------------------------------------------------------------------
  # アテンションメッセージ保持
  #
  # エラーなどのhtmlをリダイレクト先へ送る。
  #     attention :no_file
  #         views/attentions/no_file.slim をセット
  #     attention?
  #         前回、attentionメソッドを呼び出していたら、
  #         その内容（html）を返す
  #     load_attention
  #         beforeで使う。
  def attention(key = nil)
    return @attention unless key
    session[:attention] = slim :"attentions/#{key}", layout: false
  end

  def load_attention
    @attention = session[:attention]
    session[:attention] = nil
  end

  def attention?
    attention
  end

  # -------------------------------------------------------------------------
  # 入力値保持
  #
  #     last :email
  #         前回の入力値を得る
  #
  #     ignore_last :slide
  #         ほじりたくないものを指定する
  #
  def ignore_last(key)
    @last_input_without ||= []
    @last_input_without << key
  end

  def save_last
    last = {}
    @last_input_without ||= []
    params.each do |k, v|
      next if @last_input_without.include? k
      last[k] = v
    end
    session[:last_input] = last.to_json
  end

  def last(key)
    unless @last_input
      @last_input ||= JSON.parse session[:last_input] if session[:last_input]
      @last_input ||= {}
    end
    @last_input[key.to_s]
  end
end
