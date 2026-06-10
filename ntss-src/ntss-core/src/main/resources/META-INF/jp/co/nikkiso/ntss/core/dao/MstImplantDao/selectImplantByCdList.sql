SELECT 
    /*%expand "A" */*
FROM 
    mst_implant A
WHERE 
    implant_cd IN /*implantCdList*/(0)
