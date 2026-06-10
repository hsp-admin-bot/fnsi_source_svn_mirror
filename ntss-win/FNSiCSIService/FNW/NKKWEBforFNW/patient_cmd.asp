<%@ LANGUAGE="VBScript" %>
<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　患者選択機能asp
'// ファイル名：patient_cmd.asp
'// 説明      ：患者一覧から次画面へ遷移するためのフレーム
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付		担当				理由
'//	2010/01/15	堀内英史			FN2版から流用
'//
'///////////////////////////////////////////////////////////////////////////////

Option Explicit
%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=x-sjis">
		<link rel=stylesheet href="form.css" type="text/css">
	</head>
	
	<body>
	<table align=center border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td>
				<form name="form2" target=main method="post" action="dialysishist.asp">
				<center>
					<input type="button" name="next" value="    OK    " class="button" onClick="fnNext()">
					<input type="button" name="back" value="キャンセル" class="button" onClick="parent.frame1.history.back()">
					<input type="hidden" name="patid" value="">
					</center>
				</form>
			</td>
		</tr>
	</table>
	</body>
	

	<script language="JavaScript">
	<!--
		//-----------------
		// 送信データ処理
		//-----------------
		function fnNext() {
			if(parent.frame1.document.form1.pat_id.length == void(0)){
				if (parent.frame1.document.form1.pat_id.checked == true) {
					form2.patid.value = parent.frame1.document.form1.pat_id.value;
					form2.submit();
				}
			}else{
				for(i = 0; i < parent.frame1.form1.pat_id.length ;i++) {
					if ( parent.frame1.form1.pat_id[i].checked == true ) {
						form2.patid.value = parent.frame1.form1.pat_id[i].value;
						form2.submit();
						return;
					}
				}
			}
		}
	-->
	</script>
</html>
