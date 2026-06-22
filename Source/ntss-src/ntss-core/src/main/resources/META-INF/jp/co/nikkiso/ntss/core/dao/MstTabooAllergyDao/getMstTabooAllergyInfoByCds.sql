select
    /*%expand "A" */*
from mst_taboo_allergy A
where A.taboo_allergy_cd in /*tabooAllergyCds*/(null)
;

