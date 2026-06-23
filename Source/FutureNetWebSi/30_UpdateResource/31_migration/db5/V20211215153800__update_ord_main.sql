--指示コメント修正(一番長い記録が11番のため)
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{0,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{1,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{2,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{3,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{4,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{5,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{6,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{7,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{8,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{9,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;
update ord_main set ind_ind_comment_info = (jsonb_set(ind_ind_comment_info::jsonb,'{10,is_editable}','"1"'::jsonb,true)) where ind_ind_comment_info is  not null;

--実績コメント修正(一番長い記録が11番のため)
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{0,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{1,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{2,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{3,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{4,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{5,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{6,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{7,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{8,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{9,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
update ord_main set rst_ind_comment_info = (jsonb_set(rst_ind_comment_info::jsonb,'{10,is_editable}','"1"'::jsonb,true)) where rst_ind_comment_info is  not null;
