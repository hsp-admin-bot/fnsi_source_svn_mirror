select
    m1.cd
from ord_main om
    cross join lateral jsonb_to_recordset(om.rst_medi_info) as m1(
        cd bigint,
        effect_flg text,
        effect_date text
    )
where 
    ord_no = /*ordNo*/0
    and m1.cd = /*medicineCd*/0