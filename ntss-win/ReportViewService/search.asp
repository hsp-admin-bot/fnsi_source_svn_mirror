<%@ LANGUAGE="VBScript" %>
<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　患者一覧制御asp
'// ファイル名：search.asp
'// 説明      ：患者一覧の表示制御を行う為のasp
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'// 日付        担当                理由
'// 2020/05/20  TEX-SOL             既存システムより流用
'//
'///////////////////////////////////////////////////////////////////////////////

Option Explicit
%>
<!--#include file="include/functions.asp"-->
<!--#include file="include/PatBasic.asp"-->

<%
'-----------------
' 送信文字列の取得
'-----------------
call GetArg

'-----------------
' 変数宣言
'-----------------
dim ErrMsg
dim Sql
dim iCount

dim sex
dim bloodtype
dim bloodabo
dim bloodrh

iCount = 0
%>

<!-- 患者検索条件 -->
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=x-sjis">
		<title>患者検索</title>
		<link rel=stylesheet href="form.css" type="text/css">
	</head>
	
	<body>
	<form name="key" method="post" target=main action="patient.asp">
		<input type="hidden" name="Key1" value="">
	</form>
	<table class="no-border tbl-center search-info">
		<tr><th colspan="5">キーワード検索</th></tr>
		<tr>
			<td><img src="image/aa1.bmp" onclick=fnKeyword(0)></td>
			<td><img src="image/ka1.bmp" onclick=fnKeyword(1)></td>
			<td><img src="image/sa1.bmp" onclick=fnKeyword(2)></td>
			<td><img src="image/ta1.bmp" onclick=fnKeyword(3)></td>
			<td><img src="image/na1.bmp" onclick=fnKeyword(4)></td>
		</tr>
		<tr>
			<td><img src="image/ha1.bmp" onclick=fnKeyword(5)></td>
			<td><img src="image/ma1.bmp" onclick=fnKeyword(6)></td>
			<td><img src="image/ya1.bmp" onclick=fnKeyword(7)></td>
			<td><img src="image/ra1.bmp" onclick=fnKeyword(8)></td>
			<td><img src="image/wa1.bmp" onclick=fnKeyword(9)></td>
		</tr>
		<tr>
			<td><img src="image/nn1.bmp" onclick=fnKeyword(10)></td>
			<td><img src="image/al1.bmp" onclick=fnKeyword("")></td>
		</tr>
	</table>
	<script language="JavaScript">
	<!--
	function fnKeyword(index) {
		key.Key1.value = index;
		key.submit();
	}
	-->
	</script>
</html>
