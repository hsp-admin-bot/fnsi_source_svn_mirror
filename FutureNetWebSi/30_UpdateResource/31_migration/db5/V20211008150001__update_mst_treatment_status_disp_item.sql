UPDATE mst_treatment_status_disp_item SET item_name = '終了予測(透析終了)' WHERE item_cd = 11 AND item_name = '終了予測(治療終了)';

-- 既に設定されている箇所の修正 --
UPDATE
  mst_treatment_status_layout
SET
  dcs_view_items = TBC.dcs_view_items
FROM (
  SELECT
    TBB.layout_no,
    json_agg(TBB.tmp_item) AS dcs_view_items
  FROM (
    SELECT
      TBA.layout_no,
      CASE WHEN TBA.item->>'title'='終了予測(治療終了)' AND TBA.item->>'data_class'='11' THEN
        TBA.item || json_build_object(
          'title', '終了予測(透析終了)'
        )::jsonb
      ELSE TBA.item
      END AS tmp_item
    FROM (
      SELECT
        layout_no,
        jsonb_array_elements(dcs_view_items) AS item
      FROM
        mst_treatment_status_layout
    ) AS TBA
  ) AS TBB
  GROUP BY
    TBB.layout_no
) TBC
WHERE
  mst_treatment_status_layout.layout_no = TBC.layout_no
;
