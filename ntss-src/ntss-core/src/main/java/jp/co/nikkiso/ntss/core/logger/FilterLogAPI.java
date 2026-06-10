package jp.co.nikkiso.ntss.core.logger;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class FilterLogAPI {

	/**
	 * 指定パラメーターのログをフィルターする
	 *
	 * @param folderName 	フォルダー名
	 * @param fileName 	ファイル名
	 * @param strFromDate 	開始日
	 * @param strToDate 	終了日
	 * @param facilityCd 	施設コード
	 * @param logType	 ログタイプ
	 * @param userId	 ユーザーID
	 * @param serviceName	 サービス名
	 * @param patId 	患者ID
	 * @param classification 	 分類
	 * @param moduleName	モジュール名
	 * @return フィルタリングされたリスト
	 * @throws ParseException	 例外を解析
	 */
	public List<EventLogAPI> Fillter(String folderName, FilterConditionLogAPI conditionLog)
			throws ParseException {

		// 読み取りログAPI
		ReadLogAPI api = new ReadLogAPI();
		long fromDateCompare = 0l;
		long toDateCompare = 0l;
		List<String> fileNameLst = api.ReadPathFile(folderName);
		if (fileNameLst == null) {
			return new ArrayList<>();
		}

		List<EventLogAPI> lstDataResult = new ArrayList<>();
		if(conditionLog.getStrFromDate() != null) {
			fromDateCompare = convertDateToMilisecond(conditionLog.getStrFromDate());
		} else {
			fromDateCompare = 0l;

		}
		if(conditionLog.getStrToDate() != null) {
			toDateCompare = convertDateToMilisecond(conditionLog.getStrToDate());
		} else {
			toDateCompare = 9999999999999l;
		}

		for (int i = 0; i < fileNameLst.size(); i++) {
			String dateCompareSpl = convertFileName(fileNameLst.get(i)).substring(7, 15);
			List<EventLogAPI> listData = api.ReadLog(folderName, fileNameLst.get(i));
			long fileNameCompare = convertDateToMilisecondInLog(dateCompareSpl);
      // add FNSI-ログ保存場所の追加 関 start
      List<EventLogAPI> reListData = new ArrayList<>();;
			for (EventLogAPI eventLog : listData) {
        eventLog.setFileUrl(folderName + "/" + fileNameLst.get(i));
        reListData.add(eventLog);
      }
      listData = reListData;
      // add FNSI-ログ保存場所の追加 関 end
			if (fromDateCompare <= fileNameCompare && fileNameCompare <= toDateCompare) {

				SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
				// 日付から
				String strFromDate = conditionLog.getStrFromDate();
				// 現在まで
				String strToDate = conditionLog.getStrToDate();
				// 施設コード
				List<String> facilityCd = conditionLog.getFacilityCd();
				// ログタイプ
				String logType = conditionLog.getLogType();
				// ユーザーID
				String[] userId = null;
				if(conditionLog.getUserId() != null) {
					userId = conditionLog.getUserId().split(",");
				}
				// 機能名
				String[] functionCds = null;
				if (conditionLog.getServiceName() != null) {
					functionCds = conditionLog.getServiceName().split(",");
				}
				// モジュール名
				String moduleName = conditionLog.getModuleName();
				// 患者ID
				String[] patId  = null;
				if (conditionLog.getPatId() != null) {
					patId = conditionLog.getPatId().split(",");
				}
				// 分類
				String classification = conditionLog.getClassification();
				// キーワード検索
				String keySearch = conditionLog.getKeySearch();
				// 検索タイプ
				int typeSearch = conditionLog.getTypeSearch();
				// すべての条件がヌルの場合、リスト全体を返します
				if (strFromDate == null && strToDate == null && facilityCd.size() == 0 && logType == null && userId == null
						&& functionCds == null && moduleName == null && patId == null && keySearch == null && classification == null) {
					lstDataResult.addAll(listData);
				} else {
					for (EventLogAPI eventLog : listData) {
						String serviceNameParse = "";
						String moduleNameParse = "";
						String[] seviceName = eventLog.getServiceName().split(",");

						if (seviceName.length == 2) {
							moduleNameParse = seviceName[0].trim();
							serviceNameParse = seviceName[1].trim();
						} else {
							serviceNameParse = seviceName[0].trim();
						}

						boolean compare = false;

						if (strFromDate != null) {
							Date fromDate = sdf.parse(strFromDate);
							compare = eventLog.getDate().compareTo(fromDate) >= 0;
							if (!compare) {
								continue;
							}
						}
						if (strToDate != null) {
							Date toDate = sdf.parse(strToDate);
							compare = eventLog.getDate().compareTo(toDate) <= 0;
							if (!compare) {
								continue;
							}
						}
						if (facilityCd.size() > 0) {
							compare = facilityCd.contains(eventLog.getFacilityCd());
							if (!compare) {
								continue;
							}
						}
						if (logType != null) {
							if (logType.toUpperCase().contains(eventLog.getLogType().toUpperCase())) {
								compare = true;
							} else {
								continue;
							}
						}
						if (userId != null) {
							for (String user : userId) {
								compare = user.equals(eventLog.getUserId());
								if(compare == true) {
									break;
								}
							}
							if (compare == false) {
								continue;
							}
						}
						if (functionCds != null) {
							for (String function : functionCds) {
								compare = function.equals(eventLog.getFunctionCd());
								if (compare == true) {
									break;
								}
							}
							if (compare == false) {
								continue;
							}
						}
						if (moduleName != null) {
							if (moduleNameParse.equals(moduleName)) {
								compare = true;
							} else {
								continue;
							}
						}
						if (patId != null) {
							for (String pat : patId) {
								compare = pat.equals(eventLog.getPatId());
								if(compare == true) {
									break;
								}
							}
							if(compare == false) {
								continue;
							}
						}
						boolean checkExist = false;
						int flag = 10;
						if (keySearch != null) {
							boolean checkOr =keySearch.toUpperCase().contains(" OR ");

							String keySearchRs = keySearch.replace(" OR "," or ");
							String[] keySearchArr = null;
							if(checkOr) {
								keySearchArr = keySearchRs.split(" or ");
							}else {
								keySearchArr = keySearchRs.split(" ");
							}

							outerFreeWordLoop:
							for (String key : keySearchArr) {
								// Apply with case OR
								if (checkOr) {
									switch (typeSearch) {
									// 等しい
									case 0:
										if (eventLog.getLogType().equals(key) || eventLog.getFacilityCd().equals(key)
												|| eventLog.getUserId().equals(key)
												|| eventLog.getClientIp().equals(key)
												|| eventLog.getSessionId().equals(key)
												|| eventLog.getDeviceEdgeNo().equals(key)
												|| eventLog.getDeviceEdgeSerialNo().equals(key)
												|| eventLog.getMachineType().equals(key)
												|| eventLog.getMachineTypeCd().equals(key)
												|| eventLog.getEc2Identification().equals(key)
												|| serviceNameParse.equals(key)
												|| moduleNameParse.equals(key)
												|| eventLog.getFunctionCd().equals(key)
												|| eventLog.getPatId().equals(key)
												|| eventLog.getSqlIdentification().equals(key)
												|| eventLog.getLogMessage().equals(key)
												|| eventLog.getSupportMessage().equals(key)) {
											compare = true;
											break outerFreeWordLoop;
										} else {
											compare = false;
										}
										if (compare == false) {
											continue;
										}
										// 等しくない
									case 1:
										flag = 1;
										if (eventLog.getLogType().equals(key)
												|| eventLog.getFacilityCd().equals(key)
												|| eventLog.getUserId().equals(key)
												|| eventLog.getClientIp().equals(key)
												|| eventLog.getSessionId().equals(key)
												|| eventLog.getDeviceEdgeNo().equals(key)
												|| eventLog.getDeviceEdgeSerialNo().equals(key)
												|| eventLog.getMachineType().equals(key)
												|| eventLog.getMachineTypeCd().equals(key)
												|| eventLog.getEc2Identification().equals(key)
												|| serviceNameParse.equals(key)
												|| moduleNameParse.equals(key)
												|| eventLog.getFunctionCd().equals(key)
												|| eventLog.getPatId().equals(key)
												|| eventLog.getSqlIdentification().equals(key)
												|| eventLog.getLogMessage().equals(key)
												|| eventLog.getSupportMessage().equals(key)) {
											checkExist = true;
											compare = false;
											break outerFreeWordLoop;
										}
									// 始まる
									case 2:
										if ((int) eventLog.getLogType().indexOf(key) == 0
												|| (int) eventLog.getFacilityCd().indexOf(key) == 0
												|| (int) eventLog.getUserId().indexOf(key) == 0
												|| (int) eventLog.getClientIp().indexOf(key) == 0
												|| (int) eventLog.getSessionId().indexOf(key) == 0
												|| (int) eventLog.getDeviceEdgeNo().indexOf(key) == 0
												|| (int) eventLog.getDeviceEdgeSerialNo().indexOf(key) == 0
												|| (int) eventLog.getMachineType().indexOf(key) == 0
												|| (int) eventLog.getMachineTypeCd().indexOf(key) == 0
												|| (int) eventLog.getEc2Identification().indexOf(key) == 0
												|| (int) eventLog.getServiceName().indexOf(key) == 0
												|| (int) eventLog.getFunctionCd().indexOf(key) == 0
												|| (int) eventLog.getPatId().indexOf(key) == 0
												|| (int) eventLog.getSqlIdentification().indexOf(key) == 0
												|| (int) eventLog.getLogMessage().indexOf(key) == 0
												|| (int) eventLog.getSupportMessage().indexOf(key) == 0) {
											compare = true;
											break outerFreeWordLoop;
										} else {
											compare = false;
										}
										if (compare == false) {
											continue;
										}
										// 終わる
									case 3:
										if ((checkLastValue(eventLog.getLogType(), key))
												|| (checkLastValue(eventLog.getFacilityCd(), key))
												|| (checkLastValue(eventLog.getUserId(), key))
												|| (checkLastValue(eventLog.getClientIp(), key))
												|| (checkLastValue(eventLog.getSessionId(), key))
												|| (checkLastValue(eventLog.getDeviceEdgeNo(), key))
												|| (checkLastValue(eventLog.getDeviceEdgeSerialNo(), key))
												|| (checkLastValue(eventLog.getMachineType(), key))
												|| (checkLastValue(eventLog.getMachineTypeCd(), key))
												|| (checkLastValue(eventLog.getEc2Identification(), key))
												|| (checkLastValue(serviceNameParse, key))
												|| (checkLastValue(moduleNameParse, key))
												|| (checkLastValue(eventLog.getFunctionCd(), key))
												|| (checkLastValue(eventLog.getPatId(), key))
												|| (checkLastValue(eventLog.getSqlIdentification(), key))
												|| (checkLastValue(eventLog.getLogMessage(), key))
												|| (checkLastValue(eventLog.getSupportMessage(), key))) {
											compare = true;
											break outerFreeWordLoop;
										} else {
											compare = false;
										}
										if (compare == false) {
											continue;
										}
										// 含む
									case 4:
										if (eventLog.getLogType().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getFacilityCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getUserId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getClientIp().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSessionId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getDeviceEdgeNo().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getDeviceEdgeSerialNo().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getMachineType().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getMachineTypeCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getEc2Identification().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getServiceName().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getFunctionCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getPatId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSqlIdentification().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getLogMessage().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSupportMessage().toUpperCase().contains(key.toUpperCase())) {
											compare = true;
											break outerFreeWordLoop;
										} else {
											compare = false;
										}
										if (compare == false) {
											continue;
										}
									// 含まない
									case 5:
										flag = 5;
										if (checkExist == false) {
											if (eventLog.getLogType().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getFacilityCd().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getUserId().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getClientIp().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getSessionId().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getDeviceEdgeNo().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getDeviceEdgeSerialNo().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getMachineType().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getMachineTypeCd().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getEc2Identification().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getServiceName().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getFunctionCd().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getPatId().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getSqlIdentification().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getLogMessage().toUpperCase().contains(key.toUpperCase())
													|| eventLog.getSupportMessage().toUpperCase().contains(key.toUpperCase())) {
												checkExist = true;
												compare = false;
												break outerFreeWordLoop;
											}
										}
									default:
										break;
									}
								} else {
									// Apply with case AND
									// 等しい
									if(typeSearch == 0) {
										if (eventLog.getLogType().equals(key) || eventLog.getFacilityCd().equals(key)
												|| eventLog.getUserId().equals(key)
												|| eventLog.getClientIp().equals(key)
												|| eventLog.getSessionId().equals(key)
												|| eventLog.getDeviceEdgeNo().equals(key)
												|| eventLog.getDeviceEdgeSerialNo().equals(key)
												|| eventLog.getMachineType().equals(key)
												|| eventLog.getMachineTypeCd().equals(key)
												|| eventLog.getEc2Identification().equals(key)
												|| moduleNameParse.equals(key)
												|| serviceNameParse.equals(key)
												|| eventLog.getFunctionCd().equals(key)
												|| eventLog.getPatId().equals(key)
												|| eventLog.getSqlIdentification().equals(key)
												|| eventLog.getLogMessage().equals(key)
												|| eventLog.getSupportMessage().equals(key)) {
											compare = true;
										} else {
											compare = false;
										}
										if (compare == false) {
											break outerFreeWordLoop;
										}
									}
									// 等しくない
									if(typeSearch == 1) {
										flag = 1;
										if (eventLog.getLogType().equals(key)
												|| eventLog.getFacilityCd().equals(key)
												|| eventLog.getUserId().equals(key)
												|| eventLog.getClientIp().equals(key)
												|| eventLog.getSessionId().equals(key)
												|| eventLog.getDeviceEdgeNo().equals(key)
												|| eventLog.getDeviceEdgeSerialNo().equals(key)
												|| eventLog.getMachineType().equals(key)
												|| eventLog.getMachineTypeCd().equals(key)
												|| eventLog.getEc2Identification().equals(key)
												|| moduleNameParse.equals(key)
												|| serviceNameParse.equals(key)
												|| eventLog.getFunctionCd().equals(key)
												|| eventLog.getPatId().equals(key)
												|| eventLog.getSqlIdentification().equals(key)
												|| eventLog.getLogMessage().equals(key)
												|| eventLog.getSupportMessage().equals(key)) {
											checkExist = true;
											compare = false;
											break outerFreeWordLoop;
										}
									}
									// 始まる
									if(typeSearch == 2) {
										if ((int) eventLog.getLogType().indexOf(key) == 0
												|| (int) eventLog.getFacilityCd().indexOf(key) == 0
												|| (int) eventLog.getUserId().indexOf(key) == 0
												|| (int) eventLog.getClientIp().indexOf(key) == 0
												|| (int) eventLog.getSessionId().indexOf(key) == 0
												|| (int) eventLog.getDeviceEdgeNo().indexOf(key) == 0
												|| (int) eventLog.getDeviceEdgeSerialNo().indexOf(key) == 0
												|| (int) eventLog.getMachineType().indexOf(key) == 0
												|| (int) eventLog.getMachineTypeCd().indexOf(key) == 0
												|| (int) eventLog.getEc2Identification().indexOf(key) == 0
												|| (int) eventLog.getServiceName().indexOf(key) == 0
												|| (int) eventLog.getFunctionCd().indexOf(key) == 0
												|| (int) eventLog.getPatId().indexOf(key) == 0
												|| (int) eventLog.getSqlIdentification().indexOf(key) == 0
												|| (int) eventLog.getLogMessage().indexOf(key) == 0
												|| (int) eventLog.getSupportMessage().indexOf(key) == 0) {
											compare = true;
										} else {
											compare = false;
										}
										if (compare == false) {
											break outerFreeWordLoop;
										}
									}
									// 終わる
									if(typeSearch == 3) {
										if ((checkLastValue(eventLog.getLogType(), key))
												|| (checkLastValue(eventLog.getFacilityCd(), key))
												|| (checkLastValue(eventLog.getUserId(), key))
												|| (checkLastValue(eventLog.getClientIp(), key))
												|| (checkLastValue(eventLog.getSessionId(), key))
												|| (checkLastValue(eventLog.getDeviceEdgeNo(), key))
												|| (checkLastValue(eventLog.getDeviceEdgeSerialNo(), key))
												|| (checkLastValue(eventLog.getMachineType(), key))
												|| (checkLastValue(eventLog.getMachineTypeCd(), key))
												|| (checkLastValue(eventLog.getEc2Identification(), key))
												|| (checkLastValue(moduleNameParse, key))
												|| (checkLastValue(serviceNameParse, key))
												|| (checkLastValue(eventLog.getFunctionCd(), key))
												|| (checkLastValue(eventLog.getPatId(), key))
												|| (checkLastValue(eventLog.getSqlIdentification(), key))
												|| (checkLastValue(eventLog.getLogMessage(), key))
												|| (checkLastValue(eventLog.getSupportMessage(), key))) {
											compare = true;
										} else {
											compare = false;
										}
										if (compare == false) {
											break outerFreeWordLoop;
										}
									}
									// 含む
									if(typeSearch == 4) {
										if (eventLog.getLogType().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getFacilityCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getUserId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getClientIp().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSessionId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getDeviceEdgeNo().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getDeviceEdgeSerialNo().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getMachineType().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getMachineTypeCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getEc2Identification().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getServiceName().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getFunctionCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getPatId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSqlIdentification().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getLogMessage().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSupportMessage().toUpperCase().contains(key.toUpperCase())) {
											compare = true;
										} else {
											compare = false;
										}
										if (compare == false) {
											break outerFreeWordLoop;
										}
									}
									// 含まない
									if (typeSearch == 5) {
										flag = 5;
										if (eventLog.getLogType().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getFacilityCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getUserId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getClientIp().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSessionId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getDeviceEdgeNo().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getDeviceEdgeSerialNo().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getMachineType().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getMachineTypeCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getEc2Identification().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getServiceName().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getFunctionCd().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getPatId().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSqlIdentification().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getLogMessage().toUpperCase().contains(key.toUpperCase())
												|| eventLog.getSupportMessage().toUpperCase().contains(key.toUpperCase())) {
											checkExist = true;
											compare = false;
											break outerFreeWordLoop;
										}
									}
								}
							}
							if (checkExist == false && flag == 1) {
								compare = true;
							}
							if (checkExist == false && flag == 5) {
								compare = true;
							}
							if (!compare) {
								continue;
							}
						}
						if (compare) {
							lstDataResult.add(eventLog);
						}

					}
				}

			}
		}
		return lstDataResult;
	}

	/**
	 * 最後の文字を確認する
	 *
	 * @param Name
	 * @param keyFInd
	 * @return
	 */
	private boolean checkLastValue(String Name, String keyFInd) {
		int lengthName = Name.length();
		int lengthkeyFInd = keyFInd.length();
		if (lengthName > lengthkeyFInd) {
			String Namecompare = Name.substring(lengthName - lengthkeyFInd, lengthName);
			if (Namecompare.equals(keyFInd)) {
				return true;
			}
			return false;
		}
		if (lengthName == lengthkeyFInd) {
			if (Name.equals(keyFInd)) {
				return true;
			}
			return false;
		}
		return false;
	}

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
	public long convertDateToMilisecond(String strDate) throws ParseException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
		String[] arrDate = strDate.split(" ");
		DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
		try {
			Date dateConvert = dateFormat.parse(arrDate[0]);
			return dateConvert.getTime();
		} catch (ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      throw e;
    }
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//		return 0l;
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
	}
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
	public long convertDateToMilisecondInLog(String strDate) throws ParseException {
		DateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
		try {
			Date dateConvert = dateFormat.parse(strDate);
			return dateConvert.getTime();
		} catch (ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      throw e;
		}
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//		return 0l;
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
	}

	private String convertFileName(String fileName) {
		String[] fileDateSplit = fileName.split("_");
		DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyyMMdd");
		LocalDateTime now = LocalDateTime.now();
		String currentDate = dtf.format(now);
		if (fileDateSplit.length < 2) {
			fileName = fileDateSplit[0].replace(".log", "") + "_" + currentDate + ".log";
		}
		return fileName;
	}
}
