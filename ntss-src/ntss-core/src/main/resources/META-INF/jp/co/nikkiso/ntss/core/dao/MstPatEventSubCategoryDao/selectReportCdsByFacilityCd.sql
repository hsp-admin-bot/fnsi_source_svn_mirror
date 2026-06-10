SELECT DISTINCT template_cd
FROM (
       -- disp_item_infoからreportCdを取得
       SELECT (disp_item ->> 'reportCd')::INT AS template_cd
       FROM mst_pat_event_sub_category
              CROSS JOIN LATERAL jsonb_array_elements(disp_item_info) AS disp_item
       WHERE facility_cd = /*facilityCd*/null
         AND use_type = 3
         AND is_disp = '1'
         AND is_del = '0'

       UNION

       -- template_cdから取得
       SELECT template_cd
       FROM mst_pat_event_sub_category
       WHERE facility_cd = /*facilityCd*/null
         AND use_type = 3
         AND is_disp = '1'
         AND is_del = '0'
     ) AS A
WHERE template_cd IS NOT NULL;
