UPDATE
  sys_coop_journal
SET
  coop_cd_index = /* journal.coopCdIndex */'',
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  coop_version = /* journal.coopVersion */'',
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  ana_result = /* journal.anaResult */'',
  coop_result = /* journal.coopResult */'',
  dump = /* dump */'',
  dump_path = /* journal.dumpPath */'',
  /*%if journal.anaResult != null && journal.anaResult=="0" */
    report_cd=/* journal.reportCd */null,
  /*%end*/
  crud = /* journal.crud */'',
  -- mod FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 start
  --up_date = /* journal.upDate */null
  up_date = /* journal.upDate */null,
  in_ana_date = /* journal.inAnaDate */null,
  out_ana_date = /* journal.outAnaDate */null,
  in_reg_date = /* journal.inRegDate */null,
  out_reg_date = /* journal.outRegDate */null,
  message = /* journal.message */null
  -- mod FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 end
  /*%if journal.coopResult != null && journal.coopResult == "0" */
    , retry_cnt = case when coop_result = '9' then retry_cnt + 1 else retry_cnt end
  /*%end*/
WHERE
  ctl_no = /* journal.ctlNo */'0'
