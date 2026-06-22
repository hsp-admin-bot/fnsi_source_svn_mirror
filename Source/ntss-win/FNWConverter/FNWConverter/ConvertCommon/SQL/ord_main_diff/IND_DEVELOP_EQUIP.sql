
select
    IND_ID
from
    IND_DEVELOP_EQUIP  
where
    {0}  and up_date > :CONVERT_DATETIME
