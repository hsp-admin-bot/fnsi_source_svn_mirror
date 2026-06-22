/*##########################################
   フロー内でglobal.getしているので取り扱い注意
  ########################################## */

/////////////////////////////////////////
// 共通 定数定義
/////////////////////////////////////////
/** エンコード(Shift_JIS) */
const ENDORDE_SHIFT_JIS = "Shift_JIS";
/** 患者情報XML */
const FILENAME_PATIENTINFO = "PatientInfo.xml";
/** PDF表示一覧XML */
const FILENAME_PDFSERVERINFO = 'pdfserverinfo.xml';
// XML定義
const APPLICATION_XML = "application/xml";

/**
 * xmlファイルの整形して作成
 * @param {String} file ファイルパス
 */
function writeXmlFile(fileName, data) {
    var iconv = require("iconv-lite");
    var html = require('html');
    var fs = require('fs');
    // 作成したファイルを整形
    var xml = html.prettyPrint(data, {indent_size: 2});
    // 整形後のファイルを保存
    fs.writeFileSync(fileName, iconv.encode(xml, ENDORDE_SHIFT_JIS), {encoding : null});
}

/**
 * 患者情報XMLの作成
 * @param {String} originalFile 既存ファイルパス
 * @param {String} newFile 新規ファイルパス
 */
function makePatientInfo(originalFile, newFile) {
    var xmldom = require('@xmldom/xmldom');
    var path = require('path');
    var parser = xmldom.DOMParser;
    var serializer = xmldom.XMLSerializer;

    // Shift-JISのファイルをUTF-8で読み込む
    var paitentInfo = getFileEncodingUtf8(originalFile);
    var newPaitentInfo = getFileEncodingUtf8(newFile);

    /////////////////////////////////////////
    // 定数定義
    /////////////////////////////////////////
    // << 患者情報 >>
    const ELM_PATIENT = "PATIENT";
    // << 帳票情報 >>
    const ELM_REPORTS = "REPORTS";
    // 帳票情報
    const KEY_REPORT = "REPORT";
    // 帳票情報(削除)
    const KEY_REPORT_DEL = "REPORT_DEL";
    // 透析番号
    const ATT_DIALYSIS_NO = "DIALYSIS_NO";

    // 既存ファイルチェック
    var dir = path.dirname(originalFile);
    if (paitentInfo === null) {
        // 既存ファイルが存在しない場合、引数の患者情報XMLでファイルを作成
        // newPaitentInfoでXMLを作成
        writeXmlFile(originalFile, newPaitentInfo);
        return;
    }

    // 各ファイルをパース
    var xmlNewPaitentInfo = new parser().parseFromString(newPaitentInfo, APPLICATION_XML);
    var xmlPaitentInfo = new parser().parseFromString(paitentInfo, APPLICATION_XML);

    // 患者情報は新しい情報で置換
    var newPatient = xmlNewPaitentInfo.getElementsByTagName(ELM_PATIENT)[0].cloneNode(true);
    xmlPaitentInfo.documentElement.replaceChild(newPatient, xmlPaitentInfo.getElementsByTagName(ELM_PATIENT)[0]);

    // 帳票情報
    var newPatReport = xmlNewPaitentInfo.getElementsByTagName(KEY_REPORT);
    var delPatReport = xmlNewPaitentInfo.getElementsByTagName(KEY_REPORT_DEL);
    var patReport = xmlPaitentInfo.getElementsByTagName(KEY_REPORT);
    var isExist = false;
    // 新しい帳票情報
    for (var i = 0; i < newPatReport.length; i++) {
        isExist = false;
        // 引数の帳票情報のアトリビュートを取得
        var newPatAttribute = newPatReport[i].attributes;
        for (var j = 0; j < patReport.length; j++) {
            // 既存の帳票情報のアトリビュートを取得
            var attribute = patReport[j].attributes;
            if (attribute.getNamedItem(ATT_DIALYSIS_NO).nodeValue 
                    == newPatAttribute.getNamedItem(ATT_DIALYSIS_NO).nodeValue) {
                // 透析番号が一致する帳票情報がある場合は、新しい情報で置換
                var newReport = newPatReport[i].cloneNode(true);
                xmlPaitentInfo.getElementsByTagName(ELM_REPORTS)[0].replaceChild(newReport, patReport[j]);
                isExist = true;
                break;
            }
        }
        if (!isExist) {
            // 透析番号が一致する帳票情報が存在しない場合
            // 新しい帳票情報を追加
            
            var reportsElement = xmlPaitentInfo.getElementsByTagName(ELM_REPORTS)[0];

            // ① 既存の REPORT ノードを取得
            var existingReports = Array.from(reportsElement.getElementsByTagName("REPORT"));
            
            // ② 新しい REPORT ノードを取得
            var newReports = [ newPatReport[i].cloneNode(true) ];
            
            // ③ 既存と新規の REPORT ノードを結合
            var allReports = existingReports.concat(newReports);
            
            // ④ DATETIMEVALUE で降順ソート
            allReports.sort((a, b) => {
              var dateA = a.getAttribute("DATETIMEVALUE");
              var dateB = b.getAttribute("DATETIMEVALUE");
              return dateB.localeCompare(dateA); // 降順
            });
            
            // ⑤ 一旦既存の REPORT ノードを削除
            existingReports.forEach(node => reportsElement.removeChild(node));
            
            // ⑥ ソート済み REPORT ノードを挿入
            allReports.forEach(reportNode => {
              var clonedNode = reportNode.cloneNode(true);
              reportsElement.appendChild(clonedNode);
            });
        }
    }

    // 実績削除された帳票情報
    for (var i = 0; i < delPatReport.length; i++) {
        // 引数の帳票のアトリビュートを取得
        var delPatAttribute = delPatReport[i].attributes;
        for (var j = 0; j < patReport.length; j++) {
            // 既存の帳票情報のアトリビュートを取得
            var attribute = patReport[j].attributes;
            if (attribute.getNamedItem(ATT_DIALYSIS_NO).nodeValue 
                    == delPatAttribute.getNamedItem(ATT_DIALYSIS_NO).nodeValue) {
                // 透析番号が一致する帳票情報がある場合は、実績削除の情報で置換
                var delReport = delPatReport[i].cloneNode(true);
                xmlPaitentInfo.getElementsByTagName(ELM_REPORTS)[0].replaceChild(delReport, patReport[j]);
                break;
            }
        }
    }

    // 整形するためにシリアライズする
    var xml = new serializer().serializeToString(xmlPaitentInfo);
    // 編集した患者情報XMLを保存
    writeXmlFile(originalFile, xml);
}

