#!/bin/sh

# FTP取得スクリプト
# エラーが発生した場合は処理中止


# 接続情報その他
FTP_URL=$1
FTP_USER=$2
FTP_PW=$3
FTP_LOGFOLDER=$4
FTP_FOLDER=$5
FTP_SLEEP_TIMER=$6
FTP_RETRY_COUNT=$7

#FTP_CURL_OPTION=""
FTP_CURL_OPTION="-Ssf"
LAST_ERROR_NO=0


# エラーログ
FTP_LOG_FILE=${FTP_LOGFOLDER}"FTP_DL_ERRLOG.TXT"
# ダウンロード済みファイル名一覧
FTP_FILES=${FTP_LOGFOLDER}"FTP_DL_FILES.TXT"

# 初回取得ファイル情報一覧
FTP_LIST1=${FTP_LOGFOLDER}"FTP_DL_LIST1.TXT"
# 初回取得ファイル名一覧
FTP_LIST1FILES=${FTP_LOGFOLDER}"FTP_DL_LIST1FILES.TXT"
# 二回目取得ファイル情報一覧
FTP_LIST2=${FTP_LOGFOLDER}"FTP_DL_LIST2.TXT"
# 取得対象ファイル情報一覧
FTP_LIST=${FTP_LOGFOLDER}"FTP_DL_LIST.TXT"
# 取得対象ファイル名一覧
FTP_NAMES=${FTP_LOGFOLDER}"FTP_DL_NAMES.TXT"
# 取得失敗ファイル名一覧
FTP_NO_FILES=${FTP_LOGFOLDER}"FTP_NO_DL_FILES.TXT"


rm -f ${FTP_LOG_FILE}
rm -f ${FTP_FILES}


# ０．リトライ回数分繰り返す

