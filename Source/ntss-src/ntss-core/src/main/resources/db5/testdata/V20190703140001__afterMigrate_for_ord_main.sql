-- 実績情報で表示するJSON項目がnullのデータを正しい初期値に変更
-- 穿刺者情報
UPDATE
  ord_main
SET
  rst_puncture_user_info =
  '{
   "user_id_1": null,
   "user_last_name_1": null,
   "user_first_name_1": null,
   "user_id_2": null,
   "user_last_name_2": null,
   "user_first_name_2": null,
   "date": null,
   "date_1": null,
   "date_2": null
  }'
WHERE
  rst_puncture_user_info is null
;
-- 返血者情報
UPDATE
  ord_main
SET
  rst_return_user_info =
'{
  "user_id_1": null,
  "user_last_name_1": null,
  "user_first_name_1": null,
  "user_id_2": null,
  "user_last_name_2": null,
  "user_first_name_2": null,
  "date": null,
  "date_1": null,
  "date_2": null
}'
WHERE
  rst_return_user_info is null
;
-- 担当者情報
UPDATE
  ord_main
SET
  rst_charge_user_info =
'{
  "user_id_1": null,
  "user_last_name_1": null,
  "user_first_name_1": null,
  "user_id_2": null,
  "user_last_name_2": null,
  "user_first_name_2": null,
  "date_1": null,
  "date_2": null
}'
WHERE
  rst_charge_user_info is null
;
