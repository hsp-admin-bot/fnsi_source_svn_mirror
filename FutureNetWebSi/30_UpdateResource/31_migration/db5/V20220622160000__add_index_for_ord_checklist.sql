--ord_checklistにインデックスを追加(システムで管理する一意なオーダ番号)
CREATE INDEX "ord_checklist_ord_no_index" ON "ntss"."ord_checklist" USING btree (
  "ord_no" "pg_catalog"."int8_ops" ASC NULLS LAST
);