/**
 * PDF一覧表示情報XMLの作成
 * @param {String} originalFile 既存ファイルパス
 * @param {String} newFile 新規ファイルパス
 */
function makePdfServerInfo(originalFile, newFile) {
    var xmldom = require('@xmldom/xmldom');
    var path = require('path');
    var commonLib = require('./CommonLib.js');
    var parser = xmldom.DOMParser;
    var serializer = xmldom.XMLSerializer;

    // Shift-JISのファイルをUTF-8で読み込む
    var pdfserverinfo = getFileEncodingUtf8(originalFile);
    var newPdfserverinfo = getFileEncodingUtf8(newFile);

    // 既存ファイルチェック
    var dir = path.dirname(originalFile);
    if (pdfserverinfo === null) {
        // 既存ファイルが存在しない場合、引数のPDF一覧表示情報XMLでファイルを作成
        if (!commonLib.isExist(dir)) {
            // ディレクトリ作成
            createDirectory(dir);
        }
        // newPaitentInfoでXMLを作成
        writeXmlFile(originalFile, newPdfserverinfo);
        return;
    }

    // 各ファイルをパース
    var xmlNewPdfserverinfo = new parser().parseFromString(newPdfserverinfo, APPLICATION_XML);
    var xmlPdfserverinfo = new parser().parseFromString(pdfserverinfo, APPLICATION_XML);

    /////////////////////////////////////////
    // 定数定義
    /////////////////////////////////////////
    // <<患者>>
    const ELM_PATIENT = "PATIENT";
    // 表示用患者ID
    const ATT_DISP_PATID = "DISP_PATID";
    // 患者ID
    const ATT_PATID = "PATID";
    // add #9335 NKK連携 rep_dial(listxml)のDISP_PATID_LENGTHの更新が行われない 20230808 孟堅 start
    //表示用患者ID長さ
    const DISP_PATID_LENGTH = "DISP_PATID_LENGTH";
    
    var xmlPdfserverinfoRootElement = xmlPdfserverinfo.documentElement;
    var xmlNewPdfserverinfoRootElement = xmlNewPdfserverinfo.documentElement;
    if(xmlPdfserverinfoRootElement && xmlNewPdfserverinfoRootElement){
        xmlPdfserverinfoRootElement.setAttribute(DISP_PATID_LENGTH,xmlNewPdfserverinfoRootElement.getAttribute(DISP_PATID_LENGTH));
    }
    // add #9335 NKK連携 rep_dial(listxml)のDISP_PATID_LENGTHの更新が行われない 20230808　孟堅 end
    // 患者レコードを取得
    var newPatients = xmlNewPdfserverinfo.getElementsByTagName(ELM_PATIENT);
    var patients = xmlPdfserverinfo.getElementsByTagName(ELM_PATIENT);
    
    for (var i = 0; i< newPatients.length; i++) {
        // 新規患者データのアトリビュートの取得
        var newAttribute = newPatients[i].attributes;
        var isExist = false;
        for (var j = 0; j < patients.length; j++) {
            // 既存患者データのアトリビュートを取得
            var attribute = patients[j].attributes;
            
            if (newAttribute.getNamedItem(ATT_PATID).nodeValue == attribute.getNamedItem(ATT_PATID).nodeValue) {
                // 患者IDが一致する患者データが存在する場合、新しい患者データで置換
                var newPatient = newPatients[i].cloneNode(true);
                xmlPdfserverinfo.getElementsByTagName(ELM_PATIENT)[0].replaceChild(newPatient, patients[j]);
                isExist = true;
                break;
            }

            // 患者IDが一致しない場合、表示用患者IDでもチェックする
            if (newAttribute.getNamedItem(ATT_DISP_PATID).nodeValue == attribute.getNamedItem(ATT_DISP_PATID).nodeValue) {
                // 表示用患者IDが一致する患者データが存在する場合、新しい患者データで置換
                var newPatient = newPatients[i].cloneNode(true);
                xmlPdfserverinfo.getElementsByTagName(ELM_PATIENT)[0].replaceChild(newPatient, patients[j]);
                isExist = true;
                break;
            }
        }

        if (!isExist) {
            // 患者ID、表示用患者IDに一致する患者データが存在しない場合、
            // 新規患者データを追加
            var newPatient = newPatients[i].cloneNode(true);
            xmlPdfserverinfo.lastChild.appendChild(newPatient);
        }
    }

    // 整形するためにシリアライズする
    var xml = new serializer().serializeToString(xmlPdfserverinfo);
    // 編集した患者情報XMLを保存
    writeXmlFile(originalFile, xml);
}

