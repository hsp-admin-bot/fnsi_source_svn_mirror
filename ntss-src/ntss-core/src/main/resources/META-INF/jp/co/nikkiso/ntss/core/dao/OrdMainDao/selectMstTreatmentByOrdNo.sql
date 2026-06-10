-- オーダ番号に登録されている治療方法マスタを取得する.
select
  /*%expand "t" */*
from
  mst_treatment t
    inner join ord_main o on
      case
        when o.rst_treatment_cd is not null then
          o.rst_treatment_cd = t.treatment_cd
        when o.ind_treatment_cd is not null then
          o.ind_treatment_cd = t.treatment_cd
        else
          o.rst_treatment_cd = t.treatment_cd
      end
where
  o.ord_no = /*ordNo*/0
and
  o.is_del = '0'
;
