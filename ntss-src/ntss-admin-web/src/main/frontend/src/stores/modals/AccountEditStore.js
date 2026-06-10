/**
 * アカウント編集Store.
 */
import {
  sendRequestUserAccountInfo,
  sendRequestRegistUserAccount,
  sendRequestRegistProvisionalUserAccount,
  sendRequestCheckDuplication,
  sendRequestUpdateFontSize,
  sendRequestUpdateTheme,
  sendRequestUpdateMenuBar,
  sendRequestUpdateUseAuthFunctions,
  sendRequestUpdateAuthority,
  sendRequestUpdateSplitFrame,
  sendRequestUpdateDefaultSetting,
  sendRequestUpdatePatShareMode
} from "@/apis/User";
import { ApiHelper } from "@/apis/AxiosHelper";
import _ from 'underscore';
import { PATIENT_SEARCH } from "@/constants/defaultSettingConstants";
import { getKurCds } from "@/functions/modals/default-setting/defaultSettingUtils";

const DISP_USER_ID = "dispUserId";
const PASSWORD = "password";
const PASSWORD_CONFIRM = "passwordConfirm";
const LAST_NAME_KANA = "lastNameKana";
const FIRST_NAME_KANA = "firstNameKana";
const LAST_NAME = "lastName";
const FIRST_NAME = "firstName";
const LAST_NAME_ALPHA = "lastNameAlpha";
const FIRST_NAME_ALPHA = "firstNameAlpha";
const MAIL_ADDRESS1 = "mailAddress1";
const MAIL_ADDRESS2 = "mailAddress2";
const EXTENSION_NO = "extensionNo";
const HOME_NO = "homeNo";
const MOBILE_PHONE_NO = "mobilePhoneNo";
const FAX_NO = "faxNo";
const ZIPCD3 = "zipcd3";
const ZIPCD4 = "zipcd4";
const ADDRESS = "address";

// 外部リンク(url*)・メニューグループ(group*)は mst_facility.use_function に存在しない。
// 施設許可で通常機能を絞り込む時も、この2種類はメニュー構造としてそのまま残す。
const isFacilityIndependentFunction = functionCd => {
  return (
    typeof functionCd === "string" &&
    (functionCd.startsWith("url") || functionCd.startsWith("group"))
  );
};

const getFacilityUseFunctions = rootGetters => {
  return rootGetters["facility/useFunction"] || [];
};

// mst_user.user_settings の値はDB保存値として保持し、getterでだけ「現在有効なメニュー」に絞る。
// 施設情報ロード前に空配列になる場合があるため、施設許可が未取得なら元のユーザー設定を返す。
const filterByFacilityUseFunctions = (functions, facilityUseFunctions) => {
  if (!Array.isArray(functions)) {
    return [];
  }
  if (!Array.isArray(facilityUseFunctions) || facilityUseFunctions.length === 0) {
    return functions;
  }
  return functions.filter(
    functionCd =>
      isFacilityIndependentFunction(functionCd) ||
      facilityUseFunctions.indexOf(functionCd) >= 0
  );
};
const ADDRESS_KANA = "addressKana";
const ANESTHESIOLOGIST_LICENSE_NO = "anesthesiologistLicenseNo";
const IN_HOSP_CD_1 = "inHospitalCd_1";
const IN_HOSP_CD_2 = "inHospitalCd_2";
const SECRET_KEY = "secretKey";

