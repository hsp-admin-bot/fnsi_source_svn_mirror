DROP TRIGGER IF EXISTS trigger_on_mst_mainte_detail ON mst_mainte_detail;

CREATE TRIGGER "trigger_on_mst_mainte_detail" BEFORE INSERT OR UPDATE ON "ntss"."mst_mainte_detail"
FOR EACH ROW
EXECUTE PROCEDURE "ntss"."trigger_on_mst_mainte_detail"();


DROP TRIGGER IF EXISTS trigger_on_mst_mainte_layout ON mst_mainte_layout;

CREATE TRIGGER "trigger_on_mst_mainte_layout" BEFORE INSERT OR UPDATE ON "ntss"."mst_mainte_layout"
FOR EACH ROW
EXECUTE PROCEDURE "ntss"."trigger_on_mst_mainte_layout"();


DROP TRIGGER IF EXISTS trigger_on_mst_mainte_layout_group ON mst_mainte_layout_group;

CREATE TRIGGER "trigger_on_mst_mainte_layout_group" BEFORE INSERT OR UPDATE ON "ntss"."mst_mainte_layout_group"
FOR EACH ROW
EXECUTE PROCEDURE "ntss"."trigger_on_mst_mainte_layout_group"();