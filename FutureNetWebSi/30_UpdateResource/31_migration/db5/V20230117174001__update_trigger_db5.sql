DROP TRIGGER IF EXISTS trigger_on_mst_mainte_category ON mst_mainte_category;

CREATE TRIGGER "trigger_on_mst_mainte_category" BEFORE INSERT OR UPDATE ON "ntss"."mst_mainte_category"
FOR EACH ROW
EXECUTE PROCEDURE "ntss"."trigger_on_mst_mainte_category"();