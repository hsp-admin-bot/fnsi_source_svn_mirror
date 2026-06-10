# IFEdgeの連携先外部システムを変えるとは何か

## 主旨

IFEdgeの「連携先を変える」とは、対象施設がどの外部システム形式で送受信するかを決める設定群を切り替えることである。

ここでいう外部システムは、NEC HR、SSI、メディコム、セコム、富士通SX、NKK、GX、CSI、NEC iS などのカルテ/部門システムを指す。設定変更の本質は、施設コードに紐づく連携定義、通信方式、電文/ファイル形式、送受信ディレクトリ、IFEdge自身の接続設定を、選択した外部システム向けの値に変えることにある。

## 連携先を決める主要な設定

連携先外部システムは、主に次の4層で決まる。

| 層 | 主な保持場所 | 何を決めるか |
| --- | --- | --- |
| IFEdge本体設定 | `mst_coop_facility.if_edge_setting`、`if_edge/conf/ifedge_setting.json` | IFEdgeがどの施設として動くか、Web APIの向き先、IFEdgeシリアル、受信ポート、通信プロトコル、バックアップ先など。 |
| 配信/受信経路 | `mst_coop_distribute.distribute_setting` | 外部システムとの送受信方式。socket/file/ftp等、ホスト、ポート、監視ディレクトリ、出力ディレクトリ、リネーム方式など。 |
| レイアウト定義 | `mst_coop_layout`、`mst_coop_layout_detail` | どの外部システム形式の電文/ファイルとして解釈・生成するか。NECのVer、SSI/NKKの標準/拡張などもここで有効/無効が切り替わる。 |
| 連携初期設定/API設定 | `mst_coop_ini`、`mst_coop_apilink`、`mst_coop_filename`、`sys_coop_no` | 連携別のパラメータ、API呼び出し、ファイル名、採番ルール。 |

したがって、外部システムを変えるとは、単一のフラグを変えることではない。施設単位で、IFEdge設定、通信経路、レイアウト、初期設定、API/ファイル名/採番を整合した組に変えることである。

## 外部システム種別と切替点

外部システム種別ごとに、IFEdge設定JSONと連携マスタの有効な組み合わせが変わる。

| 外部システム | 施設設定JSON | 外部システムを識別する主な観点 |
| --- | --- | --- |
| NEC HR | `ifedge_setting_NEC.json` | socket/TSHPlus、NEC用ポート、NEC HR用レイアウト、NEC用 `message_type` / `nec_protocol`。 |
| SSI | `ifedge_setting_SSI.json` | SSI用ファイル監視ディレクトリ、SSI用レイアウト、透析オーダ受けの標準/拡張。 |
| メディコム | `ifedge_setting_MEDI.json` | Medicom用ファイル/ソケット経路、患者プロファイル受信、検査/受付/指示/透析実績の経路。 |
| セコム | `ifedge_setting_Secom.json` | セコム用ファイル監視ディレクトリ、`LOCK_` リネーム、受付/検査/放射線/指示/透析実績の経路。 |
| 富士通SX | `ifedge_setting_F_SX.json` | 富士通LifeMark SX用の検査オーダ/透析実績経路、fujitsu系ソケット定義。 |
| NKK | `ifedge_setting_NKK.json` | NKK用ファイル監視ディレクトリ、日機装ベンダーの各連携、透析実績の標準/拡張。 |
| GX | `ifedge_setting_GX.json` | GX向けのfujitsu系ソケット/ファイル経路。 |
| CSI | `ifedge_setting_CSI.json` | CSI向けのheadsocket/csi系ポートと経路。 |
| NEC iS | `ifedge_setting_NEC-iS.json` | NEC iS向けSOAP設定と関連レイアウト。 |

## `if_edge_setting` が変えるもの

`mst_coop_facility.if_edge_setting` と `if_edge/conf/ifedge_setting.json` は、IFEdgeプロセス自身の動作を決める。

主な切替値は次の通り。

- `facility_cd`: IFEdgeが処理対象とする施設コード。
- `urlRoot`: IFEdgeからFNSi側APIへアクセスするURL。ローカル環境なら `http://192.168.100.13:8080/ntss-coop-api/`、HSP環境なら `http://57.180.211.216:8080/ntss-coop-api/` が使われる。
- `serial_no`: IFEdge端末を識別するシリアル番号。
- `protocol`: socket、tshsocket、headsocket、file、soap など、外部システムとの通信方式。
- `socket-type`: NEC、NEC_TSHPlus、pana、fujitsu、csi など、ソケット電文の解釈種別。
- `port`: IFEdgeが外部システムから受けるポート。例としてNEC系では初回指示や検査結果などで複数ポートを使う。
- `keepDirRoot`: 送受信データのバックアップ保存先。
- `data` / `watch`: ファイル連携で監視・処理するディレクトリ。

