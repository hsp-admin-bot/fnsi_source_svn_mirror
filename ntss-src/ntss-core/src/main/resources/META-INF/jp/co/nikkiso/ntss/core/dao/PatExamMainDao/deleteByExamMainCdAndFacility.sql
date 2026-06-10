--   add FNSI-「幹対応残課題一覧.xlsx」№10対応 田
DELETE
FROM
  pat_exam_main
WHERE
  exam_main_cd = /*patExamMain.examMainCd*/'0'
  AND  facility_cd = /*patExamMain.facilityCd*/'0'
;
