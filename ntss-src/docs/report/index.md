## 帳票出力の設定について

### 概要
帳票出力機能の設定について記載します。

### application.yml の設定項目
帳票出力機能における`application.yml`の設定項目は以下の通りです。

```yml
ntss:
  report:
    s3-bucket: 'ntss-esm'
    cache-dir: '/opt/ntss-admin-web/report/cache'
```

| キー | 説明 |
| --- | --- |
|ntss.report.s3-bucket|S3のバケット名を指定します。|
|ntss.report.cache-dir|S3上の帳票ファイルをキャッシュするEC2上のディレクトリを指定します。<br>キャッシュを更新するタイミングは、帳票マスタの更新日時(`mst_report.up_date`)が変更された時点です。|
