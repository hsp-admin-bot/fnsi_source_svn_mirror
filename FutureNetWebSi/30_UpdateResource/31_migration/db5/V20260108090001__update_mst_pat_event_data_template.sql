-- 患者イベントテンプレートマスタの項目情報(input_params)のフォント名を修正
with replaced_input_params as (
  select
  mst.template_cd,
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
  from (select * from mst_pat_event_data_template where jsonb_typeof(input_params) = 'array') as mst,
  lateral jsonb_array_elements(mst.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'html_value' as html_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by mst.template_cd
)
update
mst_pat_event_data_template as mst
set
  input_params = replaced_mst.replaced_input_params_array
from
  replaced_input_params as replaced_mst
where
  mst.template_cd = replaced_mst.template_cd;

-- 患者イベントテンプレートマスタの項目情報(input_params)のゼロ幅スペースと文字が混在するタグからゼロ幅スペースを削除
with replaced_input_params as (
  select
  mst.template_cd,
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
  from (select * from mst_pat_event_data_template where jsonb_typeof(input_params) = 'array') as mst,
  lateral jsonb_array_elements(mst.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'html_value' as html_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by mst.template_cd
)
update
mst_pat_event_data_template as mst
set
  input_params = replaced_mst.replaced_input_params_array
from
  replaced_input_params as replaced_mst
where
  mst.template_cd = replaced_mst.template_cd;

-- 患者イベントテンプレートマスタの項目情報(input_params)の空タグにゼロ幅スペースを設定
with replaced_input_params as (
  select
  mst.template_cd,
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
  from (select * from mst_pat_event_data_template where jsonb_typeof(input_params) = 'array') as mst,
  lateral jsonb_array_elements(mst.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'html_value' as html_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by mst.template_cd
)
update
mst_pat_event_data_template as mst
set
  input_params = replaced_mst.replaced_input_params_array
from
  replaced_input_params as replaced_mst
where
  mst.template_cd = replaced_mst.template_cd;

-- 患者イベントテンプレートマスタの項目情報(input_params)の文字データからゼロ幅スペースを削除
with replaced_input_params as (
  select
  mst.template_cd,
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
  from (select * from mst_pat_event_data_template where jsonb_typeof(input_params) = 'array') as mst,
  lateral jsonb_array_elements(mst.input_params) as input_params_array(element),
  lateral (select key,value,value::jsonb->'default_value' as default_value from jsonb_each_text(element) as input_param(key,value) where input_param.key = 'item_json') as input_param(key,value)
  group by mst.template_cd
)
update
mst_pat_event_data_template as mst
set
  input_params = replaced_mst.replaced_input_params_array
from
  replaced_input_params as replaced_mst
where
  mst.template_cd = replaced_mst.template_cd;