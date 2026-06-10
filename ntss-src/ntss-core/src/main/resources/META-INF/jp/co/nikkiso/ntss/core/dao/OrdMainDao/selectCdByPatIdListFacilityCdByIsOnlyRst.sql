-- add by zhaohan 2022-10-20 [6523] バックエンドの処理時間かかるのでエラー発生。 --start
WITH ord_main AS
         (
             SELECT
                 ord.pat_id,
                 ord.ind_treatment_cd,
                 ord.ind_kur_cd,
                 ord.ind_bed_cd,
                 ord.ind_cond_info,
                 ord.ind_medi_info,
                 ord.ind_equip_info,
                 ord.rst_treatment_cd,
                 ord.rst_kur_cd,
                 ord.rst_bed_cd,
                 ord.rst_cond_info,
                 ord.rst_medi_info,
                 ord.rst_equip_info,
                 ord.rst_ward_cd,
                 ord.rst_course_cd,
                 ord.addition_info,
                 ord.treat_date,
                 ord.rst_dialysis_state,
                 ord.ord_no
             FROM ord_main ord
             WHERE ord.is_del = '0'
                /*%if isOnlyRst */
               AND ord.rst_dialysis_state in ('1','2','3', '4', '5', '6')
                 /*%else*/
               AND ord.rst_dialysis_state = '0'
                /*%end*/
               AND ord.facility_cd = /*facilityCd*/null                                                                           -- 施設コード
               AND ord.pat_id in /*patIdList*/(null)                                                                              -- 患者ID
               AND (
                     ( ord.treat_date >= REPLACE ( /*startDate*/NULL, '-', '' )                                                    -- 治療日
                         AND ord.treat_date <= REPLACE ( /*endDate*/NULL, '-', '' ) )                                                  -- 治療日

                     OR ( ord.rst_start_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP                     -- 実績：治療開始日時
                    AND ord.rst_start_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP )                    -- 実績：治療開始日時

                     OR ( ord.rst_end_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP                       -- 実績：治療終了日時
                    AND ord.rst_end_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP )                      -- 実績：治療終了日時
                 )
         )
-- add by zhaohan 2022-10-20 [6523] バックエンドの処理時間かかるのでエラー発生。 --end
SELECT ord.pat_id                                                                                                                 -- 患者ID
------------------------------------------------------------------------------------------------------------------------------------ 【指示】治療方法
     , ind_treatment.in_hosp_a_startdate AS ind_treatment_a_startdate                                                             -- 治療方法利用開始日A
     , ind_treatment.in_hospital_cd_a1   AS ind_treatment_cd_a1                                                                   -- 治療方法連携コードA1
     , ind_treatment.in_hospital_cd_a2   AS ind_treatment_cd_a2                                                                   -- 治療方法連携コードA2
     , ind_treatment.in_hospital_cd_a3   AS ind_treatment_cd_a3                                                                   -- 治療方法連携コードA3
     , ind_treatment.in_hospital_cd_a4   AS ind_treatment_cd_a4                                                                   -- 治療方法連携コードA4
     , ind_treatment.in_hosp_b_startdate AS ind_treatment_b_startdate                                                             -- 治療方法利用開始日B
     , ind_treatment.in_hospital_cd_b1   AS ind_treatment_cd_b1                                                                   -- 治療方法連携コードB1
     , ind_treatment.in_hospital_cd_b2   AS ind_treatment_cd_b2                                                                   -- 治療方法連携コードB2
     , ind_treatment.in_hospital_cd_b3   AS ind_treatment_cd_b3                                                                   -- 治療方法連携コードB3
     , ind_treatment.in_hospital_cd_b4   AS ind_treatment_cd_b4                                                                   -- 治療方法連携コードB4

------------------------------------------------------------------------------------------------------------------------------------ 【指示】スケジュール
     , ind_kur.in_hospital_cd_1          AS ind_kur_cd1                                                                           -- クール連携コード1
     , ind_bed.in_hospital_cd_1          AS ind_bed_cd1                                                                           -- ベッド連携コード1
     , ind_bed.in_hospital_cd_2          AS ind_bed_cd2                                                                           -- ベッド連携コード2

------------------------------------------------------------------------------------------------------------------------------------ 【指示】治療条件
     , ind_va.in_hospital_cd_1           AS ind_va_cd1                                                                            -- VA連携コード1
     , ind_va.in_hospital_cd_2           AS ind_va_cd2                                                                            -- VA連携コード2
     , ind_dialyzer.in_hospital_cd_1     AS ind_dialyzer_cd1                                                                      -- ダイアライザ連携コード1
     , ind_dialyzer.in_hospital_cd_2     AS ind_dialyzer_cd2                                                                      -- ダイアライザ連携コード2
     , ind_dialyzer.in_hospital_cd_3     AS ind_dialyzer_cd3                                                                      -- ダイアライザ連携コード3
     , ind_dialyzer.in_hospital_cd_4     AS ind_dialyzer_cd4                                                                      -- ダイアライザ連携コード4
     , ind_equipment31.in_hospital_cd_1  AS ind_equipment31_cd1                                                                   -- 吸着カラム連携コード1
     , ind_equipment31.in_hospital_cd_2  AS ind_equipment31_cd2                                                                   -- 吸着カラム連携コード2
     , ind_equipment31.in_hospital_cd_3  AS ind_equipment31_cd3                                                                   -- 吸着カラム連携コード3
     , ind_equipment31.in_hospital_cd_4  AS ind_equipment31_cd4                                                                   -- 吸着カラム連携コード4
     , ind_equipment32.in_hospital_cd_1  AS ind_equipment32_cd1                                                                   -- 1次膜連携コード1
     , ind_equipment32.in_hospital_cd_2  AS ind_equipment32_cd2                                                                   -- 1次膜連携コード2
     , ind_equipment32.in_hospital_cd_3  AS ind_equipment32_cd3                                                                   -- 1次膜連携コード3
     , ind_equipment32.in_hospital_cd_4  AS ind_equipment32_cd4                                                                   -- 1次膜連携コード4
     , ind_equipment33.in_hospital_cd_1  AS ind_equipment33_cd1                                                                   -- 2次膜連携コード1
     , ind_equipment33.in_hospital_cd_2  AS ind_equipment33_cd2                                                                   -- 2次膜連携コード2
     , ind_equipment33.in_hospital_cd_3  AS ind_equipment33_cd3                                                                   -- 2次膜連携コード3
     , ind_equipment33.in_hospital_cd_4  AS ind_equipment33_cd4                                                                   -- 2次膜連携コード4
     , ind_equipment34.in_hospital_cd_1  AS ind_equipment34_cd1                                                                   -- 穿刺針（A針）連携コード1
     , ind_equipment34.in_hospital_cd_2  AS ind_equipment34_cd2                                                                   -- 穿刺針（A針）連携コード2
     , ind_equipment34.in_hospital_cd_3  AS ind_equipment34_cd3                                                                   -- 穿刺針（A針）連携コード3
     , ind_equipment34.in_hospital_cd_4  AS ind_equipment34_cd4                                                                   -- 穿刺針（A針）連携コード4
     , ind_equipment35.in_hospital_cd_1  AS ind_equipment35_cd1                                                                   -- 穿刺針（V針）連携コード1
     , ind_equipment35.in_hospital_cd_2  AS ind_equipment35_cd2                                                                   -- 穿刺針（V針）連携コード2
     , ind_equipment35.in_hospital_cd_3  AS ind_equipment35_cd3                                                                   -- 穿刺針（V針）連携コード3
     , ind_equipment35.in_hospital_cd_4  AS ind_equipment35_cd4                                                                   -- 穿刺針（V針）連携コード4
     , ind_equipment36.in_hospital_cd_1  AS ind_equipment36_cd1                                                                   -- 穿刺針（SN）連携コード1
     , ind_equipment36.in_hospital_cd_2  AS ind_equipment36_cd2                                                                   -- 穿刺針（SN）連携コード2
     , ind_equipment36.in_hospital_cd_3  AS ind_equipment36_cd3                                                                   -- 穿刺針（SN）連携コード3
     , ind_equipment36.in_hospital_cd_4  AS ind_equipment36_cd4                                                                   -- 穿刺針（SN）連携コード4
     , ind_equipment37.in_hospital_cd_1  AS ind_equipment37_cd1                                                                   -- 血液回路連携コード1
     , ind_equipment37.in_hospital_cd_2  AS ind_equipment37_cd2                                                                   -- 血液回路連携コード2
     , ind_equipment37.in_hospital_cd_3  AS ind_equipment37_cd3                                                                   -- 血液回路連携コード3
     , ind_equipment37.in_hospital_cd_4  AS ind_equipment37_cd4                                                                   -- 血液回路連携コード4
     , ind_medicine31.in_hospital_cd_1   AS ind_medicine31_cd1                                                                    -- 透析液連携コード1
     , ind_medicine31.in_hospital_cd_2   AS ind_medicine31_cd2                                                                    -- 透析液連携コード2
     , ind_medicine31.in_hospital_cd_3   AS ind_medicine31_cd3                                                                    -- 透析液連携コード3
     , ind_medicine31.in_hospital_cd_4   AS ind_medicine31_cd4                                                                    -- 透析液連携コード4
     , ind_medicine32.in_hospital_cd_1   AS ind_medicine32_cd1                                                                    -- 補液連携コード1
     , ind_medicine32.in_hospital_cd_2   AS ind_medicine32_cd2                                                                    -- 補液連携コード2
     , ind_medicine32.in_hospital_cd_3   AS ind_medicine32_cd3                                                                    -- 補液連携コード3
     , ind_medicine32.in_hospital_cd_4   AS ind_medicine32_cd4                                                                    -- 補液連携コード4
     , ind_medicine33.in_hospital_cd_1   AS ind_medicine33_cd1                                                                    -- 抗凝固剤連携コード1
     , ind_medicine33.in_hospital_cd_2   AS ind_medicine33_cd2                                                                    -- 抗凝固剤連携コード2
     , ind_medicine33.in_hospital_cd_3   AS ind_medicine33_cd3                                                                    -- 抗凝固剤連携コード3
     , ind_medicine33.in_hospital_cd_4   AS ind_medicine33_cd4                                                                    -- 抗凝固剤連携コード4

