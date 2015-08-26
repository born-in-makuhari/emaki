#------------------------------------
# Redisの接続まわりを制御するクラス
#------------------------------------
class RedisAccessControl

    path = File.expand_path('../', __FILE__)

    #外部ファイルからredisサーバーのIPアドレスを取得
    @@env_data = YAML.load_file(path + "/env.yml")
   
    #------------------------------------
    # 環境変数の初期化 
    #------------------------------------ 
    def initialize(redis_ip="")
        @redis_ip =  @@env_data["redis-server_IP2"]
    end
    #------------------------------------
    # Redisの接続を実行するメソッド
    #------------------------------------    
    def access
   #     ad = DataMapper.setup(:default, adapter: 'redis', host: @redis_ip)
        ad = DataMapper.setup(:default, adapter: 'redis', :host => '192.168.10.111:6379')
   #     ad = DataMapper.setup(:default, adapter: 'redis', :host => '#{@redis_ip}')
    return ad
    end
end





