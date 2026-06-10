SELECT COUNT (*) FROM
    (SELECT SCHEDULE.BED_CD,MAIN.PAT_ID
      FROM ORD_SCHEDULE SCHEDULE
      LEFT JOIN ORD_MAIN MAIN
        ON SCHEDULE.FACILITY_CD = MAIN.FACILITY_CD
       AND SCHEDULE.ORD_NO      = MAIN.ORD_NO
	 WHERE SCHEDULE.FACILITY_CD = /*facilityCd*/NULL
	 AND MAIN.PAT_ID =  /*patId*/NULL
	 AND MAIN.IS_DEL          = '0'
	 /*%if null != searchStartDate*/
       AND MAIN.TREAT_DATE >= /*searchStartDate*/NULL
	   /*%end*/
	   /*%if null != searchEndDate*/
       AND MAIN.TREAT_DATE <= /*searchEndDate*/NULL
	   /*%end*/
	 GROUP BY  MAIN.PAT_ID,SCHEDULE.BED_CD) A
;
