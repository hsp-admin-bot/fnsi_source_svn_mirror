UPDATE V_PAT_CONTACT SET 
patid='@patid',
name='@name',
ctl_no='@ctlNo',
up_date=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
reg_date=to_date('@regDate','yyyy-mm-dd hh24:mi:ss'),
relation_name='@relationName',
rname='@rname',
zipcode='@zipcode',
address='@address',
address_detail='@addressDetail',
telno1='@telno1',
telno2='@telno2',
memo='@memo'


 where PATID = @patid;