------------------------------------------------------------------------------------------------------------------------------------ 【指示】投与薬剤
     , ind_procedure1.in_hosp_a_startdate AS ind_procedure1_a_startdate                                                           -- 手技1利用開始日A
     , ind_procedure1.in_hospital_cd_a1   AS ind_procedure1_cd_a1                                                                 -- 手技1連携コードA1
     , ind_procedure1.in_hospital_cd_a2   AS ind_procedure1_cd_a2                                                                 -- 手技1連携コードA2
     , ind_procedure1.in_hosp_b_startdate AS ind_procedure1_b_startdate                                                           -- 手技1利用開始日B
     , ind_procedure1.in_hospital_cd_b1   AS ind_procedure1_cd_b1                                                                 -- 手技1連携コードB1
     , ind_procedure1.in_hospital_cd_b2   AS ind_procedure1_cd_b2                                                                 -- 手技1連携コードB2
     , ind_medicine1.in_hospital_cd_1     AS ind_medicine1_cd1                                                                    -- 薬剤1連携コード1
     , ind_medicine1.in_hospital_cd_2     AS ind_medicine1_cd2                                                                    -- 薬剤1連携コード2
     , ind_medicine1.in_hospital_cd_3     AS ind_medicine1_cd3                                                                    -- 薬剤1連携コード3
     , ind_medicine1.in_hospital_cd_4     AS ind_medicine1_cd4                                                                    -- 薬剤1連携コード4
     , ind_procedure2.in_hosp_a_startdate AS ind_procedure2_a_startdate                                                           -- 手技2利用開始日A
     , ind_procedure2.in_hospital_cd_a1   AS ind_procedure2_cd_a1                                                                 -- 手技2連携コードA1
     , ind_procedure2.in_hospital_cd_a2   AS ind_procedure2_cd_a2                                                                 -- 手技2連携コードA2
     , ind_procedure2.in_hosp_b_startdate AS ind_procedure2_b_startdate                                                           -- 手技2利用開始日B
     , ind_procedure2.in_hospital_cd_b1   AS ind_procedure2_cd_b1                                                                 -- 手技2連携コードB1
     , ind_procedure2.in_hospital_cd_b2   AS ind_procedure2_cd_b2                                                                 -- 手技2連携コードB2
     , ind_medicine2.in_hospital_cd_1     AS ind_medicine2_cd1                                                                    -- 薬剤2連携コード1
     , ind_medicine2.in_hospital_cd_2     AS ind_medicine2_cd2                                                                    -- 薬剤2連携コード2
     , ind_medicine2.in_hospital_cd_3     AS ind_medicine2_cd3                                                                    -- 薬剤2連携コード3
     , ind_medicine2.in_hospital_cd_4     AS ind_medicine2_cd4                                                                    -- 薬剤2連携コード4
     , ind_procedure3.in_hosp_a_startdate AS ind_procedure3_a_startdate                                                           -- 手技3利用開始日A
     , ind_procedure3.in_hospital_cd_a1   AS ind_procedure3_cd_a1                                                                 -- 手技3連携コードA1
     , ind_procedure3.in_hospital_cd_a2   AS ind_procedure3_cd_a2                                                                 -- 手技3連携コードA2
     , ind_procedure3.in_hosp_b_startdate AS ind_procedure3_b_startdate                                                           -- 手技3利用開始日B
     , ind_procedure3.in_hospital_cd_b1   AS ind_procedure3_cd_b1                                                                 -- 手技3連携コードB1
     , ind_procedure3.in_hospital_cd_b2   AS ind_procedure3_cd_b2                                                                 -- 手技3連携コードB2
     , ind_medicine3.in_hospital_cd_1     AS ind_medicine3_cd1                                                                    -- 薬剤3連携コード1
     , ind_medicine3.in_hospital_cd_2     AS ind_medicine3_cd2                                                                    -- 薬剤3連携コード2
     , ind_medicine3.in_hospital_cd_3     AS ind_medicine3_cd3                                                                    -- 薬剤3連携コード3
     , ind_medicine3.in_hospital_cd_4     AS ind_medicine3_cd4                                                                    -- 薬剤3連携コード4
     , ind_procedure4.in_hosp_a_startdate AS ind_procedure4_a_startdate                                                           -- 手技4利用開始日A
     , ind_procedure4.in_hospital_cd_a1   AS ind_procedure4_cd_a1                                                                 -- 手技4連携コードA1
     , ind_procedure4.in_hospital_cd_a2   AS ind_procedure4_cd_a2                                                                 -- 手技4連携コードA2
     , ind_procedure4.in_hosp_b_startdate AS ind_procedure4_b_startdate                                                           -- 手技4利用開始日B
     , ind_procedure4.in_hospital_cd_b1   AS ind_procedure4_cd_b1                                                                 -- 手技4連携コードB1
     , ind_procedure4.in_hospital_cd_b2   AS ind_procedure4_cd_b2                                                                 -- 手技4連携コードB2
     , ind_medicine4.in_hospital_cd_1     AS ind_medicine4_cd1                                                                    -- 薬剤4連携コード1
     , ind_medicine4.in_hospital_cd_2     AS ind_medicine4_cd2                                                                    -- 薬剤4連携コード2
     , ind_medicine4.in_hospital_cd_3     AS ind_medicine4_cd3                                                                    -- 薬剤4連携コード3
     , ind_medicine4.in_hospital_cd_4     AS ind_medicine4_cd4                                                                    -- 薬剤4連携コード4
     , ind_procedure5.in_hosp_a_startdate AS ind_procedure5_a_startdate                                                           -- 手技5利用開始日A
     , ind_procedure5.in_hospital_cd_a1   AS ind_procedure5_cd_a1                                                                 -- 手技5連携コードA1
     , ind_procedure5.in_hospital_cd_a2   AS ind_procedure5_cd_a2                                                                 -- 手技5連携コードA2
     , ind_procedure5.in_hosp_b_startdate AS ind_procedure5_b_startdate                                                           -- 手技5利用開始日B
     , ind_procedure5.in_hospital_cd_b1   AS ind_procedure5_cd_b1                                                                 -- 手技5連携コードB1
     , ind_procedure5.in_hospital_cd_b2   AS ind_procedure5_cd_b2                                                                 -- 手技5連携コードB2
     , ind_medicine5.in_hospital_cd_1     AS ind_medicine5_cd1                                                                    -- 薬剤5連携コード1
     , ind_medicine5.in_hospital_cd_2     AS ind_medicine5_cd2                                                                    -- 薬剤5連携コード2
     , ind_medicine5.in_hospital_cd_3     AS ind_medicine5_cd3                                                                    -- 薬剤5連携コード3
     , ind_medicine5.in_hospital_cd_4     AS ind_medicine5_cd4                                                                    -- 薬剤5連携コード4
     , ind_procedure6.in_hosp_a_startdate AS ind_procedure6_a_startdate                                                           -- 手技6利用開始日A
     , ind_procedure6.in_hospital_cd_a1   AS ind_procedure6_cd_a1                                                                 -- 手技6連携コードA1
     , ind_procedure6.in_hospital_cd_a2   AS ind_procedure6_cd_a2                                                                 -- 手技6連携コードA2
     , ind_procedure6.in_hosp_b_startdate AS ind_procedure6_b_startdate                                                           -- 手技6利用開始日B
     , ind_procedure6.in_hospital_cd_b1   AS ind_procedure6_cd_b1                                                                 -- 手技6連携コードB1
     , ind_procedure6.in_hospital_cd_b2   AS ind_procedure6_cd_b2                                                                 -- 手技6連携コードB2
     , ind_medicine6.in_hospital_cd_1     AS ind_medicine6_cd1                                                                    -- 薬剤6連携コード1
     , ind_medicine6.in_hospital_cd_2     AS ind_medicine6_cd2                                                                    -- 薬剤6連携コード2
     , ind_medicine6.in_hospital_cd_3     AS ind_medicine6_cd3                                                                    -- 薬剤6連携コード3
     , ind_medicine6.in_hospital_cd_4     AS ind_medicine6_cd4                                                                    -- 薬剤6連携コード4
     , ind_procedure7.in_hosp_a_startdate AS ind_procedure7_a_startdate                                                           -- 手技7利用開始日A
     , ind_procedure7.in_hospital_cd_a1   AS ind_procedure7_cd_a1                                                                 -- 手技7連携コードA1
     , ind_procedure7.in_hospital_cd_a2   AS ind_procedure7_cd_a2                                                                 -- 手技7連携コードA2
     , ind_procedure7.in_hosp_b_startdate AS ind_procedure7_b_startdate                                                           -- 手技7利用開始日B
     , ind_procedure7.in_hospital_cd_b1   AS ind_procedure7_cd_b1                                                                 -- 手技7連携コードB1
     , ind_procedure7.in_hospital_cd_b2   AS ind_procedure7_cd_b2                                                                 -- 手技7連携コードB2
     , ind_medicine7.in_hospital_cd_1     AS ind_medicine7_cd1                                                                    -- 薬剤7連携コード1
     , ind_medicine7.in_hospital_cd_2     AS ind_medicine7_cd2                                                                    -- 薬剤7連携コード2
     , ind_medicine7.in_hospital_cd_3     AS ind_medicine7_cd3                                                                    -- 薬剤7連携コード3
     , ind_medicine7.in_hospital_cd_4     AS ind_medicine7_cd4                                                                    -- 薬剤7連携コード4
     , ind_procedure8.in_hosp_a_startdate AS ind_procedure8_a_startdate                                                           -- 手技8利用開始日A
     , ind_procedure8.in_hospital_cd_a1   AS ind_procedure8_cd_a1                                                                 -- 手技8連携コードA1
     , ind_procedure8.in_hospital_cd_a2   AS ind_procedure8_cd_a2                                                                 -- 手技8連携コードA2
     , ind_procedure8.in_hosp_b_startdate AS ind_procedure8_b_startdate                                                           -- 手技8利用開始日B
     , ind_procedure8.in_hospital_cd_b1   AS ind_procedure8_cd_b1                                                                 -- 手技8連携コードB1
     , ind_procedure8.in_hospital_cd_b2   AS ind_procedure8_cd_b2                                                                 -- 手技8連携コードB2
     , ind_medicine8.in_hospital_cd_1     AS ind_medicine8_cd1                                                                    -- 薬剤8連携コード1
     , ind_medicine8.in_hospital_cd_2     AS ind_medicine8_cd2                                                                    -- 薬剤8連携コード2
     , ind_medicine8.in_hospital_cd_3     AS ind_medicine8_cd3                                                                    -- 薬剤8連携コード3
     , ind_medicine8.in_hospital_cd_4     AS ind_medicine8_cd4                                                                    -- 薬剤8連携コード4
     , ind_procedure9.in_hosp_a_startdate AS ind_procedure9_a_startdate                                                           -- 手技9利用開始日A
     , ind_procedure9.in_hospital_cd_a1   AS ind_procedure9_cd_a1                                                                 -- 手技9連携コードA1
     , ind_procedure9.in_hospital_cd_a2   AS ind_procedure9_cd_a2                                                                 -- 手技9連携コードA2
     , ind_procedure9.in_hosp_b_startdate AS ind_procedure9_b_startdate                                                           -- 手技9利用開始日B
     , ind_procedure9.in_hospital_cd_b1   AS ind_procedure9_cd_b1                                                                 -- 手技9連携コードB1
     , ind_procedure9.in_hospital_cd_b2   AS ind_procedure9_cd_b2                                                                 -- 手技9連携コードB2
     , ind_medicine9.in_hospital_cd_1     AS ind_medicine9_cd1                                                                    -- 薬剤9連携コード1
     , ind_medicine9.in_hospital_cd_2     AS ind_medicine9_cd2                                                                    -- 薬剤9連携コード2
     , ind_medicine9.in_hospital_cd_3     AS ind_medicine9_cd3                                                                    -- 薬剤9連携コード3
     , ind_medicine9.in_hospital_cd_4     AS ind_medicine9_cd4                                                                    -- 薬剤9連携コード4
     , ind_procedure10.in_hosp_a_startdate AS ind_procedure10_a_startdate                                                         -- 手技10利用開始日A
     , ind_procedure10.in_hospital_cd_a1   AS ind_procedure10_cd_a1                                                               -- 手技10連携コードA1
     , ind_procedure10.in_hospital_cd_a2   AS ind_procedure10_cd_a2                                                               -- 手技10連携コードA2
     , ind_procedure10.in_hosp_b_startdate AS ind_procedure10_b_startdate                                                         -- 手技10利用開始日B
     , ind_procedure10.in_hospital_cd_b1   AS ind_procedure10_cd_b1                                                               -- 手技10連携コードB1
     , ind_procedure10.in_hospital_cd_b2   AS ind_procedure10_cd_b2                                                               -- 手技10連携コードB2
     , ind_medicine10.in_hospital_cd_1     AS ind_medicine10_cd1                                                                  -- 薬剤10連携コード1
     , ind_medicine10.in_hospital_cd_2     AS ind_medicine10_cd2                                                                  -- 薬剤10連携コード2
     , ind_medicine10.in_hospital_cd_3     AS ind_medicine10_cd3                                                                  -- 薬剤10連携コード3
     , ind_medicine10.in_hospital_cd_4     AS ind_medicine10_cd4                                                                  -- 薬剤10連携コード4
     , ind_procedure11.in_hosp_a_startdate AS ind_procedure11_a_startdate                                                         -- 手技11利用開始日A
     , ind_procedure11.in_hospital_cd_a1   AS ind_procedure11_cd_a1                                                               -- 手技11連携コードA1
     , ind_procedure11.in_hospital_cd_a2   AS ind_procedure11_cd_a2                                                               -- 手技11連携コードA2
     , ind_procedure11.in_hosp_b_startdate AS ind_procedure11_b_startdate                                                         -- 手技11利用開始日B
     , ind_procedure11.in_hospital_cd_b1   AS ind_procedure11_cd_b1                                                               -- 手技11連携コードB1
     , ind_procedure11.in_hospital_cd_b2   AS ind_procedure11_cd_b2                                                               -- 手技11連携コードB2
     , ind_medicine11.in_hospital_cd_1     AS ind_medicine11_cd1                                                                  -- 薬剤11連携コード1
     , ind_medicine11.in_hospital_cd_2     AS ind_medicine11_cd2                                                                  -- 薬剤11連携コード2
     , ind_medicine11.in_hospital_cd_3     AS ind_medicine11_cd3                                                                  -- 薬剤11連携コード3
     , ind_medicine11.in_hospital_cd_4     AS ind_medicine11_cd4                                                                  -- 薬剤11連携コード4
     , ind_procedure12.in_hosp_a_startdate AS ind_procedure12_a_startdate                                                         -- 手技12利用開始日A
     , ind_procedure12.in_hospital_cd_a1   AS ind_procedure12_cd_a1                                                               -- 手技12連携コードA1
     , ind_procedure12.in_hospital_cd_a2   AS ind_procedure12_cd_a2                                                               -- 手技12連携コードA2
     , ind_procedure12.in_hosp_b_startdate AS ind_procedure12_b_startdate                                                         -- 手技12利用開始日B
     , ind_procedure12.in_hospital_cd_b1   AS ind_procedure12_cd_b1                                                               -- 手技12連携コードB1
     , ind_procedure12.in_hospital_cd_b2   AS ind_procedure12_cd_b2                                                               -- 手技12連携コードB2
     , ind_medicine12.in_hospital_cd_1     AS ind_medicine12_cd1                                                                  -- 薬剤12連携コード1
     , ind_medicine12.in_hospital_cd_2     AS ind_medicine12_cd2                                                                  -- 薬剤12連携コード2
     , ind_medicine12.in_hospital_cd_3     AS ind_medicine12_cd3                                                                  -- 薬剤12連携コード3
     , ind_medicine12.in_hospital_cd_4     AS ind_medicine12_cd4                                                                  -- 薬剤12連携コード4
     , ind_procedure13.in_hosp_a_startdate AS ind_procedure13_a_startdate                                                         -- 手技13利用開始日A
     , ind_procedure13.in_hospital_cd_a1   AS ind_procedure13_cd_a1                                                               -- 手技13連携コードA1
     , ind_procedure13.in_hospital_cd_a2   AS ind_procedure13_cd_a2                                                               -- 手技13連携コードA2
     , ind_procedure13.in_hosp_b_startdate AS ind_procedure13_b_startdate                                                         -- 手技13利用開始日B
     , ind_procedure13.in_hospital_cd_b1   AS ind_procedure13_cd_b1                                                               -- 手技13連携コードB1
     , ind_procedure13.in_hospital_cd_b2   AS ind_procedure13_cd_b2                                                               -- 手技13連携コードB2
     , ind_medicine13.in_hospital_cd_1     AS ind_medicine13_cd1                                                                  -- 薬剤13連携コード1
     , ind_medicine13.in_hospital_cd_2     AS ind_medicine13_cd2                                                                  -- 薬剤13連携コード2
     , ind_medicine13.in_hospital_cd_3     AS ind_medicine13_cd3                                                                  -- 薬剤13連携コード3
     , ind_medicine13.in_hospital_cd_4     AS ind_medicine13_cd4                                                                  -- 薬剤13連携コード4
     , ind_procedure14.in_hosp_a_startdate AS ind_procedure14_a_startdate                                                         -- 手技14利用開始日A
     , ind_procedure14.in_hospital_cd_a1   AS ind_procedure14_cd_a1                                                               -- 手技14連携コードA1
     , ind_procedure14.in_hospital_cd_a2   AS ind_procedure14_cd_a2                                                               -- 手技14連携コードA2
     , ind_procedure14.in_hosp_b_startdate AS ind_procedure14_b_startdate                                                         -- 手技14利用開始日B
     , ind_procedure14.in_hospital_cd_b1   AS ind_procedure14_cd_b1                                                               -- 手技14連携コードB1
     , ind_procedure14.in_hospital_cd_b2   AS ind_procedure14_cd_b2                                                               -- 手技14連携コードB2
     , ind_medicine14.in_hospital_cd_1     AS ind_medicine14_cd1                                                                  -- 薬剤14連携コード1
     , ind_medicine14.in_hospital_cd_2     AS ind_medicine14_cd2                                                                  -- 薬剤14連携コード2
     , ind_medicine14.in_hospital_cd_3     AS ind_medicine14_cd3                                                                  -- 薬剤14連携コード3
     , ind_medicine14.in_hospital_cd_4     AS ind_medicine14_cd4                                                                  -- 薬剤14連携コード4
     , ind_procedure15.in_hosp_a_startdate AS ind_procedure15_a_startdate                                                         -- 手技15利用開始日A
     , ind_procedure15.in_hospital_cd_a1   AS ind_procedure15_cd_a1                                                               -- 手技15連携コードA1
     , ind_procedure15.in_hospital_cd_a2   AS ind_procedure15_cd_a2                                                               -- 手技15連携コードA2
     , ind_procedure15.in_hosp_b_startdate AS ind_procedure15_b_startdate                                                         -- 手技15利用開始日B
     , ind_procedure15.in_hospital_cd_b1   AS ind_procedure15_cd_b1                                                               -- 手技15連携コードB1
     , ind_procedure15.in_hospital_cd_b2   AS ind_procedure15_cd_b2                                                               -- 手技15連携コードB2
     , ind_medicine15.in_hospital_cd_1     AS ind_medicine15_cd1                                                                  -- 薬剤15連携コード1
     , ind_medicine15.in_hospital_cd_2     AS ind_medicine15_cd2                                                                  -- 薬剤15連携コード2
     , ind_medicine15.in_hospital_cd_3     AS ind_medicine15_cd3                                                                  -- 薬剤15連携コード3
     , ind_medicine15.in_hospital_cd_4     AS ind_medicine15_cd4                                                                  -- 薬剤15連携コード4
     , ind_procedure16.in_hosp_a_startdate AS ind_procedure16_a_startdate                                                         -- 手技16利用開始日A
     , ind_procedure16.in_hospital_cd_a1   AS ind_procedure16_cd_a1                                                               -- 手技16連携コードA1
     , ind_procedure16.in_hospital_cd_a2   AS ind_procedure16_cd_a2                                                               -- 手技16連携コードA2
     , ind_procedure16.in_hosp_b_startdate AS ind_procedure16_b_startdate                                                         -- 手技16利用開始日B
     , ind_procedure16.in_hospital_cd_b1   AS ind_procedure16_cd_b1                                                               -- 手技16連携コードB1
     , ind_procedure16.in_hospital_cd_b2   AS ind_procedure16_cd_b2                                                               -- 手技16連携コードB2
     , ind_medicine16.in_hospital_cd_1     AS ind_medicine16_cd1                                                                  -- 薬剤16連携コード1
     , ind_medicine16.in_hospital_cd_2     AS ind_medicine16_cd2                                                                  -- 薬剤16連携コード2
     , ind_medicine16.in_hospital_cd_3     AS ind_medicine16_cd3                                                                  -- 薬剤16連携コード3
     , ind_medicine16.in_hospital_cd_4     AS ind_medicine16_cd4                                                                  -- 薬剤16連携コード4
     , ind_procedure17.in_hosp_a_startdate AS ind_procedure17_a_startdate                                                         -- 手技17利用開始日A
     , ind_procedure17.in_hospital_cd_a1   AS ind_procedure17_cd_a1                                                               -- 手技17連携コードA1
     , ind_procedure17.in_hospital_cd_a2   AS ind_procedure17_cd_a2                                                               -- 手技17連携コードA2
     , ind_procedure17.in_hosp_b_startdate AS ind_procedure17_b_startdate                                                         -- 手技17利用開始日B
     , ind_procedure17.in_hospital_cd_b1   AS ind_procedure17_cd_b1                                                               -- 手技17連携コードB1
     , ind_procedure17.in_hospital_cd_b2   AS ind_procedure17_cd_b2                                                               -- 手技17連携コードB2
     , ind_medicine17.in_hospital_cd_1     AS ind_medicine17_cd1                                                                  -- 薬剤17連携コード1
     , ind_medicine17.in_hospital_cd_2     AS ind_medicine17_cd2                                                                  -- 薬剤17連携コード2
     , ind_medicine17.in_hospital_cd_3     AS ind_medicine17_cd3                                                                  -- 薬剤17連携コード3
     , ind_medicine17.in_hospital_cd_4     AS ind_medicine17_cd4                                                                  -- 薬剤17連携コード4
     , ind_procedure18.in_hosp_a_startdate AS ind_procedure18_a_startdate                                                         -- 手技18利用開始日A
     , ind_procedure18.in_hospital_cd_a1   AS ind_procedure18_cd_a1                                                               -- 手技18連携コードA1
     , ind_procedure18.in_hospital_cd_a2   AS ind_procedure18_cd_a2                                                               -- 手技18連携コードA2
     , ind_procedure18.in_hosp_b_startdate AS ind_procedure18_b_startdate                                                         -- 手技18利用開始日B
     , ind_procedure18.in_hospital_cd_b1   AS ind_procedure18_cd_b1                                                               -- 手技18連携コードB1
     , ind_procedure18.in_hospital_cd_b2   AS ind_procedure18_cd_b2                                                               -- 手技18連携コードB2
     , ind_medicine18.in_hospital_cd_1     AS ind_medicine18_cd1                                                                  -- 薬剤18連携コード1
     , ind_medicine18.in_hospital_cd_2     AS ind_medicine18_cd2                                                                  -- 薬剤18連携コード2
     , ind_medicine18.in_hospital_cd_3     AS ind_medicine18_cd3                                                                  -- 薬剤18連携コード3
     , ind_medicine18.in_hospital_cd_4     AS ind_medicine18_cd4                                                                  -- 薬剤18連携コード4
     , ind_procedure19.in_hosp_a_startdate AS ind_procedure19_a_startdate                                                         -- 手技19利用開始日A
     , ind_procedure19.in_hospital_cd_a1   AS ind_procedure19_cd_a1                                                               -- 手技19連携コードA1
     , ind_procedure19.in_hospital_cd_a2   AS ind_procedure19_cd_a2                                                               -- 手技19連携コードA2
     , ind_procedure19.in_hosp_b_startdate AS ind_procedure19_b_startdate                                                         -- 手技19利用開始日B
     , ind_procedure19.in_hospital_cd_b1   AS ind_procedure19_cd_b1                                                               -- 手技19連携コードB1
     , ind_procedure19.in_hospital_cd_b2   AS ind_procedure19_cd_b2                                                               -- 手技19連携コードB2
     , ind_medicine19.in_hospital_cd_1     AS ind_medicine19_cd1                                                                  -- 薬剤19連携コード1
     , ind_medicine19.in_hospital_cd_2     AS ind_medicine19_cd2                                                                  -- 薬剤19連携コード2
     , ind_medicine19.in_hospital_cd_3     AS ind_medicine19_cd3                                                                  -- 薬剤19連携コード3
     , ind_medicine19.in_hospital_cd_4     AS ind_medicine19_cd4                                                                  -- 薬剤19連携コード4
     , ind_procedure20.in_hosp_a_startdate AS ind_procedure20_a_startdate                                                         -- 手技20利用開始日A
     , ind_procedure20.in_hospital_cd_a1   AS ind_procedure20_cd_a1                                                               -- 手技20連携コードA1
     , ind_procedure20.in_hospital_cd_a2   AS ind_procedure20_cd_a2                                                               -- 手技20連携コードA2
     , ind_procedure20.in_hosp_b_startdate AS ind_procedure20_b_startdate                                                         -- 手技20利用開始日B
     , ind_procedure20.in_hospital_cd_b1   AS ind_procedure20_cd_b1                                                               -- 手技20連携コードB1
     , ind_procedure20.in_hospital_cd_b2   AS ind_procedure20_cd_b2                                                               -- 手技20連携コードB2
     , ind_medicine20.in_hospital_cd_1     AS ind_medicine20_cd1                                                                  -- 薬剤20連携コード1
     , ind_medicine20.in_hospital_cd_2     AS ind_medicine20_cd2                                                                  -- 薬剤20連携コード2
     , ind_medicine20.in_hospital_cd_3     AS ind_medicine20_cd3                                                                  -- 薬剤20連携コード3
     , ind_medicine20.in_hospital_cd_4     AS ind_medicine20_cd4                                                                  -- 薬剤20連携コード4

