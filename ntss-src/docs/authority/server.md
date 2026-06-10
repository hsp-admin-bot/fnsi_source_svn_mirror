# サーバー側の機能毎の権限制御について

## 利用者権限を設定する方法

### 利用者マスタのユーザー設定へ権限を追加する

1. 以下の`SQL`を実行してください。
   - `@userId`に対象となる利用者の`ID`を設定
   - `@auth1`、`@auth2`...に対象となる権限の`ID`を設定

```sql
    UPDATE
      mst_user
    SET
      user_settings = user_settings::jsonb || json_build_object(
        'authorized_authorities', array['@auth1', '@auth2']
      )::jsonb
    WHERE
      user_id = @userId
    ;
```

```sql
    -- 例）userId = 8 の利用者に権限 '031'、'032'、'033' を設定する場合

    UPDATE
      mst_user
    SET
      user_settings = user_settings::jsonb || json_build_object(
        'authorized_authorities', array['031', '032', '033']
      )::jsonb
    WHERE
      user_id = 8
    ;
```

### 利用者権限の全権限を付与する（開発時に設定する想定）

1. `yml`に以下の設定を追加する
   - ***注意*** `本番環境`、および `利用者権限制御が必要な環境`には適用しないようにしてください。

```yml
    ntss:
      authority:
        full-authority: true
```

## サーバ側に`Spring Security`の認可を設定する方法

### Controllerクラスに認可の設定をする

1. クラスに`@PreAuthorize("denyAll")`を設定する
   - クラスの全メソッドがアクセス不可となる

```java
    @PreAuthorize("denyAll")
    public class XxxResource {
```

2. メソッドに`@PreAuthorize()`を設定する
   - `リテラル`で指定せずに定数クラス（`AdminWebConstant.Authority`）を使用する

```java
    // 単一の権限を設定する場合
    @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.XXX + "')")
    public ResponseEntity<?> getXxx(

    // 複数の権限を設定する場合（and条件）
    @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.XXX + "') and hasAuthority('" + AdminWebConstant.Authority.XXX + "')")
    public ResponseEntity<?> getXxx(

    // 複数の権限を設定する場合（or条件）
    @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.XXX + "') or hasAuthority('" + AdminWebConstant.Authority.XXX + "')")
    public ResponseEntity<?> getXxx(
```
