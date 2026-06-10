-- 掲示板登録情報の様式付きの内容(html_content)のフォント名を修正
update
bbs_info
set
  html_content
  = regexp_replace(
      html_content,
      '(<p |<span )*?(.*?style=\".*?font-family:\s*)メイリオ(.*?>)',
      '\1\2Meiryo\3',
      'g'
    )
where
  html_content ~ 'font-family: *メイリオ';

-- 掲示板登録情報の様式付きの内容(html_content)のゼロ幅スペースと文字が混在するタグからゼロ幅スペースを削除
update
bbs_info
set
  html_content
  = regexp_replace(
      regexp_replace(
        html_content,
        '([^<|>|' || U&'\FEFF' || '])' || U&'\FEFF' || '{1,2}',
        '\1',
        'g'
      ),
      U&'\FEFF' || '{1,2}([^<|>|' || U&'\FEFF' || '])',
      '\1',
      'g'
    )
where
  html_content ~ ('[^<|>|' || U&'\FEFF' || ']' || U&'\FEFF' || '{1,2}') or html_content ~ (U&'\FEFF' || '{1,2}[^<|>|' || U&'\FEFF' || ']');

-- 掲示板登録情報の様式付きの内容(html_content)の空タグにゼロ幅スペースを設定
update
bbs_info
set
  html_content
  = regexp_replace(
      html_content,
      '﻿<(.*?)></\1>',
      '<\1>' || U&'\FEFF' || '</\1>',
      'g'
    )
where
  html_content ~ '<(.*?)></\1>';

-- 掲示板登録情報の内容(content)(文字データが格納されたカラム)からゼロ幅スペースを削除
update
bbs_info
set
  content = replace(content,U&'\FEFF','')
where
  content ~ U&'\FEFF';