------------------------------------------------------------------------------------------------------------------------------------ 【指示】医療材料
     , ind_equipment1.in_hospital_cd_1  AS ind_equipment1_cd1                                                                     -- 医材1連携コード1
     , ind_equipment1.in_hospital_cd_2  AS ind_equipment1_cd2                                                                     -- 医材1連携コード2
     , ind_equipment1.in_hospital_cd_3  AS ind_equipment1_cd3                                                                     -- 医材1連携コード3
     , ind_equipment1.in_hospital_cd_4  AS ind_equipment1_cd4                                                                     -- 医材1連携コード4
     , ind_equipment2.in_hospital_cd_1  AS ind_equipment2_cd1                                                                     -- 医材2連携コード1
     , ind_equipment2.in_hospital_cd_2  AS ind_equipment2_cd2                                                                     -- 医材2連携コード2
     , ind_equipment2.in_hospital_cd_3  AS ind_equipment2_cd3                                                                     -- 医材2連携コード3
     , ind_equipment2.in_hospital_cd_4  AS ind_equipment2_cd4                                                                     -- 医材2連携コード4
     , ind_equipment3.in_hospital_cd_1  AS ind_equipment3_cd1                                                                     -- 医材3連携コード1
     , ind_equipment3.in_hospital_cd_2  AS ind_equipment3_cd2                                                                     -- 医材3連携コード2
     , ind_equipment3.in_hospital_cd_3  AS ind_equipment3_cd3                                                                     -- 医材3連携コード3
     , ind_equipment3.in_hospital_cd_4  AS ind_equipment3_cd4                                                                     -- 医材3連携コード4
     , ind_equipment4.in_hospital_cd_1  AS ind_equipment4_cd1                                                                     -- 医材4連携コード1
     , ind_equipment4.in_hospital_cd_2  AS ind_equipment4_cd2                                                                     -- 医材4連携コード2
     , ind_equipment4.in_hospital_cd_3  AS ind_equipment4_cd3                                                                     -- 医材4連携コード3
     , ind_equipment4.in_hospital_cd_4  AS ind_equipment4_cd4                                                                     -- 医材4連携コード4
     , ind_equipment5.in_hospital_cd_1  AS ind_equipment5_cd1                                                                     -- 医材5連携コード1
     , ind_equipment5.in_hospital_cd_2  AS ind_equipment5_cd2                                                                     -- 医材5連携コード2
     , ind_equipment5.in_hospital_cd_3  AS ind_equipment5_cd3                                                                     -- 医材5連携コード3
     , ind_equipment5.in_hospital_cd_4  AS ind_equipment5_cd4                                                                     -- 医材5連携コード4
     , ind_equipment6.in_hospital_cd_1  AS ind_equipment6_cd1                                                                     -- 医材6連携コード1
     , ind_equipment6.in_hospital_cd_2  AS ind_equipment6_cd2                                                                     -- 医材6連携コード2
     , ind_equipment6.in_hospital_cd_3  AS ind_equipment6_cd3                                                                     -- 医材6連携コード3
     , ind_equipment6.in_hospital_cd_4  AS ind_equipment6_cd4                                                                     -- 医材6連携コード4
     , ind_equipment7.in_hospital_cd_1  AS ind_equipment7_cd1                                                                     -- 医材7連携コード1
     , ind_equipment7.in_hospital_cd_2  AS ind_equipment7_cd2                                                                     -- 医材7連携コード2
     , ind_equipment7.in_hospital_cd_3  AS ind_equipment7_cd3                                                                     -- 医材7連携コード3
     , ind_equipment7.in_hospital_cd_4  AS ind_equipment7_cd4                                                                     -- 医材7連携コード4
     , ind_equipment8.in_hospital_cd_1  AS ind_equipment8_cd1                                                                     -- 医材8連携コード1
     , ind_equipment8.in_hospital_cd_2  AS ind_equipment8_cd2                                                                     -- 医材8連携コード2
     , ind_equipment8.in_hospital_cd_3  AS ind_equipment8_cd3                                                                     -- 医材8連携コード3
     , ind_equipment8.in_hospital_cd_4  AS ind_equipment8_cd4                                                                     -- 医材8連携コード4
     , ind_equipment9.in_hospital_cd_1  AS ind_equipment9_cd1                                                                     -- 医材9連携コード1
     , ind_equipment9.in_hospital_cd_2  AS ind_equipment9_cd2                                                                     -- 医材9連携コード2
     , ind_equipment9.in_hospital_cd_3  AS ind_equipment9_cd3                                                                     -- 医材9連携コード3
     , ind_equipment9.in_hospital_cd_4  AS ind_equipment9_cd4                                                                     -- 医材9連携コード4
     , ind_equipment10.in_hospital_cd_1 AS ind_equipment10_cd1                                                                    -- 医材10連携コード1
     , ind_equipment10.in_hospital_cd_2 AS ind_equipment10_cd2                                                                    -- 医材10連携コード2
     , ind_equipment10.in_hospital_cd_3 AS ind_equipment10_cd3                                                                    -- 医材10連携コード3
     , ind_equipment10.in_hospital_cd_4 AS ind_equipment10_cd4                                                                    -- 医材10連携コード4
     , ind_equipment11.in_hospital_cd_1 AS ind_equipment11_cd1                                                                    -- 医材11連携コード1
     , ind_equipment11.in_hospital_cd_2 AS ind_equipment11_cd2                                                                    -- 医材11連携コード2
     , ind_equipment11.in_hospital_cd_3 AS ind_equipment11_cd3                                                                    -- 医材11連携コード3
     , ind_equipment11.in_hospital_cd_4 AS ind_equipment11_cd4                                                                    -- 医材11連携コード4
     , ind_equipment12.in_hospital_cd_1 AS ind_equipment12_cd1                                                                    -- 医材12連携コード1
     , ind_equipment12.in_hospital_cd_2 AS ind_equipment12_cd2                                                                    -- 医材12連携コード2
     , ind_equipment12.in_hospital_cd_3 AS ind_equipment12_cd3                                                                    -- 医材12連携コード3
     , ind_equipment12.in_hospital_cd_4 AS ind_equipment12_cd4                                                                    -- 医材12連携コード4
     , ind_equipment13.in_hospital_cd_1 AS ind_equipment13_cd1                                                                    -- 医材13連携コード1
     , ind_equipment13.in_hospital_cd_2 AS ind_equipment13_cd2                                                                    -- 医材13連携コード2
     , ind_equipment13.in_hospital_cd_3 AS ind_equipment13_cd3                                                                    -- 医材13連携コード3
     , ind_equipment13.in_hospital_cd_4 AS ind_equipment13_cd4                                                                    -- 医材13連携コード4
     , ind_equipment14.in_hospital_cd_1 AS ind_equipment14_cd1                                                                    -- 医材14連携コード1
     , ind_equipment14.in_hospital_cd_2 AS ind_equipment14_cd2                                                                    -- 医材14連携コード2
     , ind_equipment14.in_hospital_cd_3 AS ind_equipment14_cd3                                                                    -- 医材14連携コード3
     , ind_equipment14.in_hospital_cd_4 AS ind_equipment14_cd4                                                                    -- 医材14連携コード4
     , ind_equipment15.in_hospital_cd_1 AS ind_equipment15_cd1                                                                    -- 医材15連携コード1
     , ind_equipment15.in_hospital_cd_2 AS ind_equipment15_cd2                                                                    -- 医材15連携コード2
     , ind_equipment15.in_hospital_cd_3 AS ind_equipment15_cd3                                                                    -- 医材15連携コード3
     , ind_equipment15.in_hospital_cd_4 AS ind_equipment15_cd4                                                                    -- 医材15連携コード4
     , ind_equipment16.in_hospital_cd_1 AS ind_equipment16_cd1                                                                    -- 医材16連携コード1
     , ind_equipment16.in_hospital_cd_2 AS ind_equipment16_cd2                                                                    -- 医材16連携コード2
     , ind_equipment16.in_hospital_cd_3 AS ind_equipment16_cd3                                                                    -- 医材16連携コード3
     , ind_equipment16.in_hospital_cd_4 AS ind_equipment16_cd4                                                                    -- 医材16連携コード4
     , ind_equipment17.in_hospital_cd_1 AS ind_equipment17_cd1                                                                    -- 医材17連携コード1
     , ind_equipment17.in_hospital_cd_2 AS ind_equipment17_cd2                                                                    -- 医材17連携コード2
     , ind_equipment17.in_hospital_cd_3 AS ind_equipment17_cd3                                                                    -- 医材17連携コード3
     , ind_equipment17.in_hospital_cd_4 AS ind_equipment17_cd4                                                                    -- 医材17連携コード4
     , ind_equipment18.in_hospital_cd_1 AS ind_equipment18_cd1                                                                    -- 医材18連携コード1
     , ind_equipment18.in_hospital_cd_2 AS ind_equipment18_cd2                                                                    -- 医材18連携コード2
     , ind_equipment18.in_hospital_cd_3 AS ind_equipment18_cd3                                                                    -- 医材18連携コード3
     , ind_equipment18.in_hospital_cd_4 AS ind_equipment18_cd4                                                                    -- 医材18連携コード4
     , ind_equipment19.in_hospital_cd_1 AS ind_equipment19_cd1                                                                    -- 医材19連携コード1
     , ind_equipment19.in_hospital_cd_2 AS ind_equipment19_cd2                                                                    -- 医材19連携コード2
     , ind_equipment19.in_hospital_cd_3 AS ind_equipment19_cd3                                                                    -- 医材19連携コード3
     , ind_equipment19.in_hospital_cd_4 AS ind_equipment19_cd4                                                                    -- 医材19連携コード4
     , ind_equipment20.in_hospital_cd_1 AS ind_equipment20_cd1                                                                    -- 医材20連携コード1
     , ind_equipment20.in_hospital_cd_2 AS ind_equipment20_cd2                                                                    -- 医材20連携コード2
     , ind_equipment20.in_hospital_cd_3 AS ind_equipment20_cd3                                                                    -- 医材20連携コード3
     , ind_equipment20.in_hospital_cd_4 AS ind_equipment20_cd4                                                                    -- 医材20連携コード4

------------------------------------------------------------------------------------------------------------------------------------ 【実績】実績情報
     , rst_treatment.in_hosp_a_startdate AS rst_treatment_a_startdate                                                             -- 治療方法利用開始日A
     , rst_treatment.in_hospital_cd_a1   AS rst_treatment_cd_a1                                                                   -- 治療方法連携コードA1
     , rst_treatment.in_hospital_cd_a2   AS rst_treatment_cd_a2                                                                   -- 治療方法連携コードA2
     , rst_treatment.in_hospital_cd_a3   AS rst_treatment_cd_a3                                                                   -- 治療方法連携コードA3
     , rst_treatment.in_hospital_cd_a4   AS rst_treatment_cd_a4                                                                   -- 治療方法連携コードA4
     , rst_treatment.in_hosp_b_startdate AS rst_treatment_b_startdate                                                             -- 治療方法利用開始日B
     , rst_treatment.in_hospital_cd_b1   AS rst_treatment_cd_b1                                                                   -- 治療方法連携コードB1
     , rst_treatment.in_hospital_cd_b2   AS rst_treatment_cd_b2                                                                   -- 治療方法連携コードB2
     , rst_treatment.in_hospital_cd_b3   AS rst_treatment_cd_b3                                                                   -- 治療方法連携コードB3
     , rst_treatment.in_hospital_cd_b4   AS rst_treatment_cd_b4                                                                   -- 治療方法連携コードB4
     , rst_kur.in_hospital_cd_1          AS rst_kur_cd1                                                                           -- クール連携コード1
     , rst_bed.in_hospital_cd_1          AS rst_bed_cd1                                                                           -- ベッド連携コード1
     , rst_bed.in_hospital_cd_2          AS rst_bed_cd2                                                                           -- ベッド連携コード2
     , mst_ward.in_hospital_cd_1         AS rst_ward_cd1                                                                          -- 病棟連携コード
     , mst_course.in_hospital_cd_1       AS rst_course_cd1                                                                        -- 診療科連携コード

------------------------------------------------------------------------------------------------------------------------------------ 【実績】加算情報
     , addition1.in_hospital_cd_1        AS addition1_cd1                                                                         -- 算定加算1連携コード1
     , addition1.in_hospital_cd_2        AS addition1_cd2                                                                         -- 算定加算1連携コード2
     , addition1.in_hospital_cd_3        AS addition1_cd3                                                                         -- 算定加算1連携コード3
     , addition2.in_hospital_cd_1        AS addition2_cd1                                                                         -- 算定加算2連携コード1
     , addition2.in_hospital_cd_2        AS addition2_cd2                                                                         -- 算定加算2連携コード2
     , addition2.in_hospital_cd_3        AS addition2_cd3                                                                         -- 算定加算2連携コード3
     , addition3.in_hospital_cd_1        AS addition3_cd1                                                                         -- 算定加算3連携コード1
     , addition3.in_hospital_cd_2        AS addition3_cd2                                                                         -- 算定加算3連携コード2
     , addition3.in_hospital_cd_3        AS addition3_cd3                                                                         -- 算定加算3連携コード3
     , addition4.in_hospital_cd_1        AS addition4_cd1                                                                         -- 算定加算4連携コード1
     , addition4.in_hospital_cd_2        AS addition4_cd2                                                                         -- 算定加算4連携コード2
     , addition4.in_hospital_cd_3        AS addition4_cd3                                                                         -- 算定加算4連携コード3
     , addition5.in_hospital_cd_1        AS addition5_cd1                                                                         -- 算定加算5連携コード1
     , addition5.in_hospital_cd_2        AS addition5_cd2                                                                         -- 算定加算5連携コード2
     , addition5.in_hospital_cd_3        AS addition5_cd3                                                                         -- 算定加算5連携コード3
     , addition6.in_hospital_cd_1        AS addition6_cd1                                                                         -- 算定加算6連携コード1
     , addition6.in_hospital_cd_2        AS addition6_cd2                                                                         -- 算定加算6連携コード2
     , addition6.in_hospital_cd_3        AS addition6_cd3                                                                         -- 算定加算6連携コード3
     , addition7.in_hospital_cd_1        AS addition7_cd1                                                                         -- 算定加算7連携コード1
     , addition7.in_hospital_cd_2        AS addition7_cd2                                                                         -- 算定加算7連携コード2
     , addition7.in_hospital_cd_3        AS addition7_cd3                                                                         -- 算定加算7連携コード3
     , addition8.in_hospital_cd_1        AS addition8_cd1                                                                         -- 算定加算8連携コード1
     , addition8.in_hospital_cd_2        AS addition8_cd2                                                                         -- 算定加算8連携コード2
     , addition8.in_hospital_cd_3        AS addition8_cd3                                                                         -- 算定加算8連携コード3
     , addition9.in_hospital_cd_1        AS addition9_cd1                                                                         -- 算定加算9連携コード1
     , addition9.in_hospital_cd_2        AS addition9_cd2                                                                         -- 算定加算9連携コード2
     , addition9.in_hospital_cd_3        AS addition9_cd3                                                                         -- 算定加算9連携コード3
     , addition10.in_hospital_cd_1       AS addition10_cd1                                                                        -- 算定加算10連携コード1
     , addition10.in_hospital_cd_2       AS addition10_cd2                                                                        -- 算定加算10連携コード2
     , addition10.in_hospital_cd_3       AS addition10_cd3                                                                        -- 算定加算10連携コード3

