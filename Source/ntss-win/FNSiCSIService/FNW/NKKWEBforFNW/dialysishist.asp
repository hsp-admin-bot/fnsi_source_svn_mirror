<%@ LANGUAGE="VBScript" %>
<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名	：FNW版標準WEB-IF　患者別透析レポート一覧表示asp
'// ファイル名：dialysishist.asp
'// 説明	  ：透析レポート一覧表示のベースフレーム
'//
'// Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'// 日付		担当				理由
'// 2010/01/15  堀内英史			FN2版から流用カスタマイズ
'//
'///////////////////////////////////////////////////////////////////////////////

Option Explicit
%>
<!--#include file="include/functions.asp"-->
<!--#include file="include/PatBasic.asp"-->
<!--#include file="include/CommonConst.asp"-->
<% Response.CacheControl = "no-cache" %>
<% Response.AddHeader "Pragma", "no-cache" %>
<% Response.Expires = -1 %>
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
dim j
dim i

dim startdate
dim enddate

dim objFSO
Dim aryData()			   '全データ配列
Dim aryComboData			'コンボボックス用データ配列


iCount = 0				  '行毎に背景色を変える

Session("aryData") = ""	 '一覧データ配列　格納Session
Set objFSO = CreateObject("Scripting.FileSystemObject")

'Nullチェック関数
function gfNz(strArray,strRet)
	gfNz = strArray
	if Trim(strArray) = "" or IsNull(strArray) then
		gfNz = strRet
	end if
end function

%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=x-sjis">
		<title>透析実績一覧</title>
		<link rel=stylesheet href="form.css" type="text/css">
	</head>
	<body>
<%
	if Req("patid") = "" then
%>
		<h1>患者を選択してください。</h1>
	</body>
</html>
<%
	else
%>
	<table align=center border="0" cellspacing="0" cellpadding="0">
	<tr><td>
		<table width="100%" cellspacing="0" cellpadding="0" noborder>
		<tr>
		<td valign="top" width="20%">
			<img src="image/nikkiso.bmp">
		</td>
		<td valign="bottom" width="60%">
			<center><br /><h1>患者情報</h1></center>
		</td>
		<td align="right" width="20%">
		</td>
		</tr>
		</table>
	</td></tr>
	<tr><td>
		<Table Border="1" Width="640" Height="60" CellSpacing="0" BgColor="white">
<%

Dim XMLDoc
Dim rtResult
Dim patientList
Dim patientNode
Dim reportNode
Dim node
Dim docRoot
Dim patCount
Dim reportCount
Dim strValue
Dim strFilename
Dim strPatId
Dim strDispPatId
Dim repName

Set XMLDoc = Server.CreateObject("Microsoft.XMLDOM") 
XMLDoc.async = false 

'PDFサーバ管理情報をロード
'rtResult = XMLDoc.load(Server.MapPath("./dia_rep/pdfserverinfo.xml")) 
rtResult = XMLDoc.load(Server.MapPath("./"&pdfPath&fileName_pdfServerInfo)) 

patCount = 0
If rtResult = True Then 
	Set docRoot = XMLDoc.documentElement 

	strDispPatId = Req("patid")
	For i = 1 to Len(Req("patid"))
		if left(strDispPatId, 1) = "0" then
			if Len(strDispPatId) = 1 then
				exit for
			end if
			strDispPatId = right(strDispPatId, Len(strDispPatId) - 1)
		else
			exit for
		end if
	Next

	strPatId = ""
	Set patientList = docRoot.selectNodes("/rootNode/PATIENT")
	For Each node In patientList
		if node.getAttributeNode("DISP_PATID").Value = strDispPatId then
			'strPatId = ZeroPad(node.getAttributeNode("PATID").Value)
			strPatId = node.getAttributeNode("DISP_PATID").Value
			strPatId = Trim(strPatId)
			exit for
		end if
	Next

	if strPatId <> "" then
		'患者情報XMLをロード
