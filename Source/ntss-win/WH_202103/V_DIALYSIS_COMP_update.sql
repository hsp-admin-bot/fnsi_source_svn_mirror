update V_DIALYSIS_COMP
set PATID ='@patid',
		OCCUR_DATE=to_date('@occurDate','yyyy-mm-dd hh24:mi:ss'),
		MEASURECLASS='@measureclass',
		REQCODE='@reqcode',
		COMPLAINT ='@complaint',
		TREAT_NAME='@treatName',
		MEDICINE_CD1='@medicineCd1',
		MEDICINE_CD2='@medicineCd2',
		MEDICINE_NAME='@medicineName',
		AMOUNT='@amount',
		UNIT='@unit',
		PROCEDURE_NAME='@procedureName',
		PROCEDURE_CD1='@procedureCd1',
		PROCEDURE_CD2='@procedureCd2',
		TREAT_PERSON_NAME='@treatPersonName',
		UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss')

 where PATID = @patid;