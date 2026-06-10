UPDATE sys_coop_journal
set up_date = CURRENT_TIMESTAMP,
		crud = CASE
				WHEN crud ='U' and (select status from ord_coop_no
                                    WHERE facility_cd =/* scjParam.facilityCd */''
                                    AND pat_id = /* scjParam.patId */0
                                    AND ord_no = /* scjParam.ordNo */0
                                    -- mod #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
                                    AND coop_version = /* scjParam.coopVersion */'' LIMIT 1) is Null
                                    -- mod #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end
                                    or
                                    (select status from ord_coop_no
                                    WHERE facility_cd =/* scjParam.facilityCd */''
                                    AND pat_id = /* scjParam.patId */0
                                    AND ord_no = /* scjParam.ordNo */0
                                    -- mod #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
                                    AND coop_version = /* scjParam.coopVersion */'' LIMIT 1) !='1'
                                    -- mod #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end
                THEN 'C' ELSE  crud END

WHERE facility_cd = /* scjParam.facilityCd */''
AND key0 = /* scjParam.key0 */''
AND direction = 'S'
AND pat_id = /* scjParam.patId */0
AND ord_no = /* scjParam.ordNo */0
AND coop_cd = /* scjParam.coopCd */''
AND coop_version = /* scjParam.coopVersion */''
AND (ana_result = 'H' OR coop_result = '0');
