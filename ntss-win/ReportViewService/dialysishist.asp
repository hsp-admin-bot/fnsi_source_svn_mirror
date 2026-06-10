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
'// 日付        担当                理由
'// 2020/05/20  TEX-SOL             既存システムより流用
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
Dim aryData()				'全データ配列
Dim aryComboData			'コンボボックス用データ配列


iCount = 0					'行毎に背景色を変える

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
	<table class="no-border tbl-center">
	<tr><td>
		<table class="no-border" style="width: 100%">
		<tr>
		<td style="vertical-align: top; width: 20%">
			<img src="image/nikkiso.bmp">
		</td>
		<td style="vertical-align: top; width: 60%">
			<div class="center"><br /><h1>患者情報</h1></div>
		</td>
		<td style="width: 20%">
		</td>
		</tr>
		</table>
	</td></tr>
	<tr><td>
		<Table class="border paitient-info">
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
Dim strFilePath
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
Dim strDiffDispPatId
Dim strPathPatId
Dim hospPatIdLen
hospPatIdLen = 0
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end

Set XMLDoc = Server.CreateObject("Microsoft.XMLDOM") 
XMLDoc.async = false 

'PDFサーバ管理情報をロード
rtResult = XMLDoc.load(Server.MapPath("./"&pdfPath&fileName_pdfServerInfo)) 

patCount = 0
If rtResult = True Then 
	Set docRoot = XMLDoc.documentElement 
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'	strDispPatId = Req("patid")
'	For i = 1 to Len(Req("patid"))
'		if left(strDispPatId, 1) = "0" then
'			if Len(strDispPatId) = 1 then
'				exit for
'			end if
'			strDispPatId = right(strDispPatId, Len(strDispPatId) - 1)
'		else
'			exit for
'		end if
'	Next
	strDispPatId = ZeroTrim(Req("patid"))

	strPathPatId = ""

	'DISP_PATID_LENGTHが有りか
	if docRoot.getAttribute("DISP_PATID_LENGTH") <> "" then
		hospPatIdLen = docRoot.getAttributeNode("DISP_PATID_LENGTH").Value
		if hospPatIdLen = "" then
			hospPatIdLen = 0
		end if
	end if
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end

	strPatId = ""
	Set patientList = docRoot.selectNodes("/rootNode/PATIENT")
	For Each node In patientList
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'		if node.getAttributeNode("DISP_PATID").Value = strDispPatId then
		strDiffDispPatId = node.getAttributeNode("DISP_PATID").Value
		if ZeroTrim(strDiffDispPatId) = strDispPatId then
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end
			'strPatId = ZeroPad(node.getAttributeNode("PATID").Value)
			strPatId = node.getAttributeNode("DISP_PATID").Value
			strPatId = Trim(strPatId)
			exit for
		end if
	Next

	if strPatId <> "" then
		'患者情報XMLをロード
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'		rtResult = XMLDoc.load(Server.MapPath("./"&pdfPath&ZeroPad(strPatId)&"/"&fileName_patientInfo)) 
		strPathPatId = ZeroTrim(strPatId)
		strPathPatId = ZeroPadByLen(strPathPatId, hospPatIdLen)
		rtResult = XMLDoc.load(Server.MapPath("./"&pdfPath&strPathPatId&"/"&fileName_patientInfo)) 
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end
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
			<Th class="w120"><font>患者ID</Font></Th>
			<Td class="w240"><%=strDispPatId%></Td>
			<Th class="w120"><font>生年月日</Font></Th>
			<Td class="w110" >&nbsp;</Td>
			<Th class="w120"><font>年齢</Font></Th>
			<Td class="w110" >&nbsp;</Td>
		</Tr>
		<Tr>
			<Th class="w120"><font> 氏名 </Font></Th>
			<Td class="w410" ColSpan="3">該当患者が存在しません。</Td>
			<Th class="w120"><font>性別</Font></Th>
			<Td class="w110">&nbsp;</Td>
		</Tr>
		<Tr>
			<Th class="w120"><font> フリガナ </Font></Th>
			<Td class="w410" ColSpan="3">&nbsp;</Td>
			<Th class="w120"><font>入外区分</Font></Th>
			<Td class="w110" >&nbsp;</Td>
		</Tr>
<%
	else
