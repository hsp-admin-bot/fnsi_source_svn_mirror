### 前提

`jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboDefNode`
- 参照型コンボの構造定義にマッピングされるエンティティクラス

`jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable`
- 参照型コンボの元となるマスタの情報を保持するクラス

- `ReferenceComboDefNode`クラスは、sys_master_defineテーブルのreference_combo_defカラムで指定する配列内の
1件分のオブジェクトにマッピングされます。

`jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo`
- 参照型コンボの定義から抽出したデータを表現するエンティティクラス


`ReferenceCombo`クラスのメンバーについて
- referencedValue
  - 参照型コンボの定義にて、target_table.referenced_columnで指定されたカラムに設定されている値
- displayValue
  - 参照型コンボの定義にて、target_table.display_columnで指定されたカラムに設定されている値
- identifier
  - 参照型コンボの定義にて、target_table.identifierで指定されたカラムに設定されている値

### サービスクラス

`jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService`

### 使い方

1. サービスクラスを依存に追加します。

```java
@Autowired
private ReferenceComboService referenceComboService;
```

2. buildメソッドを呼び出します。

```java
final List<ReferenceCombo> combos
  = referenceComboService(施設コード: String, 参照型コンボの元となるマスタの情報: .ReferenceComboTargetTable);
```
