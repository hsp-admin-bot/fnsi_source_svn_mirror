## サインインの設定について

### 概要
サインインの後勝ち設定について記載します。

### application.yml の設定項目
サインインの後勝ち機能における`application.yml`の設定項目は以下の通りです。

```yml
ntss:
  admin-web:
    sing-in:
      restriction: false
```

| キー | 説明 |
| --- | --- |
|ntss.admin-web.sing-in.restriction|サインイン時の後勝ち機能の有効/無効を指定します。true:有効, false:無効|
