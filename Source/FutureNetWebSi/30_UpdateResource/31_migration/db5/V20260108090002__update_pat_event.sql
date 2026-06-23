-- 患者イベントの項目情報(input_params)のフォント名を修正
with replaced_input_params as (
  select
  pat.pat_event_cd,
  jsonb_agg(
    case
    when input_param.html_value is not null
    then
    jsonb_set(
      input_params_array.element,
      '{item_json,html_value}',
      case
        when input_param.html_value::text ~ 'font-family: *メイリオ'
        then
        regexp_replace(
          input_param.html_value::text,
          '(<p |<span )*?(.*?style=\\".*?font-family:\s*)メイリオ(.*?>)',
          '\1\2Meiryo\3',
          'g'
        )::jsonb
        else input_param.html_value
      end,
      false
    )
    else input_params_array.element
    end
  ) as replaced_input_params_array
  from (select * from pat_event where jsonb_typeof(input_params) = 'array') as pat,
  lateral jsonb_array_elements(pat.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'html_value' as html_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by pat.pat_event_cd
)
update
pat_event as pat
set
  input_params = replaced_input_pat.replaced_input_params_array
from
  replaced_input_params as replaced_input_pat
where
  pat.pat_event_cd = replaced_input_pat.pat_event_cd and pat.input_params != replaced_input_pat.replaced_input_params_array;

-- 患者イベントの項目情報(input_params)のゼロ幅スペースと文字が混在するタグからゼロ幅スペースを削除
with replaced_input_params as (
  select
  pat.pat_event_cd,
  jsonb_agg(
    case
    when input_param.html_value is not null
    then
    jsonb_set(
      input_params_array.element,
      '{item_json,html_value}',
      case
        when input_param.html_value::text ~ ('[^<|>|' || U&'\FEFF' || ']' || U&'\FEFF' || '{1,2}') or input_param.html_value::text ~ (U&'\FEFF' || '{1,2}[^<|>|' || U&'\FEFF' || ']')
        then
        regexp_replace(
          regexp_replace(
            input_param.html_value::text,
            '([^<|>|' || U&'\FEFF' || '])' || U&'\FEFF' || '{1,2}',
            '\1',
            'g'
          ),
          U&'\FEFF' || '{1,2}([^<|>|' || U&'\FEFF' || '])',
          '\1',
          'g'
        )::jsonb
        else input_param.html_value
      end,
      false
    )
    else input_params_array.element
    end
  ) as replaced_input_params_array
  from (select * from pat_event where jsonb_typeof(input_params) = 'array') as pat,
  lateral jsonb_array_elements(pat.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'html_value' as html_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by pat.pat_event_cd
)
update
pat_event as pat
set
  input_params = replaced_input_pat.replaced_input_params_array
from
  replaced_input_params as replaced_input_pat
where
  pat.pat_event_cd = replaced_input_pat.pat_event_cd and pat.input_params != replaced_input_pat.replaced_input_params_array;

-- 患者イベントの項目情報(input_params)の空タグにゼロ幅スペースを設定
with replaced_input_params as (
  select
  pat.pat_event_cd,
  jsonb_agg(
    case
    when input_param.html_value is not null
    then
    jsonb_set(
      input_params_array.element,
      '{item_json,html_value}',
      case
        when input_param.html_value::text ~ '<(.*?)></\1>'
        then
        regexp_replace(
          input_param.html_value::text,
          '<(.*?)></\1>',
          '<\1>' || U&'\FEFF' || '</\1>',
          'g'
        )::jsonb
        else input_param.html_value
      end,
      false
    )
    else input_params_array.element
    end
  ) as replaced_input_params_array
  from (select * from pat_event where jsonb_typeof(input_params) = 'array') as pat,
  lateral jsonb_array_elements(pat.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'html_value' as html_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by pat.pat_event_cd
)
update
pat_event as pat
set
  input_params = replaced_input_pat.replaced_input_params_array
from
  replaced_input_params as replaced_input_pat
where
  pat.pat_event_cd = replaced_input_pat.pat_event_cd and pat.input_params != replaced_input_pat.replaced_input_params_array;

-- 患者イベントの項目情報(input_params)の文字データからゼロ幅スペースを削除
with replaced_input_params as (
  select
  pat.pat_event_cd,
  jsonb_agg(
    case
    when input_param.default_value is not null
    then
    jsonb_set(
      input_params_array.element,
      '{item_json,default_value}',
      case
        when input_param.default_value::text ~ U&'\FEFF'
        then
        replace(
          input_param.default_value::text,
          U&'\FEFF',
          ''
        )::jsonb
        else input_param.default_value
      end,
      false
    )
    else input_params_array.element
    end
  ) as replaced_input_params_array
  from (select * from pat_event where jsonb_typeof(input_params) = 'array') as pat,
  lateral jsonb_array_elements(pat.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'default_value' as default_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by pat.pat_event_cd
)
update
pat_event as pat
set
  input_params = replaced_input_pat.replaced_input_params_array
from
  replaced_input_params as replaced_input_pat
where
  pat.pat_event_cd = replaced_input_pat.pat_event_cd and pat.input_params != replaced_input_pat.replaced_input_params_array;

-- 患者イベントの項目実績(result_params)のフォント名を修正
with replaced_result_params as (
  select
  pat.pat_event_cd,
  jsonb_agg(
    case
    when jsonb_path_exists(pat.input_params,('$[' || result_params_array.index - 1 ||'].item_json.is_formatting ? (@=="1")')::jsonpath) = true
    and result_params_array.element::text ~ 'font-family: *メイリオ'
    then
    regexp_replace(
      result_params_array.element::text,
      '(<p |<span )*?(.*?style=\\".*?font-family:\s*)メイリオ(.*?>)',
      '\1\2Meiryo\3',
      'g'
    )::jsonb
    else result_params_array.element
    end
  ) as replaced_result_params_array
  from (select * from pat_event where jsonb_typeof(result_params) = 'array') as pat,
  lateral jsonb_array_elements(pat.result_params) with ordinality as result_params_array(element,index)
  group by pat.pat_event_cd
)
update
pat_event as pat
set
  result_params = replaced_result_pat.replaced_result_params_array
from
  replaced_result_params as replaced_result_pat
where
  pat.pat_event_cd = replaced_result_pat.pat_event_cd and pat.result_params != replaced_result_pat.replaced_result_params_array;

-- 患者イベントの項目実績(result_params)のis_formattingの値によって、以下の処理を実行する
--is_formattingが1の場合、ゼロ幅スペースと文字が混在するタグからゼロ幅スペースを削除
--is_formattingが0の場合、ゼロ幅スペースをすべて削除
with replaced_result_params as (
  select
  pat.pat_event_cd,
  jsonb_agg(
    case
    when jsonb_path_exists(pat.input_params,('$[' || result_params_array.index - 1 ||'].item_json.is_formatting ? (@=="1")')::jsonpath) = true
    and result_params_array.element::text ~ ('[^<|>|' || U&'\FEFF' || ']' || U&'\FEFF' || '{1,2}') or result_params_array.element::text ~ (U&'\FEFF' || '{1,2}[^<|>|' || U&'\FEFF' || ']')
    then
    regexp_replace(
      regexp_replace(
        result_params_array.element::text,
        '([^<|>|' || U&'\FEFF' || '])' || U&'\FEFF' || '{1,2}',
        '\1',
        'g'
      ),
      U&'\FEFF' || '{1,2}([^<|>|' || U&'\FEFF' || '])',
      '\1',
      'g'
    )::jsonb
    when jsonb_path_exists(pat.input_params,('$[' || result_params_array.index - 1 ||'].item_json.is_formatting ? (@=="0")')::jsonpath) = true
    and result_params_array.element::text ~ U&'\FEFF'
    then
    replace(result_params_array.element::text,U&'\FEFF','')::jsonb
    else result_params_array.element
    end
  ) as replaced_result_params_array
  from (select * from pat_event where jsonb_typeof(result_params) = 'array') as pat,
  lateral jsonb_array_elements(pat.result_params) with ordinality as result_params_array(element,index)
  group by pat.pat_event_cd
)
update
pat_event as pat
set
  result_params = replaced_result_pat.replaced_result_params_array
from
  replaced_result_params as replaced_result_pat
where
  pat.pat_event_cd = replaced_result_pat.pat_event_cd and pat.result_params != replaced_result_pat.replaced_result_params_array;

-- is_formattingが1の場合、患者イベントの項目実績(result_params)の空タグにゼロ幅スペースを設定
with replaced_result_params as (
  select
  pat.pat_event_cd,
  jsonb_agg(
    case
    when jsonb_path_exists(pat.input_params,('$[' || result_params_array.index - 1 ||'].item_json.is_formatting ? (@=="1")')::jsonpath) = true
    and result_params_array.element::text ~ '<(.*?)></\1>'
    then
    regexp_replace(
      result_params_array.element::text,
      '﻿<(.*?)></\1>',
      '<\1>' || U&'\FEFF' || '</\1>',
      'g'
    )::jsonb
    else result_params_array.element
    end
  ) as replaced_result_params_array
  from (select * from pat_event where jsonb_typeof(result_params) = 'array') as pat,
  lateral jsonb_array_elements(pat.result_params) with ordinality as result_params_array(element,index)
  group by pat.pat_event_cd
)
update
pat_event as pat
set
  result_params = replaced_result_pat.replaced_result_params_array
from
  replaced_result_params as replaced_result_pat
where
  pat.pat_event_cd = replaced_result_pat.pat_event_cd and pat.result_params != replaced_result_pat.replaced_result_params_array;