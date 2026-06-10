CREATE OR REPLACE FUNCTION "ntss"."build_machine_record_message"("machinerecordmessage" text, "code" text, "params" _text)
  RETURNS "pg_catalog"."text" AS $BODY$DECLARE
  message text;
  ret_value text;
  param_size int;
  loop_cnt int;
  target_idx int;
  target_end_idx int;
  target_str text;
  next_msg text;
BEGIN
/* 装置記録メッセージの置換指定子に値を設定して返す */
	IF machinerecordmessage is not null AND length(machinerecordmessage) > 0 THEN
		message := machinerecordmessage;
	ELSE
		SELECT m.machine_record_message INTO message FROM mst_machine_record as m WHERE m.machine_record_cd = code;
		IF NOT FOUND THEN
		RETURN null;
		END IF;
	END IF;

  ret_value := null;

  IF message is not null AND length(message) > 0 THEN
    /*補助データ数の取得*/
    param_size := 0;
    loop_cnt := 0;
    LOOP 
      RAISE NOTICE 'param[%]:(%)', loop_cnt + 1, params[loop_cnt + 1] ;
      IF params[loop_cnt + 1] is null THEN
        EXIT;
      END IF;
      IF params[loop_cnt + 1] != '' THEN
        param_size := param_size + 1;
      END IF;
      loop_cnt := loop_cnt + 1;
    END LOOP;
    RAISE NOTICE 'param_size(%)', param_size;

    target_idx := 0;
    target_end_idx := 0;
    target_str := '';
    loop_cnt := 0;

    LOOP
      IF loop_cnt >= param_size THEN
        EXIT;
      END IF;
      target_idx := strpos(message, '{' || loop_cnt);
      RAISE NOTICE 'target_idx(%)', target_idx;
      
      IF target_idx > 0 THEN
        next_msg := substr(message, target_idx, length(message));
        RAISE NOTICE 'next_msg(%)', next_msg;
        target_end_idx := strpos(next_msg, '}');
        RAISE NOTICE 'target_end_idx(%)', target_end_idx;

        IF target_end_idx + target_idx > target_idx THEN
          target_str := substr(next_msg, 1, target_end_idx);
          RAISE NOTICE 'target_str(%)', target_str;
          /*target_strを適切に文字列にフォーマット*/
          message = replace(message, target_str, ms_string_format(target_str, params[loop_cnt + 1]));
        END IF;
      END IF;
      loop_cnt := loop_cnt + 1;
    END LOOP;

  ret_value = message;
  END IF; 

  RETURN ret_value;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100