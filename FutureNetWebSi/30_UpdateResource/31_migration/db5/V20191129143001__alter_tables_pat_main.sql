-- 項目追加
ALTER TABLE pat_main ADD COLUMN is_wheel_chair character varying(1);
-- コメント追加
COMMENT ON COLUMN "pat_main"."is_wheel_chair" IS E'車いす有無';
--初期データ
update pat_main set is_wheel_chair = '0';
update pat_main A set is_wheel_chair = '1'
from (select facility_cd, pat_id from mst_wheel_chair) B
where A.facility_cd = B.facility_cd
and A.pat_id = B.pat_id;
