<%@ LANGUAGE="VBScript" %>
<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　患者一覧表示asp
'// ファイル名：patient_main.asp
'// 説明      ：患者一覧表示のメインフレーム
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付		担当				理由
'//	2010/01/15	堀内英史			FN2版から流用カスタマイズ
'//
'///////////////////////////////////////////////////////////////////////////////

Option Explicit
%>
<!--#include file="include/functions.asp"-->
<!--#include file="include/PatBasic.asp"-->
<!--#include file="include/CommonConst.asp"-->
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

Dim arrSelectWord()
Dim word
Dim blnHit

select case Req("Key1")
	case "0":
		Redim arrSelectWord(14)
		arrSelectWord(0) = "ア"
		arrSelectWord(1) = "イ"
		arrSelectWord(2) = "ウ"
		arrSelectWord(3) = "エ"
		arrSelectWord(4) = "オ"
		arrSelectWord(5) = "ｱ"
		arrSelectWord(6) = "ｲ"
		arrSelectWord(7) = "ｳ"
		arrSelectWord(8) = "ｴ"
		arrSelectWord(9) = "ｵ"
		arrSelectWord(10) = "あ"
		arrSelectWord(11) = "い"
		arrSelectWord(12) = "う"
		arrSelectWord(13) = "え"
		arrSelectWord(14) = "お"
	case "1":
		ReDim arrSelectWord(24)
		arrSelectWord(0) = "カ"
		arrSelectWord(1) = "キ"
		arrSelectWord(2) = "ク"
		arrSelectWord(3) = "ケ"
		arrSelectWord(4) = "コ"
		arrSelectWord(5) = "ガ"
		arrSelectWord(6) = "ギ"
		arrSelectWord(7) = "グ"
		arrSelectWord(8) = "ゲ"
		arrSelectWord(9) = "ゴ"
		arrSelectWord(10) = "ｶ"
		arrSelectWord(11) = "ｷ"
		arrSelectWord(12) = "ｸ"
		arrSelectWord(13) = "ｹ"
		arrSelectWord(14) = "ｺ"
		arrSelectWord(15) = "か"
		arrSelectWord(16) = "き"
		arrSelectWord(17) = "く"
		arrSelectWord(18) = "け"
		arrSelectWord(19) = "こ"
		arrSelectWord(20) = "が"
		arrSelectWord(21) = "ぎ"
		arrSelectWord(22) = "ぐ"
		arrSelectWord(23) = "げ"
		arrSelectWord(24) = "ご"
	case "2":
		ReDim arrSelectWord(24)
		arrSelectWord(0) = "サ"
		arrSelectWord(1) = "シ"
		arrSelectWord(2) = "ス"
		arrSelectWord(3) = "セ"
		arrSelectWord(4) = "ソ"
		arrSelectWord(5) = "ザ"
		arrSelectWord(6) = "ジ"
		arrSelectWord(7) = "ズ"
		arrSelectWord(8) = "ゼ"
		arrSelectWord(9) = "ゾ"
		arrSelectWord(10) = "ｻ"
		arrSelectWord(11) = "ｼ"
		arrSelectWord(12) = "ｽ"
		arrSelectWord(13) = "ｾ"
		arrSelectWord(14) = "ｿ"
		arrSelectWord(15) = "さ"
		arrSelectWord(16) = "し"
		arrSelectWord(17) = "す"
		arrSelectWord(18) = "せ"
		arrSelectWord(19) = "そ"
		arrSelectWord(20) = "ざ"
		arrSelectWord(21) = "じ"
		arrSelectWord(22) = "ず"
		arrSelectWord(23) = "ぜ"
		arrSelectWord(24) = "ぞ"
	case "3":
		ReDim arrSelectWord(24)
		arrSelectWord(0) = "タ"
		arrSelectWord(1) = "チ"
		arrSelectWord(2) = "ツ"
		arrSelectWord(3) = "テ"
		arrSelectWord(4) = "ト"
		arrSelectWord(5) = "ダ"
		arrSelectWord(6) = "ヂ"
		arrSelectWord(7) = "ヅ"
		arrSelectWord(8) = "デ"
		arrSelectWord(9) = "ド"
		arrSelectWord(10) = "ﾀ"
		arrSelectWord(11) = "ﾁ"
		arrSelectWord(12) = "ﾂ"
		arrSelectWord(13) = "ﾃ"
		arrSelectWord(14) = "ﾄ"
		arrSelectWord(15) = "た"
		arrSelectWord(16) = "ち"
		arrSelectWord(17) = "つ"
		arrSelectWord(18) = "て"
		arrSelectWord(19) = "と"
		arrSelectWord(20) = "だ"
		arrSelectWord(21) = "ぢ"
		arrSelectWord(22) = "づ"
		arrSelectWord(23) = "で"
		arrSelectWord(24) = "ど"
		Sql = Sql & ") "
	case "4":
		ReDim arrSelectWord(14)
		arrSelectWord(0) = "ナ"
		arrSelectWord(1) = "ニ"
		arrSelectWord(2) = "ヌ"
		arrSelectWord(3) = "ネ"
		arrSelectWord(4) = "ノ"
		arrSelectWord(5) = "ﾅ"
		arrSelectWord(6) = "ﾆ"
		arrSelectWord(7) = "ﾇ"
		arrSelectWord(8) = "ﾈ"
		arrSelectWord(9) = "ﾉ"
		arrSelectWord(10) = "な"
		arrSelectWord(11) = "に"
		arrSelectWord(12) = "ぬ"
		arrSelectWord(13) = "ね"
		arrSelectWord(14) = "の"
	case "5":
		ReDim arrSelectWord(24)
		arrSelectWord(0) = "ハ"
		arrSelectWord(1) = "ヒ"
		arrSelectWord(2) = "フ"
		arrSelectWord(3) = "ヘ"
		arrSelectWord(4) = "ホ"
		arrSelectWord(5) = "バ"
		arrSelectWord(6) = "ビ"
		arrSelectWord(7) = "ブ"
		arrSelectWord(8) = "べ"
		arrSelectWord(9) = "ボ"
		arrSelectWord(10) = "ﾊ"
		arrSelectWord(11) = "ﾋ"
		arrSelectWord(12) = "ﾌ"
		arrSelectWord(13) = "ﾍ"
		arrSelectWord(14) = "ﾎ"
		arrSelectWord(15) = "は"
		arrSelectWord(16) = "ひ"
		arrSelectWord(17) = "ふ"
		arrSelectWord(18) = "へ"
		arrSelectWord(19) = "ほ"
		arrSelectWord(20) = "ば"
		arrSelectWord(21) = "び"
		arrSelectWord(22) = "ぶ"
		arrSelectWord(23) = "べ"
		arrSelectWord(24) = "ぼ"
	case "6":
		ReDim arrSelectWord(14)
		arrSelectWord(0) = "マ"
		arrSelectWord(1) = "ミ"
		arrSelectWord(2) = "ム"
		arrSelectWord(3) = "メ"
		arrSelectWord(4) = "モ"
		arrSelectWord(5) = "ﾏ"
		arrSelectWord(6) = "ﾐ"
		arrSelectWord(7) = "ﾑ"
		arrSelectWord(8) = "ﾒ"
		arrSelectWord(9) = "ﾓ"
		arrSelectWord(10) = "ま"
		arrSelectWord(11) = "み"
		arrSelectWord(12) = "む"
		arrSelectWord(13) = "め"
		arrSelectWord(14) = "も"
	case "7":
		ReDim arrSelectWord(8)
		arrSelectWord(0) = "ヤ"
		arrSelectWord(1) = "ユ"
		arrSelectWord(2) = "ヨ"
		arrSelectWord(3) = "ﾔ"
		arrSelectWord(4) = "ﾕ"
		arrSelectWord(5) = "ﾖ"
		arrSelectWord(6) = "や"
		arrSelectWord(7) = "ゆ"
		arrSelectWord(8) = "よ"
	case "8":
		ReDim arrSelectWord(14)
		arrSelectWord(0) = "ラ"
		arrSelectWord(1) = "リ"
		arrSelectWord(2) = "ル"
		arrSelectWord(3) = "レ"
		arrSelectWord(4) = "ロ"
		arrSelectWord(5) = "ﾗ"
		arrSelectWord(6) = "ﾘ"
		arrSelectWord(7) = "ﾙ"
		arrSelectWord(8) = "ﾚ"
		arrSelectWord(9) = "ﾛ"
		arrSelectWord(10) = "ら"
		arrSelectWord(11) = "り"
		arrSelectWord(12) = "る"
		arrSelectWord(13) = "れ"
		arrSelectWord(14) = "ろ"
	case "9":
		ReDim arrSelectWord(8)
		arrSelectWord(0) = "ワ"
		arrSelectWord(1) = "ヲ"
		arrSelectWord(2) = "ン"
		arrSelectWord(3) = "ﾜ"
		arrSelectWord(4) = "ｦ"
		arrSelectWord(5) = "ﾝ"
		arrSelectWord(6) = "わ"
		arrSelectWord(7) = "を"
		arrSelectWord(8) = "ん"
	case "10":
		Redim arrSelectWord(0)
		arrSelectWord(0) = "null"