export default {
  strict: true,
  namespaced: true,
  state: {
    // アカウント情報
    userAccountInfo: null,
    // Fabメニュー表示用
    userNameForFab: "",
    // バリデーション結果
    validationResults: {
      dispUserId: {
        isNull: false,
        isInvalid: false,
        isOver: false,
        isDuplication: false
      },
      password: {
        isNull: false,
        isInvalid: false,
        isOver: false
      },
      passwordConfirm: {
        isNull: false,
        isInconsistent: false
      },
      lastNameKana: {
        isNull: false,
        isInvalid: false,
        isOver: false
      },
      firstNameKana: {
        isNull: false,
        isInvalid: false,
        isOver: false
      },
      lastName: {
        isNull: false,
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン start
        isInvalid: false,
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン end
        isOver: false
      },
      firstName: {
        isNull: false,
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン start
        isInvalid: false,
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン end
        isOver: false
      },
      lastNameAlpha: {
        isNull: false,
        isInvalid: false,
        isOver: false
      },
      firstNameAlpha: {
        isNull: false,
        isInvalid: false,
        isOver: false
      },
      mailAddress1: {
        isNull: false,
        isInvalid: false,
        isOver: false
      },
      mailAddress2: {
        isInvalid: false,
        isOver: false
      },
      extensionNo: {
        isInvalid: false,
        isOver: false
      },
      homeNo: {
        isInvalid: false,
        isOver: false
      },
      mobilePhoneNo: {
        isInvalid: false,
        isOver: false
      },
      faxNo: {
        isInvalid: false,
        isOver: false
      },
      zipcd3: {
        isInvalid: false,
        isOver: false
      },
      zipcd4: {
        isInvalid: false,
        isOver: false
      },
      address: {
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン start
        isInvalid: false,
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン end
        isOver: false
      },
      addressKana: {
        isInvalid: false,
        isOver: false
      },
      anesthesiologistLicenseNo: {
        isNull: false,
        isInvalid: false,
        isOver: false
      },
      inHospitalCd_1: {
        isInvalid: false,
        isOver: false
      },
      inHospitalCd_2: {
        isInvalid: false,
        isOver: false
      },
      secretKey: {
        isNull: false,
        isInvalid: false,
        isOver: false
      }
    },
    isDuplicatedUser: false,
    registResult: {
      data: null,
      status: null
    },
    message: "",
    fontSize: 1,
    theme: 0,
    isDispMenu: 1,
    isSplitFrame: 1,
    useFunctions: [],
    initialFunction: "",
    authorizedFunctions: [],
    defaultSetting: null,
    card: null,
    isDispFloatMenu: true,
    isDispSidebarBtn: true,
    // mod #12462 患者情報共有 関 start
    patientShareMode: null,
    patientShareFacilityCdMode: null,
    // mod #12462 患者情報共有 関 end
    // del 9941 患者カレンダーで内容保持がされていない。 関 start
    // // add FNSI redmine 4257修正 鄧シン etart
    // ,selectedLayout: null,
    // // add FNSI redmine 4257修正 鄧シン end
    // del 9941 患者カレンダーで内容保持がされていない。 関 end
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    showSidebarFlg: false
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
  },
  mutations: {
    /**
     * アカウント情報設定.
     */
    setUserAccountInfo(state, userAccountInfo) {
      state.userAccountInfo = userAccountInfo;
      // userAccountInfo が空でなければstateに登録する
      if (userAccountInfo) {
        state.userNameForFab = userAccountInfo.userLastName;
        state.fontSize = userAccountInfo.userSettings.font_size;
        state.theme = userAccountInfo.userSettings.theme;
        state.isDispMenu = userAccountInfo.userSettings.is_disp_menu;
        state.isSplitFrame = userAccountInfo.userSettings.is_split_frame;
        state.useFunctions = userAccountInfo.userSettings.use_functions;
        state.initialFunction = userAccountInfo.userSettings.initial_function;
        
        //liyanz-z add 20260420 state.patientShareMode カバー start
        //state.patientShareMode = userAccountInfo.userSettings.pat_share_mode;
        if (state.patientShareMode === undefined || state.patientShareMode === null) {
          state.patientShareMode = userAccountInfo.userSettings.pat_share_mode;
        }
        //liyanz-z add 20260420 state.patientShareMode カバー end

        // mod #10136 サインイン時に初期表示機能が許可状態でない場合、許可範囲上のメニュー設定の表示順最上部の項目に遷移する dou start
        // state.initialFunction = userAccountInfo.userSettings.initial_function;
        // 外部リンクメニューは初期表示対象 指定不可
        if (
          userAccountInfo.userSettings.authorized_functions.includes(userAccountInfo.userSettings.initial_function) && 
          !userAccountInfo.userSettings.initial_function.startsWith("url")
        ) {
          state.initialFunction = userAccountInfo.userSettings.initial_function;
        } else {
          // サインイン時に初期表示機能が許可状態でない場合、外部リンクメニューを除いた許可範囲上のメニュー設定の表示順最上部の項目に設定する
          let intersection = _.intersection(
            userAccountInfo.userSettings.use_functions,
            userAccountInfo.userSettings.authorized_functions
          ).filter(item => !item.startsWith("url"));
          state.initialFunction = _.find(userAccountInfo.userSettings.use_functions, x => intersection.includes(x));
        }
        // mod #10136 サインイン時に初期表示機能が許可状態でない場合、許可範囲上のメニュー設定の表示順最上部の項目に遷移する dou end
        state.authorizedFunctions =
          userAccountInfo.userSettings.authorized_functions;
        state.defaultSetting =
          userAccountInfo.userSettings.default_setting;
        // サインイン時、サインイン時点の時刻に該当するクールコード（マスタから取得）を'default_setting'->'patient-search'->'kurCdList'に設定する
        if (userAccountInfo.mstKur != null) {
          // mstKurからシステム時刻が範囲内のクールコードの配列を取得
          const kurCdList = getKurCds(userAccountInfo.mstKur);
          // patient-searchが存在しない場合は初期化
          if (!state.defaultSetting[PATIENT_SEARCH.KEY_NAME]) {
              state.defaultSetting[PATIENT_SEARCH.KEY_NAME] = {};
          }
          // kurCdListをセット
          state.defaultSetting[PATIENT_SEARCH.KEY_NAME][PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST] = kurCdList;
        }
      }
    },
    /**
     * アカウント情報を更新する
     * @param {*} state
     * @param {*} userAccountInfo
     */
    updateUserAccountInfo(state, userAccountInfo) {
      state.userAccountInfo = userAccountInfo;
    },
    /**
     * メニュー表示フラグ設定.
     */
    setIsDispMenu(state, isDispMenu) {
      state.isDispMenu = isDispMenu;
    },
    /**
     * 文字サイズ設定.
     */
    setFontSize(state, fontSize) {
      state.fontSize = fontSize;
    },
    /**
     * テーマ設定.
     */
    setTheme(state, theme) {
      state.theme = theme;
    },
    /**
     * 画面フレーム分割設定.
     */
    setIsSplitFrame(state, isSplitFrame) {
      state.isSplitFrame = isSplitFrame;
    },
    // mod #12462 患者情報共有 関 start
    setPatientShareMode(state, patientShareMode) {
      state.patientShareMode = patientShareMode;
    },
    setPatientShareFacilityCdMode(state, patientShareFacilityCdMode) {
      state.patientShareFacilityCdMode = patientShareFacilityCdMode;
    },
    // mod #12462 患者情報共有 関 end
    /**
     * 使用機能設定.
     */
    setUseFunctions(state, useFunctions) {
      state.useFunctions = useFunctions;
    },
    /**
     * 初期表示機能コード.
     */
    setInitialFunction(state, initialFunction) {
      state.initialFunction = initialFunction;
    },
    /**
     * 仮ユーザー更新処理結果設定.
     */
    setRegistResult(state, registResult) {
      state.registResult = registResult;
    },
    /**
     * デフォルト設定を設定.
     */
    setDefaultSetting(state, defaultSetting) {
      state.defaultSetting = defaultSetting;
    },
    // ----- バリデーション結果格納 -----
    /**
     * ID重複チェック.
     */
    setIsDuplication(state, isDuplication) {
      state.validationResults.dispUserId.isDuplication = isDuplication.result;
      state.message = isDuplication.errorMessage;
    },
    /**
     * ID重複チェック.
     * TODO 上のメソッドと重複しているが、変数の持ち方が違うため、別途定義した。そのうち、統一したい
     */
    setIsDuplicatedUser(state, response) {
      state.isDuplicatedUser = response.result;
      state.message = response.errorMessage;
    },
    /**
     * 必須チェック.
     */
    setIsNull(state, itemNameAndResult) {
      const result = itemNameAndResult.result;
      switch (itemNameAndResult.itemName) {
        case DISP_USER_ID: {
          state.validationResults.dispUserId.isNull = result;
          break;
        }
        case PASSWORD: {
          state.validationResults.password.isNull = result;
          break;
        }
        case PASSWORD_CONFIRM: {
          state.validationResults.passwordConfirm.isNull = result;
          break;
        }
        case LAST_NAME_KANA: {
          state.validationResults.lastNameKana.isNull = result;
          break;
        }
        case FIRST_NAME_KANA: {
          state.validationResults.firstNameKana.isNull = result;
          break;
        }
        case LAST_NAME: {
          state.validationResults.lastName.isNull = result;
          break;
        }
        case FIRST_NAME: {
          state.validationResults.firstName.isNull = result;
          break;
        }
        case LAST_NAME_ALPHA: {
          state.validationResults.lastNameAlpha.isNull = result;
          break;
        }
        case FIRST_NAME_ALPHA: {
          state.validationResults.firstNameAlpha.isNull = result;
          break;
        }
        case MAIL_ADDRESS1: {
          state.validationResults.mailAddress1.isNull = result;
          break;
        }
        case ANESTHESIOLOGIST_LICENSE_NO: {
          state.validationResults.anesthesiologistLicenseNo.isNull = result;
          break;
        }
        case SECRET_KEY: {
          state.validationResults.secretKey.isNull = result;
          break;
        }
        default:
          break;
      }
    },
    /**
     * 型チェック.
     */
    setIsInvalid(state, itemNameAndResult) {
      const result = itemNameAndResult.result;
      switch (itemNameAndResult.itemName) {
        case DISP_USER_ID: {
          state.validationResults.dispUserId.isInvalid = result;
          break;
        }
        case PASSWORD: {
          state.validationResults.password.isInvalid = result;
          break;
        }
        case PASSWORD_CONFIRM: {
          state.validationResults.passwordConfirm.isInvalid = result;
          break;
        }
        case LAST_NAME_KANA: {
          state.validationResults.lastNameKana.isInvalid = result;
          break;
        }
        case FIRST_NAME_KANA: {
          state.validationResults.firstNameKana.isInvalid = result;
          break;
        }
        case LAST_NAME: {
          state.validationResults.lastName.isInvalid = result;
          break;
        }
        case FIRST_NAME: {
          state.validationResults.firstName.isInvalid = result;
          break;
        }
        case LAST_NAME_ALPHA: {
          state.validationResults.lastNameAlpha.isInvalid = result;
          break;
        }
        case FIRST_NAME_ALPHA: {
          state.validationResults.firstNameAlpha.isInvalid = result;
          break;
        }
        case MAIL_ADDRESS1: {
          state.validationResults.mailAddress1.isInvalid = result;
          break;
        }
        case MAIL_ADDRESS2: {
          state.validationResults.mailAddress2.isInvalid = result;
          break;
        }
        case EXTENSION_NO: {
          state.validationResults.extensionNo.isInvalid = result;
          break;
        }
        case HOME_NO: {
          state.validationResults.homeNo.isInvalid = result;
          break;
        }
        case MOBILE_PHONE_NO: {
          state.validationResults.mobilePhoneNo.isInvalid = result;
          break;
        }
        case FAX_NO: {
          state.validationResults.faxNo.isInvalid = result;
          break;
        }
        case ZIPCD3: {
          state.validationResults.zipcd3.isInvalid = result;
          break;
        }
        case ZIPCD4: {
          state.validationResults.zipcd4.isInvalid = result;
          break;
        }
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン start
        case ADDRESS: {
          state.validationResults.address.isInvalid = result;
          break;
        }
        // add 「自宅住所(漢字)」の「\」チェック 鄧シン end
        case ADDRESS_KANA: {
          state.validationResults.addressKana.isInvalid = result;
          break;
        }
        case ANESTHESIOLOGIST_LICENSE_NO: {
          state.validationResults.anesthesiologistLicenseNo.isInvalid = result;
          break;
        }
        case IN_HOSP_CD_1: {
          state.validationResults.inHospitalCd_1.isInvalid = result;
          break;
        }
        case IN_HOSP_CD_2: {
          state.validationResults.inHospitalCd_2.isInvalid = result;
          break;
        }
        case SECRET_KEY: {
          state.validationResults.secretKey.isInvalid = result;
          break;
        }
        default:
          break;
      }
    },
    /**
     * 文字数チェック.
     */
    setIsOver(state, itemNameAndResult) {
      const result = itemNameAndResult.result;
      switch (itemNameAndResult.itemName) {
        case DISP_USER_ID: {
          state.validationResults.dispUserId.isOver = result;
          break;
        }
        case PASSWORD: {
          state.validationResults.password.isOver = result;
          break;
        }
        case PASSWORD_CONFIRM: {
          state.validationResults.passwordConfirm.isOver = result;
          break;
        }
        case LAST_NAME_KANA: {
          state.validationResults.lastNameKana.isOver = result;
          break;
        }
        case FIRST_NAME_KANA: {
          state.validationResults.firstNameKana.isOver = result;
          break;
        }
        case LAST_NAME: {
          state.validationResults.lastName.isOver = result;
          break;
        }
        case FIRST_NAME: {
          state.validationResults.firstName.isOver = result;
          break;
        }
        case LAST_NAME_ALPHA: {
          state.validationResults.lastNameAlpha.isOver = result;
          break;
        }
        case FIRST_NAME_ALPHA: {
          state.validationResults.firstNameAlpha.isOver = result;
          break;
        }
        case MAIL_ADDRESS1: {
          state.validationResults.mailAddress1.isOver = result;
          break;
        }
        case MAIL_ADDRESS2: {
          state.validationResults.mailAddress2.isOver = result;
          break;
        }
        case EXTENSION_NO: {
          state.validationResults.extensionNo.isOver = result;
          break;
        }
        case HOME_NO: {
          state.validationResults.homeNo.isOver = result;
          break;
        }
        case MOBILE_PHONE_NO: {
          state.validationResults.mobilePhoneNo.isOver = result;
          break;
        }
        case FAX_NO: {
          state.validationResults.faxNo.isOver = result;
          break;
        }
        case ZIPCD3: {
          state.validationResults.zipcd3.isOver = result;
          break;
        }
        case ZIPCD4: {
          state.validationResults.zipcd4.isOver = result;
          break;
        }
        case ADDRESS: {
          state.validationResults.address.isOver = result;
          break;
        }
        case ADDRESS_KANA: {
          state.validationResults.addressKana.isOver = result;
          break;
        }
        case ANESTHESIOLOGIST_LICENSE_NO: {
          state.validationResults.anesthesiologistLicenseNo.isOver = result;
          break;
        }
        case IN_HOSP_CD_1: {
          state.validationResults.inHospitalCd_1.isOver = result;
          break;
        }
        case IN_HOSP_CD_2: {
          state.validationResults.inHospitalCd_2.isOver = result;
          break;
        }
        case SECRET_KEY: {
          state.validationResults.secretKey.isOver = result;
          break;
        }
        default:
          break;
      }
    },
    /**
     * 整合性チェック.
     */
    setIsInconsistent(state, result) {
      state.validationResults.passwordConfirm.isInconsistent = result;
    },
    /**
     * バリデーション結果の初期化.
     */
    resetValidationResults(state) {
      const validationResults = state.validationResults;
      Object.keys(validationResults).forEach(key => {
        const validationResult = validationResults[key];
        Object.keys(validationResult).forEach(
          resultKey => (validationResult[resultKey] = false)
        );
      });
    },
    setDuplicatedUser(state, result) {
      state.isDuplicatedUser = result;
    },
    /**
     * 指定の内容でカード情報を保存します.
     * @param {*} state stateオブジェクト
     * @param {*} card カード情報
     */
    setCard(state, card) {
      state.card = card;
    },
    /**
     * フロートメニュー表示フラグ設定.
     */
    setIsDispFloatMenu(state, isDispFloatMenu) {
      state.isDispFloatMenu = isDispFloatMenu;
    },
    /**
     * サイドバー開閉ボタン表示フラグ設定.
     */
    setIsDispSidebarBtn(state, isDispSidebarBtn) {
      state.isDispSidebarBtn = isDispSidebarBtn;
    },
    // del 9941 患者カレンダーで内容保持がされていない。 関 start
    // // add FNSI redmine 4257修正 鄧シン start
    // /**
    //  * 画面状態.
    //  */
    // ,setSelectedLayout(state, selectedLayout) {
    //   state.selectedLayout = selectedLayout.selectedLayout;
    // },
    // // add FNSI redmine 4257修正 鄧シン end
    // del 9941 患者カレンダーで内容保持がされていない。 関 end
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    setShowSidebarFlg(state, showSidebarFlg) {
      state.showSidebarFlg = showSidebarFlg;
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    /**
     * 権限設定を設定.
     */
    setAuthorizedFunctions(state, authorizedFunctions) {
      state.authorizedFunctions = authorizedFunctions;
    },
  },
  actions: {
    /**
     * アカウント情報取得(同期処理).
     */
    getUserAccountInfo({ commit }) {
        return sendRequestUserAccountInfo().then(response => {
        const userAccountInfo = response.data.userAccountInfo;
        commit("setUserAccountInfo", userAccountInfo);
      });
    },
    /**
     * アカウント情報取得(同期処理). サインイン時に呼出し
     */
    async getUserAccountInfoSignIn({ commit }) {
      try {
        const response = await sendRequestUserAccountInfo();
        const userAccountInfo = response.data.userAccountInfo;
        if (userAccountInfo) {
          // クールマスタ取得
          const mstKurResponse = await ApiHelper.get("/mstInfo/mstKur", {
              facility_cd: userAccountInfo.facilityCd,
              is_del: "0"
          });
          userAccountInfo.mstKur = mstKurResponse.data;
        }
        commit("setUserAccountInfo", userAccountInfo);
      } catch (error) {
        console.error(e);
        throw error;
      }
    },
    /***切替 */
    async getUserAccountInfoSignInCheck({ commit }) {
      try {
        const response = await sendRequestUserAccountInfo();
        const userAccountInfo = response.data.userAccountInfo;
        if (userAccountInfo) {
          // クールマスタ取得
          const mstKurResponse = await ApiHelper.get("/mstInfo/mstKur", {
              facility_cd: userAccountInfo.facilityCd,
              is_del: "0"
          });
          userAccountInfo.mstKur = mstKurResponse.data;
        }
        commit("setUserAccountInfo", userAccountInfo);
        return userAccountInfo
      } catch (error) {
        console.error(e);
        throw error;
      }
    },
    /**
     * ユーザ情報更新処理.
     */
    registUserAccount(context, request) {
      return sendRequestRegistUserAccount(request);
    },
    /**
     * 初回ログイン用のユーザ情報更新処理.
     * actionを呼ぶためdispatchをパラメータに持つ
     */
    registProvisionalUserAccount(context, request) {
      return sendRequestRegistProvisionalUserAccount(request);
    },
    /**
     * API結果をstateに保存する.
     * promiseのcatch句内で実行できなかったため切り出した
     * @param response APIレスポンス
     */
    setResponse({ commit }, response) {
      const result = { data: response.data, status: response.status };
      commit("setRegistResult", result);
    },
    /**
     * アカウント情報クリア.
     */
    clearUserAccountInfo({ commit }) {
      commit("setUserAccountInfo", null);
    },
    /**
     * ID重複チェック.
     */
    async checkDuplication({ commit }, userInfo) {
      // 重複チェックAPI呼出し
      return sendRequestCheckDuplication(
        userInfo.userId,
        encodeURIComponent(userInfo.dispUserId)
      ).then(response => {
        commit("setIsDuplication", response.data);
      });
    },
    /**
     * ID重複チェック.
     * TODO 上のメソッドと重複しているが、変数の持ち方が違うため、別途定義した。
     */
    async checkDuplicatedUser({ commit }, userInfo) {
      // 重複チェックAPI呼出し
      return sendRequestCheckDuplication(
        userInfo.userId,
        encodeURIComponent(userInfo.dispUserId)
      ).then(response => {
        commit("setIsDuplicatedUser", response.data);
      });
    },
    /**
     * 文字サイズ設定処理.
     */
    setFontSize({ commit }, fontSize) {
      commit("setFontSize", fontSize);
    },
    /**
     * 文字サイズ更新処理.
     */
    updateFontSize(context, request) {
      return sendRequestUpdateFontSize(request);
    },
    /**
     * 患者共有設定更新処理.
     */
    updatePatShareMode(context, request) {
      return sendRequestUpdatePatShareMode(request);
    },
    /**
     * テーマ設定処理.
     */
    setTheme({ commit }, theme) {
      commit("setTheme", theme);
    },
    /**
     * テーマリセット処理.
     */
    resetTheme({ commit }) {
      commit("setTheme", 0);
    },
    /**
     * テーマ更新処理.
     */
    updateTheme(context, request) {
      return sendRequestUpdateTheme(request);
    },
    /**
     * 画面フレーム分割設定処理.
     */
    setIsSplitFrame({ commit }, isSplitFrame) {
      commit("setIsSplitFrame", isSplitFrame);
    },
    setPatientShareMode({ commit }, patientShareMode) {
      commit("setPatientShareMode", patientShareMode);
    },
    setPatientShareFacilityCdMode({ commit }, patientShareFacilityCdMode) {
      commit("setPatientShareFacilityCdMode", patientShareFacilityCdMode);
    },
    /**
     * 画面フレーム分割更新処理.
     */
    updateIsSplitFrame(context, request) {
      return sendRequestUpdateSplitFrame(request);
    },
    /**
     * メニューバー設定処理.
     */
    setMenuBar({ commit }, request) {
      commit("setIsDispMenu", request.isDispMenu);
      commit("setUseFunctions", request.useFunctions);
      commit("setInitialFunction", request.initialFunction);
    },
    /**
     * メニューバー表示/非表示設定処理.
     */
    setDispMenuBar({ commit }, isDispFlg) {
      commit("setIsDispMenu", isDispFlg);
    },
    /**
     * メニューバー設定更新処理.
     */
    async updateMenuBar(context, request) {
      return sendRequestUpdateMenuBar(request);
    },
    /**
     * ユーザー使用可能機能設定更新処理.
     */
    async updateUseAuthFunctions(context, request) {
      return sendRequestUpdateUseAuthFunctions(request);
    },
    /**
     * ユーザー権限更新処理.
     */
    async updateAuthority(context, request) {
      return sendRequestUpdateAuthority(request);
    },
    /**
     * デフォルト設定更新処理.
     */
    async updateDefaultSetting(context, request) {
      return sendRequestUpdateDefaultSetting(request);
    },
    setIsNull({ commit }, itemNameAndResult) {
      commit("setIsNull", itemNameAndResult);
    },
    setIsInvalid({ commit }, itemNameAndResult) {
      commit("setIsInvalid", itemNameAndResult);
    },
    setIsOver({ commit }, itemNameAndResult) {
      commit("setIsOver", itemNameAndResult);
    },
    setIsInconsistent({ commit }, result) {
      commit("setIsInconsistent", result);
    },
    resetValidationResults({ commit }) {
      commit("resetValidationResults");
    },
    setDuplicatedUser({ commit }, result) {
      commit("setDuplicatedUser", result);
    },
    /**
     * 指定の内容でカード情報を保存します.
     * @param {*} commit stateオブジェクト
     * @param {*} card カード情報
     */
    setCard({ commit }, card) {
      commit("setCard", card);
    },
    /**
     * カード情報をクリアします.
     * @param {*} commit stateオブジェクト
     */
    clearCard({ commit }) {
      commit("setCard", null);
    },
    setIsDispFloatMenu({ commit }, isDispFloatMenu) {
      commit("setIsDispFloatMenu", isDispFloatMenu);
    },
    setIsDispSidebarBtn({ commit }, isDispSidebarBtn) {
      commit("setIsDispSidebarBtn", isDispSidebarBtn);
    },
    // del 9941 患者カレンダーで内容保持がされていない。 関 start
    // // add FNSI redmine 4257修正 鄧シン start
    // ,setSelectedLayoutForSave({ commit }, selectedLayout) {
    //   commit("setSelectedLayout", selectedLayout);
    // },
    // //add FNSI redmine 4257修正 鄧シン end
    // del 9941 患者カレンダーで内容保持がされていない。 関 end
    /**
     * デフォルト設定設定処理.
     */
    setDefaultSetting({ commit }, defaultSetting) {
      commit("setDefaultSetting", defaultSetting);
    },
    /**
     * 権限設定設定処理.
     */
    setAuthorizedFunctions({ commit }, authorizedFunctions) {
      commit("setAuthorizedFunctions", authorizedFunctions);
    },
  },
  getters: {
    getStateUserAccountInfo(state) {
      return state.userAccountInfo;
    },
    isDuplicatedUser(state) {
      return state.isDuplicatedUser;
    },
    isUseFunction: (state, getters) => functionCd => {
      return getters.getUseFunctions.indexOf(functionCd) >= 0;
    },
    isDispMenu(state) {
      return state.isDispMenu;
    },
    /**
     * 画面フレーム分割設定を取得する.
     * @param {*} state stateオブジェクト
     */
    getSplitFrame(state) {
      return state.isSplitFrame;
    },
    // mod #12462 患者情報共有 関 start
    getPatientShareMode(state) {
      return state.patientShareMode;
    },
    getPatientShareFacilityCdMode(state) {
      return state.patientShareFacilityCdMode;
    },
    // mod #12462 患者情報共有 関 end
    getTheme(state) {
      return state.theme;
    },
    getFontSize(state) {
      return state.fontSize;
    },
    getRegistResult(state) {
      return state.registResult;
    },
    getUserNameForFab(state) {
      return state.userNameForFab;
    },
    getUseFunctions(state, getters, rootState, rootGetters) {
      // mst_user.user_settings.use_functions はDB保存値を保持したまま、
      // 表示・遷移判定では以下の AND 条件だけを適用する。
      // 1. 施設許可ON
      // 2. 利用者許可機能ON
      // 3. 利用者メニュー設定(use_functions)ON
      // これにより施設OFF / authorized_functions OFF でも
      // use_functions に残っている項目はメニューに反映しない。
      const facilityFilteredUseFunctions = filterByFacilityUseFunctions(
        state.useFunctions,
        getFacilityUseFunctions(rootGetters)
      );
      const authorizedFunctions = getters.getAuthorizedFunctions;
      return facilityFilteredUseFunctions.filter(functionCd =>
        authorizedFunctions.includes(functionCd)
      );
    },
    getInitialFunction(state, getters) {
      const useFunctions = getters.getUseFunctions;
      const authorizedFunctions = getters.getAuthorizedFunctions;
      // DBに保存されている初期表示機能は更新しない。
      // サインイン時点で施設許可OFF・利用者許可OFF・利用者使用不可のどれかに該当した場合は無効扱いにする。
      if (
        state.initialFunction &&
        useFunctions.indexOf(state.initialFunction) >= 0 &&
        authorizedFunctions.indexOf(state.initialFunction) >= 0 &&
        !state.initialFunction.startsWith("url")
      ) {
        return state.initialFunction;
      }
      // 初期表示機能が無効になった場合、現在メニューに出せる機能の先頭をホーム機能として返す。
      // state.initialFunction 自体は書き換えず、施設許可が戻った時に元の設定を利用できるようにする。
      const intersection = _.intersection(useFunctions, authorizedFunctions).filter(item => !item.startsWith("url"));
      return _.find(useFunctions, x => intersection.includes(x)) || "";
    },
    getMessage(state) {
      return state.message;
    },
    getValidationResults(state) {
      return state.validationResults;
    },
    getAuthorizedFunctions(state, getters, rootState, rootGetters) {
      // mst_user.user_settings.authorized_functions も物理更新せず、メニュー反映時だけ施設許可をAND条件にする。
      return filterByFacilityUseFunctions(
        state.authorizedFunctions,
        getFacilityUseFunctions(rootGetters)
      );
    },
    getDefaultSetting(state) {
      return state.defaultSetting;
    },
    getUserId(state) {
      return state.userAccountInfo.userId;
    },
    getUserName(state) {
      return (
        state.userAccountInfo.userLastName +
        " " +
        state.userAccountInfo.userFirstName
      );
    },
    getIsDispFloatMenu(state) {
      return state.isDispFloatMenu;
    },
    getIsDispSidebarBtn(state) {
      return state.isDispSidebarBtn;
    },
    // del 9941 患者カレンダーで内容保持がされていない。 関 start
    // // add FNSI redmine 4257修正 鄧シン start
    // getSelectedLayout(state) {
    //   return state.selectedLayout;
    // },
    // // add FNSI redmine 4257修正 鄧シン end
    // del 9941 患者カレンダーで内容保持がされていない。 関 end
    getIsNkkAdmin(state) {
      return state.userAccountInfo.userType === 1 && state.userAccountInfo.administrator === 1
    },
    /**
     * サインイン者が日機装施設に属しているか否かを返す.
     * 判定は施設コードが"nkknkk"か否かで判断する.
     *
     * @param {*} state stateオブジェクト
     * @returns true : 日機装施設
     *          false: 通常施設
     */
    isNkkFacility(state) {
      return state.userAccountInfo.facilityCd === "nkknkk";
    },
  }
};