'	   rtResult = XMLDoc.load(Server.MapPath("./dia_rep/"&strPatId&"/patientinfo.xml")) 
		rtResult = XMLDoc.load(Server.MapPath("./"&pdfPath&strPatId&"/"&fileName_patientInfo)) 
		If rtResult = True Then 
			Set docRoot = XMLDoc.documentElement 
			'患者情報を取得
			Set patientNode = docRoot.selectSingleNode("/rootNode/PATIENT")
			patCount = 1
			'レポート情報を取得
			Set reportNode = docRoot.selectNodes("/rootNode/REPORTS/REPORT")
			reportCount = reportNode.Length
		end If
	end if
end If


'----------------------------------
' データの表示処理
'----------------------------------
	response.write "<!-- PATID="&strPatId&"-->"
	if patCount = 0 then
%>
		<Tr>
			<Th Align="left" Valign="middle" Width="120"  BgColor="#3366cc"><font color="#fffff">患者ID</Font></Th>
			<Td Align="left" Valign="middle" Width="240" ><%=strDispPatId%></Td>
			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">生年月日</Font></Th>
			<Td Align="left" Valign="middle" Width="110" >&nbsp;</Td>
			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">年齢</Font></Th>
			<Td Align="left" Valign="middle" Width="110" >&nbsp;</Td>
		</Tr>
		<Tr>
			<Th Align="left" Valign="middle" Width="120"  BgColor="#3366cc"><font color="#fffff"> 氏名 </Font></Th>
			<Td Align="left" Valign="middle" Width="430"  ColSpan="3">該当患者が存在しません。</Td>
			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">性別</Font></Th>
			<Td Align="left" Valign="middle" Width="110"  >&nbsp;</Td>
		</Tr>
		<Tr>
			<Th Align="left" Valign="middle" Width="120"  BgColor="#3366cc"><font color="#fffff"> フリガナ </Font></Th>
			<Td Align="left" Valign="middle" Width="430"  ColSpan="3">&nbsp;</Td>
			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">入外区分</Font></Th>
			<Td Align="left" Valign="middle" Width="110" >&nbsp;</Td>
		</Tr>
<%
	else
%>
		<Tr>
			<Th Align="left" Valign="middle" Width="80"  BgColor="#3366cc"><font color="#fffff">患者ID</Font></Th>
			<Td Align="left" Valign="middle" Width="120" ><%=strDispPatId%></Td>
			
			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">生年月日</Font></Th>
			<%
			strValue = ToWareki(patientNode.selectSingleNode("BIRTHDAY").text)
			if strValue = "" then
				strValue = "&nbsp;"
			end if
			%>
			<Td Align="left" Valign="middle" Width="170" ><%=strValue%></Td>

			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">年齢</Font></Th>
			<%
			strValue = patientNode.selectSingleNode("AGE").text
			if strValue = "" then
				strValue = "&nbsp;"
			else
				strValue = strValue & " 歳"
			end if
			%>
			<Td Align="left" Valign="middle" Width="110" ><%=strValue%></Td>
		</Tr>
		<Tr>
			<Th Align="left" Valign="middle" Width="120"  BgColor="#3366cc"><font color="#fffff"> 氏名 </Font></Th>
			<%
			strValue = patientNode.selectSingleNode("NAME").text
			%>
			<Td Align="left" Valign="middle" Width="430"  ColSpan="3"><%=strValue%></Td>
			
			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">性別</Font></Th>
			<%
			strValue = getSex(patientNode.selectSingleNode("SEX").text)
			%>
			<Td Align="left" Valign="middle" Width="110"  ><%=strValue%></Td>
		</Tr>
		<Tr>
			<Th Align="left" Valign="middle" Width="120"  BgColor="#3366cc"><font color="#fffff"> フリガナ </Font></Th>
			<%
			strValue = patientNode.selectSingleNode("KANA").text
			if strValue = "" then
				strValue = "&nbsp;"
			end if
			%>
			<Td Align="left" Valign="middle" Width="430"  ColSpan="3"><%=strValue%></Td>

			<Th Align="left" Valign="middle" Width="120" BgColor="#3366cc"><font color="#fffff">入外区分</Font></Th>
			<%
			strValue = getInOut(patientNode.selectSingleNode("INOUT").text)
			%>
			<Td Align="left" Valign="middle" Width="110" ><%=strValue%></Td>
		</Tr>