------------------------------------------------------------------------------------------------------------------------------------ 【実績】治療条件
     , rst_va.in_hospital_cd_1           AS rst_va_cd1                                                                            -- VA連携コード１
     , rst_va.in_hospital_cd_2           AS rst_va_cd2                                                                            -- VA連携コード１
     , rst_dialyzer.in_hospital_cd_1     AS rst_dialyzer_cd1                                                                      -- ダイアライザ連携コード1
     , rst_dialyzer.in_hospital_cd_2     AS rst_dialyzer_cd2                                                                      -- ダイアライザ連携コード2
     , rst_dialyzer.in_hospital_cd_3     AS rst_dialyzer_cd3                                                                      -- ダイアライザ連携コード3
     , rst_dialyzer.in_hospital_cd_4     AS rst_dialyzer_cd4                                                                      -- ダイアライザ連携コード4
     , rst_equipment31.in_hospital_cd_1  AS rst_equipment31_cd1                                                                   -- 吸着カラム連携コード1
     , rst_equipment31.in_hospital_cd_2  AS rst_equipment31_cd2                                                                   -- 吸着カラム連携コード2
     , rst_equipment31.in_hospital_cd_3  AS rst_equipment31_cd3                                                                   -- 吸着カラム連携コード3
     , rst_equipment31.in_hospital_cd_4  AS rst_equipment31_cd4                                                                   -- 吸着カラム連携コード4
     , rst_equipment32.in_hospital_cd_1  AS rst_equipment32_cd1                                                                   -- 1次膜連携コード1
     , rst_equipment32.in_hospital_cd_2  AS rst_equipment32_cd2                                                                   -- 1次膜連携コード2
     , rst_equipment32.in_hospital_cd_3  AS rst_equipment32_cd3                                                                   -- 1次膜連携コード3
     , rst_equipment32.in_hospital_cd_4  AS rst_equipment32_cd4                                                                   -- 1次膜連携コード4
     , rst_equipment33.in_hospital_cd_1  AS rst_equipment33_cd1                                                                   -- 2次膜連携コード1
     , rst_equipment33.in_hospital_cd_2  AS rst_equipment33_cd2                                                                   -- 2次膜連携コード2
     , rst_equipment33.in_hospital_cd_3  AS rst_equipment33_cd3                                                                   -- 2次膜連携コード3
     , rst_equipment33.in_hospital_cd_4  AS rst_equipment33_cd4                                                                   -- 2次膜連携コード4
     , rst_equipment34.in_hospital_cd_1  AS rst_equipment34_cd1                                                                   -- 穿刺針（A針）連携コード1
     , rst_equipment34.in_hospital_cd_2  AS rst_equipment34_cd2                                                                   -- 穿刺針（A針）連携コード2
     , rst_equipment34.in_hospital_cd_3  AS rst_equipment34_cd3                                                                   -- 穿刺針（A針）連携コード3
     , rst_equipment34.in_hospital_cd_4  AS rst_equipment34_cd4                                                                   -- 穿刺針（A針）連携コード4
     , rst_equipment35.in_hospital_cd_1  AS rst_equipment35_cd1                                                                   -- 穿刺針（V針）連携コード1
     , rst_equipment35.in_hospital_cd_2  AS rst_equipment35_cd2                                                                   -- 穿刺針（V針）連携コード2
     , rst_equipment35.in_hospital_cd_3  AS rst_equipment35_cd3                                                                   -- 穿刺針（V針）連携コード3
     , rst_equipment35.in_hospital_cd_4  AS rst_equipment35_cd4                                                                   -- 穿刺針（V針）連携コード4
     , rst_equipment36.in_hospital_cd_1  AS rst_equipment36_cd1                                                                   -- 穿刺針（SN）連携コード1
     , rst_equipment36.in_hospital_cd_2  AS rst_equipment36_cd2                                                                   -- 穿刺針（SN）連携コード2
     , rst_equipment36.in_hospital_cd_3  AS rst_equipment36_cd3                                                                   -- 穿刺針（SN）連携コード3
     , rst_equipment36.in_hospital_cd_4  AS rst_equipment36_cd4                                                                   -- 穿刺針（SN）連携コード4
     , rst_equipment37.in_hospital_cd_1  AS rst_equipment37_cd1                                                                   -- 血液回路連携コード1
     , rst_equipment37.in_hospital_cd_2  AS rst_equipment37_cd2                                                                   -- 血液回路連携コード2
     , rst_equipment37.in_hospital_cd_3  AS rst_equipment37_cd3                                                                   -- 血液回路連携コード3
     , rst_equipment37.in_hospital_cd_4  AS rst_equipment37_cd4                                                                   -- 血液回路連携コード4
     , rst_medicine31.in_hospital_cd_1   AS rst_medicine31_cd1                                                                    -- 透析液連携コード1
     , rst_medicine31.in_hospital_cd_2   AS rst_medicine31_cd2                                                                    -- 透析液連携コード2
     , rst_medicine31.in_hospital_cd_3   AS rst_medicine31_cd3                                                                    -- 透析液連携コード3
     , rst_medicine31.in_hospital_cd_4   AS rst_medicine31_cd4                                                                    -- 透析液連携コード4
     , rst_medicine32.in_hospital_cd_1   AS rst_medicine32_cd1                                                                    -- 補液連携コード1
     , rst_medicine32.in_hospital_cd_2   AS rst_medicine32_cd2                                                                    -- 補液連携コード2
     , rst_medicine32.in_hospital_cd_3   AS rst_medicine32_cd3                                                                    -- 補液連携コード3
     , rst_medicine32.in_hospital_cd_4   AS rst_medicine32_cd4                                                                    -- 補液連携コード4
     , rst_medicine33.in_hospital_cd_1   AS rst_medicine33_cd1                                                                    -- 抗凝固剤連携コード1
     , rst_medicine33.in_hospital_cd_2   AS rst_medicine33_cd2                                                                    -- 抗凝固剤連携コード2
     , rst_medicine33.in_hospital_cd_3   AS rst_medicine33_cd3                                                                    -- 抗凝固剤連携コード3
     , rst_medicine33.in_hospital_cd_4   AS rst_medicine33_cd4                                                                    -- 抗凝固剤連携コード4