end select


Dim XMLDoc
Dim rtResult
Dim nodeList
Dim node
Dim docRoot
Dim patCount
Dim strValue
Dim strPath

Set XMLDoc = Server.CreateObject("Microsoft.XMLDOM") 
XMLDoc.async = false 
'"./dia_rep/pdfserverinfo.xml"
strPath = Server.MapPath("./"&pdfPath&fileName_pdfServerInfo)
response.write "<!-- "&strPath&" -->"
rtResult = XMLDoc.load(strPath) 

If rtResult = True Then 

	Set docRoot = XMLDoc.documentElement 
	Set nodeList = docRoot.selectNodes("/rootNode/PATIENT")

	patCount = nodeList.Length

Else
response.write "<!-- xml not found. -->"

End If 

%>
<!-- 患者一覧選択ページ -->
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=x-sjis">
		<title>患者選択</title>
		<link rel=stylesheet href="form.css" type="text/css">
	</head>
	
	<body onLoad="fnOnLoad()">
	<table align=center border="0" cellspacing="0" cellpadding="0">
	<tr height=50><td align="right"></td></tr>
	<tr>
		<td>
			<center><h1>患者選択</h1></center>
		</td>
	</tr>
	<tr>
		<td>
				<form name="form1">
				<table border="1" align=center cellpadding="3" cellspacing="0">
					<tr bgcolor="#3366cc">
						<th><font color="#fffff">選択</font></th>
						<th><font color="#fffff">患者ID</font></th>
						<th><font color="#fffff">患者名</font></th>
						<th><font color="#fffff">フリガナ</font></th>
						<th><font color="#fffff">性別</font></th>
						<th><font color="#fffff">血液型</font></th>
						<th><font color="#fffff">年齢</font></th>
					</tr>
