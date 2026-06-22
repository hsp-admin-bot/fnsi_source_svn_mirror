DROP FUNCTION IF EXISTS get_prefix_str_11409_function(TEXT);
CREATE OR REPLACE FUNCTION get_prefix_str_11409_function(value TEXT)
RETURNS TABLE(prefix_str TEXT, without_prefix_value TEXT) AS $$
DECLARE
    prefixes TEXT[] := ARRAY[
        '【禁忌】',
        '【ｱﾚﾙｷﾞｰ】',
        '【禁忌・ｱﾚﾙｷﾞｰ】',
        '【分類不一致】',
        '【期限切れ】',
        '【削除済み】',
        '【削除済み含む】'
    ];
    current_prefix TEXT;
BEGIN
    prefix_str := ''; -- 初期化prefix用変数
    FOREACH current_prefix IN ARRAY prefixes LOOP
        IF position(current_prefix IN value) > 0 THEN
            prefix_str := prefix_str || current_prefix; -- prefix連結
            value := regexp_replace(value, current_prefix, '', 'g'); -- 現在のprefixを外す
        END IF;
    END LOOP;

    prefix_str := CASE WHEN prefix_str = '' THEN null ELSE prefix_str END;
    without_prefix_value := value; -- 編集済みのvalue_without_prefixをリターン
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE IF EXISTS reset_pat_ind_approve_11409_procedure();
CREATE OR REPLACE PROCEDURE reset_pat_ind_approve_11409_procedure()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_size INT := 1000;
	remaining_rows INT;
	current_ord_no INT := 0;
	
    cur_group_rec_cnt INT :=0;
	cur_group_idx INT :=0;
    total_group_cnt INT :=0;
    rec RECORD;
    
    start_time TIMESTAMP;
    end_time TIMESTAMP; 
	total_start_time TIMESTAMP;
    total_end_time TIMESTAMP;
	total_counter INT := 0;
    
    v_instructorName VARCHAR;
    v_updaterName VARCHAR;
    v_ind_treatment_cd INTEGER;
    v_ind_treatment_name VARCHAR;
    v_ind_kur_cd INTEGER;
    v_ind_kur_name VARCHAR;
    v_treat_date VARCHAR;
    v_ind_treat_start_time VARCHAR;
    v_ind_bed_cd INTEGER;
    v_ind_bed_name VARCHAR;
    v_ind_cond_info JSONB;
    v_cond_item JSON;
    v_ind_cond_items JSONB := '[]'::JSONB;
    v_ind_dw VARCHAR;
    v_ind_dw_user_info  JSON;
    v_ind_dw_updater VARCHAR;
    v_ind_dw_instructor VARCHAR;
    
    v_ind_medi_info JSONB;
    v_medi_item JSON;
    v_ind_medi_items JSONB := '[]'::JSONB;
    
    v_ind_equi_info JSONB;
    v_equi_item JSON;
    v_ind_equi_items JSONB := '[]'::JSONB;
    
    v_ind_comment_info JSONB;
    v_comment_item JSON;
    v_ind_comment_items JSONB := '[]'::JSONB;
    
    v_prefix_str VARCHAR;
    v_without_prefix_value VARCHAR;
    
    v_result JSON;
