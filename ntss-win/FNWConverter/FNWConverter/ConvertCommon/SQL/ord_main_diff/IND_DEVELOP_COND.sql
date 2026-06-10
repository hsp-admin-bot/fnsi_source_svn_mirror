
select
    IND_ID
from
    IND_DEVELOP_COND 
where
   {0}
    and CTL_NO NOT in ('026', '027', '028')  and up_date > :CONVERT_DATETIME