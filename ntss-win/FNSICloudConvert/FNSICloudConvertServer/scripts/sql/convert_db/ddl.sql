ALTER TABLE "public"."fk_migration_config"
DROP CONSTRAINT "fk_migration_config_fk_type_check",
  DROP CONSTRAINT "chk_fk_column",
  ADD CONSTRAINT "fk_migration_config_fk_type_check" CHECK ((fk_type = ANY (ARRAY['COLUMN'::text, 'JSON'::text, 'JsonIntArray'::text,'JSON_MULTI'::text]))),
  ADD CONSTRAINT "chk_fk_column" CHECK (fk_type = 'COLUMN'::text AND column_name IS NOT NULL OR fk_type = 'JSON'::text AND json_column IS NOT NULL AND json_path IS NOT NULL OR fk_type = 'JsonIntArray'::text AND json_column IS NOT NULL OR fk_type = 'JSON_MULTI'::text AND json_column IS NOT NULL);