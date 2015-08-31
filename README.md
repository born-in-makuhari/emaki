![emaki](https://github.com/born-in-makuhari/emaki/raw/master/public/images/emaki-logo.png)

Emaki
---
Emaki is a simple slide sharing tool.

## Quick Start

    It is easy to use Emaki with docker.  


    ```
    git clone https://github.com/born-in-makuhari/emaki.git
    cd emaki
    ./dock/build.sh
    ./dock/quick-start.sh
    ```

    which would result in:  

    ```
    33333 -> 80:tcp
    44444 -> 443:tcp
    ```

    Emaki is working in a container named "emaki".  
    And then:  

    ```
    http://localhost:33333/
    ```

## License

Emaki is available as open source under the terms of the MIT License.  

---

> Emakimono (絵巻物 emaki-mono, literally 'picture scroll'), often simply called emaki (絵巻?), is a horizontal, illustrated narrative form created during the 11th to 16th centuries in Japan. Emaki-mono combines both text and pictures, and is drawn, painted, or stamped on a handscroll. They depict battles, romance, religion, folk tales, and stories of the supernatural world.

(Emakimono)[https://en.wikipedia.org/wiki/Emakimono]
