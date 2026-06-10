DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-410000003,-409000001,-407000001,-407000002,-407000003,-407000004,-407000005,-407000006,-407000007,-407000008,-407000009,-407000010,-407000011,-407000012,-407000013,-407000014,-407000015,-407000016,-407000017,-407000018,-407000019,-407000020,-407000021,-407000022,-407000023,-407000024,-407000025,-407000026,-407000027,-407000028,-407000029,-407000030,-407000031)
;


INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-410000003, 'P_hosp', 'exam_ord', 'S', '検査項目', '検査項目', 'Medicom検査オーダ', '検査オーダ', '1', '<root name="明細詳細(検査項目)">
    <item  name="レコード区分" len="2" key="分類属性" value="const:O2"/>
    <item  name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
    <item  name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
    <item  name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
    <item  name="RSV" len="10" value="$BLANK"/>
    <item  name="項目コード1" len="17" value="dataset:-310010.exam1"/>
    <item  name="負荷時間1" len="10" value="$BLANK"/>
    <item  name="項目区分1" len="1" value="dataset:-310010.exam1p"/>
    <item  name="RSV1" len="8" value="$BLANK"/>
    <item  name="項目コード2" len="17" value="dataset:-310010.exam2"/>
    <item  name="負荷時間2" len="10" value="$BLANK"/>
    <item  name="項目区分2" len="1" value="dataset:-310010.exam2p"/>
    <item  name="RSV2" len="8" value="$BLANK"/>
    <item  name="項目コード3" len="17" value="dataset:-310010.exam3"/>
    <item  name="負荷時間3" len="10" value="$BLANK"/>
    <item  name="項目区分3" len="1" value="dataset:-310010.exam3p"/>
    <item  name="RSV3" len="8" value="$BLANK"/>
    <item  name="項目コード4" len="17" value="dataset:-310010.exam4"/>
    <item  name="負荷時間4" len="10" value="$BLANK"/>
    <item  name="項目区分4" len="1" value="dataset:-310010.exam4p"/>
    <item  name="RSV4" len="8" value="$BLANK"/>
    <item  name="項目コード5" len="17" value="dataset:-310010.exam5"/>
    <item  name="負荷時間5" len="10" value="$BLANK"/>
    <item  name="項目区分5" len="1" value="dataset:-310010.exam5p"/>
    <item  name="RSV5" len="8" value="$BLANK"/>
    <item  name="RSV" len="48" value="$BLANK"/>
    <item  name="改行" len="1" value="$CR"/>
</root>', '{"key": {"分類属性": {"02": "all"}}}'::jsonb, '1', '0', -1, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, '');



INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-409000001, 'P_hosp', 'exam_rst', 'R', '検査結果', 'all', 'Medicom', '検査結果受信', '1', '<root name="検査結果項目">
    <item  name="項目コード" len="17" col="$journal.detail.pat_exam_main.exam_result_info.item_cd" type="string"/>
    <item  name="検査結果値" len="8" col="$journal.detail.pat_exam_main.exam_result_info.result" type="string"/>
    <item  name="検査値形態" len="1" col="$journal.detail.pat_exam_main.exam_result_info.hl" type="string"/>
    <item  name="結果コメント１" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd1" type="string"/>
    <item  name="結果コメント２" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd2" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2020-05-26 10:52:13.579', CURRENT_TIMESTAMP, '');



INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000001, 'P_hosp', 'rst_dial', 'S', 'medicine', '01', '投薬内服繰り返し', '投薬内服繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307009}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000002, 'P_hosp', 'rst_dial', 'S', 'medicine', '02', '投薬頓服繰り返し', '投薬頓服繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307011}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000003, 'P_hosp', 'rst_dial', 'S', 'medicine', '03', '投薬外用繰り返し', '投薬外用繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307013}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000004, 'P_hosp', 'rst_dial', 'S', 'medicine', '04', '投薬自己注射繰り返し', '投薬自己注射繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307015}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000005, 'P_hosp', 'rst_dial', 'S', 'injection', '01', '静注', '静注', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307017}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000006, 'P_hosp', 'rst_dial', 'S', 'injection', '02', '筋注', '筋注', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307019}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000007, 'P_hosp', 'rst_dial', 'S', 'injection', '03', '皮内注', '皮内注', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307021}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000008, 'P_hosp', 'rst_dial', 'S', 'injection', '04', '皮下注', '皮下注', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307023}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000009, 'P_hosp', 'rst_dial', 'S', 'injection', '05', '点滴', '点滴', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307025}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000010, 'P_hosp', 'rst_dial', 'S', 'injection', '06', '特注', '特注', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307027}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000011, 'P_hosp', 'rst_dial', 'S', 'treatment', '01', '治療項目', '治療項目', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307029}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000012, 'P_hosp', 'rst_dial', 'S', 'treatment', '02', '障害者加算', '障害者加算', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307031}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000013, 'P_hosp', 'rst_dial', 'S', 'treatment', '03', '透析困難コメント', '透析困難コメント', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307034}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000014, 'P_hosp', 'rst_dial', 'S', 'treatment', '04', '透析液水質確保加算', '透析液水質確保加算', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307036}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000015, 'P_hosp', 'rst_dial', 'S', 'treatment', '05', '下肢抹消動脈疾患指導管理加算', '下肢抹消動脈疾患指導管理加算', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307038}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000016, 'P_hosp', 'rst_dial', 'S', 'treatment', '06', 'その他加算', 'その他加算', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307040}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000017, 'P_hosp', 'rst_dial', 'S', 'treatment', '07', '加算する治療項目', '加算する治療項目', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307042}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000018, 'P_hosp', 'rst_dial', 'S', 'treatment', '08', '抗凝固剤', '抗凝固剤', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307044}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000019, 'P_hosp', 'rst_dial', 'S', 'treatment', '09', '透析液', '透析液', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307046}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000020, 'P_hosp', 'rst_dial', 'S', 'treatment', '10', '補液', '補液', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307048}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000021, 'P_hosp', 'rst_dial', 'S', 'treatment', '11', '処置', '処置', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307050}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000022, 'P_hosp', 'rst_dial', 'S', 'treatment', '12', '消耗品', '消耗品', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307052}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000023, 'P_hosp', 'rst_dial', 'S', 'treatment', '13', 'ダイアライザ', 'ダイアライザ', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307054}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000024, 'P_hosp', 'rst_dial', 'S', 'treatment', '14', '１次膜、２次膜', '１次膜、２次膜', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307056}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000025, 'P_hosp', 'rst_dial', 'S', 'oxgen', '1', '酸素手技', '酸素手技', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307058}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000026, 'P_hosp', 'rst_dial', 'S', 'oxgen', '2', '酸素', '酸素', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307060}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000027, 'P_hosp', 'rst_dial', 'S', 'oxgen', '3', '薬剤分類が未確認の薬剤', '薬剤分類が未確認の薬剤', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307062}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000028, 'P_hosp', 'rst_dial', 'S', 'treatment', '1', '処置・人工腎臓以外', '処置・人工腎臓以外', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307064}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000029, 'P_hosp', 'rst_dial', 'S', 'medical manage fee', '1', '医学管理料', '医学管理料', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307066}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000030, 'P_hosp', 'rst_dial', 'S', 'surgery', '1', '手術・麻酔', '手術・麻酔', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307068}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000031, 'P_hosp', 'rst_dial', 'S', 'test', '1', '検査', '検査', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.amount" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
    <Order_Administration />
    <OrderUnits_Memo />
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -307070}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');