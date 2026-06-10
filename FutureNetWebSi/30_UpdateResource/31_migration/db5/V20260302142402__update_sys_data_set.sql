DELETE FROM "ntss"."sys_data_set" where sql_cd in (1,13,14,18,19,20,26,32,33,34,203,215);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1, '{"collection": "pat_personal_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_pat_contact_info}', 4, '[{"preview": "123456789012", "can_calc": "0", "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ニッキソウ　タロウ", "can_calc": "0", "data_code": "pat_name_kana", "data_name": "フリガナ", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_name_kana", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "nikkiso　tarou", "can_calc": "0", "data_code": "pat_name_alpha", "data_name": "英語表記", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_name_alpha", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1945/01/01", "can_calc": "0", "data_code": "pat_birthday", "data_name": "生年月日", "data_type": "DateTime", "conv_table": [], "data_class": "本人情報", "field_name": "pat_birthday", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "pat_age", "data_name": "年齢", "data_type": "decimal", "conv_table": [], "data_class": "本人情報", "field_name": "pat_age", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "男性", "can_calc": "0", "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "男性", "item": "男性"}, {"code": "2", "disp": "女性", "item": "女性"}], "data_class": "本人情報", "field_name": "pat_sex", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "本人情報", "field_name": "in_out_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "AB", "can_calc": "0", "data_code": "pat_blood_type_abo", "data_name": "血液型ABO型", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "A型", "item": "A型"}, {"code": "2", "disp": "B型", "item": "B型"}, {"code": "3", "disp": "O型", "item": "O型"}, {"code": "4", "disp": "AB型", "item": "AB型"}], "data_class": "本人情報", "field_name": "pat_blood_type_abo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Rh+", "can_calc": "0", "data_code": "pat_blood_type_rh", "data_name": "血液型Rh型", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "Rh+", "item": "Rh+"}, {"code": "2", "disp": "Rh-", "item": "Rh-"}], "data_class": "本人情報", "field_name": "pat_blood_type_rh", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A型 Rh-", "can_calc": "0", "data_code": "pat_blood_type_abo_rh", "data_name": "血液型ABORH", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "10", "disp": "A型 RH不明", "item": "A型 RH不明"}, {"code": "20", "disp": "B型 RH不明", "item": "B型 RH不明"}, {"code": "30", "disp": "O型 RH不明", "item": "O型 RH不明"}, {"code": "40", "disp": "AB型 RH不明", "item": "AB型 RH不明"}, {"code": "1", "disp": "不明 Rh+", "item": "不明 Rh+"}, {"code": "11", "disp": "A型 Rh+", "item": "A型 Rh+"}, {"code": "21", "disp": "B型 Rh+", "item": "B型 Rh+"}, {"code": "31", "disp": "O型 Rh+", "item": "O型 Rh+"}, {"code": "41", "disp": "AB型 Rh+", "item": "AB型 Rh+"}, {"code": "2", "disp": "不明 Rh-", "item": "不明 Rh-"}, {"code": "12", "disp": "A型 Rh-+", "item": "A型 Rh-"}, {"code": "22", "disp": "B型 Rh-", "item": "B型 Rh-"}, {"code": "32", "disp": "O型 Rh-", "item": "O型 Rh-"}, {"code": "42", "disp": "AB型 Rh-", "item": "AB型 Rh-"}], "data_class": "本人情報", "field_name": "pat_blood_type_abo_rh", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A1", "can_calc": "0", "data_code": "pat_blood_type_serovar", "data_name": "血液型亜型", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "11", "disp": "A1", "item": "A1"}, {"code": "12", "disp": "Aint型", "item": "AAint"}, {"code": "13", "disp": "A2", "item": "A2"}, {"code": "14", "disp": "A3", "item": "A3"}, {"code": "15", "disp": "Ax", "item": "Ax"}, {"code": "16", "disp": "Am", "item": "Am"}, {"code": "17", "disp": "Ael", "item": "Ael"}, {"code": "18", "disp": "Aend", "item": "Aend"}, {"code": "21", "disp": "B1", "item": "B1"}, {"code": "22", "disp": "Bint", "item": "Bint"}, {"code": "23", "disp": "B2", "item": "B2"}, {"code": "24", "disp": "B3", "item": "B3"}, {"code": "25", "disp": "Bx", "item": "Bx"}, {"code": "26", "disp": "Bm", "item": "Bm"}, {"code": "27", "disp": "Bel", "item": "Bel"}, {"code": "28", "disp": "Bend", "item": "Bend"}, {"code": "31", "disp": "Oh", "item": "Oh"}, {"code": "32", "disp": "Ah", "item": "Ah"}, {"code": "33", "disp": "Bh", "item": "Bh"}, {"code": "34", "disp": "Om", "item": "Om"}, {"code": "35", "disp": "Am", "item": "Am"}, {"code": "36", "disp": "Bm", "item": "Bm"}, {"code": "400", "disp": "不明 不明", "item": "不明 不明"}, {"code": "401", "disp": "不明 B1", "item": "不明 B1"}, {"code": "402", "disp": "不明 Bint", "item": "不明 Bint"}, {"code": "403", "disp": "不明 B2", "item": "不明 B2"}, {"code": "404", "disp": "不明 B3", "item": "不明 B3"}, {"code": "405", "disp": "不明 Bx", "item": "不明 Bx"}, {"code": "406", "disp": "不明 Bm", "item": "不明 Bm"}, {"code": "407", "disp": "不明 Bel", "item": "不明 Bel"}, {"code": "408", "disp": "不明 Bend", "item": "不明 Bend"}, {"code": "410", "disp": "A1 不明", "item": "A1 不明"}, {"code": "411", "disp": "A1 B1", "item": "A1 B1"}, {"code": "412", "disp": "A1 Bint", "item": "A1 Bint"}, {"code": "413", "disp": "A1 B2", "item": "A1 B2"}, {"code": "414", "disp": "A1 B3", "item": "A1 B3"}, {"code": "415", "disp": "A1 Bx", "item": "A1 Bx"}, {"code": "416", "disp": "A1 Bm", "item": "A1 Bm"}, {"code": "417", "disp": "A1 Bel", "item": "A1 Bel"}, {"code": "418", "disp": "A1 Bend", "item": "A1 Bend"}, {"code": "420", "disp": "Aint 不明", "item": "Aint 不明"}, {"code": "421", "disp": "Aint B1", "item": "Aint B1"}, {"code": "422", "disp": "Aint Bint", "item": "Aint Bint"}, {"code": "423", "disp": "Aint B2", "item": "Aint B2"}, {"code": "424", "disp": "Aint B3", "item": "Aint B3"}, {"code": "425", "disp": "Aint Bx", "item": "Aint Bx"}, {"code": "426", "disp": "Aint Bm", "item": "Aint Bm"}, {"code": "427", "disp": "Aint Bel", "item": "Aint Bel"}, {"code": "428", "disp": "Aint Bend", "item": "Aint Bend"}, {"code": "430", "disp": "A2 不明", "item": "A2 不明"}, {"code": "431", "disp": "A2 B1", "item": "A2 B1"}, {"code": "432", "disp": "A2 Bint", "item": "A2 Bint"}, {"code": "433", "disp": "A2 B2", "item": "A2 B2"}, {"code": "434", "disp": "A2 B3", "item": "A2 B3"}, {"code": "435", "disp": "A2 Bx", "item": "A2 Bx"}, {"code": "436", "disp": "A2 Bm", "item": "A2 Bm"}, {"code": "437", "disp": "A2 Bel", "item": "A2 Bel"}, {"code": "438", "disp": "A2 Bend", "item": "A2 Bend"}, {"code": "440", "disp": "A3 不明", "item": "A3 不明"}, {"code": "441", "disp": "A3 B1", "item": "A3 B1"}, {"code": "442", "disp": "A3 Bint", "item": "A3 Bint"}, {"code": "443", "disp": "A3 B2", "item": "A3 B2"}, {"code": "444", "disp": "A3 B3", "item": "A3 B3"}, {"code": "445", "disp": "A3 Bx", "item": "A3 Bx"}, {"code": "446", "disp": "A3 Bm", "item": "A3 Bm"}, {"code": "447", "disp": "A3 Bel", "item": "A3 Bel"}, {"code": "448", "disp": "A3 Bend", "item": "A3 Bend"}, {"code": "450", "disp": "Ax 不明", "item": "Ax 不明"}, {"code": "451", "disp": "Ax B1", "item": "Ax B1"}, {"code": "452", "disp": "Ax Bint", "item": "Ax Bint"}, {"code": "453", "disp": "Ax B2", "item": "Ax B2"}, {"code": "454", "disp": "Ax B3", "item": "Ax B3"}, {"code": "455", "disp": "Ax Bx", "item": "Ax Bx"}, {"code": "456", "disp": "Ax Bm", "item": "Ax Bm"}, {"code": "457", "disp": "Ax Bel", "item": "Ax Bel"}, {"code": "458", "disp": "Ax Bend", "item": "Ax Bend"}, {"code": "460", "disp": "Am 不明", "item": "Am 不明"}, {"code": "461", "disp": "Am B1", "item": "Am B1"}, {"code": "462", "disp": "Am Bint", "item": "Am Bint"}, {"code": "463", "disp": "Am B2", "item": "Am B2"}, {"code": "464", "disp": "Am B3", "item": "Am B3"}, {"code": "465", "disp": "Am Bx", "item": "Am Bx"}, {"code": "466", "disp": "Am Bm", "item": "Am Bm"}, {"code": "467", "disp": "Am Bel", "item": "Am Bel"}, {"code": "468", "disp": "Am Bend", "item": "Am Bend"}, {"code": "470", "disp": "Ael 不明", "item": "Ael 不明"}, {"code": "471", "disp": "Ael B1", "item": "Ael B1"}, {"code": "472", "disp": "Ael Bint", "item": "Ael Bint"}, {"code": "473", "disp": "Ael B2", "item": "Ael B2"}, {"code": "474", "disp": "Ael B3", "item": "Ael B3"}, {"code": "475", "disp": "Ael Bx", "item": "Ael Bx"}, {"code": "476", "disp": "Ael Bm", "item": "Ael Bm"}, {"code": "477", "disp": "Ael Bel", "item": "Ael Bel"}, {"code": "478", "disp": "Ael Bend", "item": "Ael Bend"}, {"code": "480", "disp": "Aend 不明", "item": "Aend 不明"}, {"code": "481", "disp": "Aend B1", "item": "Aend B1"}, {"code": "482", "disp": "Aend Bint", "item": "Aend Bint"}, {"code": "483", "disp": "Aend B2", "item": "Aend B2"}, {"code": "484", "disp": "Aend B3", "item": "Aend B3"}, {"code": "485", "disp": "Aend Bx", "item": "Aend Bx"}, {"code": "486", "disp": "Aend Bm", "item": "Aend Bm"}, {"code": "487", "disp": "Aend Bel", "item": "Aend Bel"}, {"code": "488", "disp": "Aend Bend", "item": "Aend Bend"}], "data_class": "本人情報", "field_name": "pat_blood_type_serovar", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日本", "can_calc": "0", "conv_sql": {"sql_cd": 139, "field_name": "country_name", "target_var": "@countryCdAlpha3"}, "data_code": "nationality", "data_name": "国籍", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "nationality", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150-8677", "can_calc": "0", "data_code": "pat_zip", "data_name": "郵便番号", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_zip", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "東京都渋谷区恵比寿3-43-2 日機装第１別館１F", "can_calc": "0", "data_code": "pat_address", "data_name": "住所", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_address", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-1234-5678", "can_calc": "0", "data_code": "pat_tel1", "data_name": "電話番号1", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_tel1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "090-1234-5678", "can_calc": "0", "data_code": "pat_tel2", "data_name": "電話番号2", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_tel2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-8765-4321", "can_calc": "0", "data_code": "pat_fax", "data_name": "FAX", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_fax", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxx@xxxx.xx.xx", "can_calc": "0", "data_code": "pat_e_mail", "data_name": "Email", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_e_mail", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "pat_work_name", "data_name": "勤務先名", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_work_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-5678-1234", "can_calc": "0", "data_code": "pat_work_tel", "data_name": "勤務先電話番号", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_work_tel", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ1です。", "can_calc": "0", "data_code": "pat_memo1", "data_name": "メモ1", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_memo1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ2です。", "can_calc": "0", "data_code": "pat_memo2", "data_name": "メモ2", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_memo2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期（部分介助）", "can_calc": "0", "data_code": "severity_name", "data_name": "重症度", "data_type": "string", "conv_table": [], "data_class": "透析困難・重症度・搬送区分", "field_name": "severity_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "data_code": "transport_name", "data_name": "搬送区分", "data_type": "string", "conv_table": [], "data_class": "透析困難・重症度・搬送区分", "field_name": "transport_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "急性ウィルス肝炎", "can_calc": "0", "data_code": "die_name", "data_name": "死因", "data_type": "string", "conv_table": [], "data_class": "死亡情報", "field_name": "die_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "死亡", "can_calc": "0", "data_code": "is_die", "data_name": "死亡判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "存命", "item": "存命"}, {"code": "1", "disp": "死亡", "item": "死亡"}], "data_class": "死亡情報", "field_name": "is_die", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "die_date", "data_name": "死亡日", "data_type": "DateTime", "conv_table": [], "data_class": "死亡情報", "field_name": "die_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "die_in_hospital_cd_1", "data_name": "死因連携コード", "data_type": "string", "conv_table": [], "data_class": "死亡情報", "field_name": "die_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：pat_personal_main 単型 @patId @facilityCd @toDate', '2019-05-29 17:24:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (13, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_pat_memo_info}; ', 4, '[{"preview": "", "can_calc": "0", "data_code": "memo01_title", "data_name": "タイトル1", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo01_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo01_content", "data_name": "内容1", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo01_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo02_title", "data_name": "タイトル2", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo02_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo02_content", "data_name": "内容2", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo02_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo03_title", "data_name": "タイトル3", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo03_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo03_content", "data_name": "内容3", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo03_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo04_title", "data_name": "タイトル4", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo04_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo04_content", "data_name": "内容4", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo04_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo05_title", "data_name": "タイトル5", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo05_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo05_content", "data_name": "内容5", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo05_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo06_title", "data_name": "タイトル6", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo06_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo06_content", "data_name": "内容6", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo06_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo07_title", "data_name": "タイトル7", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo07_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo07_content", "data_name": "内容7", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo07_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo08_title", "data_name": "タイトル8", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo08_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo08_content", "data_name": "内容8", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo08_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo09_title", "data_name": "タイトル9", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo09_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo09_content", "data_name": "内容9", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo09_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo10_title", "data_name": "タイトル10", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo10_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo10_content", "data_name": "内容10", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo10_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo11_title", "data_name": "タイトル11", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo11_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo11_content", "data_name": "内容11", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo11_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo12_title", "data_name": "タイトル12", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo12_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo12_content", "data_name": "内容12", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo12_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo13_title", "data_name": "タイトル13", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo13_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo13_content", "data_name": "内容13", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo13_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo14_title", "data_name": "タイトル14", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo14_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo14_content", "data_name": "内容14", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo14_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo15_title", "data_name": "タイトル15", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo15_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo15_content", "data_name": "内容15", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo15_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo16_title", "data_name": "タイトル16", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo16_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo16_content", "data_name": "内容16", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo16_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo17_title", "data_name": "タイトル17", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo17_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo17_content", "data_name": "内容17", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo17_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo18_title", "data_name": "タイトル18", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo18_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo18_content", "data_name": "内容18", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo18_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo19_title", "data_name": "タイトル19", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo19_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo19_content", "data_name": "内容19", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo19_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo20_title", "data_name": "タイトル20", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo20_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo20_content", "data_name": "内容20", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo20_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：患者フリーコメント 単型 @patId @facilityCd @toDate', '2020-03-04 13:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (14, '{"collection": "pat_insurance_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_selected": "1"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_insu_set_info&insu_info&insu_pub_info}', 4, '[{"preview": "主保険", "can_calc": "0", "data_code": "is_selected", "data_name": "主保険フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "主保険ではない", "item": "主保険ではない"}, {"code": "1", "disp": "主保険", "item": "主保険"}], "data_class": "保険情報", "field_name": "is_selected", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "公費", "can_calc": "0", "data_code": "insu_class", "data_name": "保険区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "保険", "item": "保険"}, {"code": "1", "disp": "公費", "item": "公費"}, {"code": "2", "disp": "セット", "item": "セット"}, {"code": "3", "disp": "自費", "item": "自費"}], "data_class": "保険情報", "field_name": "insu_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_name", "data_name": "保険名", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_name_short", "data_name": "略称", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_name_short", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "被扶養者", "can_calc": "0", "data_code": "insu_kbn", "data_name": "扶養区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "被保険者", "item": "被保険者"}, {"code": "1", "disp": "被扶養者", "item": "被扶養者"}], "data_class": "保険情報", "field_name": "insu_kbn", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12345678", "can_calc": "0", "data_code": "insu_no", "data_name": "保険者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "data_code": "insu_pat_name", "data_name": "保険者名称", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "insu_pat_mark", "data_name": "被保険者記号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_mark", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "insu_pat_no", "data_name": "被保険者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/2/15", "can_calc": "0", "data_code": "insu_start_date", "data_name": "開始日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_start_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/2/15", "can_calc": "0", "data_code": "insu_end_date", "data_name": "終了日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_end_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/2/16", "can_calc": "0", "data_code": "insu_check_date", "data_name": "確認日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_check_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "対象外", "can_calc": "0", "data_code": "cki_class", "data_name": "長期高額療養", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "対象者", "item": "対象者"}, {"code": "2", "disp": "１０００円対象者", "item": "１０００円対象者"}, {"code": "3", "disp": "２０００円対象者", "item": "２０００円対象者"}], "data_class": "保険情報", "field_name": "cki_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "一般", "can_calc": "0", "data_code": "kki_class", "data_name": "高額受給者又は後期高齢者医療", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "一般", "item": "一般"}, {"code": "2", "disp": "７割給付", "item": "７割給付"}], "data_class": "保険情報", "field_name": "kki_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "６歳未満", "can_calc": "0", "data_code": "und_six", "data_name": "6歳未満", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "６歳未満", "item": "６歳未満"}], "data_class": "保険情報", "field_name": "und_six", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "data_code": "futan_g", "data_name": "負担率外来", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "futan_g", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "futan_n", "data_name": "負担率入院", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "futan_n", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ１", "can_calc": "0", "data_code": "memo1", "data_name": "保険メモ1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "memo1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ２", "can_calc": "0", "data_code": "memo2", "data_name": "保険メモ2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "memo2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_name", "data_name": "公費負担者名1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_name", "data_name": "公費負担者名2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_name", "data_name": "公費負担者名3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_name", "data_name": "公費負担者名4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub1_no", "data_name": "公費負担者番号1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub2_no", "data_name": "公費負担者番号2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub3_no", "data_name": "公費負担者番号3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub4_no", "data_name": "公費負担者番号4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub1_pat_no", "data_name": "公費受給者番号1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub2_pat_no", "data_name": "公費受給者番号2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub3_pat_no", "data_name": "公費受給者番号3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub4_pat_no", "data_name": "公費受給者番号4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_passbook_no", "data_name": "障害者手帳番号1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_passbook_no", "data_name": "障害者手帳番号2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_passbook_no", "data_name": "障害者手帳番号3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_passbook_no", "data_name": "障害者手帳番号4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_info_name", "data_name": "保険", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub1_info_name", "data_name": "公費1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub2_info_name", "data_name": "公費2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub3_info_name", "data_name": "公費3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub4_info_name", "data_name": "公費4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：保険情報 単型 @patId @facilityCd @toDate', '2021-10-05 21:41:55', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (18, '{"collection": "pat_personal_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_dial_diff_com_info}', 4, '[{"preview": "あり", "can_calc": "0", "data_code": "is_pat_dial_diff", "data_name": "透析困難有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "透析困難・重症度・搬送区分", "field_name": "is_pat_dial_diff", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "高血圧", "can_calc": "0", "data_code": "pat_dial_diff_name", "data_name": "透析困難理由", "data_type": "string", "conv_table": [], "data_class": "透析困難(主)", "field_name": "pat_dial_diff_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "pat_in_hospital_cd_1", "data_name": "透析困難理由連携コード1", "data_type": "string", "conv_table": [], "data_class": "透析困難(主)", "field_name": "pat_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "pat_in_hospital_cd_2", "data_name": "透析困難理由連携コード2", "data_type": "string", "conv_table": [], "data_class": "透析困難(主)", "field_name": "pat_in_hospital_cd_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2024/01/01 00:00:00", "can_calc": "0", "data_code": "reg_date", "data_name": "透析困難理由登録日時", "data_type": "DateTime", "conv_table": [], "data_class": "透析困難(主)", "field_name": "reg_date", "disp_format": "yyyy/MM/dd hh:mm:ss", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：透析困難(主のみ) 単型 @patId @facilityCd @toDate', '2020-03-24 00:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (19, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_medical_care_info}', 4, '[{"preview": "なし", "can_calc": "0", "data_code": "is_same", "data_name": "同姓同名判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "本人情報", "field_name": "is_same", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症患者", "can_calc": "0", "data_code": "is_infect", "data_name": "感染症患者判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "非感染症患者", "item": "非感染症患者"}, {"code": "1", "disp": "感染症患者", "item": "感染症患者"}], "data_class": "感染症", "field_name": "is_infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "main_course_name", "data_name": "診療科", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "main_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "main_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "main_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "dialysis_course_name", "data_name": "透析実施科", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "ward_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "ward_in_hospital_cd_1", "data_name": "病棟名連携コード", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "ward_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dialysis_count", "data_name": "自施設通算透析回数", "data_type": "decimal", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_count", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pat_dialysis_count", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "診療情報", "field_name": "pat_dialysis_count", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "purification_count", "data_name": "自施設通算特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "診療情報", "field_name": "purification_count", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11年3ケ月", "can_calc": "0", "data_code": "dialysis_vintage", "data_name": "透析歴", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_vintage", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000/02/10", "can_calc": "0", "data_code": "dialysis_start_date", "data_name": "透析導入日", "data_type": "DateTime", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_start_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装病院", "can_calc": "0", "data_code": "facility_name", "data_name": "透析導入施設", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "糖尿病患者", "can_calc": "0", "data_code": "is_diabetes", "data_name": "糖尿病患者", "data_type": "string", "conv_table": [{"code": "0", "disp": "非糖尿病患者", "item": "非糖尿病患者"}, {"code": "1", "disp": "糖尿病患者", "item": "糖尿病患者"}], "data_class": "既往歴", "field_name": "is_diabetes", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血糖検査", "can_calc": "0", "data_code": "is_blood_suger_exam", "data_name": "血糖検査判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "既往歴", "field_name": "is_blood_suger_exam", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析導入原疾患", "can_calc": "0", "data_code": "dialysis_underlying_disease", "data_name": "透析導入原疾患", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_underlying_disease", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：既往歴 単型 @patId @facilityCd @toDate', '2020-03-24 00:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (20, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_charge_staff_info_asc}', 4, '[{"preview": "123456789", "can_calc": "0", "data_code": "doctor1_cd", "data_name": "主治医1ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師1", "can_calc": "0", "data_code": "doctor1_name", "data_name": "主治医1", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "doctor2_cd", "data_name": "主治医2ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師2", "can_calc": "0", "data_code": "doctor2_name", "data_name": "主治医2", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "staff1_cd", "data_name": "担当1ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師1", "can_calc": "0", "data_code": "staff1_name", "data_name": "担当1", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "staff2_cd", "data_name": "担当2ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師2", "can_calc": "0", "data_code": "staff2_name", "data_name": "担当2", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "puncture1_cd", "data_name": "穿刺1ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺者1", "can_calc": "0", "data_code": "puncture1_name", "data_name": "穿刺1", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "puncture2_cd", "data_name": "穿刺2ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺者2", "can_calc": "0", "data_code": "puncture2_name", "data_name": "穿刺2", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：担当・スタッフ 単型 @patId @facilityCd @toDate', '2020-03-25 10:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (26, '{"collection": "pat_unique_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_medical_hst_info}', 4, '[{"preview": "慢性糸球体腎炎", "can_calc": "0", "data_code": "disease_name", "data_name": "病名", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "dis_in_hospital_cd_1", "data_name": "病名連携コード1", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "dis_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2010", "can_calc": "0", "data_code": "disease_year", "data_name": "発症日(年)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_year", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "disease_month", "data_name": "発症日(月)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_month", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09", "can_calc": "0", "data_code": "disease_day", "data_name": "発症日(日)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_day", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2010", "can_calc": "0", "data_code": "diagnosis_year", "data_name": "診断日(年)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_year", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "diagnosis_month", "data_name": "診断日(月)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_month", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11", "can_calc": "0", "data_code": "diagnosis_day", "data_name": "診断日(日)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_day", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療中", "can_calc": "0", "data_code": "out_come", "data_name": "転帰", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "治療中", "item": "治療中"}, {"code": "2", "disp": "診断のみ", "item": "診断のみ"}, {"code": "3", "disp": "治癒", "item": "治癒"}, {"code": "4", "disp": "軽快", "item": "軽快"}, {"code": "5", "disp": "寛解", "item": "寛解"}, {"code": "6", "disp": "不変", "item": "不変"}, {"code": "7", "disp": "増悪", "item": "増悪"}, {"code": "8", "disp": "中止", "item": "中止"}, {"code": "9", "disp": "転医", "item": "転医"}, {"code": "10", "disp": "死亡", "item": "死亡"}], "data_class": "原疾患", "field_name": "out_come", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/22", "can_calc": "0", "data_code": "out_come_date", "data_name": "転帰変更日", "data_type": "DateTime", "conv_table": [], "data_class": "原疾患", "field_name": "out_come_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "is_notice", "data_name": "告知", "data_type": "string", "conv_table": [{"code": "0", "disp": "未", "item": "未"}, {"code": "1", "disp": "済", "item": "済"}], "data_class": "原疾患", "field_name": "is_notice", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OK", "can_calc": "0", "data_code": "is_confirmation_biopsy", "data_name": "生検確認", "data_type": "string", "conv_table": [{"code": "0", "disp": "NG", "item": "NG"}, {"code": "1", "disp": "OK", "item": "OK"}], "data_class": "原疾患", "field_name": "is_confirmation_biopsy", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "is_diagnosed", "data_name": "確診", "data_type": "string", "conv_table": [{"code": "0", "disp": "未", "item": "未"}, {"code": "1", "disp": "済", "item": "済"}], "data_class": "原疾患", "field_name": "is_diagnosed", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "慢性糸球体腎炎", "can_calc": "0", "data_code": "is_dialysis_underlying_disease", "data_name": "透析導入原疾患", "data_type": "string", "conv_table": [{"code": "0", "disp": "非原疾患", "item": "非原疾患"}, {"code": "1", "disp": "原疾患", "item": "原疾患"}], "data_class": "原疾患", "field_name": "is_dialysis_underlying_disease", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "主病名", "can_calc": "0", "data_code": "is_main_disease", "data_name": "主病名フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "主病名以外", "item": "主病名以外"}, {"code": "1", "disp": "主病名", "item": "主病名"}], "data_class": "原疾患", "field_name": "is_main_disease", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "病院A", "can_calc": "0", "data_code": "diagnosis_facility_name", "data_name": "診断施設", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "診療科A", "can_calc": "0", "data_code": "course_name", "data_name": "診療科", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメント１", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "memo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "data_code": "diagnostician_name", "data_name": "診断医", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnostician_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報履歴：原疾患 単型 @patId @facilityCd @toDate', '2020-03-25 16:53:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (32, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_tare_info}', 4, '[{"preview": "スリッパ", "can_calc": "0", "data_code": "name_1", "data_name": "風袋名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_1", "data_name": "風袋重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_1", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "name_2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_2", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "name_3", "data_name": "風袋名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_3", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "weight_3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_3", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "name_4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_4", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_4", "data_name": "風袋重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_4", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "name_5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_5", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_5", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "weight_sum", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_sum", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：風袋 単型 @patId @facilityCd @toDate', '2020-03-25 20:23:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (33, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_off_water_info}', 4, '[{"preview": "食事量", "can_calc": "0", "data_code": "name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_1", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_2", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_3", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_3", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_4", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_4", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_5", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_5", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "weight_sum", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_sum", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：除水補正 単型 @patId @facilityCd @toDate', '2020-03-25 20:23:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (34, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_wheel_chair_cd&wheel_chair_name&wheel_chair_weight} ', 4, '[{"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "0", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "利用しない", "can_calc": "0", "data_code": "is_wheel_chair", "data_name": "車いす利用", "data_type": "string", "conv_table": [{"code": "0", "disp": "利用しない", "item": "利用しない"}, {"code": "1", "disp": "利用する", "item": "利用する"}], "data_class": "透析困難・重症度・搬送区分", "field_name": "is_wheel_chair", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：車いす 単型 @patId @facilityCd @toDate', '2020-03-25 21:34:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (203, '{"collection": "pat_unique_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_period_start_date}', 4, '[{"preview": "2005/08/18", "can_calc": "0", "data_code": "period_start_date", "data_name": "当院開始日", "data_type": "DateTime", "conv_table": [], "data_class": "診療情報", "field_name": "period_start_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：当院開始日 単型 @patId @facilityCd @toDate', '2023-07-17 21:01:32.107', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (215, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_in_out_current_state}', 4, '[{"preview": "在院", "can_calc": "0", "data_code": "in_out_current_state", "data_name": "在院", "data_type": "string", "conv_table": [{"code": "0", "disp": "在院", "item": "在院"}, {"code": "1", "disp": "導入予定", "item": "導入予定"}, {"code": "2", "disp": "転入予定", "item": "転入予定"}, {"code": "3", "disp": "転出", "item": "転出"}, {"code": "7", "disp": "離脱", "item": "離脱"}, {"code": "8", "disp": "移植", "item": "移植"}, {"code": "9", "disp": "一時転出", "item": "一時転出"}, {"code": "9", "disp": "一時転出", "item": "一時転出"}, {"code": "10", "disp": "不明", "item": "不明"}, {"code": "11", "disp": "死亡", "item": "死亡"}], "data_class": "本人情報", "field_name": "in_out_current_state", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '患者情報：在院 単型 @patId @facilityCd @toDate', '2024-03-07 01:36:29.376', CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" where sql_cd in (29,31,35,37,46,48,53,55,56,58);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (29, 'WITH infection_order AS (
  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_exam_item''
),
result_table as (
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  info->>''result'' as result,
  info->>''unit'' as unit,
  info->>''freememo'' as freememo,
  p.result_exam_date as result_exam_date,
  p.reg_exam_date,
  p.reg_order_class,
  case p.reg_order_class
  when ''0'' then ''9''
  else p.reg_order_class
  end as reg_order_class_sort,
  p.exam_main_cd as exam_main_cd,
  case
		when info->>''upper''::TEXT = ''null'' then ''''
		when info->>''upper''::TEXT is null then ''''
		else info->>''upper''::TEXT end as upper,
  case
		when info->>''lower''::TEXT = ''null'' then ''''
		when info->>''lower''::TEXT is null then ''''
		else info->>''lower''::TEXT end as lower
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
	AND m.facility_cd = @facilityCd
    and m.result_exam_date between date_trunc(''day'', @fromDate ::timestamp) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.result_exam_date desc
  ) as p
  cross join lateral
  json_array_elements (p.exam_result_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del =''0'' and is_disp =''1''
	  left join   infection_order as inf   on info->>''item_cd''::text=inf.infection_cd
ORDER BY
  result_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class),infection_cd_order
)

SELECT rt.*, case when lower = '''' and upper = '''' then '''' else COALESCE(lower, '''') || ''~'' || COALESCE(upper, '''')  end as normal_value FROM result_table AS rt
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0～15.0", "can_calc": "0", "data_code": "normal_value", "data_name": "正常値範囲", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "normal_value", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2,  9, 10]}', '検査結果(指定日) 単型 @patId @facilityCd @date', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (31, 'WITH infection_order AS (
  SELECT
    one_json ->> ''code'' AS infection_cd,
    json_idx AS infection_cd_order
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'')
       WITH ORDINALITY AS tmp(one_json, json_idx)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
),

params AS (
  SELECT 
      date_trunc(''day'',@fromDate::timestamp) AS target_day,
      date_trunc(''day'',@fromDate::timestamp) - interval ''1 year'' AS from_day
),
base_exam_cd AS (
 SELECT m.exam_main_cd ,m.result_exam_date,m.pat_id FROM pat_exam_main m
 JOIN params p
    ON m.result_exam_date <  p.target_day + interval ''1 day''
		and m.result_exam_date >  p.target_day
		WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id = @patId

    AND m.facility_cd = @facilityCd
		ORDER BY m.result_exam_date,m.exam_main_cd LIMIT 1 
),
raw_year AS (
  SELECT
      m.pat_id              AS pat_id,
      k.exam_main_cd        AS exam_main_cd,
      m.result_exam_date    AS result_exam_date,
      m.reg_exam_date       AS reg_exam_date,
      m.reg_order_class     AS m_reg_order_class,

      info_json ->> ''item_cd''   AS item_cd,
      info_json ->> ''item_name'' AS item_name,
      COALESCE(info_json ->> ''reg_order_class'',
               m.reg_order_class::text) AS reg_order_class,
      info_json
  FROM pat_exam_main m
  JOIN params p
    ON m.result_exam_date >= p.from_day
   AND m.result_exam_date <  p.target_day + interval ''1 day''
  CROSS JOIN LATERAL
       json_array_elements(coalesce(m.exam_result_info::json, ''[]''::json)) AS info(info_json)
	left JOIN base_exam_cd k
	   ON	m.pat_id = k.pat_id
  WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id = @patId
    AND m.facility_cd = @facilityCd
),

near_day_date AS (
  SELECT DISTINCT ON (pat_id)
      pat_id,
      result_exam_date AS base_day
  FROM raw_year
  ORDER BY pat_id, result_exam_date DESC
),

raw_day AS (
  SELECT ry.*
  FROM raw_year ry
  LEFT JOIN near_day_date nd
    ON nd.pat_id = ry.pat_id
   AND date_trunc(''day'', ry.result_exam_date)
       = date_trunc(''day'', nd.base_day)
),

base_item AS (
  SELECT DISTINCT ON (pat_id, item_cd)
      pat_id,
      item_cd,
      item_name,
      result_exam_date AS base_result_exam_date,
      reg_exam_date    AS base_reg_exam_date,
      info_json        AS base_info_json,
      exam_main_cd     AS base_exam_main_cd
  FROM raw_day
  ORDER BY
      pat_id,
      item_cd,
      result_exam_date DESC,
      reg_exam_date DESC
),

real_year_nearest AS (
  SELECT DISTINCT ON (pat_id, item_cd, reg_order_class)
      pat_id,
      item_cd,
      item_name,
      reg_order_class,
      result_exam_date AS real_result_exam_date,
      reg_exam_date    AS real_reg_exam_date,
      info_json        AS real_info_json,
      exam_main_cd     AS real_exam_main_cd,
			reg_order_class  AS real_reg_order_class,
			item_name   AS real_item_name
  FROM raw_year ry
  CROSS JOIN params p
  ORDER BY
      pat_id,
      item_cd,
      reg_order_class,
      result_exam_date DESC,
      reg_exam_date DESC
),

class_list AS (
  SELECT ''1'' AS class_cd UNION ALL
  SELECT ''2'' UNION ALL
  SELECT ''0''
),

item_with_class AS (
  SELECT
      b.item_cd,
      b.pat_id,
      b.item_name,
      b.base_result_exam_date,
      b.base_reg_exam_date,
      b.base_exam_main_cd,
      c.class_cd AS reg_order_class,

      r.real_result_exam_date,
      r.real_reg_exam_date,
      r.real_info_json,
      r.real_exam_main_cd,
			r.real_reg_order_class,
			r.real_item_name
  FROM base_item b
  CROSS JOIN class_list c
  LEFT JOIN real_year_nearest r
    ON r.pat_id = b.pat_id
   AND r.item_cd = b.item_cd
   AND r.reg_order_class = c.class_cd
),

item_expanded AS (
  SELECT
      pat_id,
      item_cd,
			item_name,
      real_item_name,

      real_result_exam_date AS result_exam_date,
      real_reg_exam_date    AS reg_exam_date,

      reg_order_class,
			real_reg_order_class,
      COALESCE(real_exam_main_cd, base_exam_main_cd) AS exam_main_cd,
      real_info_json AS info_json
  FROM item_with_class
),

final_join AS (
  SELECT
      e.pat_id,
      e.item_cd,
			e.item_name,
      e.real_item_name,

      itm.in_hospital_cd1,
      itm.in_hospital_cd2,
      itm.in_hospital_cd3,
      itm.sbt_cd1,
      itm.sbt_cd2,
      itm.sbt_cd3,

      e.info_json ->> ''result''   AS result,
      e.info_json ->> ''unit''     AS unit,
      e.info_json ->> ''freememo'' AS freememo,
      e.info_json ->> ''upper''    AS upper,
      e.info_json ->> ''lower''    AS lower,

      e.result_exam_date AS result_exam_output_base_date,
      @fromDate ::date AS reg_exam_date,
      e.reg_exam_date AS real_reg_exam_date,
      e.reg_order_class,
			e.real_reg_order_class,
      e.exam_main_cd,

      inf.infection_cd_order
  FROM item_expanded e
  LEFT JOIN mst_exam_item itm
    ON itm.exam_item_cd::text = e.item_cd
   AND itm.is_del = ''0''
   AND itm.is_disp = ''1''
	 AND e.real_reg_order_class is not null
  LEFT JOIN infection_order inf
    ON e.item_cd = inf.infection_cd
)

SELECT *
FROM final_join
ORDER BY
  pat_id,
  item_cd,
  ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class),
  infection_cd_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "real_item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "real_item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_output_base_date", "data_name": "最終検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result_exam_output_base_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "real_reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日以前)", "field_name": "real_reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査結果(指定日以前) 単型 @patId @facilityCd @date', '2024-05-31 09:38:25.175', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (35, 'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
    and m.pat_id = @patId
	AND m.facility_cd = @facilityCd
    and m.reg_exam_date between date_trunc(''day'', @date ::timestamp) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(セット・指定日) 単型 @patId @facilityCd @date', '2020-03-25 22:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (37, 'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
    and m.pat_id = @patId
	AND m.facility_cd = @facilityCd
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp)
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''') where item.is_del = ''0'' and item.is_disp = ''1''
  limit 100
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・指定日以降)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(セット・指定日以降) 単型 @patId @facilityCd @date', '2020-03-25 22:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (46, 'WITH infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx )
WHERE
	facility_cd = @facilityCd
	AND master_physical_name = ''mst_exam_item''
)
SELECT
	info ->> ''item_cd'' AS item_cd,
	item.in_hospital_cd1 AS in_hospital_cd1,
	item.in_hospital_cd2 AS in_hospital_cd2,
	item.in_hospital_cd3 AS in_hospital_cd3,
	item.sbt_cd1 AS sbt_cd1,
	item.sbt_cd2 AS sbt_cd2,
	item.sbt_cd3 AS sbt_cd3,
	info ->> ''item_name'' AS item_name,
	item.unit AS unit,
	p.reg_exam_date AS reg_exam_date,
	p.reg_order_class,
	p.exam_main_cd as exam_main_cd,
CASE

	WHEN item.normal_value_class = ''0'' THEN
	item.normal_value_upper ELSE
CASE

	WHEN @patSex = 1 THEN
	item.normal_value_upper_m
	WHEN @patSex = 2 THEN
	item.normal_value_upper_w ELSE item.normal_value_upper
END
	END AS upper,
CASE

		WHEN item.normal_value_class = ''0'' THEN
		item.normal_value_lower ELSE
	CASE

			WHEN @patSex = 1 THEN
			item.normal_value_lower_m
			WHEN @patSex = 2 THEN
			item.normal_value_lower_w ELSE item.normal_value_lower
		END
		END AS lower
	FROM
		(
		SELECT
			m.*
		FROM
			pat_exam_main AS m
		WHERE
			m.is_del = ''0''
			AND jsonb_array_length ( m.order_exam_set_info ) > 0
			AND m.pat_id = @patId
			AND m.facility_cd = @facilityCd
			AND m.reg_exam_date BETWEEN date_trunc ( ''day'', @date :: TIMESTAMP )
			AND date_trunc ( ''day'', @date :: TIMESTAMP ) + ''1 days - 1 milliseconds''
		ORDER BY
			m.reg_exam_date,
			( CASE m.reg_order_class WHEN ''0'' THEN ''a'' ELSE m.reg_order_class END )
		) p
		CROSS JOIN lateral json_array_elements ( p.exam_order_info :: json ) info
		LEFT OUTER JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' )
		AND item.is_del = ''0''
		AND item.is_disp = ''1''
		LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd
ORDER BY
infection_cd_order;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "reg_exam_date", "disp_format": "yyyy/MM/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(単項目・指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(単項目・指定日) 単型 @patId @facilityCd @date @patSex', '2020-03-26 20:00:00', CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "pat_sex", "replace_var": "@patSex"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (48, 'WITH infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx )
WHERE
	facility_cd = @facilityCd
	AND master_physical_name = ''mst_exam_item''
	)
	select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  item.unit as unit,
  p.reg_exam_date as reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_upper
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_upper_m
    WHEN @patSex = 2 THEN
      item.normal_value_upper_w
    ELSE
      item.normal_value_upper
    END
  END as upper,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_lower
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_lower_m
    WHEN @patSex = 2 THEN
      item.normal_value_lower_w
    ELSE
      item.normal_value_lower
    END
  END as lower
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
	  AND m.facility_cd = @facilityCd
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp)
    order by m.reg_exam_date, (case m.reg_order_class when ''0'' then ''a''else m.reg_order_class end)
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del =''0''  and item.is_disp =''1''
	LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd
	ORDER BY