このJSONを変えることで、IFEdgeプロセスが待ち受けるプロトコル、ポート、ファイル監視場所、FNSi API接続先が変わる。

## `mst_coop_distribute` が変えるもの

`mst_coop_distribute.distribute_setting` は、連携データの実際の入出力先を決める。

外部システム切替で重要な項目は次の通り。

- `protocolInfo.protocol`: `socket`、`tshsocket`、`file`、`ftp` など。
- `protocolInfo.socket-type`: ソケット電文のベンダー種別。
- `protocolInfo.host`: ソケット/FTPの接続先。ローカル検証ではホストPCのIPv4アドレスへ向ける箇所がある。
- `protocolInfo.port`: 連携機能ごとのポート。
- `protocolInfo.address`: ファイル連携で入出力する `/work/...` 配下のパス。
- `protocolInfo.renameWhenCopying`: 外部システムがファイル確定を判断するためのリネーム方式。例: `LOCK_`、`.tmp`。
- `protocolInfo.delete`: 処理後ファイル削除有無。

たとえば、NEC HRでは指示/実績/バイタルをsocket系ポートへ向ける。一方、SSIやNKKでは `/work/ssi/...`、`/work/nkk/...` のようなファイル経路が中心になる。ここを変えることで、IFEdgeがどの外部システムの入出力場所・通信方式を使うかが変わる。

## `mst_coop_layout` / `mst_coop_layout_detail` が変えるもの

`mst_coop_layout` と `mst_coop_layout_detail` は、外部システムごとの電文・ファイルフォーマットを決める。

連携先を変える場合、通信経路だけでなく、取り込むデータ構造と出力するデータ構造も変える必要がある。たとえば同じ「透析実績」でも、NEC HR、SSI、NKK、メディコムではファイル構造や項目配置が異なる。

NEC HRでは次のような追加切替がある。

- `message_type`: NEC仕様Ver。`Ver.1=0`、`Ver.2=1`。
- `nec_protocol`: NECプロトコル。`TSHPlus=0`、`Standard=1`。
- レイアウトの `is_del`: Ver.1/Ver.2、TSHPlus/Standard のどちらを有効にするか。

SSIとNKKでは、標準フォーマット/拡張フォーマットのどちらを使うかを、該当レイアウトの `is_del` で切り替える。

## `mst_coop_ini` が変えるもの

`mst_coop_ini` は連携ごとの初期設定値を保持する。

外部システム切替で特に重要なのは、連携処理が参照する設定JSON内の値である。NEC HRでは `message_type` や `nec_protocol` が更新対象になり、IFEdge設定JSONやレイアウト有効化と整合させる必要がある。

通信方式だけを変えても、`mst_coop_ini` の内部パラメータが旧外部システム向けのままだと、処理分岐や電文生成が不整合になる。

## 施設とIFEdge端末の紐付け

`mst_if_edge` は、IFEdge端末のシリアル番号と施設コードを紐付ける。

連携先変更では、対象施設で動くIFEdge端末を次のような値で識別する。

- `serial_no`: ローカル環境では固定 `99999999001`、HSP環境ではユーザー別の `9001001` から `9001025`。
- `facility_cd`: 対象施設コード。
- `if_edge_name`: `DockerIFEdge_{serial_no}`。
- `memo`: ローカル環境用またはHSPユーザー用の説明。

この紐付けにより、IFEdgeから送られるデータがどの施設の連携データとして扱われるかが決まる。

## 連携先変更として見るべき確認観点

AIが連携先変更を調査する場合は、次を確認する。

- 対象施設の `mst_coop_facility.if_edge_setting` が、選択した外部システム用JSONの内容になっているか。
- `if_edge/conf/ifedge_setting.json` とDB上の `if_edge_setting` が同じ思想の内容になっているか。
- `mst_coop_distribute.distribute_setting` の `protocol`、`socket-type`、`host`、`port`、`address` が外部システムに合っているか。
- `mst_coop_layout` / `mst_coop_layout_detail` が対象外部システムのフォーマットを有効にしているか。
- NEC HRの場合、`message_type`、`nec_protocol`、TSHPlus/Standard、Ver.1/Ver.2 が相互に矛盾していないか。
- SSI/NKKの場合、標準/拡張フォーマットの `is_del` 切替が意図通りか。
- `mst_coop_ini` の連携パラメータが、通信方式とレイアウトに整合しているか。
- `mst_if_edge` のシリアル番号と施設コードが、実際に動かすIFEdgeと一致しているか。

## まとめ

連携先外部システムを変えるとは、施設に紐づくIFEdgeの動作定義を、別ベンダー/別プロトコル/別フォーマットの組に変えることである。

見るべき中心は、`if_edge_setting`、`mst_coop_distribute.distribute_setting`、`mst_coop_layout`、`mst_coop_layout_detail`、`mst_coop_ini`、`mst_if_edge` である。これらが同じ外部システムを指すように揃って初めて、連携先が変わったと言える。