%>
		<Tr>
			<Th class="w120"><font>患者ID</Font></Th>
			<Td class="w120" ><%=strDispPatId%></Td>
			
			<Th class="w120"><font>生年月日</Font></Th>
			<%
			strValue = ToWareki(patientNode.selectSingleNode("BIRTHDAY").text)
			if strValue = "" then
				strValue = "&nbsp;"
			end if
			%>
			<Td class="w170"><%=strValue%></Td>

			<Th class="w120"><font>年齢</Font></Th>
			<%
			strValue = patientNode.selectSingleNode("AGE").text
			if strValue = "" then
				strValue = "&nbsp;"
			else
				strValue = strValue & " 歳"
			end if
			%>
			<Td class="w110" ><%=strValue%></Td>
		</Tr>
		<Tr>
			<Th class="w120"><font> 氏名 </Font></Th>
			<%
			strValue = patientNode.selectSingleNode("NAME").text
			%>
			<Td class="w410"  ColSpan="3"><%=strValue%></Td>
			
			<Th class="w120"><font>性別</font></Th>
			<%
			strValue = getSex(patientNode.selectSingleNode("SEX").text)
			%>
			<Td class="w110"><%=strValue%></Td>
		</Tr>
		<Tr>
			<Th class="w120"><font>フリガナ</font></Th>
			<%
			strValue = patientNode.selectSingleNode("KANA").text
			if strValue = "" then
				strValue = "&nbsp;"
			end if
			%>
			<Td class="w410"  ColSpan="3"><%=strValue%></Td>

			<Th class="w120"><font>入外区分</font></Th>
			<%
			strValue = getInOut(patientNode.selectSingleNode("INOUT").text)
			%>
			<Td class="w110" ><%=strValue%></Td>
		</Tr>
<%
	end if
%>
		</Table>
	</td></tr>
	<tr style="height: 20px"><td></td></tr>
	<tr><td><div class="center"><h1>透析実績一覧</h1></div></td></tr>
	<tr><td>
		<form name="form1">
		<table class="border dialysis-info">
		<tr>
			<th><font>透析日</font></th>
			<th><font>透析開始時刻</font></th>
			<th><font>ベッド名</font></th>
			<th><font>レポート</font></th>
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
						<td colspan="4" align="center">透析実績がありません。</td>
					</tr>
<%
	else

		For Each node In reportNode

			'■一覧データを配列に格納
			ReDim Preserve aryData(4,iCount)
			
			strValue = node.getAttributeNode("STARTDATE").Value
			strValue = strValue & "（" & WeekDayName(Weekday(strValue), True) & "）"
			
			aryData(0, iCount) = strValue & "<br />" & node.getAttributeNode("STARTTIME").Value	 			'透析実績　開始日時 YYYY/MM/DD (DAY) HH24:MI:SS
			aryData(1, iCount) = strDispPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)				'"患者ID"-"透析日時(YYYYMMDDHH24MISS)"

			if iCount mod 2 = 0 then
%>				  <tr>
<%		  else
%>				  <tr class="odd">
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
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'						strFilePath = Server.MapPath("./" & pdfPath ) & "/" & ZeroPad(strPatId) & "/" & strFilename
						strFilePath = Server.MapPath("./" & pdfPath ) & "/" & strPathPatId & "/" & strFilename
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end
						If objFSO.FileExists(strFilePath) Then
							'ファイルが存在すれば配列に版数を入れていく（降順挿入）
							if aryComboData = "" then
								aryComboData = j
							else
								aryComboData = aryComboData & "," & j
							end if
						end if
					else
						strFilename = strDispPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'						strFilePath = Server.MapPath("./" & pdfPath ) & "/" & ZeroPad(strPatId) & "/" & strFilename & Right("000" & j, 4) & ".pdf"
						strFilePath = Server.MapPath("./" & pdfPath ) & "/" & strPathPatId & "/" & strFilename & Right("000" & j, 4) & ".pdf"
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end
						If objFSO.FileExists(strFilePath) Then
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
					'strFilename = strPatId & ZeroPad(node.getAttributeNode("DIALYSIS_NO").Value)
%>
							</SELECT>
<!-- mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start -->
<!--							<INPUT type="button" value="表示" class=.button onClick="Javascript:fnOpenReport(<%=iCount%>,'<%=strPatId%>','<%=strFilename%>','<%=repName%>');"> -->
							<INPUT type="button" value="表示" class=.button onClick="Javascript:fnOpenReport(<%=iCount%>,'<%=strPatId%>','<%=strFilename%>','<%=repName%>',<%=hospPatIdLen%>);">
<!-- mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end -->
<%
				end if
%>					  </td>
					</tr>
<%
			iCount = iCount + 1
		NEXT
	end if

	'一覧データ配列をSessionに格納（PDF閲覧画面で使用）
	Session("aryData") = aryData

%>

			</table>
		</form>
	</td></tr>
	</table>
	</body>
	<script language="JavaScript">
	<!--
<!-- mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start -->
<!--	function fnOpenReport(intNo, strPatID, strFileName, strRep){ -->
	function fnOpenReport(intNo, strPatID, strFileName, strRep, hospPatIdLen){
<!-- mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end -->
		with (document.form1){
<!--mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start -->
<!--			url = "Pdf_View_Main.asp?cnt="+intNo+"&ver="+elements[intNo*2].value+"&id="+strPatID+"&fn="+strFileName+"&repname="+strRep; -->
			url = "Pdf_View_Main.asp?cnt="+intNo+"&ver="+elements[intNo*2].value+"&id="+strPatID+"&fn="+strFileName+"&repname="+strRep+"&padlen="+hospPatIdLen;
<!-- mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end -->
			window.open(url,'_blank',"height=900,width=800,toolbar=no,menubar=no,status=no,location=no,resizable=yes");
		}
	}

	-->
	</script>
</html>
<%
	end if
%>