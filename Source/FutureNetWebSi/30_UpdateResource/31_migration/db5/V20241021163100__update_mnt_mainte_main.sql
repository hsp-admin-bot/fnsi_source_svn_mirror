-- #11131 定期点検で使用する記録番号のデータ型がFNWと相違している
ALTER TABLE "ntss"."mnt_mainte_main"
ALTER COLUMN "rec_no" TYPE VARCHAR(64) USING "rec_no"::VARCHAR;