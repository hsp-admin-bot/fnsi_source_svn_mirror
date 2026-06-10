### 1. テーブル上に必要な項目
マスタメンテナンス画面上で固定で参照している項目については、必ず定義を行ってください。

|使用目的|物理フィールド名|データ型|制約|
|---|---|---|---|
|主キー|任意|bigserial|単一キーで定義(複合キーは不可)|
|施設コード|facility_cd|character varying(6)||
|作成日|reg_date|timestamp[without time zone]|not null制約 推奨|
|更新日|up_date|timestamp[without time zone]|not null制約 推奨|

### 2. 対応可能なデータ型
グリッド編集で対応可能なデータ型は以下の通りです。下記のデータ型以外をメンテナンスする場合には、
独自メンテナンス画面を作成し、対応を行ってください。

|No|データ型|備考|
|---|---|---|
|1|bigint||
|2|boolean||
|3|character||
|4|character varying||
|5|date||
|6|double precision||
|7|integer||
|8|json|一覧からの直接編集は不可。モーダル画面で編集要|
|9|money||
|10|numeric||
|11|real||
|12|smallint||
|13|text||
|14|timestamp [ without time zone ]|time型、time zone付きは不可|
|15|jsonb|jsonと同様|

### 3. サンプルDDL
```
create table "ntss".mst_die (
    die_no bigint default nextval('mnt_die_die_no_seq'::regclass) not null
  , facility_cd character varying(6) not null
  , die_name character varying(80) not null
  , memo character varying(256)
  , is_del character varying(1) default '0'
  , is_disp character varying(1)
  , reg_date timestamp(3) without time zone  not null
  , up_date timestamp(3) without time zone  not null
  , primary key (die_no)
);
```

### 4. データ更新時の画面非表示項目の扱いについて
行編集画面でカラム情報が未設定の項目については、値の更新は行われません。  
テーブルのデフォルト値を定義して値を設定してください。