<%
'----------------------------------
' データの表示処理
'----------------------------------
				if patCount = 0 then
%>
					<tr>
						<td colspan="7" align="center">該当する患者がいません</td>
					</tr>
					<tr>
						<td colspan="7"><hr></td>
					</tr>
<%
				else
					For Each node In nodeList

						'絞り込み処理
						blnHit = true
						strValue = Left(node.getAttributeNode("KANA").Value, 1)
						For Each word In arrSelectWord
							if word = "null" and strValue = "" then
								blnHit = true
								exit for
							end if
							
							blnHit = false
							if strValue = word then
								blnHit = true
								exit for
							end if
						Next

						if blnHit = true then
					  
							if iCount mod 2 = 0 then
	%>
						<tr>
	<%
							else
	%>
						<tr bgcolor = "#DADFEA">
	<%
							end if
	%>

							<% strValue = node.getAttributeNode("DISP_PATID").Value %>
							<td align="center"><input type="radio" name="pat_id" value="<%=strValue%>"></td>
							<% strValue = node.getAttributeNode("DISP_PATID").Value&"<!-- "&node.getAttributeNode("PATID").Value&" -->" %>
							<%if strValue <> "" then%>
								<td><%=strValue%></td>
							<%else%>
								<td><%="&nbsp"%></td>
							<%end if%>	

							<% strValue = node.getAttributeNode("NAME").Value %>
							<%if strValue <> "" then%>
								<td><%=strValue%></td>
							<%else%>
								<td><%="&nbsp"%></td>
							<%end if%>	

							<% strValue = node.getAttributeNode("KANA").Value %>
							<%if strValue <> "" then%>
								<td><%=strValue%></td>
							<%else%>
								<td><%="&nbsp"%></td>
							<%end if%>	

							<% strValue = getSex(node.getAttributeNode("SEX").Value) %>
							<%if strValue <> "" then%>
								<td><%=strValue%></td>
							<%else%>
								<td><%="&nbsp"%></td>
							<%end if%>	

							<% strValue = getBloodType(node.getAttributeNode("BLOODABO").Value, node.getAttributeNode("BLOODRH").Value) %>
							<%if strValue <> "" then%>
								<td><%=strValue%></td>
							<%else%>
								<td><%="&nbsp"%></td>
							<%end if%>	

							<% strValue = node.getAttributeNode("AGE").Value %>
							<%if strValue <> "" then%>
								<td><%=strValue%></td>
							<%else%>
								<td><%="&nbsp"%></td>
							<%end if%>	
						</tr>
	<%
							iCount = iCount + 1
						end if
					NEXT
						
					if iCount = 0 then
%>
						<tr>
							<td colspan="7" align="center">該当する患者がいません</td>
						</tr>
						<tr>
							<td colspan="7"><hr></td>
						</tr>
<%
					end if
						
				end if
%>
				</table>
		</td>
	</tr>
	<% Session("pat_count") = iCount %>
	</table>
	</body>
	
	<script language="JavaScript">
	<!--
	//-----------------
	//チェックボックス処理
	//-----------------
	function fnOnLoad() {
		parent.frame2.location.href = "patient_cmd.asp";
		try{
			if(form1.pat_id.length == void(0)){
				form1.pat_id.checked = true;
			}else{
				for (i=0; i < form1.pat_id.length; i++) {
					if(form1.pat_id[i].checked == true) {
						return;
					}
				}
				form1.pat_id[0].checked = true;
			}
		} catch(n) {}
	}
	-->
	</script>
</html>
