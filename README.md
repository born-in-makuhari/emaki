<div align="center">
  <img src="https://github.com/born-in-makuhari/emaki/raw/master/public/images/emaki-logo.png" width="240">
</div>

Emaki
---
Emaki is a simple slide sharing tool.

## Quick Start

  It is easy to use Emaki with docker.  

  ```
  git clone https://github.com/born-in-makuhari/emaki.git
  cd emaki
  alias docker="sudo docker" # if your 'docker' command needs 'sudo'
  . dock/build.sh
  . dock/db-start.sh
  . dock/quick-start.sh
  ```

  which would result in:  

  ```
  80:tcp --> 0.0.0.0:12321
  ```

  Emaki is working in a container named "emaki".  
  And then:  

  ```
  http://localhost:12321/
  ```

## License

  Emaki is available as open source under the terms of the MIT License.  

## Emaki ?

> Emakimono (絵巻物 emaki-mono, literally 'picture scroll'), often simply called emaki (絵巻?), is a horizontal, illustrated narrative form created during the 11th to 16th centuries in Japan. Emaki-mono combines both text and pictures, and is drawn, painted, or stamped on a handscroll. They depict battles, romance, religion, folk tales, and stories of the supernatural world.

[Emakimono - Wikipedia](https://en.wikipedia.org/wiki/Emakimono)
