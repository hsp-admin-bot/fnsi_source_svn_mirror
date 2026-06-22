<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　患者情報区分変換ライブラリ
'// ファイル名：PatBasic.asp
'// 説明      ：患者の各種区分を変換するルーチンを集めたライブラリ
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付        担当                理由
'// 2020/05/20  TEX-SOL             既存システムより流用
'//
'///////////////////////////////////////////////////////////////////////////////

'----------------------------
'  変数の宣言
'----------------------------




'----------------------------
''入外の取得
'----------------------------
function getInOut(inout)
	
	getInOut = ""
	
	if inout = "0" then
		getInOut = "外来"
	elseif inout = "1" then
		getInOut = "入院" 
	else 
		getInOut = "不明"
	end if
	
end function


'----------------------------
''性別の取得
'----------------------------
function getSex(sex)
	
	getSex = ""
	
	if sex = "0" then
		getSex = "男"
	elseif sex = "1" then
		getSex = "女" 
	else 
		getSex = "不明"
	end if
	
end function

'----------------------------
''血液型の取得
'----------------------------
function getBloodType(bloodabo, bloodrh)
	getBloodType = ""
	
	if bloodabo = "0" then
		getBloodType = "Ａ"
	elseif bloodabo = "1" then
		getBloodType = "Ｂ"
	elseif bloodabo = "2" then
		getBloodType = "ＡＢ"
	elseif bloodabo = "3" then
		getBloodType = "Ｏ"
	else
		getBloodType = "型不明"
	end if
	if bloodrh = "0" then
		getBloodType = getBloodType & "＋"
	elseif bloodrh = "2" then
		getBloodType = getBloodType & "－"
	else
		getBloodType = getBloodType & " RH不明"
	end if

end function

'----------------------------
''年齢の計算
'----------------------------
function getAge(birthday)
	getAge = ""
	if isdate(birthday) then
		getAge = DateDiff("yyyy",birthday,date)

		if Month(date) < Month(birthday) then
			getAge = getAge - 1
		elseif Month(date) = Month(birthday) then
		
			if Day(date) < Day(birthday) then
				getAge = getAge - 1
			end if	
		
		end if
	end if
end function

'----------------------------
''和暦変換
'----------------------------
function ToWareki(sDate)

	if sdate = "" then
		ToWareki = sDate
	else
		dim dt
		dim gg
		dim yy
		
		dt = CDate(sDate)
	 
	    If dt <= DateSerial(1912, 7, 29) Then
	        gg = "明治"
	        yy = Year(dt) - 1867
	    ElseIf dt >= DateSerial(1912, 7, 30) And dt <= DateSerial(1926, 12, 24) Then
	        gg = "大正"
	        yy = Year(dt) - 1911
	    ElseIf dt >= DateSerial(1926, 12, 25) And dt <= DateSerial(1989, 1, 7) Then
	        gg = "昭和"
	        yy = Year(dt) - 1925
	    ElseIf dt >= DateSerial(1989, 1, 8) And dt <= DateSerial(2019, 4, 30) Then
	        gg = "平成"
	        yy = Year(dt) - 1988
	    ElseIf dt >= DateSerial(2019, 5, 1) Then
	        gg = "令和"
	        yy = Year(dt) - 2018
	    End If
	    
	    ToWareki = gg & yy & "年" & DatePart("m", sDate) & "月" & DatePart("d", sDate) & "日"
	end if
	
End Function
%>