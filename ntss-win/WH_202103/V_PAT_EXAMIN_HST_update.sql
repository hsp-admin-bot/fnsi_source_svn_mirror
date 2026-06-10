update V_PAT_EXAMIN_HST
set PATID ='@patid',
		EXAM_DATE=to_date('@examDate','yyyy-mm-dd hh24:mi:ss'),
		ORDER_CLASS='@orderClass',
		ITEM_UP_DATE='@itemUpDate',
		EXAM_ITEM_CODE='@examItemCode',
		EXAM_ITEM_CODE2='@examItemCode2',
		EXAM_ITEM_CODE3='@examItemCode3',
		EXAM_ITEM_NAME='@EXAM_ITEM_NAME',
		EXAM_RST='@EXAM_RST',
		EXAM_CLASS_RST='@EXAM_CLASS_RST',
		COMMENTS='@COMMENTS'

 where PATID = @patid;