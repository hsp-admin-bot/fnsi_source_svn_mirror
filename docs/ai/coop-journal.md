# 外部連携ジャーナル確認

送信後の確認対象テーブルは `sys_coop_journal` である。

## 代表確認列

- `facility_cd`
- `coop_cd`
- `crud`
- `ope_cd`
- `pat_id`
- `hosp_pat_id`
- `ord_no`
- `base_date`
- `ana_result`
- `coop_result`
- `reg_date`
- `message`

## 補足

連携イベント作成・中止ツールの送信では、検索結果の患者 ID、連携用患者番号、オーダ番号、基準日がジャーナルに渡る。

AI が送信結果確認を行う場合は、検索条件と送信値の対応関係を意識し、`sys_coop_journal` 上の確認観点を整理して説明すること。