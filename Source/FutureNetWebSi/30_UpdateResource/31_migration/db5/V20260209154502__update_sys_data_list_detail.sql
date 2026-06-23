-- #12478 自動ワンショット(使用する/使用しない)→IPワンショットスタート(自動/手動)修正
-- データリストのデータがカテゴリ「治療予定・治療記録」に表示される【指示】治療条件(category_cd=53)と【実績】治療条件(category_cd=74)の文言と表示順を修正

-- 【指示】治療条件の「自動ワンショット」を「IPワンショットスタート」へ文言修正。(unq_sys_data_list_detail_02にひっかかる為、disp_orderを一時的にnullセットする)
update ntss.sys_data_list_detail set disp_order=null, master_display_name='IPワンショットスタート', function_display_name='IPワンショットスタート' where data_list_detail_cd=311;

-- 【指示】治療条件の「IPワンショット量」表示順を42→45へ修正。
update ntss.sys_data_list_detail set disp_order=45 where data_list_detail_cd=308;

-- 【指示】治療条件の「IP速度」表示順を43→42へ修正。
update ntss.sys_data_list_detail set disp_order=42 where data_list_detail_cd=309;

-- 【指示】治療条件の「IP速度最大値」表示順を44→43へ修正。
update ntss.sys_data_list_detail set disp_order=43 where data_list_detail_cd=310;

-- 【指示】治療条件の「IPワンショットスタート」表示順を45→44へ修正。
update ntss.sys_data_list_detail set disp_order=44 where data_list_detail_cd=311;

--------------------

-- 【実績】治療条件の「自動ワンショット」を「IPワンショットスタート」へ文言修正。(unq_sys_data_list_detail_02にひっかかる為、disp_orderを一時的にnullセットする)
update ntss.sys_data_list_detail set disp_order=null, master_display_name='IPワンショットスタート', function_display_name='IPワンショットスタート' where data_list_detail_cd=827;

-- 【実績】治療条件の「IPワンショット量」表示順を42→45へ修正。
update ntss.sys_data_list_detail set disp_order=45 where data_list_detail_cd=824;

-- 【実績】治療条件の「IP速度」表示順を43→42へ修正。
update ntss.sys_data_list_detail set disp_order=42 where data_list_detail_cd=825;

-- 【実績】治療条件の「IP速度最大値」表示順を44→43へ修正。
update ntss.sys_data_list_detail set disp_order=43 where data_list_detail_cd=826;

-- 【実績】治療条件の「IPワンショットスタート」表示順を45→44へ修正。
update ntss.sys_data_list_detail set disp_order=44 where data_list_detail_cd=827;