/**
 * Shift-JISファイルをUTF-8で取得する
 * @param {String} file 読込対象のファイルパス
 */
function getFileEncodingUtf8(file) {
    var fs = require('fs');
    var iconv = require("iconv-lite");
    var commonLib = require('./CommonLib.js');
    if (!commonLib.isExist(file)) {
        // ファイルが存在しない場合はnullを返す
        return null;
    }
    var xml = fs.readFileSync(file);
    return iconv.decode(xml, ENDORDE_SHIFT_JIS);
}

/**
 * レポート関連ファイルかチェック
 * @param {*} fileName ファイル名
 * @returns {boolean} レポート関連ファイルの場合はtrue
 */
exports.isReportXml = function(fileName) {
    switch (fileName) {
        case FILENAME_PATIENTINFO:
        case FILENAME_PDFSERVERINFO:
            return true;
        default:
            return false;
    }
}

/**
 * レポート連携 XMLファイルの作成処理
 * @param {String} fileName ファイル名
 * @param {String} originalFile 既存データ
 * @param {String} newFile 新規データ
 */
exports.createOrReplaceReportXml = function(fileName, originalFile, newFile) {
    if (fileName === FILENAME_PATIENTINFO) {
        // 患者情報XMLの場合
        makePatientInfo(originalFile, newFile);
    } else {
        // PDF表示一覧XMLの場合
        makePdfServerInfo(originalFile, newFile);
    }
}