BEGIN  
	total_start_time := clock_timestamp();
	select count(1) INTO remaining_rows FROM ord_main odm 
      WHERE odm.ord_no > current_ord_no
	  AND NOT EXISTS (SELECT 1 FROM pat_ind_approve pia WHERE pia.ord_no = odm.ord_no);
	  
	total_group_cnt := remaining_rows/batch_size;

	WHILE remaining_rows > 0 LOOP		
		-- 開始時間を記録（性能評価用）
		start_time := clock_timestamp();
		-- 処理グループ単位 + 1
		cur_group_idx := cur_group_idx + 1;
		FOR rec IN
		  SELECT 
			(odm.ind_schedule_user_info::jsonb ->> 'ind_user_last_name') || (odm.ind_schedule_user_info::jsonb ->> 'ind_user_first_name') as instructorName,
			(odm.ind_schedule_user_info::jsonb ->> 'upd_user_last_name') || (odm.ind_schedule_user_info::jsonb ->> 'upd_user_first_name') as updaterName,
			odm.ind_treatment_cd,
			odm.ind_treatment_name,
			odm.ind_kur_cd,
			odm.ind_kur_name,
			to_char(to_date(odm.treat_date, 'YYYYMMDD'), 'YYYY/MM/DD ') as treat_date, -- 20250411 -> 2025/04/11
			substr(odm.ind_treat_start_time, 1, 2) || ':' || substr(odm.ind_treat_start_time, 3, 2) as ind_treat_start_time, -- 0630 -> 06:30
			odm.ind_bed_cd,
			odm.ind_bed_name,
			odm.ind_cond_info,
			odm.ind_dw,
			odm.ind_dw_user_info,
			odm.ind_medi_info,
			odm.ind_equip_info,
			odm.ind_ind_comment_info,
			odm.rst_dialysis_state,
			odm.facility_cd,
			odm.reg_date,
			odm.up_date,
			odm.ord_no
		  FROM ord_main odm
		  WHERE odm.ord_no > current_ord_no
		  AND NOT EXISTS (SELECT 1 FROM pat_ind_approve pia WHERE pia.ord_no = odm.ord_no)
		  ORDER BY odm.ord_no asc
		  limit batch_size
		LOOP
			v_ind_cond_items := '[]'::JSONB;
			v_ind_medi_items := '[]'::JSONB;
			v_ind_equi_items := '[]'::JSONB;
			v_ind_comment_items := '[]'::JSONB;			
			v_instructorName := rec.instructorName;
			v_updaterName := rec.updaterName;
			v_ind_treatment_cd := rec.ind_treatment_cd;
			v_ind_treatment_name := rec.ind_treatment_name;
			v_ind_kur_cd := rec.ind_kur_cd;
			v_ind_kur_name := rec.ind_kur_name;
			v_treat_date := rec.treat_date;
			v_ind_treat_start_time := rec.ind_treat_start_time;
			v_ind_bed_cd := rec.ind_bed_cd;
			v_ind_bed_name := rec.ind_bed_name;
			v_ind_cond_info := rec.ind_cond_info;
			v_ind_dw := rec.ind_dw;
			v_ind_dw_user_info := rec.ind_dw_user_info;
			v_ind_medi_info := rec.ind_medi_info;
			v_ind_equi_info := rec.ind_equip_info;
			v_ind_comment_info := rec.ind_ind_comment_info;
		 
			v_ind_dw_updater = (v_ind_dw_user_info::jsonb ->> 'upd_user_last_name') || (v_ind_dw_user_info::jsonb ->> 'upd_user_first_name');
			v_ind_dw_instructor = (v_ind_dw_user_info::jsonb ->> 'ind_user_last_name') || (v_ind_dw_user_info::jsonb ->> 'ind_user_first_name');
			
			if rec.rst_dialysis_state = '0' then
				INSERT INTO pat_ind_approve(
					"ord_no",
					"check_user1_cd",
					"check_user2_cd",
					"approve_user1_cd",
					"approve_user2_cd",
					"check_user1_time",
					"check_user2_time",
					"approve_user1_time",
					"approve_user2_time",
					"reg_date",
					"up_date",
					"is_content_changed",
					"check_content",
					"is_user1_checked",
					"is_user2_checked",
					"is_user1_approved",
					"is_user2_approved",
					"is_content_appd_changed",
					"approve_content",
					"is_content_changed_for_map",
					"content_for_map",
					"facility_cd")
				VALUES
				  (
					rec.ord_no,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					rec.reg_date,
					rec.up_date,
					'0',
					'{}',
					'0',
					'0',
					'0',
					'0',
					'0',
					'{}',
					'0',
					NULL,
					rec.facility_cd
				);
			else
				-- 治療時間(1)
				IF v_ind_cond_info ? '1' THEN
					v_cond_item = v_ind_cond_info -> '1';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', CASE 
										WHEN (v_cond_item->>'value') IS NOT NULL THEN 
											lpad(((v_cond_item->>'value')::INTEGER / 60)::text, 2, '0') || ':' || lpad(((v_cond_item->>'value')::INTEGER % 60)::text, 2, '0')
										ELSE '未登録' END
								),
								'updater', (v_cond_item::jsonb ->> 'upd_user_last_name') || (v_cond_item::jsonb ->> 'upd_user_first_name'),
								'instructor', (v_cond_item::jsonb ->> 'ind_user_last_name') || (v_cond_item::jsonb ->> 'ind_user_first_name')
							),
							'itemCd', NULL,
							'itemNo', 1,
							'itemName', '治療時間',
							'itemType', NULL
						)
					); 
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 1,
							'itemName', '治療時間',
							'itemType', NULL
						)
					);     
				END IF;
			  
			  
				-- VA(2)
				IF v_ind_cond_info ? '2' THEN
					v_cond_item = v_ind_cond_info -> '2';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item::jsonb ->> 'upd_user_last_name') || (v_cond_item::jsonb ->> 'upd_user_first_name'),
								'instructor', (v_cond_item::jsonb ->> 'ind_user_last_name') || (v_cond_item::jsonb ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 2,
							'itemName', 'VA',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 2,
							'itemName', 'VA',
							'itemType', NULL
						)
					);     
				END IF;
				  
				-- DW(-1)
				IF v_ind_cond_info ? '3' THEN
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', CASE WHEN v_ind_dw IS NULL THEN NULL ELSE 'kg' END , 
									'prefix', NULL,
									'dispVal', CASE WHEN v_ind_dw IS NULL THEN '未登録' ELSE v_ind_dw END
								  ),
								'updater', CASE WHEN v_ind_dw_updater IS NULL THEN '' ELSE v_ind_dw_updater END,
								'instructor', CASE WHEN v_ind_dw_instructor IS NULL THEN '' ELSE v_ind_dw_instructor END
							),
							'itemCd', NULL,
							'itemNo', -1,
							'itemName', 'DW',
							'itemType', NULL
						)
					); 
					-- 目標体重(3)
					v_cond_item = v_ind_cond_info -> '3';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						  'itemInfo', json_build_object(
							  'data', json_build_object(
								  'value', json_build_object(
									  'unit', CASE WHEN (v_cond_item->>'value')='-1' THEN NULL ELSE 'kg' END,
									  'prefix', NULL,
									  'dispVal', CASE WHEN (v_cond_item->>'value') = '-1' OR (v_cond_item->>'value')::numeric::int = -1 THEN 'DWと同じ' ELSE (v_cond_item->>'value') END
								  ),
								  'updater', (v_cond_item::jsonb ->> 'upd_user_last_name') || (v_cond_item::jsonb ->> 'upd_user_first_name'),
								  'instructor', (v_cond_item::jsonb ->> 'ind_user_last_name') || (v_cond_item::jsonb ->> 'ind_user_first_name')
								),
							  'itemCd', NULL,
							  'itemNo', 3,
							  'itemName', '目標体重',
							  'itemType', NULL
						  )
					  );
					
				ELSE 
					-- DW(-1)
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL, 
									'prefix', NULL,
									'dispVal', '未登録'
								  ),
								'updater', CASE WHEN v_ind_dw_updater IS NULL THEN '' ELSE v_ind_dw_updater END,
								'isDisable',TRUE,
								'instructor', CASE WHEN v_ind_dw_instructor IS NULL THEN '' ELSE v_ind_dw_instructor END
							),
							'itemCd', NULL,
							'itemNo', -1,
							'itemName', 'DW',                
							'itemType', NULL
						)
					);
					-- 目標体重(3)
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', NULL
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 3,
							  'itemName', '目標体重',
							'itemType', NULL
						)
					);     
				END IF;
		  
				-- 除水量限制(4)
				IF v_ind_cond_info ? '4' THEN
					v_cond_item = v_ind_cond_info -> '4';
						v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
							'itemInfo', json_build_object(
								'data', json_build_object(
									'value', json_build_object(                            
										'unit', (v_cond_item->>'unit') , 
										'prefix', NULL,
										'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
									),
									'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
									'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
								),
								'itemCd', NULL,
								'itemNo', 4,
								'itemName', '除水量制限',
								'itemType', NULL
							)
						);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 4,
							'itemName', '除水量制限',
							'itemType', NULL
						)
					);      
				END IF;
			  
				-- ダイアライザ(5)
				IF v_ind_cond_info ? '5' THEN
					v_cond_item = v_ind_cond_info -> '5'; 
					
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE '[' || (v_cond_item->>'value_name_1') || ']' END);
				
				
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 5,
							'itemName', 'ダイアライザ',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 5,
							'itemName', 'ダイアライザ',
							'itemType', NULL
						)
					);      
				END IF;
			  
				-- 吸着カラム(6)
				IF v_ind_cond_info ? '6' THEN
					v_cond_item = v_ind_cond_info -> '6';
				
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
				
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 6,
							'itemName', '吸着カラム',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 6,
							'itemName', '吸着カラム',
							'itemType', NULL
						)
					);      
				END IF;
			  
				-- 1次膜(7)
				IF v_ind_cond_info ? '7' THEN
					v_cond_item = v_ind_cond_info -> '7';
				  
					SELECT prefix_str, without_prefix_value
					  INTO v_prefix_str, v_without_prefix_value
					  FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
				  
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						  'itemInfo', json_build_object(
							  'data', json_build_object(
								  'value', json_build_object(
									  'unit', (v_cond_item->>'unit'),
									  'prefix', v_prefix_str,
									  'dispVal', v_without_prefix_value
								  ),
								  'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								  'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							  ),
							  'itemCd', (v_cond_item->>'value')::integer,
							  'itemNo', 7,
							  'itemName', '1次膜',
							  'itemType', NULL
						)
					);
				  
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 7,
							'itemName', '1次膜',
							'itemType', NULL
						)
					);      
				END IF;
			  
				-- 2次膜(8)
				IF v_ind_cond_info ? '8' THEN
					  v_cond_item = v_ind_cond_info -> '8';
					  
					  SELECT prefix_str, without_prefix_value
					  INTO v_prefix_str, v_without_prefix_value
					  FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
					  
					  v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						  'itemInfo', json_build_object(
							  'data', json_build_object(
								  'value', json_build_object(
									  'unit', (v_cond_item->>'unit'),
									  'prefix', v_prefix_str,
									  'dispVal', v_without_prefix_value
								  ),
								  'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								  'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							  ),
							  'itemCd', (v_cond_item->>'value')::integer,
							  'itemNo', 8,
							  'itemName', '2次膜',
							  'itemType', NULL
						  )
					  );
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 8,
							'itemName', '2次膜',
							'itemType', NULL
						)
					);      
				END IF;
			  
				-- 穿刺針(A針)(9)
				IF v_ind_cond_info ? '9' THEN
					  v_cond_item = v_ind_cond_info -> '9';
					  
					  SELECT prefix_str, without_prefix_value
					  INTO v_prefix_str, v_without_prefix_value
					  FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
					  
					  v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						  'itemInfo', json_build_object(
							  'data', json_build_object(
								  'value', json_build_object(
									  'unit', (v_cond_item->>'unit'),
									  'prefix', v_prefix_str,
									  'dispVal', v_without_prefix_value
								  ),
								  'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								  'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							  ),
							  'itemCd', (v_cond_item->>'value')::integer,
							  'itemNo', 9,
							  'itemName', '穿刺針(A針)',
							  'itemType', NULL
						  )
					  );
				  
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 9,
							'itemName', '穿刺針(A針)',
							'itemType', NULL
						)
					);      
				END IF;
			
				-- 穿刺針(V針)(10)
				IF v_ind_cond_info ? '10' THEN
					v_cond_item = v_ind_cond_info -> '10';
					
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
					
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 10,
							'itemName', '穿刺針(V針)',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 10,
							'itemName', '穿刺針(V針)',
							'itemType', NULL
						)
					);      
				END IF;
			 
			 
				-- 穿刺針(SN)(11)
				IF v_ind_cond_info ? '11' THEN
					v_cond_item = v_ind_cond_info -> '11';
					
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
					
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 11,
							'itemName', '穿刺針(SN)',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 11,
							'itemName', '穿刺針(SN)',
							'itemType', NULL
						)
					);      
				END IF;
			
				-- シングルニードル使用(12)
				IF v_ind_cond_info ? '12' THEN
					v_cond_item = v_ind_cond_info -> '12';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', NULL,
							'itemNo', 12,
							'itemName', 'シングルニードル使用',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 12,
							'itemName', 'シングルニードル使用',
							'itemType', NULL
						)
					);      
				END IF;
			
				-- 血液回路(13)
				IF v_ind_cond_info ? '13' THEN
					v_cond_item = v_ind_cond_info -> '13';
					
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
					
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 13,
							'itemName', '血液回路',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 13,
							'itemName', '血液回路',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 血流量(14)
				IF v_ind_cond_info ? '14' THEN
					v_cond_item = v_ind_cond_info -> '14';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 14,
							'itemName', '血流量',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 14,
							'itemName', '血流量',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 透析液(15)
				IF v_ind_cond_info ? '15' THEN
					v_cond_item = v_ind_cond_info -> '15';
					
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
					
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 15,
							'itemName', '透析液',
							'itemType', 1
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 15,
							'itemName', '透析液',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 透析液流量(16)
				IF v_ind_cond_info ? '16' THEN
					v_cond_item = v_ind_cond_info -> '16';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 16,
							'itemName', '透析液流量',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 16,
							'itemName', '透析液流量',
							'itemType', NULL
						)
					);      
				END IF;
					  
				-- 透析液使用数(17)
				IF v_ind_cond_info ? '17' THEN
					v_cond_item = v_ind_cond_info -> '17';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 17,
							'itemName', '透析液使用数',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 17,
							'itemName', '透析液使用数',
							'itemType', NULL
						)
					);      
				END IF;
				 
				 
				-- 透析液温度(18)
				IF v_ind_cond_info ? '18' THEN
					v_cond_item = v_ind_cond_info -> '18';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 18,
							'itemName', '透析液温度',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 18,
							'itemName', '透析液温度',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 補液(19)
				IF v_ind_cond_info ? '19' THEN
					v_cond_item = v_ind_cond_info -> '19';
					
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);        
					
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 19,
							'itemName', '補液',
							'itemType', 1
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 19,
							'itemName', '補液',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 補液量(20)
				IF v_ind_cond_info ? '20' THEN
					v_cond_item = v_ind_cond_info -> '20';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 20,
							'itemName', '補液量',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 20,
							'itemName', '補液量',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 補液選択(21)
				IF v_ind_cond_info ? '21' THEN
					v_cond_item = v_ind_cond_info -> '21';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 21,
							'itemName', '補液選択',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 21,
							'itemName', '補液選択',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 補液使用数(22)
				IF v_ind_cond_info ? '22' THEN
					v_cond_item = v_ind_cond_info -> '22';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 22,
							'itemName', '補液使用数',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 22,
							'itemName', '補液使用数',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 補液温度(23)
				IF v_ind_cond_info ? '23' THEN
					v_cond_item = v_ind_cond_info -> '23';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 23,
							'itemName', '補液温度',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 23,
							'itemName', '補液温度',
							'itemType', NULL
						)
					);      
				END IF;
				 
				 
				-- 補液速度(24)
				IF v_ind_cond_info ? '24' THEN
					v_cond_item = v_ind_cond_info -> '24';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 24,
							'itemName', '補液速度',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 24,
							'itemName', '補液速度',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 抗凝固剤(25)
				IF v_ind_cond_info ? '25' THEN
					v_cond_item = v_ind_cond_info -> '25';
					
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END);
					
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit',(v_cond_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', v_without_prefix_value
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_cond_item->>'value')::integer,
							'itemNo', 25,
							'itemName', '抗凝固剤',
							'itemType', 1
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 25,
							'itemName', '抗凝固剤',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 抗凝固剤ワンショット量(26)
				IF v_ind_cond_info ? '26' THEN
					v_cond_item = v_ind_cond_info -> '26';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 26,
							'itemName', '抗凝固剤ワンショット量',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 26,
							'itemName', '抗凝固剤ワンショット量',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 抗凝固剤持続速度(27)
				IF v_ind_cond_info ? '27' THEN
					v_cond_item = v_ind_cond_info -> '27';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 27,
							'itemName', '抗凝固剤持続速度',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 27,
							'itemName', '抗凝固剤持続速度',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- 抗凝固剤持続総量(28)
				IF v_ind_cond_info ? '28' THEN
					v_cond_item = v_ind_cond_info -> '28';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 28,
							'itemName', '抗凝固剤持続総量',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 28,
							'itemName', '抗凝固剤持続総量',
							'itemType', NULL
						)
					);      
				END IF;
				 
				 
				-- IP使用選択(29)
				IF v_ind_cond_info ? '29' THEN
					v_cond_item = v_ind_cond_info -> '29';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 29,
							'itemName', 'IP使用選択',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 29,
							'itemName', 'IP使用選択',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- IPスタート(30)
				IF v_ind_cond_info ? '30' THEN
					v_cond_item = v_ind_cond_info -> '30';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 30,
							'itemName', 'IPスタート',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 30,
							'itemName', 'IPスタート',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- IPワンショット量(31)
				IF v_ind_cond_info ? '31' THEN
					v_cond_item = v_ind_cond_info -> '31';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 31,
							'itemName', 'IPワンショット量',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 31,
							'itemName', 'IPワンショット量',
							'itemType', NULL
						)
					);      
				END IF;
				 
				-- IP速度(32)
				IF v_ind_cond_info ? '32' THEN
					v_cond_item = v_ind_cond_info -> '32';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 32,
							'itemName', 'IP速度',
							'itemType', NULL
						)
					);
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 32,
							'itemName', 'IP速度',
							'itemType', NULL
						)
					);      
				END IF;    
				 
				-- IP速度最大値(33)
				IF v_ind_cond_info ? '33' THEN
					v_cond_item = v_ind_cond_info -> '33';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 33,
							'itemName', 'IP速度最大値',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 33,
							'itemName', 'IP速度最大値',
							'itemType', NULL
						)
					);      
				END IF;  
				 
				-- 自動ワンショット(34)
				IF v_ind_cond_info ? '34' THEN
					v_cond_item = v_ind_cond_info -> '34';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 34,
							'itemName', '自動ワンショット',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 34,
							'itemName', '自動ワンショット',
							'itemType', NULL
						)
					);      
				END IF;  
				 
				-- IP電源自動切り(35)
				IF v_ind_cond_info ? '35' THEN
					v_cond_item = v_ind_cond_info -> '35';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 35,
							'itemName', 'IP電源自動切り',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 35,
							'itemName', 'IP電源自動切り',
							'itemType', NULL
						)
					);      
				END IF;  
				 
				-- IP電源自動切り時間(36)
				IF v_ind_cond_info ? '36' THEN
					v_cond_item = v_ind_cond_info -> '36';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', CASE WHEN (v_cond_item->>'value') IS NULL THEN NULL ELSE '分' END,
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 36,
							'itemName', 'IP電源自動切り時間',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 36,
							'itemName', 'IP電源自動切り時間',
							'itemType', NULL
						)
					);      
				END IF;  
				 
				-- IP電源OKモニタ切り(37)
				IF v_ind_cond_info ? '37' THEN
					v_cond_item = v_ind_cond_info -> '37';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_cond_item->>'unit'),
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value_name_1') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 37,
							'itemName', 'IP電源OKモニタ切り',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 37,
							'itemName', 'IP電源OKモニタ切り',
							'itemType', NULL
						)
					);      
				END IF;  
				 
				-- IP電源OKモニタ切り時間(38)
				IF v_ind_cond_info ? '38' THEN
					v_cond_item = v_ind_cond_info -> '38';
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', CASE WHEN (v_cond_item->>'value') IS NULL THEN NULL ELSE '分' END,
									'prefix', NULL,
									'dispVal', CASE WHEN (v_cond_item->>'value') IS NULL THEN '未登録' ELSE (v_cond_item->>'value') END
								),
								'updater', (v_cond_item ->> 'upd_user_last_name') || (v_cond_item ->> 'upd_user_first_name'),
								'instructor', (v_cond_item ->> 'ind_user_last_name') || (v_cond_item ->> 'ind_user_first_name')
							),
							'itemCd', null,
							'itemNo', 38,
							'itemName', 'IP電源OKモニタ切り時間',
							'itemType', NULL
						)
					);
					
				ELSE
					v_ind_cond_items := v_ind_cond_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', '未登録'
								),
								'updater', '',
								'isDisable',TRUE,
								'instructor', ''
							),
							'itemCd', NULL,
							'itemNo', 38,
							'itemName', 'IP電源OKモニタ切り時間',
							'itemType', NULL
						)
					);      
				END IF;  
				 
				 
				-- 投与薬剤
				FOR v_medi_item IN SELECT jsonb_array_elements(v_ind_medi_info) LOOP
				 
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(v_medi_item->>'name');
					
					v_ind_medi_items := v_ind_medi_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_medi_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', (v_medi_item->>'amount')
								),
								'updater', (v_medi_item ->> 'upd_user_last_name') || (v_medi_item ->> 'upd_user_first_name'),
								'instructor', (v_medi_item ->> 'ind_user_last_name') || (v_medi_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_medi_item->>'cd')::integer,
							'itemNo', (v_medi_item->>'no')::integer,
							'itemName', v_without_prefix_value,
							'itemType', (v_medi_item->>'medicine_type')::integer
						)
					);

				END LOOP;
				 
				 
				-- 医療材料
				FOR v_equi_item IN SELECT jsonb_array_elements(v_ind_equi_info) LOOP
				 
					SELECT prefix_str, without_prefix_value
					INTO v_prefix_str, v_without_prefix_value
					FROM get_prefix_str_11409_function(v_equi_item->>'name');
					
					v_ind_equi_items := v_ind_equi_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', (v_equi_item->>'unit'),
									'prefix', v_prefix_str,
									'dispVal', (v_equi_item->>'amount')
								),
								'updater', (v_equi_item ->> 'upd_user_last_name') || (v_equi_item ->> 'upd_user_first_name'),
								'instructor', (v_equi_item ->> 'ind_user_last_name') || (v_equi_item ->> 'ind_user_first_name')
							),
							'itemCd', (v_equi_item->>'cd')::integer,
							'itemNo', NULL,
							'itemName', v_without_prefix_value,
							'itemType', (v_equi_item->>'equip_type')::integer
						)
					);

				END LOOP;
				 
				 
				-- 指示コメント
				FOR v_comment_item IN SELECT jsonb_array_elements(v_ind_comment_info) LOOP
					v_ind_comment_items := v_ind_comment_items || jsonb_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', null,
									'dispVal', (v_comment_item->>'content')
								),
								'updater', (v_comment_item ->> 'upd_user_last_name') || (v_comment_item ->> 'upd_user_first_name'),
								'instructor', (v_comment_item ->> 'ind_user_last_name') || (v_comment_item ->> 'ind_user_first_name')
							),
							'itemCd', NULL,
							'itemNo', (v_comment_item->>'no')::integer,
							'itemName', 'コメント' || (v_comment_item->>'no'),
							'itemType', NULL
						)
					);

				END LOOP;
				 
				 
				 
				SELECT json_build_array(
					-- 治療方法
					json_build_object(
						'itemInfo', json_build_object(
							'data', json_build_object(
								'value', json_build_object(
									'unit', NULL,
									'prefix', NULL,
									'dispVal', v_ind_treatment_name
								),
								'updater', v_updaterName,
								'instructor', v_instructorName 
							),
							'itemCd', v_ind_treatment_cd,
							'itemNo', 1,
							'itemName', NULL,
							'itemType', NULL
						),
						'component', 'treat-method',
						'subCategoryNo', 2,
						'subCategoryItem',json_build_array(),
						'subCategoryName', '治療方法'
					)
					,
					
					-- スケジュール
					json_build_object(
						'component', 'schedule',
						'subCategoryNo', 3,
						'subCategoryItem', json_build_array(
							json_build_object(
								'itemInfo', json_build_object(
									'data', json_build_object(
										'value', json_build_object(
											'unit', NULL,
											'prefix', NULL,
											'dispVal', v_ind_kur_name
										),
										'updater', v_updaterName,
										'instructor', v_instructorName 
									),
									'itemCd', v_ind_kur_cd,
									'itemNo', 1,
									'itemName', 'クール',
									'itemType', NULL
								)
							),
							json_build_object(
								'itemInfo', json_build_object(
									'data', json_build_object(
										'value', json_build_object(
											'unit', NULL,
											'prefix', v_treat_date,
											'dispVal', v_ind_treat_start_time
										),
										'updater', v_updaterName,
										'instructor', v_instructorName 
									),
									'itemCd', NULL,
									'itemNo', 2,
									'itemName', '治療開始時刻',
									'itemType', NULL
								)
							),
							json_build_object(
								'itemInfo', json_build_object(
									'data', json_build_object(
										'value', json_build_object(
											'unit', NULL,
											'prefix', NULL,
											'dispVal', v_ind_bed_name
										),
										'updater', v_updaterName,
										'instructor', v_instructorName 
									),
									'itemCd', v_ind_bed_cd,
									'itemNo', 3,
									'itemName', 'ベッド',
									'itemType', NULL
								)
							)
						),
						'subCategoryName', 'スケジュール'
					)
					,
					
					-- 治療条件
					json_build_object(
						'component', 'treat-cond',
						'subCategoryNo', 4,
						'subCategoryItem', v_ind_cond_items,
						'subCategoryName', '治療条件'
					)
					,
					
					-- 投与薬剤
					json_build_object(
						'component', 'medicine',
						'subCategoryNo', 5,
						'subCategoryItem', v_ind_medi_items,
						'subCategoryName', '投与薬剤'
					) 
					,
					
					-- 資料材料
					json_build_object(
						'component', 'equipment',
						'subCategoryNo', 6,
						'subCategoryItem', v_ind_equi_items,
						'subCategoryName', '医療材料'
					)
					,
					
					-- 指示コメント
					json_build_object(
						'component', 'ind-comment',
						'subCategoryNo', 7,
						'subCategoryItem', v_ind_comment_items,
						'subCategoryName', '指示コメント'
					) 
				) INTO v_result;
				-- RAISE NOTICE 'content_for_map:%',v_result;   
				
				INSERT INTO pat_ind_approve(
					"ord_no",
					"check_user1_cd",
					"check_user2_cd",
					"approve_user1_cd",
					"approve_user2_cd",
					"check_user1_time",
					"check_user2_time",
					"approve_user1_time",
					"approve_user2_time",
					"reg_date",
					"up_date",
					"is_content_changed",
					"check_content",
					"is_user1_checked",
					"is_user2_checked",
					"is_user1_approved",
					"is_user2_approved",
					"is_content_appd_changed",
					"approve_content",
					"is_content_changed_for_map",
					"content_for_map",
					"facility_cd")
				VALUES
				  (
					rec.ord_no,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					rec.reg_date,
					rec.up_date,
					'0',
					'{}',
					'0',
					'0',
					'0',
					'0',
					'0',
					'{}',
					'0',
					v_result,
					rec.facility_cd
				);
			end if;
			current_ord_no := rec.ord_no;
			cur_group_rec_cnt := cur_group_rec_cnt + 1;
		END LOOP;
		-- 1000レコードをグループ単位でコミット実施
		COMMIT;		
		-- 終了時間記録
		end_time := clock_timestamp();		
		
		select count(1) INTO remaining_rows FROM ord_main odm 
		  WHERE odm.ord_no > current_ord_no
		  AND NOT EXISTS (SELECT 1 FROM pat_ind_approve pia WHERE pia.ord_no = odm.ord_no);
		
		-- 出力時間と処理数  
		RAISE NOTICE '現在のグループは %/%、合計 % 項目です。すべての項目が処理されましたが、処理が残っている項目は % 件です。', cur_group_idx,total_group_cnt,cur_group_rec_cnt,remaining_rows;
		RAISE NOTICE '処理開始時間: %,終了時間: %', start_time, end_time;
		RAISE NOTICE '処理合計時間: %', end_time - start_time;
		RAISE NOTICE '---------------------------------------------------------';
		RAISE NOTICE '';
		
		-- 統計情報
		total_counter := total_counter + cur_group_rec_cnt;
		cur_group_rec_cnt := 0;
	END LOOP;
	
	total_end_time := clock_timestamp();
	RAISE NOTICE '処理完了、計%件', total_counter;
	RAISE NOTICE '開始時間: %、終了時間: %', total_start_time, total_end_time;
	RAISE NOTICE '合計時間: %', total_end_time - total_start_time;
    
END;
$$;
call reset_pat_ind_approve_11409_procedure();
DROP PROCEDURE IF EXISTS reset_pat_ind_approve_11409_procedure();
DROP FUNCTION IF EXISTS get_prefix_str_11409_function(TEXT);


