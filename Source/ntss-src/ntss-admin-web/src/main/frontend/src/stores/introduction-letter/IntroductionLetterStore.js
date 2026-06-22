/**
 * 紹介状詳細Store.
 */

import {ApiHelper} from "@/apis/AxiosHelper.js";
import { showAlertDialog } from "@/functions/common/OnsenFunctions";
import {
  extractFontsFromSVG,
  isFontAvailable,
  replaceUnavailableFonts,
  findFirstAvailableFont
} from "@/stores/fontUtils";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";

// add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
function extractImageInfoFromTemplate(htmlTemplate) {
  if (!htmlTemplate || typeof htmlTemplate !== 'string') {
    return {};
  }
  const imageInfoMap = {};
  try {
    const parser = new DOMParser();
    const doc = parser.parseFromString(htmlTemplate, 'text/html');
    const tdElements = doc.querySelectorAll('td[excelCoordinate]');
    tdElements.forEach(td => {
      const excelCoordinate = td.getAttribute('excelCoordinate');
      const innerHTML = td.innerHTML;
      if (innerHTML.includes('<img')) {
        const imgMatch = innerHTML.match(/<img[^>]*>/);
        if (imgMatch) {
          const imgTag = imgMatch[0];
          const hasSemicolonPath = innerHTML.includes(';path:') ||
            (innerHTML.includes(';') && innerHTML.lastIndexOf(';') > innerHTML.indexOf('>'));
          imageInfoMap[excelCoordinate] = {
            content: innerHTML,
            imgTag: imgTag,
            hasPath: hasSemicolonPath,
            excelCoordinate: excelCoordinate
          };
        }
      }
    });
  } catch (error) {
    console.error('error', error);
  }
  return imageInfoMap;
}
function extractInitialDataFromTemplate(htmlTemplate) {
  if (!htmlTemplate || typeof htmlTemplate !== 'string') {
    return null;
  }
  try {
    const parser = new DOMParser();
    const doc = parser.parseFromString(htmlTemplate, 'text/html');
    const initialData = {};
    const templateImageCoordinates = [];
    const imageSizeMap = {};
    const tdElements = doc.querySelectorAll('td[excelCoordinate]');
    tdElements.forEach(td => {
      const coordinate = td.getAttribute('excelCoordinate');
      const innerHTML = td.innerHTML.trim();
      if (innerHTML !== '') {
        initialData[coordinate] = innerHTML;
        if (innerHTML.includes('<img')) {
          templateImageCoordinates.push(coordinate);
          const imgMatch = innerHTML.match(/<img[^>]+>/);
          if (imgMatch) {
            const imgTag = imgMatch[0];
            const widthMatch = imgTag.match(/width\s*=\s*["']?(\d+)["']?/i);
            const heightMatch = imgTag.match(/height\s*=\s*["']?(\d+)["']?/i);

            if (widthMatch && widthMatch[1] && heightMatch && heightMatch[1]) {
              imageSizeMap[coordinate] = {
                width: parseInt(widthMatch[1], 10),
                height: parseInt(heightMatch[1], 10)
              };
            }
          }
        }
      }
    });
    return {
      data: initialData,
      templateImages: templateImageCoordinates,
      imageSizes: imageSizeMap,
    };
  } catch (error) {
    return null;
  }
}
function parseSpanHtmlFromTemplate(htmlTemplate) {
  const spanHtmlMap = {};
  if (!htmlTemplate || typeof htmlTemplate !== 'string') {
    return spanHtmlMap;
  }
  try {
    const parser = new DOMParser();
    const doc = parser.parseFromString(htmlTemplate, 'text/html');
    const tdElements = doc.querySelectorAll('td[excelCoordinate]');
    tdElements.forEach(td => {
      const coordinate = td.getAttribute('excelCoordinate');
      const innerHTML = td.innerHTML.trim();
      if (innerHTML.includes('<img')) {
        const match = innerHTML.match(/<(span|div|p)[^>]*>[\s\S]*?<img[^>]*>[\s\S]*?<\/\1>/i);
        if (match) {
          spanHtmlMap[coordinate] = match[0];
        }
      }
    });
  } catch (error) {
    console.error('parseSpanHtmlFromTemplate error:', error);
  }
  return spanHtmlMap;
}
// add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end

export default {
  strict: !import.meta.env.PROD,
  namespaced: true,
  state: {
    // 患者イベントレコード
    letterCategory: "0",
    toFacilityCd: null,
    htmlTemplate: null,
    reportCd: null,
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
    pathDB:null,
    /*add FNSI-改修内容患者イベントbug 任 start*/
    updatePdf: true,
    /*add FNSI-改修内容患者イベントbug 任 end*/
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
    /*add FNSI-改修内容転入時の紹介状取込ができない/紹介状登録と編集画面改修四つボタン改修/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 start*/
    pathReal: null,
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
    toMedicalInstitutionCd:null,
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
    dialogMsg: null,
    isNotExit: false,
    isShowSomeThing: false,
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    isUpdateLetter: false,
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
    isGoNext: false,
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
    /*add FNSI-改修内容転入時の紹介状取込ができない/紹介状登録と編集画面改修四つボタン改修/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 end*/
    reportList: [],
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 start
    cltNo:null,
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 end
    reportIsDel:null,
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    templateImageInfo: {},
    initialTemplateData: null,
    hasInitialTemplate: false,
    templateImageCoordinates: [],
    spanHtmlMap: {},
    imageSizeMap: {},
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
  },
  mutations: {
    /**
     * 紹介状
     * @param {*} state
     * @param {*} value
     */
    setLetterCategory: (state, value) => {
      state.letterCategory = value;
    },
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
    setDBPath: (state, value) => {
      state.pathDB = value;
    },
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
    /*add FNSI-改修内容転入時の紹介状取込ができない/紹介状登録と編集画面改修四つボタン改修/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 start*/
    setPath: (state, value) => {
      state.pathReal = value;
    },
    setDialogMsg: (state, value) => {
      state.dialogMsg = value;
    },
    /*add FNSI-改修内容患者イベントbug 任 start*/
    setUpdatePdf: (state, value) => {
      state.updatePdf = value;
    },
    /*add FNSI-改修内容患者イベントbug 任 end*/
    setIsNotExit: (state, value) => {
      state.isNotExit = value;
    },
    setIsShowSomeThing: (state, value) => {
      state.isShowSomeThing = value;
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    setIsUpdateLetter: (state, value) => {
      state.isUpdateLetter = value;
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
    setIsGoNext: (state, value) => {
      state.isGoNext = value;
    },
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
    /*add FNSI-改修内容転入時の紹介状取込ができない/紹介状登録と編集画面改修四つボタン改修/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 end*/
    setToFacilityCd: (state, value) => {
      state.toFacilityCd = value;
    },
    setHtmlTemplate: (state, value) => {
      state.htmlTemplate = value;
    },
    setReportCd: (state, value) => {
      state.reportCd = value;
    },
    clearState: state => {
      state.letterCategory = 0,
      state.toFacilityCd = null,
      state.htmlTemplate = null,
      state.reportCd = null
    },
    setReportList: (state, value) => {
      state.reportList = value;
    },
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 start
    setCltNo: (state, value) => {
      state.cltNo = value;
    },
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 end
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
    setToMedicalInstitutionCd: (state, value) => {
      state.toMedicalInstitutionCd = value;
    },
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
    setReportIsDel: (state, value) => {
      state.reportIsDel = value;
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    setTemplateImageInfo: (state, value) => {
      state.templateImageInfo = value;
    },
    clearTemplateImageInfo: (state) => {
      state.templateImageInfo = {};
    },
    setInitialTemplateData: (state, value) => {
      state.initialTemplateData = value;
    },
    setHasInitialTemplate: (state, value) => {
      state.hasInitialTemplate = value;
    },
    setTemplateImageCoordinates: (state, value) => {
      state.templateImageCoordinates = value;
    },
    clearTemplateImageCoordinates: (state) => {
      state.templateImageCoordinates = [];
    },
    setSpanHtmlMap: (state, value) => {
      state.spanHtmlMap = value;
    },
    setImageSizeMap: (state, value) => {
      state.imageSizeMap = value;
    },
    clearImageSizeMap: (state) => {
      state.imageSizeMap = {};
    },
    removeInitialTemplateImage: (state, coordinate) => {
      if (state.initialTemplateData && state.initialTemplateData[coordinate]) {
        delete state.initialTemplateData[coordinate];
      }
    },
    hasInitialTemplateImage: (state) => (coordinate) => {
      return state.initialTemplateData &&
        state.initialTemplateData[coordinate] &&
        state.initialTemplateData[coordinate].includes('<img');
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
  },
  actions: {
    setLetterCategory({ commit }, value) {
      commit("setLetterCategory", value);
    },
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    setPath({ commit }, value) {
      commit("setPath", value);
    },
    /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
    setDBPath({ commit }, value){
      commit("setDBPath", value);
    },
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
    setIsShowSomeThing({ commit }, value) {
      commit("setIsShowSomeThing", value);
    },
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
    setIsGoNext({ commit }, value) {
      commit("setIsGoNext", value);
    },
    /*add FNSI-改修内容患者イベントbug 任 start*/
    setUpdatePdf({ commit }, value) {
      commit("setUpdatePdf", value);
    },
    /*add FNSI-改修内容患者イベントbug 任 end*/
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
    /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
    setToFacilityCd({ commit }, value) {
      commit("setToFacilityCd", value);
    },
    setHtmlTemplate({ commit }, value) {
      commit("setHtmlTemplate", value);
    },
    setReportCd({ commit }, value) {
      commit("setReportCd", value);
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    setIsUpdateLetter({ commit }, value) {
      commit("setIsUpdateLetter", value);
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
    setToMedicalInstitutionCd({ commit }, value) {
      commit("setToMedicalInstitutionCd", value);
    },
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
    async setTemplate({ commit }, params) {
      // mod 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 start
      //await ApiHelper.get(`/pat-introduction-letter/get-intro-letter-template/${params.patId}/${params.reportCd}`)
      // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
       //await ApiHelper.get(`/pat-introduction-letter/get-intro-letter-template/${params.patId}/${params.reportCd}/${params.ctlNo}/${params.isUpdate}`)
       await ApiHelper.get(`/pat-introduction-letter/get-intro-letter-template/${params.patId}/${params.reportCd}/${params.ctlNo}/${params.isUpdate}/${params.reportStartDate}`)
      // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
       // mod 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 end
        .then(async response => {
          let data = response.data;
          // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe start
          // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
          if (data.htmlTemplate) {
            data.htmlTemplate = data.htmlTemplate.replaceAll("text-align:fill;", "overflow:hidden;");
            const imageInfoMap = extractImageInfoFromTemplate(data.htmlTemplate);
            commit("setTemplateImageInfo", imageInfoMap);
            const extractionResult = extractInitialDataFromTemplate(data.htmlTemplate);
            if (extractionResult && extractionResult.data) {
              commit("setInitialTemplateData", extractionResult.data);
              commit("setHasInitialTemplate", true);
              commit("setTemplateImageCoordinates", extractionResult.templateImages);
              commit("setImageSizeMap", extractionResult.imageSizes);
            } else {
              commit("setInitialTemplateData", {});
              commit("setHasInitialTemplate", false);
              commit("setTemplateImageCoordinates", []);
              commit("setImageSizeMap", {});
            }
            
            const spanHtmlMap = parseSpanHtmlFromTemplate(data.htmlTemplate);
            commit("setSpanHtmlMap", spanHtmlMap);
          }
          // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
          // add #11425 紹介状画面のhtml内で1つのタグにid属性が重複設定される limingzhe end
          // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 start
          // ApiHelper.post("/report_menu/getSysFontsConfig").then(responseFonts =>{
          //   const fontFallbackRules = responseFonts.data;
          //   const fonts = extractFontsFromSVG(data.htmlTemplate)
          //   const fallbackMap = {}
          //   fonts.forEach(font => {
          //     if (!isFontAvailable(font) && fontFallbackRules[font]) {
          //       const fallbackFont = findFirstAvailableFont(fontFallbackRules[font])
          //       if (fallbackFont) {
          //         fallbackMap[font] = fallbackFont
          //       }
          //     }
          //   })
          //   if(fallbackMap) {
          //     data.htmlTemplate = replaceUnavailableFonts(data.htmlTemplate, fallbackMap);
          //     commit("setHtmlTemplate", processedTemplate);
          //   }
          // });
          // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 end
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 start
          let processedTemplate = data.htmlTemplate;
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 end
          try {
            const fontResponse = await ApiHelper.post("/report_menu/getSysFontsConfig");
            const fontFallbackRules = fontResponse.data;
            const fonts = extractFontsFromSVG(processedTemplate);
            const fallbackMap = {};
            fonts.forEach(font => {
              if (!isFontAvailable(font) && fontFallbackRules[font]) {
                const fallbackFont = findFirstAvailableFont(fontFallbackRules[font]);
                if (fallbackFont) {
                  fallbackMap[font] = fallbackFont;
                }
              }
            });
            if (Object.keys(fallbackMap).length > 0) {
              processedTemplate = replaceUnavailableFonts(processedTemplate, fallbackMap);
            }
          } catch (fontError) {
            console.error("fontError:", fontError);
          }
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
          commit("setHtmlTemplate", processedTemplate);
          commit("setReportCd", params.reportCd);
          // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 start
          if (data.ctlNo) {
            commit("setCltNo", data.ctlNo);
          }
          // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 end
          /*add FNSI-改修内容帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 start*/
          commit("setIsNotExit",false);
          /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
          commit("setIsShowSomeThing",false);
          /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
          /*add FNSI-改修内容帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 end*/
          commit("setReportIsDel", data.reportIsDel);
        })
        .catch (() => {
          commit("setHtmlTemplate", null);
          commit("setReportCd", params.reportCd);
          /*mod FNSI-改修内容帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 start*/
          /*ons.notification.alert({
            title: "エラー",
            message: "紹介状テンプレートが存在していません。"
          });*/
          commit("setIsNotExit",true);
          /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
          commit("setIsShowSomeThing",true);
          /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
          /*mod FNSI-改修内容帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 end*/
        })
    },
    /*mod FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
   /* async onUpdatePatInfo(temp, params) {*/
    async onUpdatePatInfo({ commit }, params) {
      /*mod FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
      await ApiHelper.post(`/pat-introduction-letter/sync-patient-information`, {
        letterData: params.letterData,
        reportCd: params.reportCd,
        patId: params.patId
      })
      /*mod FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
      // .then(() => {
      //     ons.notification.alert({
      //       title: "更新完了",
      //       message: "患者情報更新が完了しました。"
      //     });
      .then(res => {
        if(res.data.msg === "false"){
          commit("setDialogMsg", res.data.msg);
        }else if(res.data.msg === "dateFalse"){
          commit("setDialogMsg", res.data.msg);
          /*add FNSI-改修内容患者イベント外结No.6 任 start*/
        }else if(res.data.msg === "inOutClassFalse"){
          commit("setDialogMsg", res.data.msg);
          /*add FNSI-改修内容患者イベント外结No.6 任 end*/
        }else{
          commit("setDialogMsg", true);
          showAlertDialog({
            title: "更新完了",
            message: "患者情報更新が完了しました。"
          });
        }
        /*mod FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
      })
      .catch ( () => {
        showAlertDialog({
          title: "更新失敗",
          message: "患者情報が</br>更新されませんでした。"
        });
      })
    },
    async onPrintLetter(temp, params) {
      await ApiHelper.post(`/pat-introduction-letter/print-report`, {
        htmlTemplate: params.htmlTemplate,
        patId: params.patId,
        /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
        dispItemInfo: params.dispItemInfo,
        /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
        reportCd: params.reportCd,
        printerCd:params.printerCd
        // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
        , ctlNo: params.ctlNo
        // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
      })
        .then( () => {
          showAlertDialog({
            title: "",
            message: "印刷完了しました。"
          });
        })
        .catch ( () => {
          // del #12107 帳票印刷失敗通知が行われない limingzhe start
          // // add 9616 帳票印刷失敗通知がされない 李 start
          // ApiHelper.put(`/report_menu/registerNotification/${params.facilityCd}/紹介状/紹介状`)
          // // add 9616 帳票印刷失敗通知がされない 李 end
          // del #12107 帳票印刷失敗通知が行われない limingzhe end
          // mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start
          // ons.notification.alert({
          //   title: "",
          //   message: "印刷失敗しました。"
          // });
          showAlertDialog({
            title: DIALOG_MESSAGES[12000207].title,
            message: DIALOG_MESSAGES[12000207].message
          });
          // mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end
        })
    },
    setReportList({commit}, value) {
      commit("setReportList", value);
    },
    clearState({ commit }) {
      commit("clearState");
    }
  },
  getters: {
    getLetterCategory :state => state.letterCategory,
    getToFacilityCd :state => state.toFacilityCd,
    getHtmlTemplate :state => state.htmlTemplate,
    getReportCd :state => state.reportCd,
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
    getDBPath (state){
      return state.pathDB;
    },
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
    /*add FNSI-改修内容転入時の紹介状取込ができない/紹介状登録と編集画面改修四つボタン改修/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 start*/
    getPathReal(state) {
      return state.pathReal;
    },
    getDialogMsg: state => state.dialogMsg,
    getIsNotExit: state => state.isNotExit,
    getIsShowSomeThing: state => state.isShowSomeThing,
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
    getIsGoNext: state => state.isGoNext,
    /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
    /*add FNSI-改修内容転入時の紹介状取込ができない/紹介状登録と編集画面改修四つボタン改修/帳票テンプレートが存在しない場合のメッセージをPOPUP表示ではないく、画面に表示するように修正。 任 end*/
    getReportList: state => state.reportList,
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 start
    getCltNo:state => state.cltNo,
    // add 11488 紹介状登録内容保存時に帳票の版も記憶する 1.1A  吉 end
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    getIsUpdateLetter: state => state.isUpdateLetter,
    /*add FNSI-改修内容患者イベントbug 任 start*/
    getUpdatePdf: state => state.updatePdf,
    /*add FNSI-改修内容患者イベントbug 任 end*/
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
    getToMedicalInstitutionCd: state => state.toMedicalInstitutionCd,
    // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
    getReportIsDel:state => state.reportIsDel,
    getTemplateImageInfo: state => state.templateImageInfo,
    getImageInfoByCoordinate: state => coordinate => {
      return state.templateImageInfo[coordinate] || null;
    },
    hasTemplateImages: state => {
      return Object.keys(state.templateImageInfo).length > 0;
    },
    getInitialTemplateData: state => state.initialTemplateData,
    getHasInitialTemplate: state => state.hasInitialTemplate,
    getTemplateImageCoordinates: state => state.templateImageCoordinates,
    isTemplateImage: state => coordinate => {
      return state.templateImageCoordinates.includes(coordinate);
    },
    getSpanHtmlByCoordinate: state => coordinate => {
      return state.spanHtmlMap[coordinate] || null;
    },
    getImageSizeByCoordinate: state => coordinate => {
      return state.imageSizeMap[coordinate] || null;
    },
    getImageSizeMap: state => state.imageSizeMap,
  },
};
