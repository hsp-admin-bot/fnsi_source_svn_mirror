select
ord_no
from
  ord_main
WHERE
  -- add #12462 患者情報共有 zhao start
  facility_cd = /*facilityCd*/'000000'
  and
  -- add #12462 患者情報共有 zhao end
  pat_id = /*patId*/'0'
  -- add FNSI6371-紹介状に指示内容が表示されない 周 start
  and
  -- add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
  /*%if null != treatDate*/
    treat_date <= to_char(to_date(/*treatDate*/'19000101', 'yyyyMMdd'), 'yyyyMMdd')
  /*%else*/
  -- add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
    treat_date <= to_char(now(), 'yyyyMMdd')
  -- add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
  /*%end*/
  -- add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
  -- add FNSI6371-紹介状に指示内容が表示されない 周 end
order by
-- mod FNSI-改修内容6371 任 start
--rst_end_date IS NULL, rst_end_date DESC
  treat_date DESC,up_date desc
  -- mod FNSI-改修内容6371 任 end
limit 1
;