------------------------------------------------------------------------------------------------------------------------------------ 【実績】投与薬剤
     , rst_procedure1.in_hosp_a_startdate AS rst_procedure1_a_startdate                                                           -- 手技1利用開始日A
     , rst_procedure1.in_hospital_cd_a1   AS rst_procedure1_cd_a1                                                                 -- 手技1連携コードA1
     , rst_procedure1.in_hospital_cd_a2   AS rst_procedure1_cd_a2                                                                 -- 手技1連携コードA2
     , rst_procedure1.in_hosp_b_startdate AS rst_procedure1_b_startdate                                                           -- 手技1利用開始日B
     , rst_procedure1.in_hospital_cd_b1   AS rst_procedure1_cd_b1                                                                 -- 手技1連携コードB1
     , rst_procedure1.in_hospital_cd_b2   AS rst_procedure1_cd_b2                                                                 -- 手技1連携コードB2
     , rst_medicine1.in_hospital_cd_1     AS rst_medicine1_cd1                                                                    -- 薬剤1連携コード1
     , rst_medicine1.in_hospital_cd_2     AS rst_medicine1_cd2                                                                    -- 薬剤1連携コード2
     , rst_medicine1.in_hospital_cd_3     AS rst_medicine1_cd3                                                                    -- 薬剤1連携コード3
     , rst_medicine1.in_hospital_cd_4     AS rst_medicine1_cd4                                                                    -- 薬剤1連携コード4
     , rst_procedure2.in_hosp_a_startdate AS rst_procedure2_a_startdate                                                           -- 手技2利用開始日A
     , rst_procedure2.in_hospital_cd_a1   AS rst_procedure2_cd_a1                                                                 -- 手技2連携コードA1
     , rst_procedure2.in_hospital_cd_a2   AS rst_procedure2_cd_a2                                                                 -- 手技2連携コードA2
     , rst_procedure2.in_hosp_b_startdate AS rst_procedure2_b_startdate                                                           -- 手技2利用開始日B
     , rst_procedure2.in_hospital_cd_b1   AS rst_procedure2_cd_b1                                                                 -- 手技2連携コードB1
     , rst_procedure2.in_hospital_cd_b2   AS rst_procedure2_cd_b2                                                                 -- 手技2連携コードB2
     , rst_medicine2.in_hospital_cd_1     AS rst_medicine2_cd1                                                                    -- 薬剤2連携コード1
     , rst_medicine2.in_hospital_cd_2     AS rst_medicine2_cd2                                                                    -- 薬剤2連携コード2
     , rst_medicine2.in_hospital_cd_3     AS rst_medicine2_cd3                                                                    -- 薬剤2連携コード3
     , rst_medicine2.in_hospital_cd_4     AS rst_medicine2_cd4                                                                    -- 薬剤2連携コード4
     , rst_procedure3.in_hosp_a_startdate AS rst_procedure3_a_startdate                                                           -- 手技3利用開始日A
     , rst_procedure3.in_hospital_cd_a1   AS rst_procedure3_cd_a1                                                                 -- 手技3連携コードA1
     , rst_procedure3.in_hospital_cd_a2   AS rst_procedure3_cd_a2                                                                 -- 手技3連携コードA2
     , rst_procedure3.in_hosp_b_startdate AS rst_procedure3_b_startdate                                                           -- 手技3利用開始日B
     , rst_procedure3.in_hospital_cd_b1   AS rst_procedure3_cd_b1                                                                 -- 手技3連携コードB1
     , rst_procedure3.in_hospital_cd_b2   AS rst_procedure3_cd_b2                                                                 -- 手技3連携コードB2
     , rst_medicine3.in_hospital_cd_1     AS rst_medicine3_cd1                                                                    -- 薬剤3連携コード1
     , rst_medicine3.in_hospital_cd_2     AS rst_medicine3_cd2                                                                    -- 薬剤3連携コード2
     , rst_medicine3.in_hospital_cd_3     AS rst_medicine3_cd3                                                                    -- 薬剤3連携コード3
     , rst_medicine3.in_hospital_cd_4     AS rst_medicine3_cd4                                                                    -- 薬剤3連携コード4
     , rst_procedure4.in_hosp_a_startdate AS rst_procedure4_a_startdate                                                           -- 手技4利用開始日A
     , rst_procedure4.in_hospital_cd_a1   AS rst_procedure4_cd_a1                                                                 -- 手技4連携コードA1
     , rst_procedure4.in_hospital_cd_a2   AS rst_procedure4_cd_a2                                                                 -- 手技4連携コードA2
     , rst_procedure4.in_hosp_b_startdate AS rst_procedure4_b_startdate                                                           -- 手技4利用開始日B
     , rst_procedure4.in_hospital_cd_b1   AS rst_procedure4_cd_b1                                                                 -- 手技4連携コードB1
     , rst_procedure4.in_hospital_cd_b2   AS rst_procedure4_cd_b2                                                                 -- 手技4連携コードB2
     , rst_medicine4.in_hospital_cd_1     AS rst_medicine4_cd1                                                                    -- 薬剤4連携コード1
     , rst_medicine4.in_hospital_cd_2     AS rst_medicine4_cd2                                                                    -- 薬剤4連携コード2
     , rst_medicine4.in_hospital_cd_3     AS rst_medicine4_cd3                                                                    -- 薬剤4連携コード3
     , rst_medicine4.in_hospital_cd_4     AS rst_medicine4_cd4                                                                    -- 薬剤4連携コード4
     , rst_procedure5.in_hosp_a_startdate AS rst_procedure5_a_startdate                                                           -- 手技5利用開始日A
     , rst_procedure5.in_hospital_cd_a1   AS rst_procedure5_cd_a1                                                                 -- 手技5連携コードA1
     , rst_procedure5.in_hospital_cd_a2   AS rst_procedure5_cd_a2                                                                 -- 手技5連携コードA2
     , rst_procedure5.in_hosp_b_startdate AS rst_procedure5_b_startdate                                                           -- 手技5利用開始日B
     , rst_procedure5.in_hospital_cd_b1   AS rst_procedure5_cd_b1                                                                 -- 手技5連携コードB1
     , rst_procedure5.in_hospital_cd_b2   AS rst_procedure5_cd_b2                                                                 -- 手技5連携コードB2
     , rst_medicine5.in_hospital_cd_1     AS rst_medicine5_cd1                                                                    -- 薬剤5連携コード1
     , rst_medicine5.in_hospital_cd_2     AS rst_medicine5_cd2                                                                    -- 薬剤5連携コード2
     , rst_medicine5.in_hospital_cd_3     AS rst_medicine5_cd3                                                                    -- 薬剤5連携コード3
     , rst_medicine5.in_hospital_cd_4     AS rst_medicine5_cd4                                                                    -- 薬剤5連携コード4
     , rst_procedure6.in_hosp_a_startdate AS rst_procedure6_a_startdate                                                           -- 手技6利用開始日A
     , rst_procedure6.in_hospital_cd_a1   AS rst_procedure6_cd_a1                                                                 -- 手技6連携コードA1
     , rst_procedure6.in_hospital_cd_a2   AS rst_procedure6_cd_a2                                                                 -- 手技6連携コードA2
     , rst_procedure6.in_hosp_b_startdate AS rst_procedure6_b_startdate                                                           -- 手技6利用開始日B
     , rst_procedure6.in_hospital_cd_b1   AS rst_procedure6_cd_b1                                                                 -- 手技6連携コードB1
     , rst_procedure6.in_hospital_cd_b2   AS rst_procedure6_cd_b2                                                                 -- 手技6連携コードB2
     , rst_medicine6.in_hospital_cd_1     AS rst_medicine6_cd1                                                                    -- 薬剤6連携コード1
     , rst_medicine6.in_hospital_cd_2     AS rst_medicine6_cd2                                                                    -- 薬剤6連携コード2
     , rst_medicine6.in_hospital_cd_3     AS rst_medicine6_cd3                                                                    -- 薬剤6連携コード3
     , rst_medicine6.in_hospital_cd_4     AS rst_medicine6_cd4                                                                    -- 薬剤6連携コード4
     , rst_procedure7.in_hosp_a_startdate AS rst_procedure7_a_startdate                                                           -- 手技7利用開始日A
     , rst_procedure7.in_hospital_cd_a1   AS rst_procedure7_cd_a1                                                                 -- 手技7連携コードA1
     , rst_procedure7.in_hospital_cd_a2   AS rst_procedure7_cd_a2                                                                 -- 手技7連携コードA2
     , rst_procedure7.in_hosp_b_startdate AS rst_procedure7_b_startdate                                                           -- 手技7利用開始日B
     , rst_procedure7.in_hospital_cd_b1   AS rst_procedure7_cd_b1                                                                 -- 手技7連携コードB1
     , rst_procedure7.in_hospital_cd_b2   AS rst_procedure7_cd_b2                                                                 -- 手技7連携コードB2
     , rst_medicine7.in_hospital_cd_1     AS rst_medicine7_cd1                                                                    -- 薬剤7連携コード1
     , rst_medicine7.in_hospital_cd_2     AS rst_medicine7_cd2                                                                    -- 薬剤7連携コード2
     , rst_medicine7.in_hospital_cd_3     AS rst_medicine7_cd3                                                                    -- 薬剤7連携コード3
     , rst_medicine7.in_hospital_cd_4     AS rst_medicine7_cd4                                                                    -- 薬剤7連携コード4
     , rst_procedure8.in_hosp_a_startdate AS rst_procedure8_a_startdate                                                           -- 手技8利用開始日A
     , rst_procedure8.in_hospital_cd_a1   AS rst_procedure8_cd_a1                                                                 -- 手技8連携コードA1
     , rst_procedure8.in_hospital_cd_a2   AS rst_procedure8_cd_a2                                                                 -- 手技8連携コードA2
     , rst_procedure8.in_hosp_b_startdate AS rst_procedure8_b_startdate                                                           -- 手技8利用開始日B
     , rst_procedure8.in_hospital_cd_b1   AS rst_procedure8_cd_b1                                                                 -- 手技8連携コードB1
     , rst_procedure8.in_hospital_cd_b2   AS rst_procedure8_cd_b2                                                                 -- 手技8連携コードB2
     , rst_medicine8.in_hospital_cd_1     AS rst_medicine8_cd1                                                                    -- 薬剤8連携コード1
     , rst_medicine8.in_hospital_cd_2     AS rst_medicine8_cd2                                                                    -- 薬剤8連携コード2
     , rst_medicine8.in_hospital_cd_3     AS rst_medicine8_cd3                                                                    -- 薬剤8連携コード3
     , rst_medicine8.in_hospital_cd_4     AS rst_medicine8_cd4                                                                    -- 薬剤8連携コード4
     , rst_procedure9.in_hosp_a_startdate AS rst_procedure9_a_startdate                                                           -- 手技9利用開始日A
     , rst_procedure9.in_hospital_cd_a1   AS rst_procedure9_cd_a1                                                                 -- 手技9連携コードA1
     , rst_procedure9.in_hospital_cd_a2   AS rst_procedure9_cd_a2                                                                 -- 手技9連携コードA2
     , rst_procedure9.in_hosp_b_startdate AS rst_procedure9_b_startdate                                                           -- 手技9利用開始日B
     , rst_procedure9.in_hospital_cd_b1   AS rst_procedure9_cd_b1                                                                 -- 手技9連携コードB1
     , rst_procedure9.in_hospital_cd_b2   AS rst_procedure9_cd_b2                                                                 -- 手技9連携コードB2
     , rst_medicine9.in_hospital_cd_1     AS rst_medicine9_cd1                                                                    -- 薬剤9連携コード1
     , rst_medicine9.in_hospital_cd_2     AS rst_medicine9_cd2                                                                    -- 薬剤9連携コード2
     , rst_medicine9.in_hospital_cd_3     AS rst_medicine9_cd3                                                                    -- 薬剤9連携コード3
     , rst_medicine9.in_hospital_cd_4     AS rst_medicine9_cd4                                                                    -- 薬剤9連携コード4
     , rst_procedure10.in_hosp_a_startdate AS rst_procedure10_a_startdate                                                         -- 手技10利用開始日A
     , rst_procedure10.in_hospital_cd_a1   AS rst_procedure10_cd_a1                                                               -- 手技10連携コードA1
     , rst_procedure10.in_hospital_cd_a2   AS rst_procedure10_cd_a2                                                               -- 手技10連携コードA2
     , rst_procedure10.in_hosp_b_startdate AS rst_procedure10_b_startdate                                                         -- 手技10利用開始日B
     , rst_procedure10.in_hospital_cd_b1   AS rst_procedure10_cd_b1                                                               -- 手技10連携コードB1
     , rst_procedure10.in_hospital_cd_b2   AS rst_procedure10_cd_b2                                                               -- 手技10連携コードB2
     , rst_medicine10.in_hospital_cd_1     AS rst_medicine10_cd1                                                                  -- 薬剤10連携コード1
     , rst_medicine10.in_hospital_cd_2     AS rst_medicine10_cd2                                                                  -- 薬剤10連携コード2
     , rst_medicine10.in_hospital_cd_3     AS rst_medicine10_cd3                                                                  -- 薬剤10連携コード3
     , rst_medicine10.in_hospital_cd_4     AS rst_medicine10_cd4                                                                  -- 薬剤10連携コード4
     , rst_procedure11.in_hosp_a_startdate AS rst_procedure11_a_startdate                                                         -- 手技11利用開始日A
     , rst_procedure11.in_hospital_cd_a1   AS rst_procedure11_cd_a1                                                               -- 手技11連携コードA1
     , rst_procedure11.in_hospital_cd_a2   AS rst_procedure11_cd_a2                                                               -- 手技11連携コードA2
     , rst_procedure11.in_hosp_b_startdate AS rst_procedure11_b_startdate                                                         -- 手技11利用開始日B
     , rst_procedure11.in_hospital_cd_b1   AS rst_procedure11_cd_b1                                                               -- 手技11連携コードB1
     , rst_procedure11.in_hospital_cd_b2   AS rst_procedure11_cd_b2                                                               -- 手技11連携コードB2
     , rst_medicine11.in_hospital_cd_1     AS rst_medicine11_cd1                                                                  -- 薬剤11連携コード1
     , rst_medicine11.in_hospital_cd_2     AS rst_medicine11_cd2                                                                  -- 薬剤11連携コード2
     , rst_medicine11.in_hospital_cd_3     AS rst_medicine11_cd3                                                                  -- 薬剤11連携コード3
     , rst_medicine11.in_hospital_cd_4     AS rst_medicine11_cd4                                                                  -- 薬剤11連携コード4
     , rst_procedure12.in_hosp_a_startdate AS rst_procedure12_a_startdate                                                         -- 手技12利用開始日A
     , rst_procedure12.in_hospital_cd_a1   AS rst_procedure12_cd_a1                                                               -- 手技12連携コードA1
     , rst_procedure12.in_hospital_cd_a2   AS rst_procedure12_cd_a2                                                               -- 手技12連携コードA2
     , rst_procedure12.in_hosp_b_startdate AS rst_procedure12_b_startdate                                                         -- 手技12利用開始日B
     , rst_procedure12.in_hospital_cd_b1   AS rst_procedure12_cd_b1                                                               -- 手技12連携コードB1
     , rst_procedure12.in_hospital_cd_b2   AS rst_procedure12_cd_b2                                                               -- 手技12連携コードB2
     , rst_medicine12.in_hospital_cd_1     AS rst_medicine12_cd1                                                                  -- 薬剤12連携コード1
     , rst_medicine12.in_hospital_cd_2     AS rst_medicine12_cd2                                                                  -- 薬剤12連携コード2
     , rst_medicine12.in_hospital_cd_3     AS rst_medicine12_cd3                                                                  -- 薬剤12連携コード3
     , rst_medicine12.in_hospital_cd_4     AS rst_medicine12_cd4                                                                  -- 薬剤12連携コード4
     , rst_procedure13.in_hosp_a_startdate AS rst_procedure13_a_startdate                                                         -- 手技13利用開始日A
     , rst_procedure13.in_hospital_cd_a1   AS rst_procedure13_cd_a1                                                               -- 手技13連携コードA1
     , rst_procedure13.in_hospital_cd_a2   AS rst_procedure13_cd_a2                                                               -- 手技13連携コードA2
     , rst_procedure13.in_hosp_b_startdate AS rst_procedure13_b_startdate                                                         -- 手技13利用開始日B
     , rst_procedure13.in_hospital_cd_b1   AS rst_procedure13_cd_b1                                                               -- 手技13連携コードB1
     , rst_procedure13.in_hospital_cd_b2   AS rst_procedure13_cd_b2                                                               -- 手技13連携コードB2
     , rst_medicine13.in_hospital_cd_1     AS rst_medicine13_cd1                                                                  -- 薬剤13連携コード1
     , rst_medicine13.in_hospital_cd_2     AS rst_medicine13_cd2                                                                  -- 薬剤13連携コード2
     , rst_medicine13.in_hospital_cd_3     AS rst_medicine13_cd3                                                                  -- 薬剤13連携コード3
     , rst_medicine13.in_hospital_cd_4     AS rst_medicine13_cd4                                                                  -- 薬剤13連携コード4
     , rst_procedure14.in_hosp_a_startdate AS rst_procedure14_a_startdate                                                         -- 手技14利用開始日A
     , rst_procedure14.in_hospital_cd_a1   AS rst_procedure14_cd_a1                                                               -- 手技14連携コードA1
     , rst_procedure14.in_hospital_cd_a2   AS rst_procedure14_cd_a2                                                               -- 手技14連携コードA2
     , rst_procedure14.in_hosp_b_startdate AS rst_procedure14_b_startdate                                                         -- 手技14利用開始日B
     , rst_procedure14.in_hospital_cd_b1   AS rst_procedure14_cd_b1                                                               -- 手技14連携コードB1
     , rst_procedure14.in_hospital_cd_b2   AS rst_procedure14_cd_b2                                                               -- 手技14連携コードB2
     , rst_medicine14.in_hospital_cd_1     AS rst_medicine14_cd1                                                                  -- 薬剤14連携コード1
     , rst_medicine14.in_hospital_cd_2     AS rst_medicine14_cd2                                                                  -- 薬剤14連携コード2
     , rst_medicine14.in_hospital_cd_3     AS rst_medicine14_cd3                                                                  -- 薬剤14連携コード3
     , rst_medicine14.in_hospital_cd_4     AS rst_medicine14_cd4                                                                  -- 薬剤14連携コード4
     , rst_procedure15.in_hosp_a_startdate AS rst_procedure15_a_startdate                                                         -- 手技15利用開始日A
     , rst_procedure15.in_hospital_cd_a1   AS rst_procedure15_cd_a1                                                               -- 手技15連携コードA1
     , rst_procedure15.in_hospital_cd_a2   AS rst_procedure15_cd_a2                                                               -- 手技15連携コードA2
     , rst_procedure15.in_hosp_b_startdate AS rst_procedure15_b_startdate                                                         -- 手技15利用開始日B
     , rst_procedure15.in_hospital_cd_b1   AS rst_procedure15_cd_b1                                                               -- 手技15連携コードB1
     , rst_procedure15.in_hospital_cd_b2   AS rst_procedure15_cd_b2                                                               -- 手技15連携コードB2
     , rst_medicine15.in_hospital_cd_1     AS rst_medicine15_cd1                                                                  -- 薬剤15連携コード1
     , rst_medicine15.in_hospital_cd_2     AS rst_medicine15_cd2                                                                  -- 薬剤15連携コード2
     , rst_medicine15.in_hospital_cd_3     AS rst_medicine15_cd3                                                                  -- 薬剤15連携コード3
     , rst_medicine15.in_hospital_cd_4     AS rst_medicine15_cd4                                                                  -- 薬剤15連携コード4
     , rst_procedure16.in_hosp_a_startdate AS rst_procedure16_a_startdate                                                         -- 手技16利用開始日A
     , rst_procedure16.in_hospital_cd_a1   AS rst_procedure16_cd_a1                                                               -- 手技16連携コードA1
     , rst_procedure16.in_hospital_cd_a2   AS rst_procedure16_cd_a2                                                               -- 手技16連携コードA2
     , rst_procedure16.in_hosp_b_startdate AS rst_procedure16_b_startdate                                                         -- 手技16利用開始日B
     , rst_procedure16.in_hospital_cd_b1   AS rst_procedure16_cd_b1                                                               -- 手技16連携コードB1
     , rst_procedure16.in_hospital_cd_b2   AS rst_procedure16_cd_b2                                                               -- 手技16連携コードB2
     , rst_medicine16.in_hospital_cd_1     AS rst_medicine16_cd1                                                                  -- 薬剤16連携コード1
     , rst_medicine16.in_hospital_cd_2     AS rst_medicine16_cd2                                                                  -- 薬剤16連携コード2
     , rst_medicine16.in_hospital_cd_3     AS rst_medicine16_cd3                                                                  -- 薬剤16連携コード3
     , rst_medicine16.in_hospital_cd_4     AS rst_medicine16_cd4                                                                  -- 薬剤16連携コード4
     , rst_procedure17.in_hosp_a_startdate AS rst_procedure17_a_startdate                                                         -- 手技17利用開始日A
     , rst_procedure17.in_hospital_cd_a1   AS rst_procedure17_cd_a1                                                               -- 手技17連携コードA1
     , rst_procedure17.in_hospital_cd_a2   AS rst_procedure17_cd_a2                                                               -- 手技17連携コードA2
     , rst_procedure17.in_hosp_b_startdate AS rst_procedure17_b_startdate                                                         -- 手技17利用開始日B
     , rst_procedure17.in_hospital_cd_b1   AS rst_procedure17_cd_b1                                                               -- 手技17連携コードB1
     , rst_procedure17.in_hospital_cd_b2   AS rst_procedure17_cd_b2                                                               -- 手技17連携コードB2
     , rst_medicine17.in_hospital_cd_1     AS rst_medicine17_cd1                                                                  -- 薬剤17連携コード1
     , rst_medicine17.in_hospital_cd_2     AS rst_medicine17_cd2                                                                  -- 薬剤17連携コード2
     , rst_medicine17.in_hospital_cd_3     AS rst_medicine17_cd3                                                                  -- 薬剤17連携コード3
     , rst_medicine17.in_hospital_cd_4     AS rst_medicine17_cd4                                                                  -- 薬剤17連携コード4
     , rst_procedure18.in_hosp_a_startdate AS rst_procedure18_a_startdate                                                         -- 手技18利用開始日A
     , rst_procedure18.in_hospital_cd_a1   AS rst_procedure18_cd_a1                                                               -- 手技18連携コードA1
     , rst_procedure18.in_hospital_cd_a2   AS rst_procedure18_cd_a2                                                               -- 手技18連携コードA2
     , rst_procedure18.in_hosp_b_startdate AS rst_procedure18_b_startdate                                                         -- 手技18利用開始日B
     , rst_procedure18.in_hospital_cd_b1   AS rst_procedure18_cd_b1                                                               -- 手技18連携コードB1
     , rst_procedure18.in_hospital_cd_b2   AS rst_procedure18_cd_b2                                                               -- 手技18連携コードB2
     , rst_medicine18.in_hospital_cd_1     AS rst_medicine18_cd1                                                                  -- 薬剤18連携コード1
     , rst_medicine18.in_hospital_cd_2     AS rst_medicine18_cd2                                                                  -- 薬剤18連携コード2
     , rst_medicine18.in_hospital_cd_3     AS rst_medicine18_cd3                                                                  -- 薬剤18連携コード3
     , rst_medicine18.in_hospital_cd_4     AS rst_medicine18_cd4                                                                  -- 薬剤18連携コード4
     , rst_procedure19.in_hosp_a_startdate AS rst_procedure19_a_startdate                                                         -- 手技19利用開始日A
     , rst_procedure19.in_hospital_cd_a1   AS rst_procedure19_cd_a1                                                               -- 手技19連携コードA1
     , rst_procedure19.in_hospital_cd_a2   AS rst_procedure19_cd_a2                                                               -- 手技19連携コードA2
     , rst_procedure19.in_hosp_b_startdate AS rst_procedure19_b_startdate                                                         -- 手技19利用開始日B
     , rst_procedure19.in_hospital_cd_b1   AS rst_procedure19_cd_b1                                                               -- 手技19連携コードB1
     , rst_procedure19.in_hospital_cd_b2   AS rst_procedure19_cd_b2                                                               -- 手技19連携コードB2
     , rst_medicine19.in_hospital_cd_1     AS rst_medicine19_cd1                                                                  -- 薬剤19連携コード1
     , rst_medicine19.in_hospital_cd_2     AS rst_medicine19_cd2                                                                  -- 薬剤19連携コード2
     , rst_medicine19.in_hospital_cd_3     AS rst_medicine19_cd3                                                                  -- 薬剤19連携コード3
     , rst_medicine19.in_hospital_cd_4     AS rst_medicine19_cd4                                                                  -- 薬剤19連携コード4
     , rst_procedure20.in_hosp_a_startdate AS rst_procedure20_a_startdate                                                         -- 手技20利用開始日A
     , rst_procedure20.in_hospital_cd_a1   AS rst_procedure20_cd_a1                                                               -- 手技20連携コードA1
     , rst_procedure20.in_hospital_cd_a2   AS rst_procedure20_cd_a2                                                               -- 手技20連携コードA2
     , rst_procedure20.in_hosp_b_startdate AS rst_procedure20_b_startdate                                                         -- 手技20利用開始日B
     , rst_procedure20.in_hospital_cd_b1   AS rst_procedure20_cd_b1                                                               -- 手技20連携コードB1
     , rst_procedure20.in_hospital_cd_b2   AS rst_procedure20_cd_b2                                                               -- 手技20連携コードB2
     , rst_medicine20.in_hospital_cd_1     AS rst_medicine20_cd1                                                                  -- 薬剤20連携コード1
     , rst_medicine20.in_hospital_cd_2     AS rst_medicine20_cd2                                                                  -- 薬剤20連携コード2
     , rst_medicine20.in_hospital_cd_3     AS rst_medicine20_cd3                                                                  -- 薬剤20連携コード3
     , rst_medicine20.in_hospital_cd_4     AS rst_medicine20_cd4                                                                  -- 薬剤20連携コード4

