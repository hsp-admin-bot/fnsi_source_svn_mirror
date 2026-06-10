# 開発

ntss-admin-webはフロントエンドがJavaScriptで、バックエンドはJavaで書かれています。
フロントエンドとバックエンドはREST APIでやりとりします。

### フロントエンド

[Vue.js](https://jp.vuejs.org/index.html)で作成されています。
ラウティングには[vue-router](https://router.vuejs.org/ja/)を、状態管理には[vuex](https://vuex.vuejs.org/ja/)を利用します。

### バックエンド

バックエンドは[Spring Boot](https://projects.spring.io/spring-boot/)で構築されています。
データベースへのアクセスには[Doma2](https://doma.readthedocs.io/ja/stable/)を利用します。
データベースは[PostgreSQL](https://www.postgresql.org/)を利用します。
