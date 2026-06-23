-- Function: ms_string_format(text, text)
CREATE OR REPLACE FUNCTION ms_string_format(
    format_str text,
    value_param text)
  RETURNS text AS
$BODY$DECLARE
  ret_str_len int;
  ret_str_point_fmt text;
  ret_str_len_idx int;
  ret_str_point_fmt_idx int;
  ret_value text := value_param;
  point_idx int;
  point_cnt int;
  point_ins_idx int;
  loop_cnt int;
BEGIN
  /* {0}や{0,n}, {0,n:0"."00}形式の置換指定子を解釈してvalue_paramで置換*/
  
  ret_str_len_idx := strpos(format_str, ',');
  RAISE NOTICE 'ret_str_len_idx(%)', ret_str_len_idx;
  ret_str_point_fmt_idx := strpos(format_str,':');
  RAISE NOTICE 'ret_str_point_fmt_idx(%)', ret_str_point_fmt_idx;
  
  /* ,後には文字列長を指定されている*/
  IF ret_str_len_idx > 0 THEN
    IF ret_str_point_fmt_idx > 0 THEN
      ret_str_len := to_number(substr(format_str, ret_str_len_idx + 1, ret_str_point_fmt_idx - ret_str_len_idx), '9');
    ELSE
      ret_str_len := to_number(substr(format_str, ret_str_len_idx + 1, length(format_str) - ret_str_len_idx), '9');
    END IF;
  END IF;
  RAISE NOTICE 'ret_str_len(%)', ret_str_len;

  /* :後には小数点位置のフォーマットがある*/
  IF ret_str_point_fmt_idx > 0 THEN
    ret_str_point_fmt := substr(format_str, ret_str_point_fmt_idx + 1, length(format_str) - 1 - ret_str_point_fmt_idx);
    RAISE NOTICE 'ret_str_point_fmt(%)', ret_str_point_fmt;
    
    /* "." が存在するindex取得*/
    point_idx := strpos(ret_str_point_fmt, '"."') + 3;
    RAISE NOTICE 'point_idx(%)', point_idx;
    point_cnt := char_length(ret_str_point_fmt) - point_idx + 1;
    RAISE NOTICE 'point_cnt(%)', point_cnt;

    LOOP
      EXIT WHEN length(ret_value) > point_cnt;
      ret_value := '0' || ret_value;
    END LOOP;
    RAISE NOTICE 'ret_value(%)', ret_value;
    
    /* "." の挿入位置*/
    point_ins_idx := length(ret_value) - point_cnt;
    RAISE NOTICE 'point_ins_idx(%)', point_ins_idx;
    /* "." の挿入*/
    ret_value := substr(ret_value, 1, point_ins_idx) || '.' || substr(ret_value, point_ins_idx + 1, length(ret_value) - point_ins_idx);
    RAISE NOTICE 'ret_value(%)', ret_value;
  END IF;

  IF ret_str_len is not null AND ret_str_len > 0 THEN
    /*右詰め*/
    loop_cnt := 0;
    LOOP
      EXIT WHEN loop_cnt >= ret_str_len;
      ret_value = ' ' || ret_value;
      loop_cnt := loop_cnt + 1;
    END LOOP;
    RAISE NOTICE 'ret_value(%)', ret_value;
    ret_value := right(ret_value, ret_str_len);
    RAISE NOTICE 'ret_value(%)', ret_value;
  ELSIF ret_str_len is not null THEN
    /*左詰め*/
    loop_cnt := ret_str_len;
    LOOP
      EXIT WHEN loop_cnt >= 0;
      ret_value = ret_value || ' ';
      loop_cnt := loop_cnt + 1;
    END LOOP;
    RAISE NOTICE 'ret_value(%)', ret_value;
    ret_value := left(ret_value, -1 * ret_str_len);
    RAISE NOTICE 'ret_value(%)', ret_value;
  END IF;

  RETURN ret_value;

END;$BODY$
  LANGUAGE plpgsql STABLE;

-- Function: build_machine_record_message(text, text[])
CREATE OR REPLACE FUNCTION build_machine_record_message(
    code text,
    params text[])
  RETURNS text AS
$BODY$DECLARE
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
  SELECT m.machine_record_message INTO message FROM mst_machine_record as m WHERE m.machine_record_cd = code;
  IF NOT FOUND THEN
    RETURN null;
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
  LANGUAGE plpgsql VOLATILE;