------------------------------------------------------------------------------------------------------------------------------------ 【実績】医療材料
     , rst_equipment1.in_hospital_cd_1  AS rst_equipment1_cd1                                                                     -- 医材1連携コード1
     , rst_equipment1.in_hospital_cd_2  AS rst_equipment1_cd2                                                                     -- 医材1連携コード2
     , rst_equipment1.in_hospital_cd_3  AS rst_equipment1_cd3                                                                     -- 医材1連携コード3
     , rst_equipment1.in_hospital_cd_4  AS rst_equipment1_cd4                                                                     -- 医材1連携コード4
     , rst_equipment2.in_hospital_cd_1  AS rst_equipment2_cd1                                                                     -- 医材2連携コード1
     , rst_equipment2.in_hospital_cd_2  AS rst_equipment2_cd2                                                                     -- 医材2連携コード2
     , rst_equipment2.in_hospital_cd_3  AS rst_equipment2_cd3                                                                     -- 医材2連携コード3
     , rst_equipment2.in_hospital_cd_4  AS rst_equipment2_cd4                                                                     -- 医材2連携コード4
     , rst_equipment3.in_hospital_cd_1  AS rst_equipment3_cd1                                                                     -- 医材3連携コード1
     , rst_equipment3.in_hospital_cd_2  AS rst_equipment3_cd2                                                                     -- 医材3連携コード2
     , rst_equipment3.in_hospital_cd_3  AS rst_equipment3_cd3                                                                     -- 医材3連携コード3
     , rst_equipment3.in_hospital_cd_4  AS rst_equipment3_cd4                                                                     -- 医材3連携コード4
     , rst_equipment4.in_hospital_cd_1  AS rst_equipment4_cd1                                                                     -- 医材4連携コード1
     , rst_equipment4.in_hospital_cd_2  AS rst_equipment4_cd2                                                                     -- 医材4連携コード2
     , rst_equipment4.in_hospital_cd_3  AS rst_equipment4_cd3                                                                     -- 医材4連携コード3
     , rst_equipment4.in_hospital_cd_4  AS rst_equipment4_cd4                                                                     -- 医材4連携コード4
     , rst_equipment5.in_hospital_cd_1  AS rst_equipment5_cd1                                                                     -- 医材5連携コード1
     , rst_equipment5.in_hospital_cd_2  AS rst_equipment5_cd2                                                                     -- 医材5連携コード2
     , rst_equipment5.in_hospital_cd_3  AS rst_equipment5_cd3                                                                     -- 医材5連携コード3
     , rst_equipment5.in_hospital_cd_4  AS rst_equipment5_cd4                                                                     -- 医材5連携コード4
     , rst_equipment6.in_hospital_cd_1  AS rst_equipment6_cd1                                                                     -- 医材6連携コード1
     , rst_equipment6.in_hospital_cd_2  AS rst_equipment6_cd2                                                                     -- 医材6連携コード2
     , rst_equipment6.in_hospital_cd_3  AS rst_equipment6_cd3                                                                     -- 医材6連携コード3
     , rst_equipment6.in_hospital_cd_4  AS rst_equipment6_cd4                                                                     -- 医材6連携コード4
     , rst_equipment7.in_hospital_cd_1  AS rst_equipment7_cd1                                                                     -- 医材7連携コード1
     , rst_equipment7.in_hospital_cd_2  AS rst_equipment7_cd2                                                                     -- 医材7連携コード2
     , rst_equipment7.in_hospital_cd_3  AS rst_equipment7_cd3                                                                     -- 医材7連携コード3
     , rst_equipment7.in_hospital_cd_4  AS rst_equipment7_cd4                                                                     -- 医材7連携コード4
     , rst_equipment8.in_hospital_cd_1  AS rst_equipment8_cd1                                                                     -- 医材8連携コード1
     , rst_equipment8.in_hospital_cd_2  AS rst_equipment8_cd2                                                                     -- 医材8連携コード2
     , rst_equipment8.in_hospital_cd_3  AS rst_equipment8_cd3                                                                     -- 医材8連携コード3
     , rst_equipment8.in_hospital_cd_4  AS rst_equipment8_cd4                                                                     -- 医材8連携コード4
     , rst_equipment9.in_hospital_cd_1  AS rst_equipment9_cd1                                                                     -- 医材9連携コード1
     , rst_equipment9.in_hospital_cd_2  AS rst_equipment9_cd2                                                                     -- 医材9連携コード2
     , rst_equipment9.in_hospital_cd_3  AS rst_equipment9_cd3                                                                     -- 医材9連携コード3
     , rst_equipment9.in_hospital_cd_4  AS rst_equipment9_cd4                                                                     -- 医材9連携コード4
     , rst_equipment10.in_hospital_cd_1 AS rst_equipment10_cd1                                                                    -- 医材10連携コード1
     , rst_equipment10.in_hospital_cd_2 AS rst_equipment10_cd2                                                                    -- 医材10連携コード2
     , rst_equipment10.in_hospital_cd_3 AS rst_equipment10_cd3                                                                    -- 医材10連携コード3
     , rst_equipment10.in_hospital_cd_4 AS rst_equipment10_cd4                                                                    -- 医材10連携コード4
     , rst_equipment11.in_hospital_cd_1 AS rst_equipment11_cd1                                                                    -- 医材11連携コード1
     , rst_equipment11.in_hospital_cd_2 AS rst_equipment11_cd2                                                                    -- 医材11連携コード2
     , rst_equipment11.in_hospital_cd_3 AS rst_equipment11_cd3                                                                    -- 医材11連携コード3
     , rst_equipment11.in_hospital_cd_4 AS rst_equipment11_cd4                                                                    -- 医材11連携コード4
     , rst_equipment12.in_hospital_cd_1 AS rst_equipment12_cd1                                                                    -- 医材12連携コード1
     , rst_equipment12.in_hospital_cd_2 AS rst_equipment12_cd2                                                                    -- 医材12連携コード2
     , rst_equipment12.in_hospital_cd_3 AS rst_equipment12_cd3                                                                    -- 医材12連携コード3
     , rst_equipment12.in_hospital_cd_4 AS rst_equipment12_cd4                                                                    -- 医材12連携コード4
     , rst_equipment13.in_hospital_cd_1 AS rst_equipment13_cd1                                                                    -- 医材13連携コード1
     , rst_equipment13.in_hospital_cd_2 AS rst_equipment13_cd2                                                                    -- 医材13連携コード2
     , rst_equipment13.in_hospital_cd_3 AS rst_equipment13_cd3                                                                    -- 医材13連携コード3
     , rst_equipment13.in_hospital_cd_4 AS rst_equipment13_cd4                                                                    -- 医材13連携コード4
     , rst_equipment14.in_hospital_cd_1 AS rst_equipment14_cd1                                                                    -- 医材14連携コード1
     , rst_equipment14.in_hospital_cd_2 AS rst_equipment14_cd2                                                                    -- 医材14連携コード2
     , rst_equipment14.in_hospital_cd_3 AS rst_equipment14_cd3                                                                    -- 医材14連携コード3
     , rst_equipment14.in_hospital_cd_4 AS rst_equipment14_cd4                                                                    -- 医材14連携コード4
     , rst_equipment15.in_hospital_cd_1 AS rst_equipment15_cd1                                                                    -- 医材15連携コード1
     , rst_equipment15.in_hospital_cd_2 AS rst_equipment15_cd2                                                                    -- 医材15連携コード2
     , rst_equipment15.in_hospital_cd_3 AS rst_equipment15_cd3                                                                    -- 医材15連携コード3
     , rst_equipment15.in_hospital_cd_4 AS rst_equipment15_cd4                                                                    -- 医材15連携コード4
     , rst_equipment16.in_hospital_cd_1 AS rst_equipment16_cd1                                                                    -- 医材16連携コード1
     , rst_equipment16.in_hospital_cd_2 AS rst_equipment16_cd2                                                                    -- 医材16連携コード2
     , rst_equipment16.in_hospital_cd_3 AS rst_equipment16_cd3                                                                    -- 医材16連携コード3
     , rst_equipment16.in_hospital_cd_4 AS rst_equipment16_cd4                                                                    -- 医材16連携コード4
     , rst_equipment17.in_hospital_cd_1 AS rst_equipment17_cd1                                                                    -- 医材17連携コード1
     , rst_equipment17.in_hospital_cd_2 AS rst_equipment17_cd2                                                                    -- 医材17連携コード2
     , rst_equipment17.in_hospital_cd_3 AS rst_equipment17_cd3                                                                    -- 医材17連携コード3
     , rst_equipment17.in_hospital_cd_4 AS rst_equipment17_cd4                                                                    -- 医材17連携コード4
     , rst_equipment18.in_hospital_cd_1 AS rst_equipment18_cd1                                                                    -- 医材18連携コード1
     , rst_equipment18.in_hospital_cd_2 AS rst_equipment18_cd2                                                                    -- 医材18連携コード2
     , rst_equipment18.in_hospital_cd_3 AS rst_equipment18_cd3                                                                    -- 医材18連携コード3
     , rst_equipment18.in_hospital_cd_4 AS rst_equipment18_cd4                                                                    -- 医材18連携コード4
     , rst_equipment19.in_hospital_cd_1 AS rst_equipment19_cd1                                                                    -- 医材19連携コード1
     , rst_equipment19.in_hospital_cd_2 AS rst_equipment19_cd2                                                                    -- 医材19連携コード2
     , rst_equipment19.in_hospital_cd_3 AS rst_equipment19_cd3                                                                    -- 医材19連携コード3
     , rst_equipment19.in_hospital_cd_4 AS rst_equipment19_cd4                                                                    -- 医材19連携コード4
     , rst_equipment20.in_hospital_cd_1 AS rst_equipment20_cd1                                                                    -- 医材20連携コード1
     , rst_equipment20.in_hospital_cd_2 AS rst_equipment20_cd2                                                                    -- 医材20連携コード2
     , rst_equipment20.in_hospital_cd_3 AS rst_equipment20_cd3                                                                    -- 医材20連携コード3
     , rst_equipment20.in_hospital_cd_4 AS rst_equipment20_cd4                                                                    -- 医材20連携コード4

FROM ord_main ord                                                                                                               -- 治療情報
------------------------------------------------------------------------------------------------------------------------------------ 【指示】治療方法
         LEFT JOIN mst_treatment ind_treatment                                                                                           -- 治療方法マスタ
                   ON ind_treatment.treatment_cd = ord.ind_treatment_cd                                                                          -- 治療方法コード
                       AND ind_treatment.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_treatment.is_disp = '1' AND ind_treatment.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【指示】スケジュール
         LEFT JOIN mst_kur ind_kur                                                                                                       -- クールマスタ
                   ON ind_kur.kur_cd = ord.ind_kur_cd                                                                                            -- クールコード
                       AND ind_kur.is_del = '0'                                                                                                       -- 削除フラグ
         LEFT JOIN mst_bed ind_bed                                                                                                       -- ベッドマスタ
                   ON ind_bed.bed_cd = ord.ind_bed_cd                                                                                            -- ベッドコード
                       AND ind_bed.is_del = '0'                                                                                                       -- 削除フラグ
                       AND ind_bed.is_disp = '1' AND ind_bed.facility_cd = /*facilityCd*/null                                                                                                               -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【指示】治療条件
         LEFT JOIN mst_va ind_va                                                                                                         -- VAマスタ
