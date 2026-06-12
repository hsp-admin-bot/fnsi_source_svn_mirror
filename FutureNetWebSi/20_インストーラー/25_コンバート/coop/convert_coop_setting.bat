@echo off
@echo FNWの連携設定を出力
sqlplus nkk/nkk@NKKFN3_innoshima @.\sql\get_fnw_coop_setting.sql
@echo FNWの連携データ設定を出力
sqlplus nkk/nkk@NKKFN3_innoshima @.\sql\get_fnw_coop_ini.sql
@echo FNWの施設設定を出力
sqlplus nkk/nkk@NKKFN3_innoshima @.\sql\get_fnw_coop_facility.sql
