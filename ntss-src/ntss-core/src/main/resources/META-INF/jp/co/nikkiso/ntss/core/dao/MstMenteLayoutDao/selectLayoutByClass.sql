select
        A.mainte_layout_cd,
        A.edition_no,
        A.facility_cd,
        A.layout_class,
        A.layout_name,
        A.type_info,
        A.detail_info_1,
        A.detail_info_2,
        A.is_disp,
        A.is_del,
        A.up_date,
        A.reg_date,
        --add FNSI-No.694 レイアウトヘッダーを追加する 趙 start
        A.layout_header
        --add FNSI-No.694 レイアウトヘッダーを追加する 趙 end
from
        mst_mainte_layout A  --テーブル名
        ,(
                select
                        mss.facility_cd, ms.*, row_number() over() as index
                from
                        mst_selector mss
                cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
                (
                        code bigint,
                        name text
                )
                where
                master_physical_name = 'mst_mainte_layout' --テーブル名
                /*%if facilityCd != null */
                    and
                    facility_cd = /* facilityCd*/'000000'
                /*%end */
        ) ms
where
        A.facility_cd = ms.facility_cd
and
        A.mainte_layout_cd = ms.code --コードのカラム
and
        A.layout_class = /* layoutClass*/'1'
and
        A.is_del = '0'
and
        A.is_disp = '1'
order by
        ms.index
;
