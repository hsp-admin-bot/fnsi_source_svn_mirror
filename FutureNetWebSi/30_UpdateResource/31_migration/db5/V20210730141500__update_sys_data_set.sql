UPDATE
"ntss"."sys_data_set"
SET "sql" = 'update pat_personal_main set

  fn_pat_id = NULLIF(''@fnPatId'',''''),

  hosp_pat_id = NULLIF(''@hospPatId'',''''),

  nkk_pat_id = NULLIF(''@nkkPatId'',''''),

  facility_cd = NULLIF(''@facilityCd'',''''),

  pat_last_name = personal_info_encrypt(split_part(''@patLastName'',''　'',1)),

  pat_first_name = personal_info_encrypt(split_part(''@patLastName'',''　'',2)),

  pat_last_name_kana = personal_info_encrypt(''@patLastNmKana''),

  pat_first_name_kana = personal_info_encrypt(''@patFirstNmKana''),

  pat_last_name_alpha = NULLIF(''@patLastNmAlpha'',''''),

  pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'',''''),

  pat_birth_name = NULLIF(''@patBirthName'',''''),

  pat_birth_name_kana = NULLIF(''@patBirthNmKana'',''''),

  pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'',''''),

  pat_birthday = NULLIF(''@patBirthday'',''''),

  pat_sex = case ''@patSex''

              when '''' then null

              else to_number(''@patSex'',''9999999999999999'')

            end,

  nationality = NULLIF(''@nationality'',''''),

  pat_blood_type_abo = case ''@patBloodTypeAbo''

                         when '''' then null

                         else to_number(''@patBloodTypeAbo'',''9999999999999999'')

                       end,

  pat_blood_type_rh = case ''@patBloodTypeRh''

                        when '''' then null

                        else to_number(''@patBloodTypeRh'',''9999999999999999'')

                      end,

  pat_blood_type_serovar = case ''@patBloodTypeSerovar''

                             when '''' then null

                             else to_number(''@patBloodTypeSerovar'',''9999999999999999'')

                           end,

  in_out_class = case ''@inOutClass''

                   when '''' then null

                   else to_number(''@inOutClass'',''9999999999999999'')

                 end,

  is_die = NULLIF(''@isDie'',''''),

  die_cd = case ''@dieCd''

             when '''' then null

             else to_number(''@dieCd'',''99999999999999999999999999999999'')

           end,

  die_date = case ''@dieDate_Date''

               when '''' then null

               else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')

             end,

  dial_diff_com_info = ''@dialDiffComInfoValue'',

  severity_cd = case ''@severityCd''

                  when '''' then null

                  else to_number(''@severityCd'',''99999999999999999999999999999999'')

                end,

  transport_cd = case ''@transportCd''

                   when '''' then null

                   else to_number(''@transportCd'',''99999999999999999999999999999999'')

  end,

  pat_contact_info = case ''@patContactInfoFlg''

                       when '''' then ''@patContactInfoValue''

                       else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(''@patContactInfo.address'',''''),''tel'',NULLIF(''@patContactInfo.tel'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))

                     end,

  other_contact_info = ''@otherContactInfoValue'',

  vendor_contact_info = ''@vendorContactInfoValue'',

  insurance_info = ''@insuranceInfoValue'',

  reg_date = ''@regDate'',

  up_date = CURRENT_TIMESTAMP,

  primary_disease_cd = case ''@primaryDiseaseCd''

                         when '''' then null

                         else to_number(''@primaryDiseaseCd'',''99999999999999999999999999999999'')

                       end,

  remote_monitor_service = case ''@remoteMonitorService''

                             when '''' then null

                             else to_number(''@remoteMonitorService'',''99999999999999999999999999999999'')

                           end,

  remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'',''''),

  remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'','''')

where

  is_del = ''0''

and

  hosp_pat_id = ''@hospPatId''

and

  facility_cd = ''@facilityCd''
'
	WHERE "sql_cd" = 1103;
