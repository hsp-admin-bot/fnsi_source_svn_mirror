DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-661);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-661, 'WITH  KOU_COAG_RESOLVE_MODE_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE'')
,CREATE_NUMBER_FUNCTION_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
,IND_COND_INFO AS (
select ord.ord_no,
ord.ind_cond_info:: json ->''25'' ->> ''value'' as mix_cd, 
ord.ind_cond_info:: json ->''25'' ->> ''medicine_type'' as mix_medicine_type, 
to_number(ord.ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ord.ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count
from ord_main ord where ord.ord_no = @ordNo
)
select 
TRIM(condinfo.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit 
from 
(
SELECT * FROM 
    (--①調製
select mmx.in_hospital_cd_1 as e01,
to_char((select mix_count from IND_COND_INFO) :: NUMERIC, ''FM99990.00'' ) as e02,
mmx.unit as e03,
''1'' as e04
from mst_medicine_mix as mmx 
where mmx.medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
AND (select mix_medicine_type from IND_COND_INFO) = ''2''
UNION ALL
    select mmx.in_hospital_cd_1 as e01,
to_char((select mix_count from IND_COND_INFO) :: NUMERIC, ''FM99990.00'' ) as e02,
mmx.unit as e03,
''0'' as e04
from mst_medicine_mix as mmx 
where mmx.medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
AND (select mix_medicine_type from IND_COND_INFO) = ''2'' ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO) = ''2''
UNION --②単体
select mmd.in_hospital_cd_1 as e01,
to_char((select mix_count from IND_COND_INFO) :: NUMERIC, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''-1'' as e04
from mst_medicine as mmd 
where mmd.medicine_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
AND (select mix_medicine_type from IND_COND_INFO) = ''1'') AS condinfo

', 2, '[{}]', '1', '{"applications": [4]}', NULL, '抗凝固剤', '2022-12-17 05:44:06.942', CURRENT_TIMESTAMP, NULL);