<%
	end if
%>
		</Table>
	</td></tr>
	<tr height=20><td align="right"></td></tr>
	<tr><td><center><h1>透析実績一覧</h1></center></td></tr>
	<tr><td>
		<form name="form1">
		<table valign=top Border="1" Width="640" Height="60" CellSpacing="0" BgColor="white">
		<tr BgColor="#3366cc">
			<th><font color="#fffff">透析日</font></th>
			<th><font color="#fffff">透析開始時刻</font></th>
			<th><font color="#fffff">ベッド名</font></th>
			<th><font color="#fffff">レポート</font></th>
		</tr>
<%
'-----------------
' 条件の作成
'-----------------
enddate = date
startdate = dateadd("m",-12,enddate)

'※※※1年前から今日までのレポートを一覧表示している
'response.write enddate&"<br />"
'response.write startdate&"<br />"

'----------------------------------
' データの表示処理
'----------------------------------
	if reportCount = 0 then
%>
					<tr>
						<% '>>>>> 2010.01.19 h.horiuchi 1年間の限定表示は廃止 %>
						<% '<td colspan="4" align="center">透析実績がありません。<#="（"&startdate&"～"&enddate&"）"#></td> %>
						<td colspan="4" align="center">透析実績がありません。</td>
						<% '<<<<< 2010.01.19 h.horiuchi 1年間の限定表示は廃止 %>
					</tr>
<%
	else

		For Each node In reportNode

		'>>>>> 2010.01.19 h.horiuchi 1年間の限定表示は廃止
		'if startdate <= DateValue(node.getAttributeNode("STARTDATE").Value) and DateValue(node.getAttributeNode("STARTDATE").Value) <= enddate then
		'<<<<< 2010.01.19 h.horiuchi 1年間の限定表示は廃止

			'■一覧データを配列に格納
'			ReDim Preserve aryData(2,iCount)
			ReDim Preserve aryData(4,iCount)
			
			strValue = node.getAttributeNode("STARTDATE").Value
			strValue = strValue & "（" & WeekDayName(Weekday(strValue), True) & "）"
			
			aryData(0, iCount) = strValue & "<br />" & node.getAttributeNode("STARTTIME").Value	 '透析実績　開始日時 YYYY/MM/DD (DAY) HH24:MI:SS
			'aryData(1, iCount) = ZeroPad(strPatId) & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)									'"患者ID"-"透析日時(YYYYMMDDHH24MISS)"
			aryData(1, iCount) = strPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)									'"患者ID"-"透析日時(YYYYMMDDHH24MISS)"

			if iCount mod 2 = 0 then
%>				  <tr>
<%		  else
%>				  <tr bgcolor = "#DADFEA">
<%		  end if

				strValue = node.getAttributeNode("STARTDATE").Value
				strValue = strValue & "（" & WeekDayName(Weekday(strValue), True) & "）"

%>
							<td><%=strValue%></td>
							<td><%=node.getAttributeNode("STARTTIME").Value%></td>
							<td><%=node.getAttributeNode("BEDNAME").Value%></td>
							<td align="center">
<%
				'■コンボボックス作成
				aryComboData = ""

				'版数最大値から１番までファイル存在チェック　→　D:\nkkdir\NKKWEB\dia_rep\患者ID\"患者ID"-"透析開始日時"-"連番".pdf
