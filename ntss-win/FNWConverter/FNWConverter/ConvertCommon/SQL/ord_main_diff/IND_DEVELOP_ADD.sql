select
    IND_ID
from
    IND_DEVELOP_ADD 
where
   {0}  and up_date > :CONVERT_DATETIME