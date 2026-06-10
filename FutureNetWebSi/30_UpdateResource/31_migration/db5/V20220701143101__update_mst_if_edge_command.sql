ALTER TABLE "ntss"."mst_if_edge_command" DROP COLUMN IF EXISTS processing;
ALTER TABLE "ntss"."mst_if_edge_command" add COLUMN processing varchar(255);
ALTER TABLE "ntss"."mst_if_edge_command" DROP COLUMN IF EXISTS processing_detail;
ALTER TABLE "ntss"."mst_if_edge_command" add COLUMN processing_detail varchar(255);