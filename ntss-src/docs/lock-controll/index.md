## 排他制御について

### 概要

排他制御の対応方法について記載します。

### 実現方法

楽観的排他制御による排他制御を行なっています。
- クライアントから指定された`更新日時`(※1)とテーブルに登録されている`更新日時`が同じかどうかをチェックする
   - 同じ場合、後続処理を実行する
   - 異なる場合、排他エラーとする(後続処理を実装しない)

(※1) 初期表示時にテーブルから取得した更新日時

### 共通対応

#### サーバ

以下の前提条件を満たしていることで共通的に楽観的排他制御を行なっています。

- 前提条件
   - `BaseEntity`を継承していること
   - `BaseEntityListener`が指定されていること
   - 対象テーブルの定義がされていること
   - `@Id`が付与されたフィールドが1つ以上あること
   - `@Id`が付与されたフィールドに値が設定されていること
   - 更新日時に値が設定されていること

   ```Java
   // (排他制御以外の実装は省略)
   
   @Entity(listener = BaseEntityListener.class)
   @Table(name = "xxx")
   public class xxx extends BaseEntity {

       @Id
       private Long xxx;
   ```

- 実装内容
   - `preUpdate`(更新前処理)にて以下の処理を行なっている
     - `Entity`クラスをもとにデータを取得する`SQL`を生成する
       - 対象テーブル：`@Table(name = "xxx")`に指定されているテーブル
       - 抽出項目：全項目
       - 抽出条件：`@Id`が付与されたフィールド + 更新日時
     - 上記で生成したSQLを実行
       - データが取得できた場合、更新処理を行う
       - データが取得できない場合、例外クラス`OptimisticLockException`をスローする

#### クライアント

Web API 呼び出しの際に HTTPステータス 409(Conflict) が返ってきた場合にエラーメッセージを表示する処理を行なっています。

### 各機能側対応

各社様にて対応して頂く内容として、下記の対応が必要となります。

1. 前述の前提条件を満たす`Entity`クラスを実装する。
1. データ取得時に更新日時を取得し、クライアントで保持する。
1. データ更新時に上記2.で保持した更新日時を指定し、Web API を呼び出す。
1. パラメータに上記1.の`Entity`を指定した更新処理を行う。

### 個別対応

何かの理由で共通対応に沿った排他制御を行えない場合、個別に対応が必要です。<br>
その場合は、排他処理を実装したAPIから例外クラス`OptimisticLockException`をスローしてください。<br>
`NtssExceptionHandler`クラスでハンドリングされて、クライアントへ HTTPステータス 409(Conflict) を返します。

```Java
  @ExceptionHandler(OptimisticLockException.class)
  public ResponseEntity<?> handleOptimisticLockException(Exception e, WebRequest request) {
    return createErrorResponse(e, OPTIMISTIC_LOCK_ERROR, request);
  }
```

#### マスタメンテナンスの対応内容

モード1のマスタメンテナンスは、個別対応が必要であったため、以下の修正を行いました。
- データ取得時に更新日時を取得する
- データ更新時の`SQL`の条件に更新日時を追加した
- 更新失敗時に例外クラス`OptimisticLockException`をスローする

(※)モード2のマスタメンテナンスは個別対応が必要
