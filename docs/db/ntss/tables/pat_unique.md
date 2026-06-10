# pat_unique

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_unique`
- Logical name: 患者固有情報
- Physical name: `pat_unique`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_id`
- Column count: 9
- NOT NULL columns: 1

## Related Config / Notes

- [../config/pat_unique.md](../config/pat_unique.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_personal.pat_id |
|  | 既往歴情報 | medical_hst_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no": (Number)管理番号,<br>    "disp_order": (Number)表示順,<br>　　"facility_cd": (String)登録施設コード,<br>    "is_primary_illness": (String)原疾患,<br>    "is_main_disease": (String)主病名,　※'0':主病名以外、'1':主病名<br>    "is_notice": (String)告知,　※'1:告知済、0:未告知<br>    "disease_date": (String)発症日,<br>    "disease_cd": (Number)病名マスタ.病名コード,<br>    "out_come": (String)転帰,　※'1:治療中、2:診断のみ、3:治癒、4:軽快、5:寛解、6:不変、7:増悪、8:中止、9:転医、10:死亡<br>    "out_come_date": (String)転帰日,<br>    "diagnostician_cd": (Number)スタッフマスタ.スタッフコード　※診断医コード,<br>    "memo": (String)メモ<br><br>    "diagnosis_year": (String)診断年<br>    "diagnosis_month": (String)診断月<br>    "diagnosis_day": (String)診断日<br>    "diagnosis_facility_cd": (String)施設 施設マスタ.施設コード<br>    "course_cd": (Number)診療科 診療科マスタ.診療科コード<br>    "is_confirmation_biopsy": (String)生検確認<br>    "is_diagnosed": (String)確診<br>    "is_dialysis_underlying_disease": (String)透析導入原疾患として扱う<br>    "disease_year": (String)発症年<br>    "disease_month": (String)発症月<br>    "disease_day": (String)発症日<br>    "course_is_free": (String)診療科がフリー入力されているか0:選択 1:フリー入力<br>    "diagnostician_is_free": (String)診断医がフリー入力されているか0:選択 1:フリー入力<br>    "diagnosis_date": (String)診断日付 <br>    "diagnosis_facility_is_free": (String)施設がフリーワードで入力されているか '0':選択、 '1':フリーワード<br>    "die_date": (String)死亡日<br>  },・・・<br>] |
|  | 入外・転入出情報 | in_out_visit_history_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":管理番号,<br>    "disp_order":表示順,<br>　　"facility_cd":登録施設コード,<br>    "move_in_out":転入出区分,<br>    "period_start":転入出期間(開始),<br>    "period_end":転入出期間(終了),<br>    "in_out":,入外区分<br>    "reason":入出理由,<br>    "from_facility":元施設,<br>    "from_course":元科,<br>    "from_doctor":元施設医,<br>    "to_facility":先施設,<br>    "to_course":先科,<br>    "to_doctor":先施設医,<br>    "is_reply":元施設への返信,<br>    "comment":コメント<br>  }, …<br>]<br><br>↓ 10/24-26 打ち合わせ内容(DocBase)<br>受信歴（名称変更：「入外・転入出」(仮)）<br>↑ここまで |
|  | 身体情報 | physical_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":(Number)管理番号,<br>    "exam_date":(String)検査日時<br>    "order_class":(Number)検査区分<br>    "height":(String)身長<br>    "ctr_weight":(String)検査時の体重<br>    "breast_dia":(String)心横径<br>    "chest_dia":(String)胸郭横径<br>    "ctr":(String)CTR<br>    "dw":(String) <br>    "target_weight":(String)目標体重<br>    "indicator_cd":(String)指示者<br>    "indicator_start_date":(String)指示開始日<br>    "memo":(String)コメント<br>    "pre_scale_upper":(String)前体重許容割合（上限）<br>    "pre_scale_lower":(String)前体重許容割合（下限）<br>    "facility_cd":(String) "施設コード"<br>    "inspect_date": (String)"検査日"<br>    "changer_cd": (Number)更新者<br>  },・・・<br>] |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | (旧)更新日時 | old_up_date_unique | timestamp(3) |  |  |  |  |
