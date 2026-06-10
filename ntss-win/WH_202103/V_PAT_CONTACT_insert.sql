INSERT INTO V_PAT_CONTACT VALUES(
    '@patid',
    '@name',
    '@ctlNo',
    to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
    to_date('@regDate','yyyy-mm-dd hh24:mi:ss'),
    '@relationName',
    '@rname',
    '@zipcode',
    '@address',
    '@addressDetail',
    '@telno1',
    '@telno2',
    '@memo'
);