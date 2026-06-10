-- ord_main(治療情報)　の実績：ベッド名を修正
UPDATE ord_main
  SET rst_bed_name = '101号室2'
WHERE
  ord_no = 1;