--     ON ind_va.va_cd = ( ( ord.ind_cond_info :: json #>> '{2}' ) :: TEXT :: json #>> '{value}' ) :: INT                            -- VAコード
                   ON ind_va.va_cd =  CAST(COALESCE( ord.ind_cond_info -> '2' ->> 'value'  , '0') AS INTEGER)                       -- VAコード
                       AND ind_va.is_del = '0'                                                                                                        -- 削除フラグ
                       AND ind_va.is_disp = '1' AND ind_va.facility_cd = /*facilityCd*/null                                                                                                                -- 表示フラグ
         LEFT JOIN mst_dialyzer ind_dialyzer                                                                                             -- ダイアライザマスタ
--     ON ind_dialyzer.dialyzer_cd = ( ( ord.ind_cond_info :: json #>> '{5}' ) :: TEXT :: json #>> '{value}' ) :: INT                -- ダイアライザコード
                   ON ind_dialyzer.dialyzer_cd = CAST(COALESCE( ord.ind_cond_info -> '5' ->> 'value'  , '0') AS INTEGER)                -- ダイアライザコード
                       AND ind_dialyzer.is_del = '0'                                                                                                  -- 削除フラグ
                       AND ind_dialyzer.is_disp = '1' AND ind_dialyzer.facility_cd = /*facilityCd*/null                                                                                                          -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment31                                                                                         -- 医療材料マスタ
--     ON ind_equipment31.equipment_cd = ( ( ord.ind_cond_info :: json #>> '{6}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON ind_equipment31.equipment_cd = CAST(COALESCE( ord.ind_cond_info -> '6' ->> 'value'  , '0') AS INTEGER)        -- 医療材料コード
                       AND ind_equipment31.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment31.is_disp = '1' AND ind_equipment31.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ

         LEFT JOIN mst_equipment ind_equipment32                                                                                         -- 医療材料マスタ
--     ON ind_equipment32.equipment_cd = ( ( ord.ind_cond_info :: json #>> '{7}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON ind_equipment32.equipment_cd = CAST(COALESCE( ord.ind_cond_info -> '7' ->> 'value'  , '0') AS INTEGER)    -- 医療材料コード
                       AND ind_equipment32.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment32.is_disp = '1' AND ind_equipment32.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment33                                                                                         -- 医療材料マスタ
--     ON ind_equipment33.equipment_cd = ( ( ord.ind_cond_info :: json #>> '{8}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON ind_equipment33.equipment_cd = CAST(COALESCE( ord.ind_cond_info -> '8' ->> 'value'  , '0') AS INTEGER)    -- 医療材料コード
                       AND ind_equipment33.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment33.is_disp = '1' AND ind_equipment33.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment34                                                                                         -- 医療材料マスタ
--     ON ind_equipment34.equipment_cd = ( ( ord.ind_cond_info :: json #>> '{9}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON ind_equipment34.equipment_cd = CAST(COALESCE( ord.ind_cond_info -> '9' ->> 'value'  , '0') AS INTEGER)    -- 医療材料コード
                       AND ind_equipment34.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment34.is_disp = '1' AND ind_equipment34.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment35                                                                                         -- 医療材料マスタ
--     ON ind_equipment35.equipment_cd = ( ( ord.ind_cond_info :: json #>> '{10}' ) :: TEXT :: json #>> '{value}' ) :: INT           -- 医療材料コード
                   ON ind_equipment35.equipment_cd = CAST(COALESCE( ord.ind_cond_info -> '10' ->> 'value'  , '0') AS INTEGER)   -- 医療材料コード
                       AND ind_equipment35.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment35.is_disp = '1' AND ind_equipment35.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment36                                                                                         -- 医療材料マスタ
--     ON ind_equipment36.equipment_cd = ( ( ord.ind_cond_info :: json #>> '{11}' ) :: TEXT :: json #>> '{value}' ) :: INT           -- 医療材料コード
                   ON ind_equipment36.equipment_cd = CAST(COALESCE( ord.ind_cond_info -> '11' ->> 'value'  , '0') AS INTEGER)   -- 医療材料コード
                       AND ind_equipment36.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment36.is_disp = '1' AND ind_equipment36.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment37                                                                                         -- 医療材料マスタ
--     ON ind_equipment37.equipment_cd = ( ( ord.ind_cond_info :: json #>> '{13}' ) :: TEXT :: json #>> '{value}' ) :: INT           -- 医療材料コード
                   ON ind_equipment37.equipment_cd = CAST(COALESCE( ord.ind_cond_info -> '13' ->> 'value'  , '0') AS INTEGER)   -- 医療材料コード
                       AND ind_equipment37.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment37.is_disp = '1' AND ind_equipment37.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine31                                                                                           -- 薬剤マスタ
--     ON ind_medicine31.medicine_cd = ( ( ord.ind_cond_info :: json #>> '{15}' ) :: TEXT :: json #>> '{value}' ) :: INT             -- 薬剤コード
                   ON ind_medicine31.medicine_cd = CAST(COALESCE( ord.ind_cond_info -> '15' ->> 'value'  , '0') AS INTEGER)     -- 薬剤コード
                       AND ind_medicine31.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine31.is_disp = '1' AND ind_medicine31.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine32                                                                                           -- 薬剤マスタ
--     ON ind_medicine32.medicine_cd = ( ( ord.ind_cond_info :: json #>> '{19}' ) :: TEXT :: json #>> '{value}' ) :: INT             -- 薬剤コード
                   ON ind_medicine32.medicine_cd = CAST(COALESCE( ord.ind_cond_info -> '19' ->> 'value'  , '0') AS INTEGER)     -- 薬剤コード
                       AND ind_medicine32.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine32.is_disp = '1' AND ind_medicine32.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine33                                                                                           -- 薬剤マスタ
--     ON ind_medicine33.medicine_cd = ( ( ord.ind_cond_info :: json #>> '{25}' ) :: TEXT :: json #>> '{value}' ) :: INT             -- 薬剤コード
                   ON ind_medicine33.medicine_cd = CAST(COALESCE( ord.ind_cond_info -> '25' ->> 'value'  , '0') AS INTEGER)     -- 薬剤コード
                       AND ind_medicine33.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine33.is_disp = '1' AND ind_medicine33.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【指示】投与薬剤
         LEFT JOIN mst_procedure ind_procedure1                                                                                          -- 手技マスタ
--     ON ind_procedure1.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{0}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure1.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 0 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure1.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure1.is_disp = '1' AND ind_procedure1.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine1                                                                                            -- 薬剤マスタ
--     ON ind_medicine1.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{0}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine1.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 0 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine1.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine1.is_disp = '1' AND ind_medicine1.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure2                                                                                          -- 手技マスタ
--     ON ind_procedure2.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{1}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure2.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 1 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure2.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure2.is_disp = '1' AND ind_procedure2.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine2                                                                                            -- 薬剤マスタ
--     ON ind_medicine2.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{1}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine2.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 1 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine2.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine2.is_disp = '1' AND ind_medicine2.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure3                                                                                          -- 手技マスタ
--     ON ind_procedure3.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{2}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure3.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 2 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure3.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure3.is_disp = '1' AND ind_procedure3.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine3                                                                                            -- 薬剤マスタ
--     ON ind_medicine3.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{2}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine3.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 2 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine3.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine3.is_disp = '1' AND ind_medicine3.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure4                                                                                          -- 手技マスタ
--     ON ind_procedure4.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{3}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure4.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 3 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure4.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure4.is_disp = '1' AND ind_procedure4.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine4                                                                                            -- 薬剤マスタ
--     ON ind_medicine4.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{3}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine4.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 3 ->> 'cd'  , '0') AS INTEGER)           -- 薬剤コード
                       AND ind_medicine4.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine4.is_disp = '1' AND ind_medicine4.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure5                                                                                          -- 手技マスタ
--     ON ind_procedure5.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{4}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure5.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 4 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure5.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure5.is_disp = '1' AND ind_procedure5.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine5                                                                                            -- 薬剤マスタ
--     ON ind_medicine5.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{4}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine5.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 4 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine5.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine5.is_disp = '1' AND ind_medicine5.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure6                                                                                          -- 手技マスタ
--     ON ind_procedure6.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{5}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure6.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 5 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure6.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure6.is_disp = '1' AND ind_procedure6.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine6                                                                                            -- 薬剤マスタ
--     ON ind_medicine6.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{5}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine6.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 5 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine6.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine6.is_disp = '1' AND ind_medicine6.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure7                                                                                          -- 手技マスタ
--     ON ind_procedure7.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{6}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure7.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 6 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure7.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure7.is_disp = '1' AND ind_procedure7.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine7                                                                                            -- 薬剤マスタ
--     ON ind_medicine7.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{6}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine7.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 6 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine7.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine7.is_disp = '1' AND ind_medicine7.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure8                                                                                          -- 手技マスタ
--     ON ind_procedure8.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{7}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure8.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 7 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure8.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure8.is_disp = '1' AND ind_procedure8.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine8                                                                                            -- 薬剤マスタ
--     ON ind_medicine8.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{7}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine8.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 7 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine8.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine8.is_disp = '1' AND ind_medicine8.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure9                                                                                          -- 手技マスタ
--     ON ind_procedure9.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{8}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON ind_procedure9.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 8 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND ind_procedure9.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_procedure9.is_disp = '1' AND ind_procedure9.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine9                                                                                            -- 薬剤マスタ
--     ON ind_medicine9.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{8}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON ind_medicine9.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 8 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND ind_medicine9.is_del = '0'                                                                                                 -- 削除フラグ
                       AND ind_medicine9.is_disp = '1' AND ind_medicine9.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure10                                                                                         -- 手技マスタ
--     ON ind_procedure10.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{9}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT     -- 手技コード
                   ON ind_procedure10.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 9 ->> 'procedure_cd'  , '0') AS INTEGER) -- 手技コード
                       AND ind_procedure10.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure10.is_disp = '1' AND ind_procedure10.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine10                                                                                           -- 薬剤マスタ
--     ON ind_medicine10.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{9}' ) :: TEXT :: json #>> '{cd}' ) :: INT                 -- 薬剤コード
                   ON ind_medicine10.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 9 ->> 'cd'  , '0') AS INTEGER)         -- 薬剤コード
                       AND ind_medicine10.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine10.is_disp = '1' AND ind_medicine10.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure11                                                                                         -- 手技マスタ
--     ON ind_procedure11.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{10}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure11.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 10 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure11.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure11.is_disp = '1' AND ind_procedure11.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine11                                                                                           -- 薬剤マスタ
--     ON ind_medicine11.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{10}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine11.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 10 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine11.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine11.is_disp = '1' AND ind_medicine11.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure12                                                                                         -- 手技マスタ
--     ON ind_procedure12.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{11}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure12.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 11 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure12.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure12.is_disp = '1' AND ind_procedure12.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine12                                                                                           -- 薬剤マスタ
--     ON ind_medicine12.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{11}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine12.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 11 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine12.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine12.is_disp = '1' AND ind_medicine12.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure13                                                                                         -- 手技マスタ
--     ON ind_procedure13.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{12}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure13.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 12 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure13.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure13.is_disp = '1' AND ind_procedure13.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine13                                                                                           -- 薬剤マスタ
--     ON ind_medicine13.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{12}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine13.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 12 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine13.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine13.is_disp = '1' AND ind_medicine13.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure14                                                                                         -- 手技マスタ
--     ON ind_procedure14.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{13}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure14.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 13 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure14.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure14.is_disp = '1' AND ind_procedure14.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine14                                                                                           -- 薬剤マスタ
--     ON ind_medicine14.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{13}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine14.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 13 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine14.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine14.is_disp = '1' AND ind_medicine14.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure15                                                                                         -- 手技マスタ
--     ON ind_procedure15.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{14}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure15.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 14 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure15.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure15.is_disp = '1' AND ind_procedure15.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine15                                                                                           -- 薬剤マスタ
--     ON ind_medicine15.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{14}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine15.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 14 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine15.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine15.is_disp = '1' AND ind_medicine15.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure16                                                                                         -- 手技マスタ
--     ON ind_procedure16.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{15}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure16.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 15 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure16.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure16.is_disp = '1' AND ind_procedure16.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine16                                                                                           -- 薬剤マスタ
--     ON ind_medicine16.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{15}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine16.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 15 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine16.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine16.is_disp = '1' AND ind_medicine16.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure17                                                                                         -- 手技マスタ
--     ON ind_procedure17.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{16}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure17.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 16 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure17.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure17.is_disp = '1' AND ind_procedure17.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine17                                                                                           -- 薬剤マスタ
--     ON ind_medicine17.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{16}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine17.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 16 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine17.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine17.is_disp = '1' AND ind_medicine17.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure18                                                                                         -- 手技マスタ
--     ON ind_procedure18.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{17}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure18.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 17 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure18.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure18.is_disp = '1' AND ind_procedure18.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine18                                                                                           -- 薬剤マスタ
--     ON ind_medicine18.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{17}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine18.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 17 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine18.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine18.is_disp = '1' AND ind_medicine18.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure19                                                                                         -- 手技マスタ
--     ON ind_procedure19.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{18}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure19.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 18 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure19.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure19.is_disp = '1' AND ind_procedure19.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine19                                                                                           -- 薬剤マスタ
--     ON ind_medicine19.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{18}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine19.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 18 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine19.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine19.is_disp = '1' AND ind_medicine19.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure ind_procedure20                                                                                         -- 手技マスタ
--     ON ind_procedure20.procedure_cd = ( ( ord.ind_medi_info :: json #>> '{19}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON ind_procedure20.procedure_cd = CAST(COALESCE( ord.ind_medi_info -> 19 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND ind_procedure20.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_procedure20.is_disp = '1' AND ind_procedure20.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine ind_medicine20                                                                                           -- 薬剤マスタ
--     ON ind_medicine20.medicine_cd = ( ( ord.ind_medi_info :: json #>> '{19}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON ind_medicine20.medicine_cd = CAST(COALESCE( ord.ind_medi_info -> 19 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND ind_medicine20.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_medicine20.is_disp = '1' AND ind_medicine20.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【指示】医療材料
         LEFT JOIN mst_equipment ind_equipment1                                                                                          -- 医療材料マスタ
--     ON ind_equipment1.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{0}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment1.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 0 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment1.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment1.is_disp = '1' AND ind_equipment1.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment2                                                                                          -- 医療材料マスタ
--     ON ind_equipment2.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{1}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment2.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 1 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment2.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment2.is_disp = '1' AND ind_equipment2.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment3                                                                                          -- 医療材料マスタ
--     ON ind_equipment3.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{2}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment3.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 2 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment3.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment3.is_disp = '1' AND ind_equipment3.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment4                                                                                          -- 医療材料マスタ
--     ON ind_equipment4.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{3}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment4.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 3 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment4.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment4.is_disp = '1' AND ind_equipment4.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment5                                                                                          -- 医療材料マスタ
--     ON ind_equipment5.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{4}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment5.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 4 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment5.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment5.is_disp = '1' AND ind_equipment5.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment6                                                                                          -- 医療材料マスタ
--     ON ind_equipment6.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{5}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment6.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 5 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment6.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment6.is_disp = '1' AND ind_equipment6.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment7                                                                                          -- 医療材料マスタ
--     ON ind_equipment7.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{6}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment7.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 6 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment7.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment7.is_disp = '1' AND ind_equipment7.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment8                                                                                          -- 医療材料マスタ
--     ON ind_equipment8.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{7}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment8.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 7 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment8.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment8.is_disp = '1' AND ind_equipment8.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment9                                                                                          -- 医療材料マスタ
--     ON ind_equipment9.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{8}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON ind_equipment9.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 8 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND ind_equipment9.is_del = '0'                                                                                                -- 削除フラグ
                       AND ind_equipment9.is_disp = '1' AND ind_equipment9.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment10                                                                                         -- 医療材料マスタ
--     ON ind_equipment10.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{9}' ) :: TEXT :: json #>> '{cd}' ) :: INT              -- 医療材料コード
                   ON ind_equipment10.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 9 ->> 'cd'  , '0') AS INTEGER)      -- 医療材料コード
                       AND ind_equipment10.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment10.is_disp = '1' AND ind_equipment10.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment11                                                                                         -- 医療材料マスタ
--     ON ind_equipment11.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{10}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment11.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 10 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment11.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment11.is_disp = '1' AND ind_equipment11.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment12                                                                                         -- 医療材料マスタ
--     ON ind_equipment12.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{11}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment12.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 11 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment12.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment12.is_disp = '1' AND ind_equipment12.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment13                                                                                         -- 医療材料マスタ
--     ON ind_equipment13.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{12}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment13.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 12 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment13.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment13.is_disp = '1' AND ind_equipment13.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment14                                                                                         -- 医療材料マスタ
--     ON ind_equipment14.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{13}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment14.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 13 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment14.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment14.is_disp = '1' AND ind_equipment14.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment15                                                                                         -- 医療材料マスタ
--     ON ind_equipment15.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{14}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment15.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 14 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment15.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment15.is_disp = '1' AND ind_equipment15.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment16                                                                                         -- 医療材料マスタ
--     ON ind_equipment16.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{15}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment16.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 15 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment16.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment16.is_disp = '1' AND ind_equipment16.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment17                                                                                         -- 医療材料マスタ
--     ON ind_equipment17.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{16}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment17.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 16 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment17.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment17.is_disp = '1' AND ind_equipment17.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment18                                                                                         -- 医療材料マスタ
--     ON ind_equipment18.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{17}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment18.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 17 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment18.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment18.is_disp = '1' AND ind_equipment18.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment19                                                                                         -- 医療材料マスタ
--     ON ind_equipment19.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{18}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment19.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 18 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment19.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment19.is_disp = '1' AND ind_equipment19.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment ind_equipment20                                                                                         -- 医療材料マスタ
--     ON ind_equipment20.equipment_cd = ( ( ord.ind_equip_info :: json #>> '{19}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON ind_equipment20.equipment_cd = CAST(COALESCE( ord.ind_equip_info -> 19 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND ind_equipment20.is_del = '0'                                                                                               -- 削除フラグ
                       AND ind_equipment20.is_disp = '1' AND ind_equipment20.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【実績】実績情報
         LEFT JOIN mst_treatment rst_treatment                                                                                           -- 治療方法マスタ
                   ON rst_treatment.treatment_cd = ord.rst_treatment_cd                                                                          -- 治療方法コード
                       AND rst_treatment.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_treatment.is_disp = '1' AND rst_treatment.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_kur rst_kur                                                                                                       -- クールマスタ
                   ON rst_kur.kur_cd = ord.rst_kur_cd                                                                                            -- クールコード
                       AND rst_kur.is_del = '0'                                                                                                       -- 削除フラグ
         LEFT JOIN mst_bed rst_bed                                                                                                       -- ベッドマスタ
                   ON rst_bed.bed_cd = ord.rst_bed_cd                                                                                            -- ベッドコード
                       AND rst_bed.is_del = '0'                                                                                                       -- 削除フラグ
                       AND rst_bed.is_disp = '1' AND rst_bed.facility_cd = /*facilityCd*/null                                                                                                               -- 表示フラグ
         LEFT JOIN mst_ward                                                                                                              -- 病棟マスタ
                   ON mst_ward.ward_cd = ord.rst_ward_cd                                                                                         -- 病棟コード
                       AND mst_ward.is_del = '0'                                                                                                      -- 削除フラグ
                       AND mst_ward.is_disp = '1' AND mst_ward.facility_cd = /*facilityCd*/null                                                                                                              -- 表示フラグ
         LEFT JOIN mst_course                                                                                                            -- 診療科マスタ
                   ON mst_course.course_cd = ord.rst_course_cd                                                                                   -- 診療科コード
                       AND mst_course.is_del = '0'                                                                                                    -- 削除フラグ
                       AND mst_course.is_disp = '1' AND mst_course.facility_cd = /*facilityCd*/null                                                                                                            -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【実績】加算情報
         LEFT JOIN mst_addition addition1                                                                                                -- 加算マスタ
--     ON addition1.addition_cd = ( ( ord.addition_info :: json #>> '{0}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition1.addition_cd = CAST(COALESCE( ord.addition_info -> 0 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition1.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition1.is_disp = '1' AND addition1.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition2                                                                                                -- 加算マスタ
--     ON addition2.addition_cd = ( ( ord.addition_info :: json #>> '{1}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition2.addition_cd = CAST(COALESCE( ord.addition_info -> 1 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition2.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition2.is_disp = '1' AND addition2.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition3                                                                                                -- 加算マスタ
--     ON addition3.addition_cd = ( ( ord.addition_info :: json #>> '{2}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition3.addition_cd = CAST(COALESCE( ord.addition_info -> 2 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition3.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition3.is_disp = '1' AND addition3.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition4                                                                                                -- 加算マスタ
--     ON addition4.addition_cd = ( ( ord.addition_info :: json #>> '{3}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition4.addition_cd = CAST(COALESCE( ord.addition_info -> 3 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition4.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition4.is_disp = '1' AND addition4.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition5                                                                                                -- 加算マスタ
--     ON addition5.addition_cd = ( ( ord.addition_info :: json #>> '{4}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition5.addition_cd = CAST(COALESCE( ord.addition_info -> 4 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition5.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition5.is_disp = '1' AND addition5.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition6                                                                                                -- 加算マスタ
--     ON addition6.addition_cd = ( ( ord.addition_info :: json #>> '{5}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition6.addition_cd = CAST(COALESCE( ord.addition_info -> 5 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition6.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition6.is_disp = '1' AND addition6.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition7                                                                                                -- 加算マスタ
--     ON addition7.addition_cd = ( ( ord.addition_info :: json #>> '{6}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition7.addition_cd = CAST(COALESCE( ord.addition_info -> 6 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition7.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition7.is_disp = '1' AND addition7.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition8                                                                                                -- 加算マスタ
--     ON addition8.addition_cd = ( ( ord.addition_info :: json #>> '{7}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition8.addition_cd = CAST(COALESCE( ord.addition_info -> 7 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition8.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition8.is_disp = '1' AND addition8.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition9                                                                                                -- 加算マスタ
--     ON addition9.addition_cd = ( ( ord.addition_info :: json #>> '{8}' ) :: TEXT :: json #>> '{cd}' ) :: INT                      -- 加算コード
                   ON addition9.addition_cd = CAST(COALESCE( ord.addition_info -> 8 ->> 'cd'  , '0') AS INTEGER)              -- 加算コード
                       AND addition9.is_del = '0'                                                                                                     -- 削除フラグ
                       AND addition9.is_disp = '1' AND addition9.facility_cd = /*facilityCd*/null                                                                                                             -- 表示フラグ
         LEFT JOIN mst_addition addition10                                                                                               -- 加算マスタ
--     ON addition10.addition_cd = ( ( ord.addition_info :: json #>> '{9}' ) :: TEXT :: json #>> '{cd}' ) :: INT                     -- 加算コード
                   ON addition10.addition_cd = CAST(COALESCE( ord.addition_info -> 9 ->> 'cd'  , '0') AS INTEGER)             -- 加算コード
                       AND addition10.is_del = '0'                                                                                                    -- 削除フラグ
                       AND addition10.is_disp = '1' AND addition10.facility_cd = /*facilityCd*/null                                                                                                            -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【実績】治療条件
         LEFT JOIN mst_va rst_va                                                                                                         -- VAマスタ
--     ON rst_va.va_cd = ( ( ord.rst_cond_info :: json #>> '{2}' ) :: TEXT :: json #>> '{value}' ) :: INT                            -- VAコード
                   ON rst_va.va_cd = CAST(COALESCE( ord.rst_cond_info -> '2' ->> 'value'  , '0') AS INTEGER)                    -- VAコード
                       AND rst_va.is_del = '0'                                                                                                        -- 削除フラグ
                       AND rst_va.is_disp = '1' AND rst_va.facility_cd = /*facilityCd*/null                                                                                                                -- 表示フラグ
         LEFT JOIN mst_dialyzer rst_dialyzer                                                                                             -- ダイアライザマスタ
--     ON rst_dialyzer.dialyzer_cd = ( ( ord.rst_cond_info :: json #>> '{5}' ) :: TEXT :: json #>> '{value}' ) :: INT                -- ダイアライザコード
                   ON rst_dialyzer.dialyzer_cd = CAST(COALESCE( ord.rst_cond_info -> '5' ->> 'value'  , '0') AS INTEGER)        -- ダイアライザコード
                       AND rst_dialyzer.is_del = '0'                                                                                                  -- 削除フラグ
                       AND rst_dialyzer.is_disp = '1' AND rst_dialyzer.facility_cd = /*facilityCd*/null                                                                                                          -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment31                                                                                         -- 医療材料マスタ
--     ON rst_equipment31.equipment_cd = ( ( ord.rst_cond_info :: json #>> '{6}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON rst_equipment31.equipment_cd = CAST(COALESCE( ord.rst_cond_info -> '6' ->> 'value'  , '0') AS INTEGER)    -- 医療材料コード
                       AND rst_equipment31.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment31.is_disp = '1' AND rst_equipment31.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ

         LEFT JOIN mst_equipment rst_equipment32                                                                                         -- 医療材料マスタ
--     ON rst_equipment32.equipment_cd = ( ( ord.rst_cond_info :: json #>> '{7}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON rst_equipment32.equipment_cd = CAST(COALESCE( ord.rst_cond_info -> '7' ->> 'value'  , '0') AS INTEGER)    -- 医療材料コード
                       AND rst_equipment32.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment32.is_disp = '1' AND rst_equipment32.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment33                                                                                         -- 医療材料マスタ
--     ON rst_equipment33.equipment_cd = ( ( ord.rst_cond_info :: json #>> '{8}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON rst_equipment33.equipment_cd = CAST(COALESCE( ord.rst_cond_info -> '8' ->> 'value'  , '0') AS INTEGER)    -- 医療材料コード
                       AND rst_equipment33.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment33.is_disp = '1' AND rst_equipment33.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment34                                                                                         -- 医療材料マスタ
--     ON rst_equipment34.equipment_cd = ( ( ord.rst_cond_info :: json #>> '{9}' ) :: TEXT :: json #>> '{value}' ) :: INT            -- 医療材料コード
                   ON rst_equipment34.equipment_cd = CAST(COALESCE( ord.rst_cond_info -> '9' ->> 'value'  , '0') AS INTEGER)    -- 医療材料コード
                       AND rst_equipment34.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment34.is_disp = '1' AND rst_equipment34.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment35                                                                                         -- 医療材料マスタ
--     ON rst_equipment35.equipment_cd = ( ( ord.rst_cond_info :: json #>> '{10}' ) :: TEXT :: json #>> '{value}' ) :: INT           -- 医療材料コード
                   ON rst_equipment35.equipment_cd = CAST(COALESCE( ord.rst_cond_info -> '10' ->> 'value'  , '0') AS INTEGER)   -- 医療材料コード
                       AND rst_equipment35.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment35.is_disp = '1' AND rst_equipment35.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment36                                                                                         -- 医療材料マスタ
--     ON rst_equipment36.equipment_cd = ( ( ord.rst_cond_info :: json #>> '{11}' ) :: TEXT :: json #>> '{value}' ) :: INT           -- 医療材料コード
                   ON rst_equipment36.equipment_cd = CAST(COALESCE( ord.rst_cond_info -> '11' ->> 'value'  , '0') AS INTEGER)   -- 医療材料コード
                       AND rst_equipment36.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment36.is_disp = '1' AND rst_equipment36.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment37                                                                                         -- 医療材料マスタ
--     ON rst_equipment37.equipment_cd = ( ( ord.rst_cond_info :: json #>> '{13}' ) :: TEXT :: json #>> '{value}' ) :: INT           -- 医療材料コード
                   ON rst_equipment37.equipment_cd = CAST(COALESCE( ord.rst_cond_info -> '13' ->> 'value'  , '0') AS INTEGER)   -- 医療材料コード
                       AND rst_equipment37.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment37.is_disp = '1' AND rst_equipment37.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine31                                                                                           -- 薬剤マスタ
--     ON rst_medicine31.medicine_cd = ( ( ord.rst_cond_info :: json #>> '{15}' ) :: TEXT :: json #>> '{value}' ) :: INT             -- 薬剤コード
                   ON rst_medicine31.medicine_cd = CAST(COALESCE( ord.rst_cond_info -> '15' ->> 'value'  , '0') AS INTEGER)     -- 薬剤コード
                       AND rst_medicine31.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine31.is_disp = '1' AND rst_medicine31.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine32                                                                                           -- 薬剤マスタ
--     ON rst_medicine32.medicine_cd = ( ( ord.rst_cond_info :: json #>> '{19}' ) :: TEXT :: json #>> '{value}' ) :: INT             -- 薬剤コード
                   ON rst_medicine32.medicine_cd = CAST(COALESCE( ord.rst_cond_info -> '19' ->> 'value'  , '0') AS INTEGER)     -- 薬剤コード
                       AND rst_medicine32.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine32.is_disp = '1' AND rst_medicine32.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine33                                                                                           -- 薬剤マスタ
--     ON rst_medicine33.medicine_cd = ( ( ord.rst_cond_info :: json #>> '{25}' ) :: TEXT :: json #>> '{value}' ) :: INT             -- 薬剤コード
                   ON rst_medicine33.medicine_cd = CAST(COALESCE( ord.rst_cond_info -> '25' ->> 'value'  , '0') AS INTEGER)     -- 薬剤コード
                       AND rst_medicine33.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine33.is_disp = '1' AND rst_medicine33.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【実績】投与薬剤
         LEFT JOIN mst_procedure rst_procedure1                                                                                          -- 手技マスタ
--     ON rst_procedure1.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{0}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure1.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 0 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure1.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure1.is_disp = '1' AND rst_procedure1.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine1                                                                                            -- 薬剤マスタ
--     ON rst_medicine1.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{0}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine1.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 0 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine1.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine1.is_disp = '1' AND rst_medicine1.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure2                                                                                          -- 手技マスタ
--     ON rst_procedure2.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{1}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure2.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 1 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure2.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure2.is_disp = '1' AND rst_procedure2.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine2                                                                                            -- 薬剤マスタ
--     ON rst_medicine2.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{1}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine2.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 1 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine2.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine2.is_disp = '1' AND rst_medicine2.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure3                                                                                          -- 手技マスタ
--     ON rst_procedure3.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{2}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure3.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 2 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure3.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure3.is_disp = '1' AND rst_procedure3.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine3                                                                                            -- 薬剤マスタ
--     ON rst_medicine3.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{2}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine3.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 2 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine3.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine3.is_disp = '1' AND rst_medicine3.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure4                                                                                          -- 手技マスタ
--     ON rst_procedure4.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{3}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure4.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 3 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure4.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure4.is_disp = '1' AND rst_procedure4.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine4                                                                                            -- 薬剤マスタ
--     ON rst_medicine4.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{3}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine4.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 3 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine4.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine4.is_disp = '1' AND rst_medicine4.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure5                                                                                          -- 手技マスタ
--     ON rst_procedure5.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{4}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure5.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 4 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure5.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure5.is_disp = '1' AND rst_procedure5.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine5                                                                                            -- 薬剤マスタ
--     ON rst_medicine5.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{4}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine5.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 4 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine5.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine5.is_disp = '1' AND rst_medicine5.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure6                                                                                          -- 手技マスタ
--     ON rst_procedure6.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{5}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure6.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 5 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure6.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure6.is_disp = '1' AND rst_procedure6.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine6                                                                                            -- 薬剤マスタ
--     ON rst_medicine6.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{5}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine6.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 5 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine6.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine6.is_disp = '1' AND rst_medicine6.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure7                                                                                          -- 手技マスタ
--     ON rst_procedure7.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{6}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure7.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 6 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure7.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure7.is_disp = '1' AND rst_procedure7.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine7                                                                                            -- 薬剤マスタ
--     ON rst_medicine7.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{6}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine7.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 6 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine7.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine7.is_disp = '1' AND rst_medicine7.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure8                                                                                          -- 手技マスタ
--     ON rst_procedure8.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{7}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure8.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 7 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure8.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure8.is_disp = '1' AND rst_procedure8.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine8                                                                                            -- 薬剤マスタ
--     ON rst_medicine8.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{7}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine8.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 7 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine8.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine8.is_disp = '1' AND rst_medicine8.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure9                                                                                          -- 手技マスタ
--     ON rst_procedure9.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{8}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT      -- 手技コード
                   ON rst_procedure9.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 8 ->> 'procedure_cd'  , '0') AS INTEGER)  -- 手技コード
                       AND rst_procedure9.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_procedure9.is_disp = '1' AND rst_procedure9.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine9                                                                                            -- 薬剤マスタ
--     ON rst_medicine9.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{8}' ) :: TEXT :: json #>> '{cd}' ) :: INT                  -- 薬剤コード
                   ON rst_medicine9.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 8 ->> 'cd'  , '0') AS INTEGER)          -- 薬剤コード
                       AND rst_medicine9.is_del = '0'                                                                                                 -- 削除フラグ
                       AND rst_medicine9.is_disp = '1' AND rst_medicine9.facility_cd = /*facilityCd*/null                                                                                                         -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure10                                                                                         -- 手技マスタ
--     ON rst_procedure10.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{9}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT     -- 手技コード
                   ON rst_procedure10.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 9 ->> 'procedure_cd'  , '0') AS INTEGER) -- 手技コード
                       AND rst_procedure10.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure10.is_disp = '1' AND rst_procedure10.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine10                                                                                           -- 薬剤マスタ
--     ON rst_medicine10.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{9}' ) :: TEXT :: json #>> '{cd}' ) :: INT                 -- 薬剤コード
                   ON rst_medicine10.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 9 ->> 'cd'  , '0') AS INTEGER)         -- 薬剤コード
                       AND rst_medicine10.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine10.is_disp = '1' AND rst_medicine10.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure11                                                                                         -- 手技マスタ
--     ON rst_procedure11.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{10}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure11.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 10 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure11.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure11.is_disp = '1' AND rst_procedure11.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine11                                                                                           -- 薬剤マスタ
--     ON rst_medicine11.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{10}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine11.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 10 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine11.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine11.is_disp = '1' AND rst_medicine11.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure12                                                                                         -- 手技マスタ
--     ON rst_procedure12.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{11}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure12.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 11 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure12.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure12.is_disp = '1' AND rst_procedure12.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine12                                                                                           -- 薬剤マスタ
--     ON rst_medicine12.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{11}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine12.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 11 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine12.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine12.is_disp = '1' AND rst_medicine12.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure13                                                                                         -- 手技マスタ
--     ON rst_procedure13.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{12}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure13.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 12 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure13.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure13.is_disp = '1' AND rst_procedure13.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine13                                                                                           -- 薬剤マスタ
--     ON rst_medicine13.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{12}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine13.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 12 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine13.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine13.is_disp = '1' AND rst_medicine13.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure14                                                                                         -- 手技マスタ
--     ON rst_procedure14.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{13}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure14.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 13 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure14.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure14.is_disp = '1' AND rst_procedure14.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine14                                                                                           -- 薬剤マスタ
--     ON rst_medicine14.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{13}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine14.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 13 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine14.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine14.is_disp = '1' AND rst_medicine14.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure15                                                                                         -- 手技マスタ
--     ON rst_procedure15.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{14}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure15.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 14 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure15.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure15.is_disp = '1' AND rst_procedure15.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine15                                                                                           -- 薬剤マスタ
--     ON rst_medicine15.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{14}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine15.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 14 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine15.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine15.is_disp = '1' AND rst_medicine15.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure16                                                                                         -- 手技マスタ
--     ON rst_procedure16.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{15}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure16.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 15 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure16.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure16.is_disp = '1' AND rst_procedure16.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine16                                                                                           -- 薬剤マスタ
--     ON rst_medicine16.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{15}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine16.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 15 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine16.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine16.is_disp = '1' AND rst_medicine16.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure17                                                                                         -- 手技マスタ
--     ON rst_procedure17.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{16}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure17.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 16 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure17.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure17.is_disp = '1' AND rst_procedure17.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine17                                                                                           -- 薬剤マスタ
--     ON rst_medicine17.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{16}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine17.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 16 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine17.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine17.is_disp = '1' AND rst_medicine17.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure18                                                                                         -- 手技マスタ
--     ON rst_procedure18.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{17}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure18.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 17 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure18.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure18.is_disp = '1' AND rst_procedure18.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine18                                                                                           -- 薬剤マスタ
--     ON rst_medicine18.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{17}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine18.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 17 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine18.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine18.is_disp = '1' AND rst_medicine18.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure19                                                                                         -- 手技マスタ
--     ON rst_procedure19.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{18}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure19.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 18 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure19.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure19.is_disp = '1' AND rst_procedure19.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine19                                                                                           -- 薬剤マスタ
--     ON rst_medicine19.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{18}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine19.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 18 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine19.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine19.is_disp = '1' AND rst_medicine19.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_procedure rst_procedure20                                                                                         -- 手技マスタ
--     ON rst_procedure20.procedure_cd = ( ( ord.rst_medi_info :: json #>> '{19}' ) :: TEXT :: json #>> '{procedure_cd}' ) :: INT    -- 手技コード
                   ON rst_procedure20.procedure_cd = CAST(COALESCE( ord.rst_medi_info -> 19 ->> 'procedure_cd'  , '0') AS INTEGER)-- 手技コード
                       AND rst_procedure20.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_procedure20.is_disp = '1' AND rst_procedure20.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_medicine rst_medicine20                                                                                           -- 薬剤マスタ
--     ON rst_medicine20.medicine_cd = ( ( ord.rst_medi_info :: json #>> '{19}' ) :: TEXT :: json #>> '{cd}' ) :: INT                -- 薬剤コード
                   ON rst_medicine20.medicine_cd = CAST(COALESCE( ord.rst_medi_info -> 19 ->> 'cd'  , '0') AS INTEGER)        -- 薬剤コード
                       AND rst_medicine20.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_medicine20.is_disp = '1' AND rst_medicine20.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ

------------------------------------------------------------------------------------------------------------------------------------ 【実績】医療材料
         LEFT JOIN mst_equipment rst_equipment1                                                                                          -- 医療材料マスタ
--     ON rst_equipment1.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{0}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment1.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 0 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment1.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment1.is_disp = '1' AND rst_equipment1.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment2                                                                                          -- 医療材料マスタ
--     ON rst_equipment2.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{1}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment2.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 1 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment2.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment2.is_disp = '1' AND rst_equipment2.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment3                                                                                          -- 医療材料マスタ
--     ON rst_equipment3.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{2}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment3.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 2 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment3.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment3.is_disp = '1' AND rst_equipment3.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment4                                                                                          -- 医療材料マスタ
--     ON rst_equipment4.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{3}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment4.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 3 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment4.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment4.is_disp = '1' AND rst_equipment4.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment5                                                                                          -- 医療材料マスタ
--     ON rst_equipment5.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{4}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment5.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 4 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment5.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment5.is_disp = '1' AND rst_equipment5.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment6                                                                                          -- 医療材料マスタ
--     ON rst_equipment6.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{5}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment6.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 5 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment6.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment6.is_disp = '1' AND rst_equipment6.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment7                                                                                          -- 医療材料マスタ
--     ON rst_equipment7.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{6}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment7.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 6 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment7.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment7.is_disp = '1' AND rst_equipment7.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment8                                                                                          -- 医療材料マスタ
--     ON rst_equipment8.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{7}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment8.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 7 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment8.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment8.is_disp = '1' AND rst_equipment8.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment9                                                                                          -- 医療材料マスタ
--     ON rst_equipment9.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{8}' ) :: TEXT :: json #>> '{cd}' ) :: INT               -- 医療材料コード
                   ON rst_equipment9.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 8 ->> 'cd'  , '0') AS INTEGER)       -- 医療材料コード
                       AND rst_equipment9.is_del = '0'                                                                                                -- 削除フラグ
                       AND rst_equipment9.is_disp = '1' AND rst_equipment9.facility_cd = /*facilityCd*/null                                                                                                        -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment10                                                                                         -- 医療材料マスタ
--     ON rst_equipment10.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{9}' ) :: TEXT :: json #>> '{cd}' ) :: INT              -- 医療材料コード
                   ON rst_equipment10.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 9 ->> 'cd'  , '0') AS INTEGER)      -- 医療材料コード
                       AND rst_equipment10.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment10.is_disp = '1' AND rst_equipment10.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment11                                                                                         -- 医療材料マスタ
--     ON rst_equipment11.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{10}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment11.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 10 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment11.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment11.is_disp = '1' AND rst_equipment11.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment12                                                                                         -- 医療材料マスタ
--     ON rst_equipment12.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{11}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment12.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 11 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment12.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment12.is_disp = '1' AND rst_equipment12.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment13                                                                                         -- 医療材料マスタ
--     ON rst_equipment13.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{12}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment13.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 12 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment13.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment13.is_disp = '1' AND rst_equipment13.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment14                                                                                         -- 医療材料マスタ
--     ON rst_equipment14.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{13}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment14.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 13 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment14.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment14.is_disp = '1' AND rst_equipment14.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment15                                                                                         -- 医療材料マスタ
--     ON rst_equipment15.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{14}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment15.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 14 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment15.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment15.is_disp = '1' AND rst_equipment15.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment16                                                                                         -- 医療材料マスタ
--     ON rst_equipment16.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{15}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment16.equipment_cd = CAST(COALESCE(ord.ind_equip_info -> 15 ->> 'cd'  , '0') AS INTEGER) -- 医療材料コード
                       AND rst_equipment16.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment16.is_disp = '1' AND rst_equipment16.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment17                                                                                         -- 医療材料マスタ
--     ON rst_equipment17.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{16}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment17.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 16 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment17.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment17.is_disp = '1' AND rst_equipment17.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment18                                                                                         -- 医療材料マスタ
--     ON rst_equipment18.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{17}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment18.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 17 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment18.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment18.is_disp = '1' AND rst_equipment18.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment19                                                                                         -- 医療材料マスタ
--     ON rst_equipment19.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{18}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment19.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 18 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment19.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment19.is_disp = '1' AND rst_equipment19.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ
         LEFT JOIN mst_equipment rst_equipment20                                                                                         -- 医療材料マスタ
--     ON rst_equipment20.equipment_cd = ( ( ord.rst_equip_info :: json #>> '{19}' ) :: TEXT :: json #>> '{cd}' ) :: INT             -- 医療材料コード
                   ON rst_equipment20.equipment_cd = CAST(COALESCE( ord.rst_equip_info -> 19 ->> 'cd'  , '0') AS INTEGER)     -- 医療材料コード
                       AND rst_equipment20.is_del = '0'                                                                                               -- 削除フラグ
                       AND rst_equipment20.is_disp = '1' AND rst_equipment20.facility_cd = /*facilityCd*/null                                                                                                       -- 表示フラグ

-- del by zhaohan 2022-10-20 [6523] バックエンドの処理時間かかるのでエラー発生。 --start
-- WHERE ord.is_del = '0'                                                                                                           -- 削除フラグ
--   AND ord.facility_cd = /*facilityCd*/null                                                                                       -- 施設コード
--   AND ord.pat_id in /*patIdList*/(null)                                                                                          -- 患者ID
--   -- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 start
--   -- AND (ord.rst_dialysis_state = '0' OR ord.rst_dialysis_state = '6')
--   -- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 end
--   AND (
--        ( ord.treat_date >= REPLACE ( /*startDate*/NULL, '-', '' )                                                                -- 治療日
--        AND ord.treat_date <= REPLACE ( /*endDate*/NULL, '-', '' ) )                                                              -- 治療日
--
--        OR ( ord.rst_start_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP                                 -- 実績：治療開始日時
--        AND ord.rst_start_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP )                                -- 実績：治療開始日時
--
--        OR ( ord.rst_end_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP                                   -- 実績：治療終了日時
--        AND ord.rst_end_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP )                                  -- 実績：治療終了日時
--   )
-- del by zhaohan 2022-10-20 [6523] バックエンドの処理時間かかるのでエラー発生。 --end

order by
    ord.pat_id, ord.treat_date, ord.rst_dialysis_state, ord.ord_no
;