'				for j = node.getAttributeNode("EDITION").Value to 1 step -1
'					'strFilename = ZeroPad(strPatId) & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)
'					'If objFSO.FileExists(pdfFolder & ZeroPad(strPatId) & "\\" & strFilename & Right("000" & j, 4) & ".pdf") Then
'					strFilename = strPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)
'					If objFSO.FileExists(pdfFolder & strPatId & "\\" & strFilename & Right("000" & j, 4) & ".pdf") Then
'						'ファイルが存在すれば配列に版数を入れていく（降順挿入）
'						if aryComboData = "" then
'							aryComboData = j
'						else
'							aryComboData = aryComboData & "," & j
'						end if
'					end if
'				next

				'前システムの時のレポートファイル名取得
				If node.getAttribute("FILENAME") <> "" Then
					repName = node.getAttributeNode("FILENAME").Value
				else
					repName = ""
				End If

				for j = node.getAttributeNode("EDITION").Value to 1 step -1
					if j=1 and len(repName)>0 then
						strFilename = repName
						aryData(3, iCount) = strFilename
						If objFSO.FileExists(pdfFolder & strPatId & "\\" & strFilename) Then
							'ファイルが存在すれば配列に版数を入れていく（降順挿入）
							if aryComboData = "" then
								aryComboData = j
							else
								aryComboData = aryComboData & "," & j
							end if
						end if
					else
						strFilename = strPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)
						If objFSO.FileExists(pdfFolder & strPatId & "\\" & strFilename & Right("000" & j, 4) & ".pdf") Then
							'ファイルが存在すれば配列に版数を入れていく（降順挿入）
							if aryComboData = "" then
								aryComboData = j
							else
								aryComboData = aryComboData & "," & j
							end if
						end if
					end if
				next

				'1つもファイルがない場合「表示不可」、空要素（コンボ用とボタン用）を２つ用意
				if aryComboData = "" then
					aryData(2, iCount) = 0	  '版数なし
%>
								表示不可
								<input type="hidden" name="lstJisseki" value="">
								<input type="hidden" name="button" value="">
<%
				else
					'カンマ分割（配列化）
					aryComboData = Split(aryComboData, ",")
%>
							<SELECT NAME="lstJisseki" style="width:4em;">
<%
					'コンボボックス作成
					for j = LBound(aryComboData) to UBound(aryComboData)
%>
								<OPTION VALUE=<%=aryComboData(j)%>><%=Right("000" & aryComboData(j),4)%></OPTION>
<%
					next
					aryData(2, iCount) = aryComboData(LBound(aryComboData))	 '表示可能　最大版数
'					strFilename = ZeroPad(strPatId) & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)
'					strFilename = strPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)

					strFilename = strPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)

%>
							</SELECT>
							<INPUT type="button" value="表示" class=.button onClick="Javascript:fnOpenReport(<%=iCount%>,'<%=strPatId%>','<%=strFilename%>','<%=repName%>');">
<%
				end if
%>					  </td>
					</tr>
<%
			iCount = iCount + 1
		'>>>>> 2010.01.19 h.horiuchi 1年間の限定表示は廃止
		'end if
		'<<<<< 2010.01.19 h.horiuchi 1年間の限定表示は廃止
		NEXT
	end if

	'一覧データ配列をSessionに格納（PDF閲覧画面で使用）
	Session("aryData") = aryData

%>

			</table>
		</form>
	</td></tr>
	</body>
	<script language="JavaScript">
	<!--
	function fnOpenReport(intNo, strPatID, strFileName, strRep){
		with (document.form1){
			url = "Pdf_View_Main.asp?cnt="+intNo+"&ver="+elements[intNo*2].value+"&id="+strPatID+"&fn="+strFileName+"&repname="+strRep;
			window.open(url,'_blank',"height=900,width=800,toolbar=no,menubar=no,status=no,location=no,resizable=yes");
		}
	}

	-->
	</script>
</html>
<%
	end if
%>