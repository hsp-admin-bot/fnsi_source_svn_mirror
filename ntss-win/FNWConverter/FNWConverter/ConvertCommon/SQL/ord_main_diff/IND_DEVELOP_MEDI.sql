select
    IND_ID
from
    IND_DEVELOP_MEDI 
where
    {0} and up_date > :CONVERT_DATETIME
