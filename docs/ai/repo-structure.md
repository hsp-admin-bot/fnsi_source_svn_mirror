# ディレクトリ構造

## Git と SVN

`C:\FNW\fnsi_local` は開発環境で Git 管理されている。

`C:\FNW\Source` はクライアントリポジトリで SVN 管理されている。

## fnsi_local と Source はミラーリングしている

以下の 2 つは、それ以降のディレクトリ構造がミラーリングしている。

- `C:\FNW\fnsi_local\dev_debug\Source`
- `C:\FNW\Source`

開発者は Git 側の `C:\FNW\fnsi_local\dev_debug\Source` にソースフォルダを配置する。

`C:\FNW\fnsi_local\dev_debug\Source` 配下には、コミットに必要な一部ファイルだけが格納されている。

そのため、更新分比較を行う場合は、`C:\FNW\Source` 配下の本体と比較する必要がある。

## マイグレーションフォルダ

### 開発者マイグレーション格納先

`C:\FNW\fnsi_local\dev_debug\Source\FutureNetWebSi\30_UpdateResource\31_migration\db5`

このフォルダは開発者のマイグレーションを格納するフォルダである。

### リリース用マイグレーション格納先

`C:\FNW\Source\FutureNetWebSi\30_UpdateResource\31_migration\db5`

このフォルダは、開発者マイグレーションに問題がないことを確認した後、リリースする用のフォルダである。

開発者マイグレーションとは中身が異なるため、両者を同一視しないこと。