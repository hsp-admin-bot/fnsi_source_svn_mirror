# 開発環境構築

NTSSのWebアプリケーション開発環境を構築する方法を説明します。

### 前提条件

開発に利用するマシンは以下のいずれかである必要があります。

- Windows10 Professional
- macOS Sierra
- Linux

次のソフトウェアをインストールしてください。

- Git
- Docker
- Java 8
- Node.js 8.4.0
- Npm 5.4.1

#### Git

Windowsなら[git for windows](https://git-for-windows.github.io/)から最新版をダウンロードしてインストールしてください。
macOSなら以下のコマンドでインストールできます。
```sh
brew install git
```

#### Docker

https://store.docker.com/search?type=edition&offering=community から自分のマシンのOSにあったエディションをダウンロードしてインストールしてください。


#### Java

http://www.oracle.com/technetwork/java/javase/downloads/index.html から最新版のJDKをダウンロードしてインストールしてください。

#### Node.js

 ##### nvmのインストール

Node.js自体のバージョンアップを容易にするために、Windowsの場合は[nvm for Windows](https://github.com/coreybutler/nvm-windows)を利用してNode.jsをインストールします。https://github.com/coreybutler/nvm-windows/releases から最新版の`nvm-setup.zip`をダウンロードし、zip内のインストーラを実行してインストールするとnvmがインストールできます。
macOS、Linuxの場合は[nvm](https://github.com/creationix/nvm)や[ndenv](https://github.com/riywo/ndenv)を利用してください。

##### Node.jsのインストール

コマンドプロンプトを起動して、次のコマンドを実行するとNode.jsをインストールできます。

```
 > nvm install latest
 > nvm use latest
```

上記コマンド実行時に下記メッセージが表示される場合があります。

 > node vlatest.0.0 (64-bit) is not installed.

その場合はインストールされたバージョンを調べて、使用するバージョンを指定してください。

```
 > nvm ls
 > nvm use [インストールされたバージョン]
```

#### npmのインストール（アップデート）

コマンドプロンプトを起動して、次のコマンドを実行すると最新のnpmをインストールできます。

```sh
 > npm install -g npm
```

#### C++コンパイラ、Pythonのインストール

Node.jsの一部のモジュールを利用するにはC++コンパイラ、Pythonが必要になります。Windowsの場合、それらを個別にインストールするのは大変なので[windows-build-tools](https://github.com/felixrieseberg/windows-build-tools)を利用すると一括で必要なツールをインストールできます。

PowerShellを管理者権限で起動して次のコマンドを実行してください。

```
 -> npm install --global windows-build-tools
```

### application.ymlファイルの作成
最新のntss-doc/003.application.yml仕様書/application_yml_仕様書.xlsmを取得する。
application_yml_仕様書.xlsmを起動し、マクロを有効化する。
「ymlファイル出力」シートを開き、「適用対象選択」を選び、「出力先のntss-srcパス」を入力する(ntss-srcの後ろに\はつけないこと)。
ymlファイルの出力実行ボタンを押し。完了メッセージが表示するのを待つ。各出力先にファイルが更新されたことを確認する。


### データベースの作成

データベースにはPostgreSQLを利用します。データベースのインスタンスはDockerを利用して起動します。
以下のコマンドを実行すると開発用DBと自動テスト用DBの2つのPostgreSQLのDockerコンテナが起動します。

```sh
docker-compose -f ntss-admin-web/src/main/docker/postgresql.yml up -d
```

開発用DBはホスト側の5432番ポート、自動テスト用DBはホスト側の5433番ポートにポートフォワードしています。
つまり、開発用DBに接続するにはホスト側でローカルホストの5432番ポート、自動テスト用DBに接続するにはホスト側でローカルホストの5433番ポートが利用できます。

#### マイグレーションの実行

データベースが起動したら、マイグレーションを実行して必要なテーブルを作成します。データベースのマイグレーションには[flyway](https://flywaydb.org/)を利用します。

次のコマンドを実行すると、開発用DBと自動テスト用DBのマイグレーションを実行します。

```sh
./gradlew flywayMigrateAll
./gradlew flywayMigrateAll -Pprofile=test
```

### ビルド環境の構築

バックエンドはJavaで書かれているのでビルドツールには[Gradle](https://gradle.org/)を利用します。
フロントエンドのビルドツールには[webpack](https://webpack.github.io/)を利用します。通常、webpackを利用したフロントエンドのビルドの実行もGradleを経由して実行します（Gradleから[gradle-node-plugin](https://github.com/srs/gradle-node-plugin)を利用してnodeコマンドを実行しています）。

#### フロントエンドモジュールのインストール

フロントエンドのビルドにはプロダクトコードに含むVue.jsとそれらに関連するライブラリ、ビルドに利用するwebpackなどのモジュールが必要です。
次のコマンドを実行するとGradleからnpmを実行して必要なモジュールをインストールします。

```sh
./gradlew npmInstall
```

### ビルドの実行

次のコマンドを実行することでビルドを実行できます。

```sh
./gradlew build -Pfrontend
```

`-Pfrontend`を追加することでフロントエンドのビルドも同時に実行できます。

(E2Eテストを実行しない場合)
```sh
./gradlew build -Pfrontend -x npmRunTestE2e
```
(テストを実行しない場合)
```sh
./gradlew build -Pfrontend -x test -x npmRunTestE2e -x npmTest
```

### テストの実行

次のコマンドを実行することで自動テストを実行できます。
自動テストの実行前には自動テスト用のデータベースが起動している必要があります。

```sh
./gradlew check
```

### アプリケーションの実行

```sh
./gradlew bootRun
```

#### 修正内容を即確認する手順。(対応内容によっては確認できない場合があるため、最終確認は別です事。)

1, bootRunが正常動作中。

2, 新しいpowershellを管理者権限で起動し、『\\*\ntss-src\ntss-admin-web\src\main\frontend』へ移動する。

3, 以下のコマンドを実行する。

```sh
npm run serve
```

4, 成功すれば以下のURL(任意の施設ハッシュ)で起動が可能となる。

```sh
http://localhost:8000/ntss-admin-web/～
```
 　

### アプリケーションの実行(指示履歴のMongoDB使用)

```sh
./gradlew bootRun -Pmongo
```

### API仕様書の生成

```sh
./gradlew apiDoc
```
詳細は[Spring REST DocsでのAPI仕様書生成手順](DEVELOPMENT/API-DOCUMENTATION.md)を参照

### IDE

- Eclipse Java EE IDE for Web Developers. Version: Oxygen Release (4.7.1)

#### プラグイン

Eclipseに次のプラグインをインストールしてください。

- [EditorConfig](https://marketplace.eclipse.org/node/2506426)
- [STS](https://spring.io/tools/sts/all)
  - Update Site: http://dist.springsource.com/release/TOOLS/update/e4.7/
- [Doma Tools](http://eclipse.seasar.org/updates/3.5/features/)
- [Lombok](https://projectlombok.org/)

#### プロジェクトのインポート

Eclipseにインポートする前に、次のコマンドを実行してEclipseの設定ファイルを生成します。

```sh
./gradlew eclipse
```

次に、以下のディレクトリをEclipseのGradleプロジェクトとしてインポートします。

- ntss
  - ntss-admin-web

#### Intellij IDEAを使う場合

1, IDEAに以下のプラグインをインストールしてください。

- [lombok-intellij-plugin](https://github.com/mplushnikov/lombok-intellij-plugin#plugin-installation)

2, ntssディレクトリをインポートしてください。

3, 以下の設定を変更してください。

- Annotation Processingを有効化
  - `Preferences` → `Build, Execution, Deployment` → `Compiler` → `Annotation Processors` → `Enable annotation processing`にチェックを入れる。

- ビルド結果の出力先ディレクトリを変更
  - `File` → `Project Structure` → `Project Settings` → `Modules` → 各モジュールの`Paths > Compiler output`を`Inherit...`に変更する。

### スペルチェック

Visual Studio Codeを使用している場合は、以下のプラグインが使用できます。

[Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)

また、以下のようにすると上記のプラグインをコマンドラインで使用できます。
時々実行してスペルチェックを行ってください。
```
npm install -g cspell
cspell "**/*.js" "**/*.vue" "**/*.java"
```
