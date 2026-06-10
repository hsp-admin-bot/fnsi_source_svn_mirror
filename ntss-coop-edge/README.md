# NTSS

 ## IFエッジ用
  ### ディレクトリ構成
 ~~~
ntss-coop-edge
│settings.js                Node-RED設定
├custom_nodes               カスタムノード
│└custom-file-watch            ファイル監視ノード
│   custom-file-watch.html
│   custom-file-watch.js
│   exclude.json
│   package.json
├Flow                       フロー
│   ntss_if.json               IFメインフロー
├lib                        自作ライブラリ
│   CommonLib.js
│   hextosjistest.js
│   socket_normal.js
│   socket_standard.js
│   socket_tshplus.js
└settings                   その他Node-RED動作にかかる設定
  ├etc
  │ ├sysconfig
  │ │   ntss
  │ └systemd
  │   └system
  │      nodered.service
  └IF_Edge
     └conf
        ifedge_setting.json
        ifedge_setting_Fujitsu.json

~~~

 ### 項目



 ### その他

 

 ### 補足