while [ true ]
do

	# 作業用ファイル削除
	rm -f ${FTP_LIST1}
	rm -f ${FTP_LIST1FILES}
	rm -f ${FTP_LIST2}
	rm -f ${FTP_LIST}
	rm -f ${FTP_NAMES}
	rm -f ${FTP_NO_FILES}


	# １．最初に指定されたFTP_URLのファイル一覧(属性、更新日時、サイズ含む)を取得する

	curl ${FTP_CURL_OPTION} -u ${FTP_USER}:${FTP_PW} ftp://${FTP_URL} > ${FTP_LIST1}
	LAST_ERROR_NO=$?
	if [ "${LAST_ERROR_NO}" != 0 ]
	then
		if [ "${LAST_ERROR_NO}" != 7 ]
		then
			echo "GET LIST1 ERROR:"${LAST_ERROR_NO} >> ${FTP_LOG_FILE}
		else
			echo "(NO FILE) GET LIST1 ERROR:"${LAST_ERROR_NO} >> ${FTP_LOG_FILE}
			LAST_ERROR_NO=0
		fi
		exit ${LAST_ERROR_NO}
	fi


	# １．５．指定されたFTP_URLからファイル名のみのリストを作成する(取得できなかったファイルチェックに使用するため)

	curl ${FTP_CURL_OPTION} -l -u ${FTP_USER}:${FTP_PW} ftp://${FTP_URL} > ${FTP_LIST1FILES}
	LAST_ERROR_NO=$?
	if [ "${LAST_ERROR_NO}" != 0 ]
	then
		echo "GET LIST1FILES ERROR:"${LAST_ERROR_NO} >> ${FTP_LOG_FILE}
		exit ${LAST_ERROR_NO}
	fi



	# ２．指定数秒停止(ファイル書き込み中のチェックのため)

	sleep ${FTP_SLEEP_TIMER}s


	## ２．５．キー入力待ち(debug)

	#echo "Enterキーを入力してください"
	#read Wait


	# ３．再度指定されたFTP_URLのファイル一覧(属性、更新日時、サイズ含む)を取得する

	curl ${FTP_CURL_OPTION} -u ${FTP_USER}:${FTP_PW} ftp://${FTP_URL} > ${FTP_LIST2}
	LAST_ERROR_NO=$?
	if [ "${LAST_ERROR_NO}" != 0 ]
	then
		echo "GET LIST2 ERROR:"${LAST_ERROR_NO} >> ${FTP_LOG_FILE}
		exit ${LAST_ERROR_NO}
	fi


	# ４．２つのファイル一覧を比較し、サイズ、更新日付が変わっていないファイルのダウンロード対象リストを作成する

	grep -x -i -f ${FTP_LIST1} ${FTP_LIST2} > ${FTP_LIST}


	# ５．ファイル名のみのリストからダウンロード対象リストにあるものを検索しファイル名のみのダウンロードリストを作成する

	if [ -f "${FTP_LIST1FILES}" ]
	then
		# 行ごとに繰り返し処理を実行
		while read line
		do
			#echo ${line}
			file=$(grep -i ${line} ${FTP_LIST})
			#echo ${file}
			if [ "${file}" ]
			then
				# 対象ファイルがある場合
				echo ${line} >> ${FTP_NAMES}
			fi
		done < ${FTP_LIST1FILES}
	fi


	# ６．FTP_URLからファイルを取得する

	if [ -f "${FTP_NAMES}" ]
	then
		# 行ごとに繰り返し処理を実行
		while read line
		do
			# ダウンロード対象ファイル
			#echo ${line}
			curl ${FTP_CURL_OPTION} -u ${FTP_USER}:${FTP_PW} ftp://${FTP_URL}${line} -R -o ${FTP_FOLDER}${line}
			LAST_ERROR_NO=$?
			if [ "${LAST_ERROR_NO}" != 0 ]
			then
				echo "GET FILE ERROR:"${LAST_ERROR_NO} ${line} >> ${FTP_LOG_FILE}
				echo ${line} >> ${FTP_NO_FILES}
				exit ${LAST_ERROR_NO}
			else
				echo ${line} >> ${FTP_FILES}
			fi
		done < ${FTP_NAMES}
	fi


	# ７．取得したファイルの削除

	if [ -f "${FTP_FILES}" ]
	then
		while read line
		do
			#echo ${line}
			curl ${FTP_CURL_OPTION} -u ${FTP_USER}:${FTP_PW} -X "DELE ${line}" ftp://${FTP_URL}
			LAST_ERROR_NO=$?
			#echo "FILE:"${line}" ERROR:"${LAST_ERROR_NO}
			if [ "${LAST_ERROR_NO}" != 0 ] && [ "${LAST_ERROR_NO}" != 19 ]
			then
				echo "DEL FILE ERROR:"${LAST_ERROR_NO} ${line} >> ${FTP_LOG_FILE}
				exit ${LAST_ERROR_NO}
			else
				LAST_ERROR_NO=0
			fi
		done < ${FTP_FILES}
	fi


	# ８．取得しなかったファイルの確認

	if [ -f "${FTP_FILES}" ]
	then
		# 行ごとに繰り返し処理を実行
		while read line
		do
			#echo ${line}
			#file=$(grep -x -i ${line} ${FTP_FILES})
			#if [ -z "${file}" ]
			file=$(echo ${FTP_FOLDER}${line})
			#echo ${file}
			if [ ! -e "${file}" ]
			then
				# 対象ファイルがない場合
				echo ${line} >> ${FTP_NO_FILES}
			fi
		done < ${FTP_LIST1FILES}
	fi


	# ９．取得していないファイルがある場合は再度ファイル取得処理を行う

	if [ -f "${FTP_NO_FILES}" ]
	then
		LAST_ERROR_NO=1
		# リトライ回数判定
		if [ "${FTP_RETRY_COUNT}" -gt 0 ]
		then
			# リトライ回数が１以上の場合はリトライ実施
			FTP_RETRY_COUNT=$((FTP_RETRY_COUNT-1))
			echo "FTP_RETRY_COUNT:"${FTP_RETRY_COUNT}
		else
			# リトライ回数が０以下の場合は抜ける
			break;
		fi
	else
		# 取得していないファイルがない場合は処理終了
		break;
	fi
done

exit ${LAST_ERROR_NO}
