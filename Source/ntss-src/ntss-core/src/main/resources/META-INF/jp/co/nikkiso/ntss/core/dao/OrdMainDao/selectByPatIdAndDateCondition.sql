-- // mod #8932 【IES起票】患者情報画面にて単患者帳票機能帳票印刷してプレビュー時空白となる 修正 liuc start
--select
--  /*%expand "A" */*
--from
--  ord_main A
--where
--    pat_id = /*patId*/0
--  and treat_date <= /*data*/''
--  and facility_cd = /*facilityCd*/'000000'
--order by
--  rst_end_date IS NOT NULL, rst_end_date DESC limit 1
--;

select
  /*%expand "A" */*
from
  ord_main A
where
    pat_id = /*patId*/0
  and treat_date <= /*data*/''
  and facility_cd = /*facilityCd*/'000000'
  and rst_end_date IS NOT NULL
order by
    rst_end_date DESC limit 1
;
-- // mod #8932 【IES起票】患者情報画面にて単患者帳票機能帳票印刷してプレビュー時空白となる 修正 liuc end
