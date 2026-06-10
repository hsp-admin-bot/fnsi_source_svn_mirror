# 放射線検査オーダ関連

連携種別コードは `rad_ord` である。

表示名は `放射線検査オーダ` である。

主なテーブルは `pat_rad_main` である。

## pat_rad_main の代表列

- `rad_result_cd`
  - 放射線検査結果コード。オーダ番号として扱われることがある。
- `pat_id`
  - 患者 ID。
- `facility_cd`
  - 施設コード。
- `reg_rad_date`
  - 登録時放射線検査日時。基準日になることがある。
- `rad_status`
  - 状態区分。
- `is_del`
  - 削除フラグ。

## 関連情報

患者の同姓同名フラグは `pat_main.is_same` である。

ツール側の検索結果 JSON は `MyJson.PatInfo` にマッピングされる。

主な項目は以下である。

- `pat_name`
- `pat_id`
- `ord_no`
- `treat_date`
- `hosp_pat_id`
- `is_same`