# フロントエンド開発手順

### 単体テスト
単体テストの実施手順を説明します。

NTSSでは、フロントエンドの単体テストにvueのテストライブラリである[Vue-test-utils](https://vue-test-utils.vuejs.org/ja/)とJavaScriptテストフレームワークの[Jest](https://jestjs.io/ja/)を利用します。
Jestの設定は`package.json`に記載しました。

- テストの書き方
「[Facebook製のJavaScriptテストツール「Jest」の逆引き使用例](https://qiita.com/chimame/items/e97883fd46b67529d59f#%E3%83%86%E3%82%B9%E3%83%88%E6%A7%8B%E6%96%87%E7%B7%A8)」あたりが参考になると思います。

- テストファイル
`任意のファイル名.spec.js`と命名すれば、テストファイルとして自動的に認識されます。
（`××.test.js`でもOKなのですが、単体テストについては`××.spec.js`で統一しましょう。）

- テストコードの格納先
`/ntss-admin-web/src/main/frontend/unit/specs`

- テストの実行
`/ntss-admin-web/src/main/frontend`配下で`npm test`実施
  - テストファイルを自動で読み込んで実行してくれます。
  - `/ntss`での`./gradlew build` 時にもテストは呼ばれます。
