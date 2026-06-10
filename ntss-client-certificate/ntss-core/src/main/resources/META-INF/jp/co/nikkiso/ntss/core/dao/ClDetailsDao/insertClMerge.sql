-- ntss-certificate-download の証明書マージ機能専用 INSERT。
-- 通常発行の insertCl との違いは以下の2点:
--   is_merge_issued : '1' 固定（マージ発行証明書であることを示す）
--   file_rand_suffix: 呼び出し元で生成した3桁ランダム数字を設定する。
--                     同一CN組み合わせの複数回マージ時にディスク上のファイルが
--                     上書きされないよう、ファイル名の末尾に付与するためのサフィックス。
Insert into client_cer_detail
    (password_cl,
    facility_cd,
    many_facility_cd,
    many_facility_name,
    cur_download,
    latest_issued_user,
    reg_date,
    up_date,
    is_delete,
    is_merge_issued,
    file_rand_suffix)
values
    (/*passwordCl*/NULL,
    /*facilityCd*/null,
    /*manyFacilityCd*/null,
    /*manyFacilityName*/null,
    '0',
    /*latestIssuedUser*/null,
    /*regDate*/null,
    /*upDate*/null,
    '0',
    '1',
    /*fileRandSuffix*/null)