infection_cd_order
	limit 100
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(単項目・指定日以降)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(単項目・指定日以降) 単型 @patId @facilityCd @date @patSex', '2020-03-26 20:00:00', CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "pat_sex", "replace_var": "@patSex"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (53, 'select
  spitz.spitz_name,
	p.exam_main_cd,
  p.reg_exam_date
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
     and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'',  @date ::timestamp ) and date_trunc(''day'',  @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	group by
  spitz.spitz_name,
	p.exam_main_cd,
  p.reg_exam_date
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(採血管・指定日) 単型 @patId @date', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (55, 'select
  spitz.spitz_name,
	p.exam_main_cd,
  p.reg_exam_date
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_exam_date
    limit 100
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
group by
  spitz.spitz_name,
	p.exam_main_cd,
  p.reg_exam_date
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日以降)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(採血管・指定日以降) 単型 @patId @date', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (56, 'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
;', 2, '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "reg_rad_date", "disp_format": "HH:mm", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "rad_set_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '放射線検査予定(指定日) 単型 @patId @date', '2020-03-26 22:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (58, 'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
  limit 100
;', 2, '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "hh:mm", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '放射線検査予定(指定日以降) 単型 @patId @date', '2020-03-26 22:30:00', CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" where sql_cd in (301,302,303,304,305,306,307,308,309,310,311,312);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (301, '{"collection": "pat_personal_main_history", "in":{"pat_id": "@patIds"}, "eq": { "facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_pat_contact_info}', 4, '[{"preview": "123456789012", "can_calc": "0", "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ニッキソウ　タロウ", "can_calc": "0", "data_code": "pat_name_kana", "data_name": "フリガナ", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_name_kana", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "nikkiso　tarou", "can_calc": "0", "data_code": "pat_name_alpha", "data_name": "英語表記", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_name_alpha", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1945/01/01", "can_calc": "0", "data_code": "pat_birthday", "data_name": "生年月日", "data_type": "DateTime", "conv_table": [], "data_class": "本人情報", "field_name": "pat_birthday", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "pat_age", "data_name": "年齢", "data_type": "decimal", "conv_table": [], "data_class": "本人情報", "field_name": "pat_age", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "男性", "can_calc": "0", "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "男性", "item": "男性"}, {"code": "2", "disp": "女性", "item": "女性"}], "data_class": "本人情報", "field_name": "pat_sex", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "本人情報", "field_name": "in_out_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "AB", "can_calc": "0", "data_code": "pat_blood_type_abo", "data_name": "血液型ABO型", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "A型", "item": "A型"}, {"code": "2", "disp": "B型", "item": "B型"}, {"code": "3", "disp": "O型", "item": "O型"}, {"code": "4", "disp": "AB型", "item": "AB型"}], "data_class": "本人情報", "field_name": "pat_blood_type_abo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Rh+", "can_calc": "0", "data_code": "pat_blood_type_rh", "data_name": "血液型Rh型", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "Rh+", "item": "Rh+"}, {"code": "2", "disp": "Rh-", "item": "Rh-"}], "data_class": "本人情報", "field_name": "pat_blood_type_rh", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A型 Rh-", "can_calc": "0", "data_code": "pat_blood_type_abo_rh", "data_name": "血液型ABORH", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "10", "disp": "A型 RH不明", "item": "A型 RH不明"}, {"code": "20", "disp": "B型 RH不明", "item": "B型 RH不明"}, {"code": "30", "disp": "O型 RH不明", "item": "O型 RH不明"}, {"code": "40", "disp": "AB型 RH不明", "item": "AB型 RH不明"}, {"code": "1", "disp": "不明 Rh+", "item": "不明 Rh+"}, {"code": "11", "disp": "A型 Rh+", "item": "A型 Rh+"}, {"code": "21", "disp": "B型 Rh+", "item": "B型 Rh+"}, {"code": "31", "disp": "O型 Rh+", "item": "O型 Rh+"}, {"code": "41", "disp": "AB型 Rh+", "item": "AB型 Rh+"}, {"code": "2", "disp": "不明 Rh-", "item": "不明 Rh-"}, {"code": "12", "disp": "A型 Rh-+", "item": "A型 Rh-"}, {"code": "22", "disp": "B型 Rh-", "item": "B型 Rh-"}, {"code": "32", "disp": "O型 Rh-", "item": "O型 Rh-"}, {"code": "42", "disp": "AB型 Rh-", "item": "AB型 Rh-"}], "data_class": "本人情報", "field_name": "pat_blood_type_abo_rh", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A1", "can_calc": "0", "data_code": "pat_blood_type_serovar", "data_name": "血液型亜型", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "11", "disp": "A1", "item": "A1"}, {"code": "12", "disp": "Aint型", "item": "AAint"}, {"code": "13", "disp": "A2", "item": "A2"}, {"code": "14", "disp": "A3", "item": "A3"}, {"code": "15", "disp": "Ax", "item": "Ax"}, {"code": "16", "disp": "Am", "item": "Am"}, {"code": "17", "disp": "Ael", "item": "Ael"}, {"code": "18", "disp": "Aend", "item": "Aend"}, {"code": "21", "disp": "B1", "item": "B1"}, {"code": "22", "disp": "Bint", "item": "Bint"}, {"code": "23", "disp": "B2", "item": "B2"}, {"code": "24", "disp": "B3", "item": "B3"}, {"code": "25", "disp": "Bx", "item": "Bx"}, {"code": "26", "disp": "Bm", "item": "Bm"}, {"code": "27", "disp": "Bel", "item": "Bel"}, {"code": "28", "disp": "Bend", "item": "Bend"}, {"code": "31", "disp": "Oh", "item": "Oh"}, {"code": "32", "disp": "Ah", "item": "Ah"}, {"code": "33", "disp": "Bh", "item": "Bh"}, {"code": "34", "disp": "Om", "item": "Om"}, {"code": "35", "disp": "Am", "item": "Am"}, {"code": "36", "disp": "Bm", "item": "Bm"}, {"code": "400", "disp": "不明 不明", "item": "不明 不明"}, {"code": "401", "disp": "不明 B1", "item": "不明 B1"}, {"code": "402", "disp": "不明 Bint", "item": "不明 Bint"}, {"code": "403", "disp": "不明 B2", "item": "不明 B2"}, {"code": "404", "disp": "不明 B3", "item": "不明 B3"}, {"code": "405", "disp": "不明 Bx", "item": "不明 Bx"}, {"code": "406", "disp": "不明 Bm", "item": "不明 Bm"}, {"code": "407", "disp": "不明 Bel", "item": "不明 Bel"}, {"code": "408", "disp": "不明 Bend", "item": "不明 Bend"}, {"code": "410", "disp": "A1 不明", "item": "A1 不明"}, {"code": "411", "disp": "A1 B1", "item": "A1 B1"}, {"code": "412", "disp": "A1 Bint", "item": "A1 Bint"}, {"code": "413", "disp": "A1 B2", "item": "A1 B2"}, {"code": "414", "disp": "A1 B3", "item": "A1 B3"}, {"code": "415", "disp": "A1 Bx", "item": "A1 Bx"}, {"code": "416", "disp": "A1 Bm", "item": "A1 Bm"}, {"code": "417", "disp": "A1 Bel", "item": "A1 Bel"}, {"code": "418", "disp": "A1 Bend", "item": "A1 Bend"}, {"code": "420", "disp": "Aint 不明", "item": "Aint 不明"}, {"code": "421", "disp": "Aint B1", "item": "Aint B1"}, {"code": "422", "disp": "Aint Bint", "item": "Aint Bint"}, {"code": "423", "disp": "Aint B2", "item": "Aint B2"}, {"code": "424", "disp": "Aint B3", "item": "Aint B3"}, {"code": "425", "disp": "Aint Bx", "item": "Aint Bx"}, {"code": "426", "disp": "Aint Bm", "item": "Aint Bm"}, {"code": "427", "disp": "Aint Bel", "item": "Aint Bel"}, {"code": "428", "disp": "Aint Bend", "item": "Aint Bend"}, {"code": "430", "disp": "A2 不明", "item": "A2 不明"}, {"code": "431", "disp": "A2 B1", "item": "A2 B1"}, {"code": "432", "disp": "A2 Bint", "item": "A2 Bint"}, {"code": "433", "disp": "A2 B2", "item": "A2 B2"}, {"code": "434", "disp": "A2 B3", "item": "A2 B3"}, {"code": "435", "disp": "A2 Bx", "item": "A2 Bx"}, {"code": "436", "disp": "A2 Bm", "item": "A2 Bm"}, {"code": "437", "disp": "A2 Bel", "item": "A2 Bel"}, {"code": "438", "disp": "A2 Bend", "item": "A2 Bend"}, {"code": "440", "disp": "A3 不明", "item": "A3 不明"}, {"code": "441", "disp": "A3 B1", "item": "A3 B1"}, {"code": "442", "disp": "A3 Bint", "item": "A3 Bint"}, {"code": "443", "disp": "A3 B2", "item": "A3 B2"}, {"code": "444", "disp": "A3 B3", "item": "A3 B3"}, {"code": "445", "disp": "A3 Bx", "item": "A3 Bx"}, {"code": "446", "disp": "A3 Bm", "item": "A3 Bm"}, {"code": "447", "disp": "A3 Bel", "item": "A3 Bel"}, {"code": "448", "disp": "A3 Bend", "item": "A3 Bend"}, {"code": "450", "disp": "Ax 不明", "item": "Ax 不明"}, {"code": "451", "disp": "Ax B1", "item": "Ax B1"}, {"code": "452", "disp": "Ax Bint", "item": "Ax Bint"}, {"code": "453", "disp": "Ax B2", "item": "Ax B2"}, {"code": "454", "disp": "Ax B3", "item": "Ax B3"}, {"code": "455", "disp": "Ax Bx", "item": "Ax Bx"}, {"code": "456", "disp": "Ax Bm", "item": "Ax Bm"}, {"code": "457", "disp": "Ax Bel", "item": "Ax Bel"}, {"code": "458", "disp": "Ax Bend", "item": "Ax Bend"}, {"code": "460", "disp": "Am 不明", "item": "Am 不明"}, {"code": "461", "disp": "Am B1", "item": "Am B1"}, {"code": "462", "disp": "Am Bint", "item": "Am Bint"}, {"code": "463", "disp": "Am B2", "item": "Am B2"}, {"code": "464", "disp": "Am B3", "item": "Am B3"}, {"code": "465", "disp": "Am Bx", "item": "Am Bx"}, {"code": "466", "disp": "Am Bm", "item": "Am Bm"}, {"code": "467", "disp": "Am Bel", "item": "Am Bel"}, {"code": "468", "disp": "Am Bend", "item": "Am Bend"}, {"code": "470", "disp": "Ael 不明", "item": "Ael 不明"}, {"code": "471", "disp": "Ael B1", "item": "Ael B1"}, {"code": "472", "disp": "Ael Bint", "item": "Ael Bint"}, {"code": "473", "disp": "Ael B2", "item": "Ael B2"}, {"code": "474", "disp": "Ael B3", "item": "Ael B3"}, {"code": "475", "disp": "Ael Bx", "item": "Ael Bx"}, {"code": "476", "disp": "Ael Bm", "item": "Ael Bm"}, {"code": "477", "disp": "Ael Bel", "item": "Ael Bel"}, {"code": "478", "disp": "Ael Bend", "item": "Ael Bend"}, {"code": "480", "disp": "Aend 不明", "item": "Aend 不明"}, {"code": "481", "disp": "Aend B1", "item": "Aend B1"}, {"code": "482", "disp": "Aend Bint", "item": "Aend Bint"}, {"code": "483", "disp": "Aend B2", "item": "Aend B2"}, {"code": "484", "disp": "Aend B3", "item": "Aend B3"}, {"code": "485", "disp": "Aend Bx", "item": "Aend Bx"}, {"code": "486", "disp": "Aend Bm", "item": "Aend Bm"}, {"code": "487", "disp": "Aend Bel", "item": "Aend Bel"}, {"code": "488", "disp": "Aend Bend", "item": "Aend Bend"}], "data_class": "本人情報", "field_name": "pat_blood_type_serovar", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日本", "can_calc": "0", "conv_sql": {"sql_cd": 139, "field_name": "country_name", "target_var": "@countryCdAlpha3"}, "data_code": "nationality", "data_name": "国籍", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "nationality", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150-8677", "can_calc": "0", "data_code": "pat_zip", "data_name": "郵便番号", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_zip", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "東京都渋谷区恵比寿3-43-2 日機装第１別館１F", "can_calc": "0", "data_code": "pat_address", "data_name": "住所", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_address", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-1234-5678", "can_calc": "0", "data_code": "pat_tel1", "data_name": "電話番号1", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_tel1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "090-1234-5678", "can_calc": "0", "data_code": "pat_tel2", "data_name": "電話番号2", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_tel2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-8765-4321", "can_calc": "0", "data_code": "pat_fax", "data_name": "FAX", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_fax", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxx@xxxx.xx.xx", "can_calc": "0", "data_code": "pat_e_mail", "data_name": "Email", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_e_mail", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "pat_work_name", "data_name": "勤務先名", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_work_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-5678-1234", "can_calc": "0", "data_code": "pat_work_tel", "data_name": "勤務先電話番号", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_work_tel", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ1です。", "can_calc": "0", "data_code": "pat_memo1", "data_name": "メモ1", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_memo1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ2です。", "can_calc": "0", "data_code": "pat_memo2", "data_name": "メモ2", "data_type": "string", "conv_table": [], "data_class": "本人情報", "field_name": "pat_memo2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期（部分介助）", "can_calc": "0", "data_code": "severity_name", "data_name": "重症度", "data_type": "string", "conv_table": [], "data_class": "透析困難・重症度・搬送区分", "field_name": "severity_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "data_code": "transport_name", "data_name": "搬送区分", "data_type": "string", "conv_table": [], "data_class": "透析困難・重症度・搬送区分", "field_name": "transport_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "急性ウィルス肝炎", "can_calc": "0", "data_code": "die_name", "data_name": "死因", "data_type": "string", "conv_table": [], "data_class": "死亡情報", "field_name": "die_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "死亡", "can_calc": "0", "data_code": "is_die", "data_name": "死亡判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "存命", "item": "存命"}, {"code": "1", "disp": "死亡", "item": "死亡"}], "data_class": "死亡情報", "field_name": "is_die", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "die_date", "data_name": "死亡日", "data_type": "DateTime", "conv_table": [], "data_class": "死亡情報", "field_name": "die_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "die_in_hospital_cd_1", "data_name": "死因連携コード", "data_type": "string", "conv_table": [], "data_class": "死亡情報", "field_name": "die_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：pat_personal_main分 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (302, '{"collection": "pat_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_pat_memo_info}; ', 4, '[{"preview": "", "can_calc": "0", "data_code": "memo01_title", "data_name": "タイトル1", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo01_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo01_content", "data_name": "内容1", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo01_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo02_title", "data_name": "タイトル2", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo02_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo02_content", "data_name": "内容2", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo02_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo03_title", "data_name": "タイトル3", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo03_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo03_content", "data_name": "内容3", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo03_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo04_title", "data_name": "タイトル4", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo04_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo04_content", "data_name": "内容4", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo04_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo05_title", "data_name": "タイトル5", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo05_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo05_content", "data_name": "内容5", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo05_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo06_title", "data_name": "タイトル6", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo06_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo06_content", "data_name": "内容6", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo06_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo07_title", "data_name": "タイトル7", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo07_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo07_content", "data_name": "内容7", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo07_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo08_title", "data_name": "タイトル8", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo08_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo08_content", "data_name": "内容8", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo08_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo09_title", "data_name": "タイトル9", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo09_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo09_content", "data_name": "内容9", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo09_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo10_title", "data_name": "タイトル10", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo10_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo10_content", "data_name": "内容10", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo10_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo11_title", "data_name": "タイトル11", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo11_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo11_content", "data_name": "内容11", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo11_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo12_title", "data_name": "タイトル12", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo12_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo12_content", "data_name": "内容12", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo12_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo13_title", "data_name": "タイトル13", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo13_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo13_content", "data_name": "内容13", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo13_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo14_title", "data_name": "タイトル14", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo14_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo14_content", "data_name": "内容14", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo14_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo15_title", "data_name": "タイトル15", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo15_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo15_content", "data_name": "内容15", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo15_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo16_title", "data_name": "タイトル16", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo16_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo16_content", "data_name": "内容16", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo16_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo17_title", "data_name": "タイトル17", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo17_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo17_content", "data_name": "内容17", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo17_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo18_title", "data_name": "タイトル18", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo18_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo18_content", "data_name": "内容18", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo18_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo19_title", "data_name": "タイトル19", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo19_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo19_content", "data_name": "内容19", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo19_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo20_title", "data_name": "タイトル20", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo20_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "memo20_content", "data_name": "内容20", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "memo20_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：患者フリーコメント 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (303, '{"collection": "pat_insurance_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_selected": "1"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_insu_set_info&insu_info&insu_pub_info}', 4, '[{"preview": "主保険", "can_calc": "0", "data_code": "is_selected", "data_name": "主保険フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "主保険ではない", "item": "主保険ではない"}, {"code": "1", "disp": "主保険", "item": "主保険"}], "data_class": "保険情報", "field_name": "is_selected", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "公費", "can_calc": "0", "data_code": "insu_class", "data_name": "保険区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "保険", "item": "保険"}, {"code": "1", "disp": "公費", "item": "公費"}, {"code": "2", "disp": "セット", "item": "セット"}, {"code": "3", "disp": "自費", "item": "自費"}], "data_class": "保険情報", "field_name": "insu_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_name", "data_name": "保険名", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_name_short", "data_name": "略称", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_name_short", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "被扶養者", "can_calc": "0", "data_code": "insu_kbn", "data_name": "扶養区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "被保険者", "item": "被保険者"}, {"code": "1", "disp": "被扶養者", "item": "被扶養者"}], "data_class": "保険情報", "field_name": "insu_kbn", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12345678", "can_calc": "0", "data_code": "insu_no", "data_name": "保険者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "data_code": "insu_pat_name", "data_name": "保険者名称", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "insu_pat_mark", "data_name": "被保険者記号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_mark", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "insu_pat_no", "data_name": "被保険者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/2/15", "can_calc": "0", "data_code": "insu_start_date", "data_name": "開始日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_start_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/2/15", "can_calc": "0", "data_code": "insu_end_date", "data_name": "終了日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_end_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/2/16", "can_calc": "0", "data_code": "insu_check_date", "data_name": "確認日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_check_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "対象外", "can_calc": "0", "data_code": "cki_class", "data_name": "長期高額療養", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "対象者", "item": "対象者"}, {"code": "2", "disp": "１０００円対象者", "item": "１０００円対象者"}, {"code": "3", "disp": "２０００円対象者", "item": "２０００円対象者"}], "data_class": "保険情報", "field_name": "cki_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "一般", "can_calc": "0", "data_code": "kki_class", "data_name": "高額受給者又は後期高齢者医療", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "一般", "item": "一般"}, {"code": "2", "disp": "７割給付", "item": "７割給付"}], "data_class": "保険情報", "field_name": "kki_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "６歳未満", "can_calc": "0", "data_code": "und_six", "data_name": "6歳未満", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "６歳未満", "item": "６歳未満"}], "data_class": "保険情報", "field_name": "und_six", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "data_code": "futan_g", "data_name": "負担率外来", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "futan_g", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "futan_n", "data_name": "負担率入院", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "futan_n", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ１", "can_calc": "0", "data_code": "memo1", "data_name": "保険メモ1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "memo1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ２", "can_calc": "0", "data_code": "memo2", "data_name": "保険メモ2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "memo2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_name", "data_name": "公費負担者名1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_name", "data_name": "公費負担者名2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_name", "data_name": "公費負担者名3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_name", "data_name": "公費負担者名4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub1_no", "data_name": "公費負担者番号1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub2_no", "data_name": "公費負担者番号2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub3_no", "data_name": "公費負担者番号3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub4_no", "data_name": "公費負担者番号4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub1_pat_no", "data_name": "公費受給者番号1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub2_pat_no", "data_name": "公費受給者番号2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub3_pat_no", "data_name": "公費受給者番号3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub4_pat_no", "data_name": "公費受給者番号4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_passbook_no", "data_name": "障害者手帳番号1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_passbook_no", "data_name": "障害者手帳番号2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_passbook_no", "data_name": "障害者手帳番号3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_passbook_no", "data_name": "障害者手帳番号4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_passbook_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_info_name", "data_name": "保険", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub1_info_name", "data_name": "公費1", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub1_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub2_info_name", "data_name": "公費2", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub2_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub3_info_name", "data_name": "公費3", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub3_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "0", "data_code": "insu_pub4_info_name", "data_name": "公費4", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub4_info_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：保険情報 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (304, '{"collection": "pat_personal_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_dial_diff_com_info}', 4, '[{"preview": "あり", "can_calc": "0", "data_code": "is_pat_dial_diff", "data_name": "透析困難有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "透析困難・重症度・搬送区分", "field_name": "is_pat_dial_diff", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "高血圧", "can_calc": "0", "data_code": "pat_dial_diff_name", "data_name": "透析困難理由", "data_type": "string", "conv_table": [], "data_class": "透析困難(主)", "field_name": "pat_dial_diff_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "pat_in_hospital_cd_1", "data_name": "透析困難理由連携コード1", "data_type": "string", "conv_table": [], "data_class": "透析困難(主)", "field_name": "pat_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "pat_in_hospital_cd_2", "data_name": "透析困難理由連携コード2", "data_type": "string", "conv_table": [], "data_class": "透析困難(主)", "field_name": "pat_in_hospital_cd_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2024/01/01 00:00:00", "can_calc": "0", "data_code": "reg_date", "data_name": "透析困難理由登録日時", "data_type": "DateTime", "conv_table": [], "data_class": "透析困難(主)", "field_name": "reg_date", "disp_format": "yyyy/MM/dd hh:mm:ss", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：透析困難(主のみ) 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (305, '{"collection": "pat_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_medical_care_info}', 4, '[{"preview": "なし", "can_calc": "0", "data_code": "is_same", "data_name": "同姓同名判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "本人情報", "field_name": "is_same", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症患者", "can_calc": "0", "data_code": "is_infect", "data_name": "感染症患者判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "非感染症患者", "item": "非感染症患者"}, {"code": "1", "disp": "感染症患者", "item": "感染症患者"}], "data_class": "感染症", "field_name": "is_infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "main_course_name", "data_name": "診療科", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "main_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "main_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "main_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "dialysis_course_name", "data_name": "透析実施科", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "ward_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "ward_in_hospital_cd_1", "data_name": "病棟名連携コード", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "ward_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dialysis_count", "data_name": "自施設通算透析回数", "data_type": "decimal", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_count", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pat_dialysis_count", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "診療情報", "field_name": "pat_dialysis_count", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "purification_count", "data_name": "自施設通算特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "診療情報", "field_name": "purification_count", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11年3ケ月", "can_calc": "0", "data_code": "dialysis_vintage", "data_name": "透析歴", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_vintage", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000/02/10", "can_calc": "0", "data_code": "dialysis_start_date", "data_name": "透析導入日", "data_type": "DateTime", "conv_table": [], "data_class": "診療情報", "field_name": "dialysis_start_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装病院", "can_calc": "0", "data_code": "facility_name", "data_name": "透析導入施設", "data_type": "string", "conv_table": [], "data_class": "診療情報", "field_name": "facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "糖尿病患者", "can_calc": "0", "data_code": "is_diabetes", "data_name": "糖尿病患者", "data_type": "string", "conv_table": [{"code": "0", "disp": "非糖尿病患者", "item": "非糖尿病患者"}, {"code": "1", "disp": "糖尿病患者", "item": "糖尿病患者"}], "data_class": "既往歴", "field_name": "is_diabetes", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血糖検査", "can_calc": "0", "data_code": "is_blood_suger_exam", "data_name": "血糖検査判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "既往歴", "field_name": "is_blood_suger_exam", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析導入原疾患", "can_calc": "0", "data_code": "dialysis_underlying_disease", "data_name": "透析導入原疾患", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_underlying_disease", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：既往歴 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (306, '{"collection": "pat_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_charge_staff_info_asc}', 4, '[{"preview": "123456789", "can_calc": "0", "data_code": "doctor1_cd", "data_name": "主治医1ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師1", "can_calc": "0", "data_code": "doctor1_name", "data_name": "主治医1", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "doctor2_cd", "data_name": "主治医2ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師2", "can_calc": "0", "data_code": "doctor2_name", "data_name": "主治医2", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "doctor2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "staff1_cd", "data_name": "担当1ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師1", "can_calc": "0", "data_code": "staff1_name", "data_name": "担当1", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "staff2_cd", "data_name": "担当2ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師2", "can_calc": "0", "data_code": "staff2_name", "data_name": "担当2", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "staff2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "puncture1_cd", "data_name": "穿刺1ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture1_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺者1", "can_calc": "0", "data_code": "puncture1_name", "data_name": "穿刺1", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture1_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "puncture2_cd", "data_name": "穿刺2ID", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture2_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺者2", "can_calc": "0", "data_code": "puncture2_name", "data_name": "穿刺2", "data_type": "string", "conv_table": [], "data_class": "担当者", "field_name": "puncture2_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：担当・スタッフ 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (307, '{"collection": "pat_unique_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_medical_hst_info}', 4, '[{"preview": "慢性糸球体腎炎", "can_calc": "0", "data_code": "disease_name", "data_name": "病名", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "dis_in_hospital_cd_1", "data_name": "病名連携コード1", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "dis_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2010", "can_calc": "0", "data_code": "disease_year", "data_name": "発症日(年)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_year", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "disease_month", "data_name": "発症日(月)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_month", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09", "can_calc": "0", "data_code": "disease_day", "data_name": "発症日(日)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "disease_day", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2010", "can_calc": "0", "data_code": "diagnosis_year", "data_name": "診断日(年)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_year", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "diagnosis_month", "data_name": "診断日(月)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_month", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11", "can_calc": "0", "data_code": "diagnosis_day", "data_name": "診断日(日)", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_day", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療中", "can_calc": "0", "data_code": "out_come", "data_name": "転帰", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "治療中", "item": "治療中"}, {"code": "2", "disp": "診断のみ", "item": "診断のみ"}, {"code": "3", "disp": "治癒", "item": "治癒"}, {"code": "4", "disp": "軽快", "item": "軽快"}, {"code": "5", "disp": "寛解", "item": "寛解"}, {"code": "6", "disp": "不変", "item": "不変"}, {"code": "7", "disp": "増悪", "item": "増悪"}, {"code": "8", "disp": "中止", "item": "中止"}, {"code": "9", "disp": "転医", "item": "転医"}, {"code": "10", "disp": "死亡", "item": "死亡"}], "data_class": "原疾患", "field_name": "out_come", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/22", "can_calc": "0", "data_code": "out_come_date", "data_name": "転帰変更日", "data_type": "DateTime", "conv_table": [], "data_class": "原疾患", "field_name": "out_come_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "is_notice", "data_name": "告知", "data_type": "string", "conv_table": [{"code": "0", "disp": "未", "item": "未"}, {"code": "1", "disp": "済", "item": "済"}], "data_class": "原疾患", "field_name": "is_notice", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OK", "can_calc": "0", "data_code": "is_confirmation_biopsy", "data_name": "生検確認", "data_type": "string", "conv_table": [{"code": "0", "disp": "NG", "item": "NG"}, {"code": "1", "disp": "OK", "item": "OK"}], "data_class": "原疾患", "field_name": "is_confirmation_biopsy", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "is_diagnosed", "data_name": "確診", "data_type": "string", "conv_table": [{"code": "0", "disp": "未", "item": "未"}, {"code": "1", "disp": "済", "item": "済"}], "data_class": "原疾患", "field_name": "is_diagnosed", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "慢性糸球体腎炎", "can_calc": "0", "data_code": "is_dialysis_underlying_disease", "data_name": "透析導入原疾患", "data_type": "string", "conv_table": [{"code": "0", "disp": "非原疾患", "item": "非原疾患"}, {"code": "1", "disp": "原疾患", "item": "原疾患"}], "data_class": "原疾患", "field_name": "is_dialysis_underlying_disease", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "主病名", "can_calc": "0", "data_code": "is_main_disease", "data_name": "主病名フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "主病名以外", "item": "主病名以外"}, {"code": "1", "disp": "主病名", "item": "主病名"}], "data_class": "原疾患", "field_name": "is_main_disease", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "病院A", "can_calc": "0", "data_code": "diagnosis_facility_name", "data_name": "診断施設", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnosis_facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "診療科A", "can_calc": "0", "data_code": "course_name", "data_name": "診療科", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメント１", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "memo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "data_code": "diagnostician_name", "data_name": "診断医", "data_type": "string", "conv_table": [], "data_class": "原疾患", "field_name": "diagnostician_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報履歴：原疾患 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (308, '{"collection": "pat_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_tare_info}', 4, '[{"preview": "スリッパ", "can_calc": "0", "data_code": "name_1", "data_name": "風袋名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_1", "data_name": "風袋重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_1", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "name_2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_2", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "name_3", "data_name": "風袋名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_3", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "weight_3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_3", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "name_4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_4", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_4", "data_name": "風袋重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_4", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "name_5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_5", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_5", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "weight_sum", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_sum", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：風袋 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (309, '{"collection": "pat_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_off_water_info}', 4, '[{"preview": "食事量", "can_calc": "0", "data_code": "name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_1", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_2", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_3", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_3", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_4", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_4", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_5", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_5", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "weight_sum", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_sum", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：除水補正 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (310, '{"collection": "pat_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_wheel_chair_cd&wheel_chair_name&wheel_chair_weight} ', 4, '[{"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "0", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "利用しない", "can_calc": "0", "data_code": "is_wheel_chair", "data_name": "車いす利用", "data_type": "string", "conv_table": [{"code": "0", "disp": "利用しない", "item": "利用しない"}, {"code": "1", "disp": "利用する", "item": "利用する"}], "data_class": "透析困難・重症度・搬送区分", "field_name": "is_wheel_chair", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：車いす 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (311, '{"collection": "pat_unique_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_period_start_date}', 4, '[{"preview": "2005/08/18", "can_calc": "0", "data_code": "period_start_date", "data_name": "当院開始日", "data_type": "DateTime", "conv_table": [], "data_class": "診療情報", "field_name": "period_start_date", "disp_format": "yyyy/MM/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：当院開始日 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (312, '{"collection": "pat_main_history", "in":{"pat_id": "@patIds"}, "eq": {"facility_cd": "@facilityCd", "is_del": "0"}, "lt": {"up_date": "@toDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_in_out_current_state}', 4, '[{"preview": "在院", "can_calc": "0", "data_code": "in_out_current_state", "data_name": "在院", "data_type": "string", "conv_table": [{"code": "0", "disp": "在院", "item": "在院"}, {"code": "1", "disp": "導入予定", "item": "導入予定"}, {"code": "2", "disp": "転入予定", "item": "転入予定"}, {"code": "3", "disp": "転出", "item": "転出"}, {"code": "7", "disp": "離脱", "item": "離脱"}, {"code": "8", "disp": "移植", "item": "移植"}, {"code": "9", "disp": "一時転出", "item": "一時転出"}, {"code": "9", "disp": "一時転出", "item": "一時転出"}, {"code": "10", "disp": "不明", "item": "不明"}, {"code": "11", "disp": "死亡", "item": "死亡"}], "data_class": "本人情報", "field_name": "in_out_current_state", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '患者情報：在院 複数型 @patIds @facilityCd @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" where sql_cd in (313,314,315,316,318,319,321,322,323,324);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (313, 'WITH exam_item_order AS (
	SELECT
    one_json ->> ''code'' as exam_item_cd
    , json_idx as exam_item_order
	FROM
    mst_selector
    CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
),
result_table AS (
	select
		p.pat_id,
		p.exam_main_cd as exam_main_cd,
		p.result_exam_date as result_exam_date,
		p.reg_exam_date,
		p.reg_order_class,
		case p.reg_order_class
			when ''0'' then ''9''
			else p.reg_order_class
		end as reg_order_class_sort,
		info->>''item_cd'' as item_cd,
		info->>''item_name'' as item_name,
		info->>''result'' as result,
		info->>''unit'' as unit,
		info->>''freememo'' as freememo,
		case
			when info->>''upper''::TEXT = ''null'' then ''''
			when info->>''upper''::TEXT is null then ''''
			else info->>''upper''::TEXT
		end as upper,
		case
			when info->>''lower''::TEXT = ''null'' then ''''
			when info->>''lower''::TEXT is null then ''''
			else info->>''lower''::TEXT
		end as lower,
		item.in_hospital_cd1 as in_hospital_cd1,
		item.in_hospital_cd2 as in_hospital_cd2,
		item.in_hospital_cd3 as in_hospital_cd3,
		item.sbt_cd1 as sbt_cd1,
		item.sbt_cd2 as sbt_cd2,
		item.sbt_cd3 as sbt_cd3,
		exam_item_order
	from (
		select
			m.*
		from
			pat_exam_main as m
		where
			m.pat_id IN (@patIds)
			AND m.facility_cd = @facilityCd
			AND m.result_exam_date between date_trunc(''day'', @fromDate ::timestamp) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
			AND m.is_del = ''0''
			AND m.exam_status = ''1''
	) as p
	cross join lateral
		json_array_elements (p.exam_result_info :: json) info
	left outer join
		mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del =''0'' and is_disp =''1''
	left join exam_item_order as inf on info->>''item_cd''::text = inf.exam_item_cd
	ORDER BY
		pat_id, result_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class), exam_item_order
)

SELECT rt.*, case when lower = '''' and upper = '''' then '''' else COALESCE(lower, '''') || ''~'' || COALESCE(upper, '''')  end as normal_value FROM result_table AS rt;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0～15.0", "can_calc": "0", "data_code": "normal_value", "data_name": "正常値範囲", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "normal_value", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査結果(指定日) 複数型 @patIds @facilityCd @fromDate @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (314, 'WITH exam_item_order AS (
	SELECT
    one_json ->> ''code'' as exam_item_cd
    , json_idx as exam_item_order
	FROM
    mst_selector
    CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
),

params AS (
  SELECT 
      date_trunc(''day'',@fromDate::timestamp) AS target_day,
      date_trunc(''day'',@fromDate::timestamp) - interval ''1 year'' AS from_day
),
base_exam_cd AS (
  SELECT DISTINCT ON (m.pat_id)
      m.exam_main_cd,
      m.result_exam_date,
      m.pat_id
  FROM pat_exam_main m
  JOIN params p
    ON m.result_exam_date <  p.target_day + interval ''1 day''
   AND m.result_exam_date >  p.target_day
  WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id IN (@patIds)
    AND m.facility_cd = ''NKKSBR''
  ORDER BY
      m.pat_id,
      m.result_exam_date DESC
),
raw_year AS (
  SELECT
      m.pat_id              AS pat_id,
      k.exam_main_cd        AS exam_main_cd,
      m.result_exam_date    AS result_exam_date,
      m.reg_exam_date       AS reg_exam_date,
      m.reg_order_class     AS m_reg_order_class,

      info_json ->> ''item_cd''   AS item_cd,
      info_json ->> ''item_name'' AS item_name,
      COALESCE(info_json ->> ''reg_order_class'',
               m.reg_order_class::text) AS reg_order_class,
      info_json
  FROM pat_exam_main m
  JOIN params p
    ON m.result_exam_date >= p.from_day
   AND m.result_exam_date <  p.target_day + interval ''1 day''
  CROSS JOIN LATERAL
       json_array_elements(coalesce(m.exam_result_info::json, ''[]''::json)) AS info(info_json)
	left JOIN base_exam_cd k
	   ON	m.pat_id = k.pat_id
  WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id IN (@patIds)
    AND m.facility_cd = @facilityCd
),

near_day_date AS (
  SELECT DISTINCT ON (pat_id)
      pat_id,
      result_exam_date AS base_day
  FROM raw_year
  ORDER BY pat_id, result_exam_date DESC
),

raw_day AS (
  SELECT ry.*
  FROM raw_year ry
  LEFT JOIN near_day_date nd
    ON nd.pat_id = ry.pat_id
   AND date_trunc(''day'', ry.result_exam_date)
       = date_trunc(''day'', nd.base_day)
),

base_item AS (
  SELECT DISTINCT ON (pat_id, item_cd)
      pat_id,
      item_cd,
      item_name,
      result_exam_date AS base_result_exam_date,
      reg_exam_date    AS base_reg_exam_date,
      info_json        AS base_info_json,
      exam_main_cd     AS base_exam_main_cd
  FROM raw_day
  ORDER BY
      pat_id,
      item_cd,
      result_exam_date DESC,
      reg_exam_date DESC
),

real_year_nearest AS (
  SELECT DISTINCT ON (pat_id, item_cd, reg_order_class)
      pat_id,
      item_cd,
      item_name,
      reg_order_class,
      result_exam_date AS real_result_exam_date,
      reg_exam_date    AS real_reg_exam_date,
      info_json        AS real_info_json,
      exam_main_cd     AS real_exam_main_cd,
			reg_order_class  AS real_reg_order_class,
			item_name   AS real_item_name
  FROM raw_year ry
  CROSS JOIN params p
  ORDER BY
      pat_id,
      item_cd,
      reg_order_class,
      result_exam_date DESC,
      reg_exam_date DESC
),

class_list AS (
  SELECT ''1'' AS class_cd UNION ALL
  SELECT ''2'' UNION ALL
  SELECT ''0''
),

item_with_class AS (
  SELECT
      b.item_cd,
      b.pat_id,
      b.item_name,
      b.base_result_exam_date,
      b.base_reg_exam_date,
      b.base_exam_main_cd,
      c.class_cd AS reg_order_class,

      r.real_result_exam_date,
      r.real_reg_exam_date,
      r.real_info_json,
      r.real_exam_main_cd,
			r.real_reg_order_class,
			r.real_item_name
  FROM base_item b
  CROSS JOIN class_list c
  LEFT JOIN real_year_nearest r
    ON r.pat_id = b.pat_id
   AND r.item_cd = b.item_cd
   AND r.reg_order_class = c.class_cd
),

item_expanded AS (
  SELECT
      pat_id,
      item_cd,
			item_name,
      real_item_name,

      real_result_exam_date AS result_exam_date,
      real_reg_exam_date    AS reg_exam_date,

      reg_order_class,
			real_reg_order_class,
      COALESCE(real_exam_main_cd, base_exam_main_cd) AS exam_main_cd,
      real_info_json AS info_json
  FROM item_with_class
),

final_join AS (
  SELECT
      e.pat_id,
      e.exam_main_cd,
      e.result_exam_date AS result_exam_output_base_date,
      @fromDate ::date AS reg_exam_date,
      e.reg_exam_date AS real_reg_exam_date,
      e.reg_order_class,
      e.real_reg_order_class,
      e.item_cd,
      e.item_name,
      e.real_item_name,
      e.info_json ->> ''result''   AS result,
      e.info_json ->> ''unit''     AS unit,
      e.info_json ->> ''freememo'' AS freememo,
      e.info_json ->> ''upper''    AS upper,
      e.info_json ->> ''lower''    AS lower,
      itm.in_hospital_cd1,
      itm.in_hospital_cd2,
      itm.in_hospital_cd3,
      itm.sbt_cd1,
      itm.sbt_cd2,
      itm.sbt_cd3,
      inf.exam_item_order
  FROM item_expanded e
  LEFT JOIN mst_exam_item itm
    ON itm.exam_item_cd::text = e.item_cd
   AND itm.is_del = ''0''
   AND itm.is_disp = ''1''
	 AND e.real_reg_order_class is not null
  LEFT JOIN exam_item_order inf
    ON e.item_cd = inf.exam_item_cd
)

SELECT *
FROM final_join
ORDER BY
  pat_id,
  item_cd,
  ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class),
  exam_item_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "real_item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "real_item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_output_base_date", "data_name": "最終検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result_exam_output_base_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "real_reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日以前)", "field_name": "real_reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査結果(指定日以前) 複数型 @patIds @facilityCd @fromDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (315, 'with exam_set_order AS (
  select
    one_json ->> ''code'' as exam_set_cd
    , json_idx as exam_set_order 
  from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_exam_set''
)
select
	p.pat_id,
	p.exam_main_cd as exam_main_cd,
  p.reg_exam_date,
  p.reg_order_class,
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
	item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  exam_set_order
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.pat_id IN (@patIds)
		AND m.facility_cd = @facilityCd
    AND m.reg_exam_date between date_trunc(''day'', @date ::timestamp) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
		AND m.is_del = ''0''
    AND jsonb_array_length(m.order_exam_set_info) > 0
) p
cross join lateral
	json_array_elements (p.order_exam_set_info :: json) info
left outer join
	mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
left join exam_set_order as inf on info->>''set_cd''::text = inf.exam_set_cd
ORDER BY
	pat_id, reg_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class), exam_set_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(セット・指定日) 複数型 @patIds @facilityCd @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (316, 'with exam_set_order AS (
  select
    one_json ->> ''code'' as exam_set_cd
    , json_idx as exam_set_order 
  from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_exam_set''
)
select
	p.pat_id,
	p.exam_main_cd as exam_main_cd,
  p.reg_exam_date,
  p.reg_order_class,
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  exam_set_order
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.pat_id IN (@patIds)
		AND m.facility_cd = @facilityCd
    AND m.reg_exam_date >= date_trunc(''day'', @date ::timestamp)
		AND m.is_del = ''0''
    AND jsonb_array_length(m.order_exam_set_info) > 0
) p
cross join lateral
	json_array_elements (p.order_exam_set_info :: json) info
left outer join
	mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
left join exam_set_order as inf on info->>''set_cd''::text = inf.exam_set_cd
ORDER BY
	pat_id, reg_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class), exam_set_order
limit 100;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・指定日以降)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・指定日以降)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(セット・指定日以降) 複数型 @patIds @facilityCd @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (318, 'WITH exam_item_order AS (
	SELECT
    one_json ->> ''code'' as exam_item_cd
    , json_idx as exam_item_order
	FROM
    mst_selector
    CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
)
, normal_value_set AS (
	SELECT value FROM mst_facility_setting WHERE facility_cd = @facilityCd AND facility_setting_no = ''1017''
)
, result_table AS (
	SELECT
		p.pat_id as pat_id,
		p.exam_main_cd as exam_main_cd,
		p.reg_exam_date AS reg_exam_date,
		p.reg_order_class,
		info ->> ''item_cd'' AS item_cd,
		info ->> ''item_name'' AS item_name
	FROM (
		SELECT
			m.*
		FROM
			pat_exam_main AS m
		WHERE
			m.pat_id IN (@patIds)
			AND m.facility_cd = @facilityCd
			AND m.reg_exam_date BETWEEN date_trunc ( ''day'', @date :: TIMESTAMP ) AND date_trunc ( ''day'', @date :: TIMESTAMP ) + ''1 days - 1 milliseconds''
			AND m.is_del = ''0''
			AND jsonb_array_length ( m.order_exam_set_info ) > 0
	) p
	CROSS JOIN lateral json_array_elements ( p.exam_order_info :: json ) info
)
SELECT
	rt.pat_id,
	rt.exam_main_cd,
	rt.reg_exam_date,
	rt.reg_order_class,
	CASE 
		WHEN rt.item_cd IS NOT NULL AND rt.item_cd != '''' THEN CAST(rt.item_cd AS NUMERIC)
		ELSE mei.exam_item_cd
	END AS item_cd,
	CASE 
		WHEN rt.item_name IS NOT NULL AND rt.item_name != '''' THEN rt.item_name
		ELSE mei.exam_item_name
	END AS item_name,
	mei.unit,
	CASE
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''1'' THEN normal_value_upper_m
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''2'' THEN normal_value_upper_w
		ELSE normal_value_upper
	END AS upper,
	CASE
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''1'' THEN normal_value_lower_m
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''2'' THEN normal_value_lower_w
		ELSE normal_value_lower
	END AS lower,
	mei.in_hospital_cd1,
	mei.in_hospital_cd2,
	mei.in_hospital_cd3,
	mei.sbt_cd1,
	mei.sbt_cd2,
	mei.sbt_cd3
FROM
	result_table AS rt
LEFT JOIN mst_exam_item as mei ON mei.exam_item_cd = CAST(rt.item_cd AS NUMERIC)
LEFT JOIN exam_item_order ON CAST(exam_item_order.exam_item_cd AS NUMERIC) = mei.exam_item_cd
WHERE
	mei.is_disp = ''1''
	AND mei.is_del = ''0''
	AND mei.facility_Cd = @facilityCd
ORDER BY rt.pat_id, rt.reg_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], rt.reg_order_class), exam_item_order.exam_item_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "reg_exam_date", "disp_format": "yyyy/MM/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(単項目・指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(単項目・指定日) 複数型 @patIds @facilityCd @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (319, 'WITH exam_item_order AS (
	SELECT
    one_json ->> ''code'' as exam_item_cd
    , json_idx as exam_item_order
	FROM
    mst_selector
    CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
)
, normal_value_set AS (
	SELECT value FROM mst_facility_setting WHERE facility_cd = @facilityCd AND facility_setting_no = ''1017''
)
, result_table AS (
	SELECT
		p.pat_id as pat_id,
		p.exam_main_cd as exam_main_cd,
		p.reg_exam_date AS reg_exam_date,
		p.reg_order_class,
		info ->> ''item_cd'' AS item_cd,
		info ->> ''item_name'' AS item_name
	FROM (
		SELECT
			m.*
		FROM
			pat_exam_main AS m
		WHERE
			m.pat_id IN (@patIds)
			AND m.facility_cd = @facilityCd
			AND m.reg_exam_date  >= date_trunc(''day'', @date ::timestamp)
			AND m.is_del = ''0''
			AND jsonb_array_length ( m.order_exam_set_info ) > 0
		ORDER BY m.reg_exam_date, (case m.reg_order_class when ''0'' then ''a''else m.reg_order_class end)
	) p
	CROSS JOIN lateral json_array_elements ( p.exam_order_info :: json ) info
	limit 100
)
SELECT
	rt.pat_id,
	rt.exam_main_cd,
	rt.reg_exam_date,
	rt.reg_order_class,
	CASE 
		WHEN rt.item_cd IS NOT NULL AND rt.item_cd != '''' THEN CAST(rt.item_cd AS NUMERIC)
		ELSE mei.exam_item_cd
	END AS item_cd,
	CASE 
		WHEN rt.item_name IS NOT NULL AND rt.item_name != '''' THEN rt.item_name
		ELSE mei.exam_item_name
	END AS item_name,
	mei.unit,
	CASE
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''1'' THEN normal_value_upper_m
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''2'' THEN normal_value_upper_w
		ELSE normal_value_upper
	END AS upper,
	CASE
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''1'' THEN normal_value_lower_m
		WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''2'' THEN normal_value_lower_w
		ELSE normal_value_lower
	END AS lower,
	mei.in_hospital_cd1,
	mei.in_hospital_cd2,
	mei.in_hospital_cd3,
	mei.sbt_cd1,
	mei.sbt_cd2,
	mei.sbt_cd3
FROM
	result_table AS rt
LEFT JOIN mst_exam_item as mei ON mei.exam_item_cd = CAST(rt.item_cd AS NUMERIC)
LEFT JOIN exam_item_order ON CAST(exam_item_order.exam_item_cd AS NUMERIC) = mei.exam_item_cd
WHERE
	mei.is_disp = ''1''
	AND mei.is_del = ''0''
	AND mei.facility_Cd = @facilityCd
ORDER BY rt.pat_id, rt.reg_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], rt.reg_order_class), exam_item_order.exam_item_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(単項目・指定日以降)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(単項目・指定日以降) 複数型 @patIds @facilityCd @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (321, 'select
  p.pat_id,
	p.exam_main_cd,
	p.reg_exam_date,
	spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
     and m.pat_id IN (@patIds)
    and m.reg_exam_date between date_trunc(''day'',  @date ::timestamp ) and date_trunc(''day'',  @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
group by
  spitz.spitz_name,
	p.exam_main_cd,
	p.reg_exam_date,
	p.pat_id
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(採血管・指定日) 複数型 @patIds @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (322, 'select
  p.pat_id,
	p.exam_main_cd,
	p.reg_exam_date,
	spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id IN (@patIds)
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_exam_date
    limit 100
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
group by
  spitz.spitz_name,
	p.exam_main_cd,
	p.reg_exam_date,
	p.pat_id
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日以降)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(採血管・指定日以降) 複数型 @patIds @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (323, 'select
  p.pat_id,
	p.rad_result_cd,
	p.reg_rad_date,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id IN (@patIds)
    and m.reg_rad_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
;', 2, '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "reg_rad_date", "disp_format": "HH:mm", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "rad_set_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '放射線検査予定(指定日) 複数型 @patIds @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (324, 'select
  p.pat_id,
  p.rad_result_cd,
	p.reg_rad_date,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id IN (@patIds)
    and m.reg_rad_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
  limit 100
;', 2, '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "hh:mm", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '放射線検査予定(指定日以降) 複数型 @patIds @date', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" where sql_cd in (95);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (95, 'WITH
ord_tbl as (
  select
    facility_cd,
    pat_id,
    rst_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from ord_main
  where 
  facility_cd = @facilityCd
  and ord_no = @ordNo
  and is_del = ''0''
)
, bed_group_tbl AS (
  select
    facility_cd,
    room_bed_group_name as bed_group_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 1
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
)
, room_tbl AS (
  select
    facility_cd,
    room_bed_group_name as room_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 2
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
)
, pat_physical_tbl AS (
-- 指定患者、基準日以前のDWがある身体情報を取得
  select
    work_tbl.*
  from
    (
    select
      pat_id,
      info->>''exam_date'' as exam_date,
      info->>''dw'' as dw,
      info->>''pre_scale_upper'' as pre_scale_upper,
      info->>''pre_scale_lower'' as pre_scale_lower
    from
      (select * from pat_unique where is_del = ''0'') as pat_unique
      cross join lateral
        json_array_elements (pat_unique.physical_info :: json) info
    where
      pat_unique.pat_id = (select pat_id from ord_tbl)
    ) work_tbl
  where
    exam_date::timestamp <= (select treat_date_end from ord_tbl)
  and
    dw is not null
  order by
    exam_date desc
  limit 1
)
, pat_wheel_chair_tbl AS (
-- 指定患者の車いす情報を取得
  select
    pat_id,
    wheel_chair_name,
    wheel_chair_weight
  from
    mst_wheel_chair,
    (
      select
        mss.facility_cd, ms.*, row_number() over() as index
      from
        mst_selector mss
      cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
      (
        code bigint,
        name text
      )
      where
        facility_cd = @facilityCd
      and
        master_physical_name = ''mst_wheel_chair''
    ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = (select pat_id from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
    is_personal = ''1''
  limit 1
)
,equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = @facilityCd
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
-- 指定患者、基準日以前のDWがある身体情報を取得
)
,oms_puncture_needle_a_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''06''
		AND ind_rst_class=''2''

)
,oms_puncture_needle_v_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''07''
		AND ind_rst_class=''2''

)
,oms_puncture_needle_sn_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''05''
		AND ind_rst_class=''2''

)
,oms_blood_circuit_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''00''
		AND ind_rst_class=''2''

)
select
	ord.ord_no as ord_no,
	to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
	ord.rst_kur_cd as kur_cd,

	ord.rst_treatment_cd as treatment_cd,
	to_char(ord.rst_start_date, ''HH24:MI'') as treat_start_time,

	to_char(ord.rst_end_date, ''HH24:MI'') as treat_end_time,

	ord.rst_bed_cd as bed_cd,

	ord.rst_cond_info->''1''->>''value'' as treatment_time,
	--ord.rst_cond_info->''2''->>''value_name_1'' as va,
	ord.rst_cond_info->''4''->>''value'' as water_removal_amount_limit,
	ord.rst_cond_info->''12''->>''value'' as single_needle,
	ord.rst_cond_info->''14''->>''value'' as blood_flow,
	ord.rst_cond_info->''16''->>''value'' as dialysate_flow_rate,
	ord.rst_cond_info->''17''->>''value'' as dialysate_amount,
	ord.rst_cond_info->''18''->>''value'' as dialysate_temperature,
	ord.rst_cond_info->''20''->>''value'' as fluid_replacement_amount,
	ord.rst_cond_info->''21''->>''value'' as fluid_replacement_timing,
	ord.rst_cond_info->''22''->>''value'' as fluid_replacement_use_count,
	ord.rst_cond_info->''23''->>''value'' as fluid_replacement_temperature,
	ord.rst_cond_info->''24''->>''value'' as fluid_replacement_speed,
	ord.rst_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
	ord.rst_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
	ord.rst_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
	ord.rst_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
	ord.rst_cond_info->''29''->>''value'' as ip,
	ord.rst_cond_info->''30''->>''value'' as ip_start,
	ord.rst_cond_info->''31''->>''value'' as ip_one_shot_amount,
	ord.rst_cond_info->''32''->>''value'' as ip_speed,
	ord.rst_cond_info->''33''->>''value'' as ip_speed_max,
	ord.rst_cond_info->''34''->>''value'' as auto_one_shot,
	ord.rst_cond_info->''35''->>''value'' as ip_auto_off,
	ord.rst_cond_info->''36''->>''value'' as ip_auto_off_time,
	ord.rst_cond_info->''37''->>''value'' as ip_monitor_auto_off,
	ord.rst_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,
	
	case 
		when ord.rst_device_mode is null then mst_treatment.device_mode
		else ord.rst_device_mode 
	end as device_mode,
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b1 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b1
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b1
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1
		else ''''
	end as treatment_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b2 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b2
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b2
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2
		else ''''
	end as treatment_in_hospital_cd_2,
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b3 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b3
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b3
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3
		else ''''
	end as treatment_in_hospital_cd_3,
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b4 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b4
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b4
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4
		else ''''
	end as treatment_in_hospital_cd_4,	
	

  CAST(ord.rst_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.rst_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,

  case
    when ord.rst_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.rst_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.rst_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

  ord.rst_tare_info->>''name_1'' as tare_name1,
  ord.rst_tare_info->>''name_2'' as tare_name2,
  ord.rst_tare_info->>''name_3'' as tare_name3,
  ord.rst_tare_info->>''name_4'' as tare_name4,
  ord.rst_tare_info->>''name_5'' as tare_name5,
  ord.rst_tare_info->>''weight_1'' as tare_weight1,
  ord.rst_tare_info->>''weight_2'' as tare_weight2,
  ord.rst_tare_info->>''weight_3'' as tare_weight3,
  ord.rst_tare_info->>''weight_4'' as tare_weight4,
  ord.rst_tare_info->>''weight_5'' as tare_weight5,
  CAST(ord.rst_tare_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_5'' AS DECIMAL)
    as tare_weight_total,

  ord.rst_off_water_info->>''name_1'' as off_water_name1,
  ord.rst_off_water_info->>''name_2'' as off_water_name2,
  ord.rst_off_water_info->>''name_3'' as off_water_name3,
  ord.rst_off_water_info->>''name_4'' as off_water_name4,
  ord.rst_off_water_info->>''name_5'' as off_water_name5,
  ord.rst_off_water_info->>''weight_1'' as off_water_weight1,
  ord.rst_off_water_info->>''weight_2'' as off_water_weight2,
  ord.rst_off_water_info->>''weight_3'' as off_water_weight3,
  ord.rst_off_water_info->>''weight_4'' as off_water_weight4,
  ord.rst_off_water_info->>''weight_5'' as off_water_weight5,
  CAST(ord.rst_off_water_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_5'' AS DECIMAL)
    as off_water_weight_total,

  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.rst_cond_info->''3''->>''value''
  end as target_weight,

  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  mst_va.va_name as va_name,
  mst_va.in_hospital_cd_1 as va_in_hospital_cd_1,
  mst_va.in_hospital_cd_2  as va_in_hospital_cd_2,
  mst_va.va_direct as va_direct,

  mst_bed.shunt_position,
  mst_bed.is_infection,
  mst_bed.emergency_class,
  mst_machine.machine_name,

  bed_group_tbl.bed_group_name, -- 実績
  room_tbl.room_name, -- 実績

  mst_dialyzer.model_number as dialyzer_name,
  mst_dialyzer.maker,
  mst_dialyzer.function_class,
  mst_dialyzer.area,
  mst_dialyzer.ufr,
  mst_dialyzer.koa,
  mst_dialyzer.material,
  mst_dialyzer.wetdry,
  mst_dialyzer.sterilization,
  mst_dialyzer.bloodamt,
  mst_dialyzer.alqd_flood_vol,
  mst_dialyzer.urea_clearance,
  mst_dialyzer.gas_purge_time,
  mst_dialyzer.substituent_wash_amt,
  mst_dialyzer.membrane_wash,
  mst_dialyzer.in_hospital_cd_1 as rst_dialyzer_in_hospital_cd_1,
  mst_dialyzer.in_hospital_cd_2 as rst_dialyzer_in_hospital_cd_2,
  mst_dialyzer.in_hospital_cd_3 as rst_dialyzer_in_hospital_cd_3,
  mst_dialyzer.in_hospital_cd_4 as rst_dialyzer_in_hospital_cd_4,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as rst_adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as rst_adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as rst_adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as rst_adsorption_in_hospital_cd_4,

  primary_film_tbl.equipment_name as primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as rst_primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as rst_primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as rst_primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as rst_primary_film_in_hospital_cd_4,

  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as rst_secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as rst_secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as rst_secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as rst_secondary_film_in_hospital_cd_4,

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as rst_pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as rst_pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as rst_pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_4 as rst_pn_a_in_hospital_cd_4,

  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as rst_pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as rst_pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as rst_pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_4 as rst_pn_v_in_hospital_cd_4,

  puncture_needle_sn_tbl.equipment_name as puncture_needle_s_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as rst_pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as rst_pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as rst_pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_4 as rst_pn_s_in_hospital_cd_4,

  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as rst_bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as rst_bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as rst_bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_4 as rst_bc_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
    else med_dialysate_tbl.medicine_name
  end as dialysate_name,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_1
    else med_dialysate_tbl.in_hospital_cd_1
  end as rst_dialysate_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_2
    else med_dialysate_tbl.in_hospital_cd_2
  end as rst_dialysate_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_3
    else med_dialysate_tbl.in_hospital_cd_3
  end as rst_dialysate_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then ''''
    else med_dialysate_tbl.in_hospital_cd_4
  end as rst_dialysate_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
    else med_fluid_replacement_tbl.medicine_name
  end as fluid_replacement_name,

   case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_1
    else med_fluid_replacement_tbl.in_hospital_cd_1
  end as rst_fluid_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_2
    else med_fluid_replacement_tbl.in_hospital_cd_2
  end as rst_fluid_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_3
    else med_fluid_replacement_tbl.in_hospital_cd_3
  end as rst_fluid_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then ''''
    else med_fluid_replacement_tbl.in_hospital_cd_4
  end as rst_fluid_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
    else med_anti_coagulant_tbl.medicine_name
  end as anti_coagulant_name,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_1
    else med_anti_coagulant_tbl.in_hospital_cd_1
  end as rst_anti_in_hospital_cd_1,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_2
    else med_anti_coagulant_tbl.in_hospital_cd_2
  end as rst_anti_in_hospital_cd_2,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_3
    else med_anti_coagulant_tbl.in_hospital_cd_3
  end as rst_anti_in_hospital_cd_3,

  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then ''''
    else med_anti_coagulant_tbl.in_hospital_cd_4
  end as rst_anti_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit

  -- 実績
  ,rst_dialysis_cnt
  ,rst_in_out_class
  ,rst_ward_name
  ,mst_ward_tbl.in_hospital_cd_1 as  rst_ward_in_hospital_cd_1
  ,rst_course_name
  ,mst_course_tbl.in_hospital_cd_1 as  rst_course_in_hospital_cd_1
  ,rst_accept_date
  ,rst_return_home_date
  ,rst_purification_cnt
  ,trim(coalesce(rst_charge_user_info->>''user_id_1'', '''') , '' '') as rst_charge_user_id_1
  ,trim(coalesce(rst_charge_user_info->>''user_id_2'', '''') , '' '') as rst_charge_user_id_2
  ,coalesce(rst_charge_user_info->>''user_last_name_1'', '''') || coalesce(rst_charge_user_info->>''user_first_name_1'', '''') as rst_charge_user_name1
  ,coalesce(rst_charge_user_info->>''user_last_name_2'', '''') || coalesce(rst_charge_user_info->>''user_first_name_2'', '''') as rst_charge_user_name2
  ,(rst_charge_user_info->>''date_1'')::timestamp as rst_charge_date1
  ,(rst_charge_user_info->>''date_2'')::timestamp as rst_charge_date2
  ,trim(coalesce(rst_puncture_user_info->>''user_id_1'', '''') , '' '') as rst_puncture_user_id_1
  ,trim(coalesce(rst_puncture_user_info->>''user_id_2'', '''') , '' '') as rst_puncture_user_id_2
  ,coalesce(rst_puncture_user_info->>''user_last_name_1'', '''') || coalesce(rst_puncture_user_info->>''user_first_name_1'', '''') as rst_puncture_user_name1
  ,coalesce(rst_puncture_user_info->>''user_last_name_2'', '''') || coalesce(rst_puncture_user_info->>''user_first_name_2'', '''') as rst_puncture_user_name2
  ,(rst_puncture_user_info->>''date_1'')::timestamp as rst_puncture_date1
  ,(rst_puncture_user_info->>''date_2'')::timestamp as rst_puncture_date2
  ,trim(coalesce(rst_return_user_info->>''user_id_1'', '''') , '' '') as rst_return_user_id_1
  ,trim(coalesce(rst_return_user_info->>''user_id_2'', '''') , '' '') as rst_return_user_id_2
  ,coalesce(rst_return_user_info->>''user_last_name_1'', '''') || coalesce(rst_return_user_info->>''user_first_name_1'', '''') as rst_return_user_name1
  ,coalesce(rst_return_user_info->>''user_last_name_2'', '''') || coalesce(rst_return_user_info->>''user_first_name_2'', '''') as rst_return_user_name2
  ,(rst_return_user_info->>''date_1'')::timestamp as rst_return_date1
  ,(rst_return_user_info->>''date_2'')::timestamp as rst_return_date2
  ,ord.rst_dw
  ,ord.rst_treatment_name
from
  ord_main as ord

  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id

  left join mst_va on cast(rst_cond_info->''2''->>''value'' as integer) = mst_va.va_cd  and mst_va.is_del = ''0'' and mst_va.is_disp = ''1''  -- 実績

  left join mst_treatment on ord.rst_treatment_cd = mst_treatment.treatment_cd and mst_treatment.is_del = ''0'' and mst_treatment.is_disp = ''1''
  left join mst_bed on ord.rst_bed_cd = mst_bed.bed_cd and mst_bed.is_del = ''0'' and mst_bed.is_disp = ''1''
  left join mst_machine on mst_bed.machine_no = mst_machine.machine_no and mst_machine.is_del = ''0'' and mst_machine.is_disp = ''1''

  left join bed_group_tbl on mst_bed.facility_cd = bed_group_tbl.facility_cd -- 実績
  left join room_tbl on mst_bed.facility_cd = room_tbl.facility_cd -- 実績

  left join mst_dialyzer on ord.rst_cond_info->''5''->>''value'' = mst_dialyzer.dialyzer_cd::text and mst_dialyzer.is_del = ''0'' and mst_dialyzer.is_disp = ''1''AND mst_dialyzer.dialyzer_cd IN (@diaIds)

  left join mst_equipment as adsorption_column_tbl on ord.rst_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text and adsorption_column_tbl.is_del = ''0'' and adsorption_column_tbl.is_disp = ''1'' AND adsorption_column_tbl.class_cd IN (@eqIds)
	and adsorption_column_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as primary_film_tbl on ord.rst_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text and primary_film_tbl.is_del = ''0'' and primary_film_tbl.is_disp = ''1'' AND primary_film_tbl.class_cd IN (@eqIds)
	and primary_film_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as secondary_film_tbl on ord.rst_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text and secondary_film_tbl.is_del = ''0'' and secondary_film_tbl.is_disp = ''1'' AND secondary_film_tbl.class_cd IN (@eqIds)
and secondary_film_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as puncture_needle_a_tbl on ord.rst_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text and puncture_needle_a_tbl.is_del = ''0'' and puncture_needle_a_tbl.is_disp = ''1'' and puncture_needle_a_tbl.class_cd IN (@eqIds)
	and puncture_needle_a_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as puncture_needle_v_tbl on ord.rst_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text and puncture_needle_v_tbl.is_del = ''0'' and puncture_needle_v_tbl.is_disp = ''1'' and puncture_needle_v_tbl.class_cd IN (@eqIds)
	and puncture_needle_v_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as puncture_needle_sn_tbl on ord.rst_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text and puncture_needle_sn_tbl.is_del = ''0'' and puncture_needle_sn_tbl.is_disp = ''1'' and puncture_needle_sn_tbl.class_cd IN (@eqIds)
	and puncture_needle_sn_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as blood_circuit_tbl on ord.rst_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text and blood_circuit_tbl.is_del = ''0'' and blood_circuit_tbl.is_disp = ''1'' and blood_circuit_tbl.class_cd IN (@eqIds)
and blood_circuit_tbl.facility_cd = ord.facility_cd
  left join mst_medicine as med_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text and med_dialysate_tbl.is_del = ''0'' and med_dialysate_tbl.is_disp = ''1'' AND med_dialysate_tbl.class_cd IN (@medIds)
	and med_dialysate_tbl.facility_cd = ord.facility_cd
  left join mst_medicine as med_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text and med_fluid_replacement_tbl.is_del = ''0'' and med_fluid_replacement_tbl.is_disp = ''1'' and med_fluid_replacement_tbl.class_cd in  (@medIds)
	and med_fluid_replacement_tbl.facility_cd = ord.facility_cd
  left join mst_medicine as med_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text and med_anti_coagulant_tbl.is_del = ''0'' and med_anti_coagulant_tbl.is_disp = ''1''and med_anti_coagulant_tbl.class_cd in  (@medIds)
and med_anti_coagulant_tbl.facility_cd = ord.facility_cd
  left join mst_medicine_mix as mix_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text and mix_dialysate_tbl.is_del = ''0'' and mix_dialysate_tbl.is_disp = ''1'' and mix_dialysate_tbl.class_cd in (@medIds)
  left join mst_medicine_mix as mix_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text and mix_fluid_replacement_tbl.is_del = ''0'' and mix_fluid_replacement_tbl.is_disp = ''1'' and mix_fluid_replacement_tbl.class_cd in (@medIds)
  left join mst_medicine_mix as mix_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text and mix_anti_coagulant_tbl.is_del = ''0'' and mix_anti_coagulant_tbl.is_disp = ''1'' and mix_anti_coagulant_tbl.class_cd in (@medIds)
  left join mst_ward as mst_ward_tbl on (ord.rst_ward_cd = mst_ward_tbl.ward_cd and mst_ward_tbl.is_disp =''1'' and mst_ward_tbl.is_del =''0''    )
  left join mst_course as mst_course_tbl on (ord.rst_course_cd = mst_course_tbl.course_cd and mst_course_tbl.is_disp =''1'' and mst_course_tbl.is_del =''0''   )
where
	ord.facility_cd = @facilityCd
	AND ord.ord_no = @ordNo
	AND ord.rst_dialysis_state > ''0''
 and ord.is_del = ''0''
', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "treat_end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_end_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "decimal", "conv_table": [], "data_class": "", "field_name": "treatment_time", "disp_format": "0", "data_category": "", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_dialysis_cnt", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_purification_cnt", "data_name": "特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_purification_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "rst_in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}], "data_class": "実績情報", "field_name": "rst_in_out_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "rst_ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_ward_in_hospital_cd_1", "data_name": "病棟連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_name", "data_name": "診療科名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "rst_accept_date", "data_name": "受付時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_accept_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "rst_return_home_date", "data_name": "帰宅時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_home_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_1", "data_name": "担当者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_charge_user_name1", "data_name": "担当者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:03", "can_calc": "0", "data_code": "rst_charge_date1", "data_name": "担当日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_2", "data_name": "担当者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "rst_charge_user_name2", "data_name": "担当者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:04", "can_calc": "0", "data_code": "rst_charge_date2", "data_name": "担当日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_1", "data_name": "穿刺者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "rst_puncture_user_name1", "data_name": "穿刺者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date1", "data_name": "穿刺日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_2", "data_name": "穿刺者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_puncture_user_name2", "data_name": "穿刺者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date2", "data_name": "穿刺日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_1", "data_name": "返血者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_return_user_name1", "data_name": "返血者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date1", "data_name": "返血日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_2", "data_name": "返血者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_return_user_name2", "data_name": "返血者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date2", "data_name": "返血日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕部シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "後補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "1", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_s_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "bed_group_name", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_group_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析室", "can_calc": "0", "data_code": "room_name", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "1", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "koa", "data_name": "KOA", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線滅菌", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：透析条件/ベッド情報/ダイアライザ情報/実績情報 @ordNo @facilityCd 使用', '2026-01-21 19:19:49.398', CURRENT_TIMESTAMP, NULL);