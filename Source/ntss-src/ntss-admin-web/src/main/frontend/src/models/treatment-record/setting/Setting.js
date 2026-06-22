import { SousaHani } from "@/models/treatment-record/setting/SousaHani";
import { KeihouTen } from "@/models/treatment-record/setting/KeihouTen";
import { KetsuatsuKei } from "@/models/treatment-record/setting/KetsuatsuKei";
import { Bv } from "@/models/treatment-record/setting/Bv";
import { PrimingAndHenketsu } from "@/models/treatment-record/setting/PrimingAndHenketsu";
import { DFas } from "@/models/treatment-record/setting/DFas";
import { SouchiProgram } from "@/models/treatment-record/setting/SouchiProgram";
import { KetsuryuuRyouAndTousekiEkiRyuuRyouProgram } from "@/models/treatment-record/setting/KetsuryuuRyouAndTousekiEkiRyuuRyouProgram";
import { TousekiRyouProgram } from "@/models/treatment-record/setting/TousekiRyouProgram";
import { BvUfc } from "@/models/treatment-record/setting/BvUfc";
import { IHdf } from "@/models/treatment-record/setting/IHdf";
import { SeitekiJoumyakuAtsu } from "@/models/treatment-record/setting/SeitekiJoumyakuAtsu";
import { KeihouJouhou } from "@/models/treatment-record/setting/KeihouJouhou";
import { ShijiJouhou } from "@/models/treatment-record/setting/ShijiJouhou";
import { JosuiHoseiJouhou } from "@/models/treatment-record/setting/JosuiHoseiJouhou";
import { TaijuuJouhou } from "@/models/treatment-record/setting/TaijuuJouhou";
import { MasterJouhou } from "@/models/treatment-record/setting/MasterJouhou";
// FNSI-add 装置設定画面表示の修正 徐 start
import { EcumSetting } from "@/models/treatment-record/setting/EcumSetting";
import { Concentration } from "@/models/treatment-record/setting/Concentration";
import { DiversionProgram } from "@/models/treatment-record/setting/DiversionProgram";
import { NaInjectionProgram } from "@/models/treatment-record/setting/NaInjectionProgram";
import { DialysisSolConcentrationProgram } from "@/models/treatment-record/setting/DialysisSolConcentrationProgram";
// FNSI-add 装置設定画面表示の修正 徐 end
import { ORD_TREAT_CONDITION } from "@/constants/OrdTreatCondition";

export class Setting {
  constructor(ordTreatCondition) {
    this.receiveDate = ordTreatCondition.receive_date;
    this.treatCondition = ordTreatCondition.treat_condition;
    this.treatClass = ordTreatCondition.treat_class;
  }

  /**
   * 操作範囲モデルを取得する
   */
  getSousaHani() {
    return new SousaHani(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["179"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["181"],
      this.treatCondition["181"] ? Number(this.treatCondition["181"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["38"],
      this.treatCondition["21"],
      this.treatCondition["22"],
      this.treatCondition["39"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["182"],
      this.treatCondition["182"] ? Number(this.treatCondition["182"]).toFixed(1) : "0.0",
      // this.treatCondition["183"],
      this.treatCondition["183"] ? Number(this.treatCondition["183"]).toFixed(1) : "0.0",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["268"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["269"],
      this.treatCondition["269"] ? Number(this.treatCondition["269"]).toFixed(1) : "0.0",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["24"],
      this.treatCondition["25"],
      this.treatCondition["241"],
      this.treatCondition["168"],
      this.treatCondition["169"],
      this.treatCondition["171"],
      this.treatCondition["172"],
      this.treatCondition["174"],
      this.treatCondition["175"],
      this.treatCondition["177"],
      this.treatCondition["178"],
      this.treatCondition["391"],
      this.treatCondition["392"],
      this.treatCondition["394"],
      this.treatCondition["395"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["383"],
      this.treatCondition["383"] ? Number(this.treatCondition["383"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["389"],
      this.treatCondition["379"],
      this.treatCondition["398"],
      this.treatCondition["369"],
      this.treatCondition["90"],
      this.treatCondition["91"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["92"],
      this.treatCondition["92"] ? Number(this.treatCondition["92"]).toFixed(1) : "0.0",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["472"],
      this.treatCondition["473"],
      this.treatCondition["474"],
      this.treatCondition["475"],
      // FNSI-add 装置設定画面表示の修正 徐 end
      this.treatCondition["336"],
      this.treatCondition["337"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["185"],
      this.treatCondition["185"] ? Number(this.treatCondition["185"]).toFixed(2) : "0.00",
      // this.treatCondition["186"],
      this.treatCondition["186"] ? Number(this.treatCondition["186"]).toFixed(2) : "0.00",
      // this.treatCondition["396"],
      this.treatCondition["396"] ? Number(this.treatCondition["396"]).toFixed(2) : "0.00",
      // this.treatCondition["397"],
      this.treatCondition["397"] ? Number(this.treatCondition["397"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["384"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["385"],
      this.treatCondition["385"] ? Number(this.treatCondition["385"]).toFixed(1) : "0.0",
      // this.treatCondition["386"],
      this.treatCondition["386"] ? Number(this.treatCondition["386"]).toFixed(2) : "0.00",
      // this.treatCondition["387"],
      this.treatCondition["387"] ? Number(this.treatCondition["387"]).toFixed(2) : "0.00"
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // FNSI-add 装置設定画面表示の修正 徐 start
      // this.treatCondition["472"],
      // this.treatCondition["473"],
      // this.treatCondition["474"],
      // this.treatCondition["475"]
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * 操作範囲の項目名を取得する
   */
  getSousaHaniTitle() {
    return [
      ORD_TREAT_CONDITION["179"].name,
      ORD_TREAT_CONDITION["181"].name,
      ORD_TREAT_CONDITION["38"].name,
      ORD_TREAT_CONDITION["21"].name,
      ORD_TREAT_CONDITION["22"].name,
      ORD_TREAT_CONDITION["39"].name,
      ORD_TREAT_CONDITION["182"].name,
      ORD_TREAT_CONDITION["183"].name,
      ORD_TREAT_CONDITION["268"].name,
      ORD_TREAT_CONDITION["269"].name,
      ORD_TREAT_CONDITION["24"].name,
      ORD_TREAT_CONDITION["25"].name,
      ORD_TREAT_CONDITION["241"].name,
      ORD_TREAT_CONDITION["168"].name,
      ORD_TREAT_CONDITION["169"].name,
      ORD_TREAT_CONDITION["171"].name,
      ORD_TREAT_CONDITION["172"].name,
      ORD_TREAT_CONDITION["174"].name,
      ORD_TREAT_CONDITION["175"].name,
      ORD_TREAT_CONDITION["177"].name,
      ORD_TREAT_CONDITION["178"].name,
      ORD_TREAT_CONDITION["391"].name,
      ORD_TREAT_CONDITION["392"].name,
      ORD_TREAT_CONDITION["394"].name,
      ORD_TREAT_CONDITION["395"].name,
      ORD_TREAT_CONDITION["383"].name,
      ORD_TREAT_CONDITION["389"].name,
      ORD_TREAT_CONDITION["379"].name,
      ORD_TREAT_CONDITION["398"].name,
      ORD_TREAT_CONDITION["369"].name,
      ORD_TREAT_CONDITION["90"].name,
      ORD_TREAT_CONDITION["91"].name,
      ORD_TREAT_CONDITION["92"].name,
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["472"].name,
      ORD_TREAT_CONDITION["473"].name,
      ORD_TREAT_CONDITION["474"].name,
      ORD_TREAT_CONDITION["475"].name,
      // FNSI-add 装置設定画面表示の修正 徐 end
      ORD_TREAT_CONDITION["336"].name,
      ORD_TREAT_CONDITION["337"].name,
      ORD_TREAT_CONDITION["185"].name,
      ORD_TREAT_CONDITION["186"].name,
      ORD_TREAT_CONDITION["396"].name,
      ORD_TREAT_CONDITION["397"].name,
      ORD_TREAT_CONDITION["384"].name,
      ORD_TREAT_CONDITION["385"].name,
      ORD_TREAT_CONDITION["386"].name,
      ORD_TREAT_CONDITION["387"].name
      // FNSI-add 装置設定画面表示の修正 徐 start
      // ORD_TREAT_CONDITION["472"].name,
      // ORD_TREAT_CONDITION["473"].name,
      // ORD_TREAT_CONDITION["474"].name,
      // ORD_TREAT_CONDITION["475"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }

  /**
   * 警報点モデルを取得する
   */
  getKeihouTen() {
    return new KeihouTen(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["240"],
      this.treatCondition["100"],
      this.treatCondition["101"],
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["106"],
      this.treatCondition["107"],
      this.treatCondition["102"],
      this.treatCondition["103"],
      this.treatCondition["104"],
      this.treatCondition["105"],
      this.treatCondition["110"],
      this.treatCondition["111"],
      this.treatCondition["108"],
      this.treatCondition["109"],
      this.treatCondition["152"],
      this.treatCondition["153"],
      this.treatCondition["158"],
      this.treatCondition["159"],
      this.treatCondition["154"],
      this.treatCondition["155"],
      this.treatCondition["156"],
      this.treatCondition["157"],
      this.treatCondition["162"],
      this.treatCondition["163"],
      this.treatCondition["160"],
      this.treatCondition["161"],
      this.treatCondition["112"],
      this.treatCondition["113"],
      this.treatCondition["118"],
      this.treatCondition["119"],
      this.treatCondition["120"],
      this.treatCondition["121"],
      this.treatCondition["114"],
      this.treatCondition["115"],
      this.treatCondition["122"],
      this.treatCondition["123"],
      this.treatCondition["116"],
      this.treatCondition["117"],
      this.treatCondition["124"],
      this.treatCondition["125"],
      this.treatCondition["128"],
      this.treatCondition["129"],
      this.treatCondition["136"],
      this.treatCondition["137"],
      this.treatCondition["140"],
      this.treatCondition["141"],
      this.treatCondition["130"],
      this.treatCondition["131"],
      this.treatCondition["142"],
      this.treatCondition["143"],
      this.treatCondition["132"],
      this.treatCondition["133"],
      this.treatCondition["144"],
      this.treatCondition["145"],
      this.treatCondition["126"],
      this.treatCondition["127"],
      this.treatCondition["134"],
      this.treatCondition["135"],
      this.treatCondition["138"],
      this.treatCondition["139"],
      this.treatCondition["146"],
      this.treatCondition["147"],
      this.treatCondition["150"],
      this.treatCondition["151"],
      this.treatCondition["148"],
      this.treatCondition["149"],
      this.treatCondition["254"],
      this.treatCondition["255"],
      this.treatCondition["256"],
      this.treatCondition["257"],
      this.treatCondition["242"],
      this.treatCondition["243"],
      this.treatCondition["244"],
      this.treatCondition["245"],
      this.treatCondition["246"],
      this.treatCondition["247"]
      // this.treatCondition["102"],
      // this.treatCondition["103"],
      // this.treatCondition["104"],
      // this.treatCondition["105"],
      // this.treatCondition["152"],
      // this.treatCondition["153"],
      // this.treatCondition["154"],
      // this.treatCondition["155"],
      // this.treatCondition["156"],
      // this.treatCondition["157"],
      // this.treatCondition["112"],
      // this.treatCondition["113"],
      // this.treatCondition["114"],
      // this.treatCondition["115"],
      // this.treatCondition["116"],
      // this.treatCondition["117"],
      // this.treatCondition["128"],
      // this.treatCondition["129"],
      // this.treatCondition["130"],
      // this.treatCondition["131"],
      // this.treatCondition["132"],
      // this.treatCondition["133"],
      // this.treatCondition["126"],
      // this.treatCondition["127"],
      // this.treatCondition["146"],
      // this.treatCondition["147"],
      // this.treatCondition["148"],
      // this.treatCondition["149"],
      // this.treatCondition["106"],
      // this.treatCondition["107"],
      // this.treatCondition["158"],
      // this.treatCondition["159"],
      // this.treatCondition["118"],
      // this.treatCondition["119"],
      // this.treatCondition["136"],
      // this.treatCondition["137"],
      // this.treatCondition["134"],
      // this.treatCondition["135"],
      // this.treatCondition["150"],
      // this.treatCondition["151"],
      // this.treatCondition["110"],
      // this.treatCondition["111"],
      // this.treatCondition["162"],
      // this.treatCondition["163"],
      // this.treatCondition["120"],
      // this.treatCondition["121"],
      // this.treatCondition["122"],
      // this.treatCondition["123"],
      // this.treatCondition["124"],
      // this.treatCondition["125"],
      // this.treatCondition["140"],
      // this.treatCondition["141"],
      // this.treatCondition["142"],
      // this.treatCondition["143"],
      // this.treatCondition["144"],
      // this.treatCondition["145"],
      // this.treatCondition["138"],
      // this.treatCondition["139"],
      // this.treatCondition["108"],
      // this.treatCondition["109"],
      // this.treatCondition["160"],
      // this.treatCondition["161"],
      // this.treatCondition["254"],
      // this.treatCondition["255"],
      // this.treatCondition["256"],
      // this.treatCondition["257"],
      // this.treatCondition["242"],
      // this.treatCondition["243"],
      // this.treatCondition["244"],
      // this.treatCondition["245"],
      // this.treatCondition["246"],
      // this.treatCondition["247"],
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * 警報点の項目名を取得する
   */
  getKeihouTenTitle() {
    return [
      ORD_TREAT_CONDITION["240"].name,
      ORD_TREAT_CONDITION["100"].name,
      ORD_TREAT_CONDITION["101"].name,
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["106"].name,
      ORD_TREAT_CONDITION["107"].name,
      ORD_TREAT_CONDITION["102"].name,
      ORD_TREAT_CONDITION["103"].name,
      ORD_TREAT_CONDITION["104"].name,
      ORD_TREAT_CONDITION["105"].name,
      ORD_TREAT_CONDITION["110"].name,
      ORD_TREAT_CONDITION["111"].name,
      ORD_TREAT_CONDITION["108"].name,
      ORD_TREAT_CONDITION["109"].name,
      ORD_TREAT_CONDITION["152"].name,
      ORD_TREAT_CONDITION["153"].name,
      ORD_TREAT_CONDITION["158"].name,
      ORD_TREAT_CONDITION["159"].name,
      ORD_TREAT_CONDITION["154"].name,
      ORD_TREAT_CONDITION["155"].name,
      ORD_TREAT_CONDITION["156"].name,
      ORD_TREAT_CONDITION["157"].name,
      ORD_TREAT_CONDITION["162"].name,
      ORD_TREAT_CONDITION["163"].name,
      ORD_TREAT_CONDITION["160"].name,
      ORD_TREAT_CONDITION["161"].name,
      ORD_TREAT_CONDITION["112"].name,
      ORD_TREAT_CONDITION["113"].name,
      ORD_TREAT_CONDITION["118"].name,
      ORD_TREAT_CONDITION["119"].name,
      ORD_TREAT_CONDITION["120"].name,
      ORD_TREAT_CONDITION["121"].name,
      ORD_TREAT_CONDITION["114"].name,
      ORD_TREAT_CONDITION["115"].name,
      ORD_TREAT_CONDITION["122"].name,
      ORD_TREAT_CONDITION["123"].name,
      ORD_TREAT_CONDITION["116"].name,
      ORD_TREAT_CONDITION["117"].name,
      ORD_TREAT_CONDITION["124"].name,
      ORD_TREAT_CONDITION["125"].name,
      ORD_TREAT_CONDITION["128"].name,
      ORD_TREAT_CONDITION["129"].name,
      ORD_TREAT_CONDITION["136"].name,
      ORD_TREAT_CONDITION["137"].name,
      ORD_TREAT_CONDITION["140"].name,
      ORD_TREAT_CONDITION["141"].name,
      ORD_TREAT_CONDITION["130"].name,
      ORD_TREAT_CONDITION["131"].name,
      ORD_TREAT_CONDITION["142"].name,
      ORD_TREAT_CONDITION["143"].name,
      ORD_TREAT_CONDITION["132"].name,
      ORD_TREAT_CONDITION["133"].name,
      ORD_TREAT_CONDITION["144"].name,
      ORD_TREAT_CONDITION["145"].name,
      ORD_TREAT_CONDITION["126"].name,
      ORD_TREAT_CONDITION["127"].name,
      ORD_TREAT_CONDITION["134"].name,
      ORD_TREAT_CONDITION["135"].name,
      ORD_TREAT_CONDITION["138"].name,
      ORD_TREAT_CONDITION["139"].name,
      ORD_TREAT_CONDITION["146"].name,
      ORD_TREAT_CONDITION["147"].name,
      ORD_TREAT_CONDITION["150"].name,
      ORD_TREAT_CONDITION["151"].name,
      ORD_TREAT_CONDITION["148"].name,
      ORD_TREAT_CONDITION["149"].name,
      ORD_TREAT_CONDITION["254"].name,
      ORD_TREAT_CONDITION["255"].name,
      ORD_TREAT_CONDITION["256"].name,
      ORD_TREAT_CONDITION["257"].name,
      ORD_TREAT_CONDITION["242"].name,
      ORD_TREAT_CONDITION["243"].name,
      ORD_TREAT_CONDITION["244"].name,
      ORD_TREAT_CONDITION["245"].name,
      ORD_TREAT_CONDITION["246"].name,
      ORD_TREAT_CONDITION["247"].name
      // ORD_TREAT_CONDITION["102"].name,
      // ORD_TREAT_CONDITION["103"].name,
      // ORD_TREAT_CONDITION["104"].name,
      // ORD_TREAT_CONDITION["105"].name,
      // ORD_TREAT_CONDITION["152"].name,
      // ORD_TREAT_CONDITION["153"].name,
      // ORD_TREAT_CONDITION["154"].name,
      // ORD_TREAT_CONDITION["155"].name,
      // ORD_TREAT_CONDITION["156"].name,
      // ORD_TREAT_CONDITION["157"].name,
      // ORD_TREAT_CONDITION["112"].name,
      // ORD_TREAT_CONDITION["113"].name,
      // ORD_TREAT_CONDITION["114"].name,
      // ORD_TREAT_CONDITION["115"].name,
      // ORD_TREAT_CONDITION["116"].name,
      // ORD_TREAT_CONDITION["117"].name,
      // ORD_TREAT_CONDITION["128"].name,
      // ORD_TREAT_CONDITION["129"].name,
      // ORD_TREAT_CONDITION["130"].name,
      // ORD_TREAT_CONDITION["131"].name,
      // ORD_TREAT_CONDITION["132"].name,
      // ORD_TREAT_CONDITION["133"].name,
      // ORD_TREAT_CONDITION["126"].name,
      // ORD_TREAT_CONDITION["127"].name,
      // ORD_TREAT_CONDITION["146"].name,
      // ORD_TREAT_CONDITION["147"].name,
      // ORD_TREAT_CONDITION["148"].name,
      // ORD_TREAT_CONDITION["149"].name,
      // ORD_TREAT_CONDITION["106"].name,
      // ORD_TREAT_CONDITION["107"].name,
      // ORD_TREAT_CONDITION["158"].name,
      // ORD_TREAT_CONDITION["159"].name,
      // ORD_TREAT_CONDITION["118"].name,
      // ORD_TREAT_CONDITION["119"].name,
      // ORD_TREAT_CONDITION["136"].name,
      // ORD_TREAT_CONDITION["137"].name,
      // ORD_TREAT_CONDITION["134"].name,
      // ORD_TREAT_CONDITION["135"].name,
      // ORD_TREAT_CONDITION["150"].name,
      // ORD_TREAT_CONDITION["151"].name,
      // ORD_TREAT_CONDITION["110"].name,
      // ORD_TREAT_CONDITION["111"].name,
      // ORD_TREAT_CONDITION["162"].name,
      // ORD_TREAT_CONDITION["163"].name,
      // ORD_TREAT_CONDITION["120"].name,
      // ORD_TREAT_CONDITION["121"].name,
      // ORD_TREAT_CONDITION["122"].name,
      // ORD_TREAT_CONDITION["123"].name,
      // ORD_TREAT_CONDITION["124"].name,
      // ORD_TREAT_CONDITION["125"].name,
      // ORD_TREAT_CONDITION["140"].name,
      // ORD_TREAT_CONDITION["141"].name,
      // ORD_TREAT_CONDITION["142"].name,
      // ORD_TREAT_CONDITION["143"].name,
      // ORD_TREAT_CONDITION["144"].name,
      // ORD_TREAT_CONDITION["145"].name,
      // ORD_TREAT_CONDITION["138"].name,
      // ORD_TREAT_CONDITION["139"].name,
      // ORD_TREAT_CONDITION["108"].name,
      // ORD_TREAT_CONDITION["109"].name,
      // ORD_TREAT_CONDITION["160"].name,
      // ORD_TREAT_CONDITION["161"].name,
      // ORD_TREAT_CONDITION["254"].name,
      // ORD_TREAT_CONDITION["255"].name,
      // ORD_TREAT_CONDITION["256"].name,
      // ORD_TREAT_CONDITION["257"].name,
      // ORD_TREAT_CONDITION["242"].name,
      // ORD_TREAT_CONDITION["243"].name,
      // ORD_TREAT_CONDITION["244"].name,
      // ORD_TREAT_CONDITION["245"].name,
      // ORD_TREAT_CONDITION["246"].name,
      // ORD_TREAT_CONDITION["247"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }

  /**
   * 血圧計モデルを取得する
   */
  getKetsuatsuKei() {
    return new KetsuatsuKei(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["211"],
      this.treatCondition["212"],
      this.treatCondition["213"],
      this.treatCondition["214"],
      this.treatCondition["215"],
      this.treatCondition["216"],
      this.treatCondition["217"],
      this.treatCondition["218"],
      // FNSI-add 装置設定画面表示の修正 徐 start
      // this.treatCondition["227"],
      this.treatCondition["219"],
      this.treatCondition["227"],
      this.treatCondition["220"],
      this.treatCondition["228"],
      this.treatCondition["221"],
      // this.treatCondition["220"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["229"],
      this.treatCondition["229"] ? Number(this.treatCondition["229"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["221"],
      this.treatCondition["222"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["230"],
      this.treatCondition["230"] ? Number(this.treatCondition["230"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["222"],
      this.treatCondition["223"],
      this.treatCondition["231"],
      this.treatCondition["224"],
      // this.treatCondition["223"],
      this.treatCondition["232"],
      this.treatCondition["225"],
      // this.treatCondition["224"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["233"],
      this.treatCondition["233"] ? Number(this.treatCondition["233"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["226"],
      // this.treatCondition["225"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["234"],
      this.treatCondition["234"] ? Number(this.treatCondition["234"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["226"],
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["191"],
      this.treatCondition["190"],
      this.treatCondition["192"],
      this.treatCondition["193"],
      this.treatCondition["195"],
      this.treatCondition["239"],
      this.treatCondition["194"],
      this.treatCondition["235"],
      this.treatCondition["236"],
      this.treatCondition["237"],
      this.treatCondition["238"]
    );
  }

  /**
   * 血圧計の項目名を取得する
   */
  getKetsuatsuKeiTitle() {
    return [
      ORD_TREAT_CONDITION["211"].name,
      ORD_TREAT_CONDITION["212"].name,
      ORD_TREAT_CONDITION["213"].name,
      ORD_TREAT_CONDITION["214"].name,
      ORD_TREAT_CONDITION["215"].name,
      ORD_TREAT_CONDITION["216"].name,
      ORD_TREAT_CONDITION["217"].name,
      ORD_TREAT_CONDITION["218"].name,
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["219"].name,
      ORD_TREAT_CONDITION["227"].name,
      ORD_TREAT_CONDITION["220"].name,
      ORD_TREAT_CONDITION["228"].name,
      ORD_TREAT_CONDITION["221"].name,
      ORD_TREAT_CONDITION["229"].name,
      ORD_TREAT_CONDITION["222"].name,
      ORD_TREAT_CONDITION["230"].name,
      ORD_TREAT_CONDITION["223"].name,
      ORD_TREAT_CONDITION["231"].name,
      ORD_TREAT_CONDITION["224"].name,
      ORD_TREAT_CONDITION["232"].name,
      ORD_TREAT_CONDITION["225"].name,
      ORD_TREAT_CONDITION["233"].name,
      ORD_TREAT_CONDITION["226"].name,
      ORD_TREAT_CONDITION["234"].name,
      // ORD_TREAT_CONDITION["227"].name,
      // ORD_TREAT_CONDITION["219"].name,
      // ORD_TREAT_CONDITION["228"].name,
      // ORD_TREAT_CONDITION["220"].name,
      // ORD_TREAT_CONDITION["229"].name,
      // ORD_TREAT_CONDITION["221"].name,
      // ORD_TREAT_CONDITION["230"].name,
      // ORD_TREAT_CONDITION["222"].name,
      // ORD_TREAT_CONDITION["231"].name,
      // ORD_TREAT_CONDITION["223"].name,
      // ORD_TREAT_CONDITION["232"].name,
      // ORD_TREAT_CONDITION["224"].name,
      // ORD_TREAT_CONDITION["233"].name,
      // ORD_TREAT_CONDITION["225"].name,
      // ORD_TREAT_CONDITION["234"].name,
      // ORD_TREAT_CONDITION["226"].name,
      // FNSI-add 装置設定画面表示の修正 徐 end
      ORD_TREAT_CONDITION["191"].name,
      ORD_TREAT_CONDITION["190"].name,
      ORD_TREAT_CONDITION["192"].name,
      ORD_TREAT_CONDITION["193"].name,
      ORD_TREAT_CONDITION["195"].name,
      ORD_TREAT_CONDITION["239"].name,
      ORD_TREAT_CONDITION["194"].name,
      ORD_TREAT_CONDITION["235"].name,
      ORD_TREAT_CONDITION["236"].name,
      ORD_TREAT_CONDITION["237"].name,
      ORD_TREAT_CONDITION["238"].name
    ];
  }

  /**
   * BVモデルを取得する
   */
  getBv() {
    return new Bv(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["267"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["260"],
      this.treatCondition["260"] ? Number(this.treatCondition["260"]).toFixed(1) : "0.0",
      // this.treatCondition["261"],
      this.treatCondition["261"] ? Number(this.treatCondition["261"]).toFixed(1) : "0.0",
      // this.treatCondition["262"],
      this.treatCondition["262"] ? Number(this.treatCondition["262"]).toFixed(1) : "0.0",
      // this.treatCondition["277"],
      this.treatCondition["277"] ? Number(this.treatCondition["277"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["278"],
      // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
      this.treatCondition["476"] ? Number(this.treatCondition["476"]).toFixed(1) : "0.0",
      // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
      this.treatCondition["258"],
      this.treatCondition["259"],
      this.treatCondition["263"],
      this.treatCondition["264"],
      this.treatCondition["265"],
      this.treatCondition["266"],
      this.treatCondition["281"]
    );
  }

  /**
   * BVの項目名を取得する
   */
  // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 start
  /*
  getBvTitle() {
    return [
      ORD_TREAT_CONDITION["267"].name,
      ORD_TREAT_CONDITION["260"].name,
      ORD_TREAT_CONDITION["261"].name,
      ORD_TREAT_CONDITION["262"].name,
      ORD_TREAT_CONDITION["277"].name,
      ORD_TREAT_CONDITION["278"].name,
      ORD_TREAT_CONDITION["476"].name,
      ORD_TREAT_CONDITION["258"].name,
      ORD_TREAT_CONDITION["259"].name,
      ORD_TREAT_CONDITION["263"].name,
      ORD_TREAT_CONDITION["264"].name,
      ORD_TREAT_CONDITION["265"].name,
      ORD_TREAT_CONDITION["266"].name,
      ORD_TREAT_CONDITION["281"].name
    ];
  }
  */
  getBvTitle(so2Count) {
    var bvTitle = [
      ORD_TREAT_CONDITION["267"].name,
      ORD_TREAT_CONDITION["260"].name,
      ORD_TREAT_CONDITION["261"].name,
      ORD_TREAT_CONDITION["262"].name,
      ORD_TREAT_CONDITION["277"].name,
      ORD_TREAT_CONDITION["278"].name,
      ORD_TREAT_CONDITION["476"].name,
      ORD_TREAT_CONDITION["258"].name,
      ORD_TREAT_CONDITION["259"].name,
      ORD_TREAT_CONDITION["263"].name,
      ORD_TREAT_CONDITION["264"].name,
      ORD_TREAT_CONDITION["265"].name,
      ORD_TREAT_CONDITION["266"].name,
      ORD_TREAT_CONDITION["281"].name
    ];

    if ( so2Count == 0 ) {
      let index  = bvTitle.indexOf(ORD_TREAT_CONDITION["476"].name);
      if ( index > 0 ) {
        bvTitle.splice(index, 1);
      }
    }
    return bvTitle;
  }
  // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 end

  /**
   * プライミング・返血モデルを取得する
   */
  getPrimingAndHenketsu() {
    return new PrimingAndHenketsu(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["370"],
      this.treatCondition["371"],
      this.treatCondition["372"]
    );
  }

  /**
   * プライミング・返血の項目名を取得する
   */
  getPrimingAndHenketsuTitle() {
    return [
      ORD_TREAT_CONDITION["370"].name,
      ORD_TREAT_CONDITION["371"].name,
      ORD_TREAT_CONDITION["372"].name
    ];
  }

  /**
   * D-FASモデルを取得する
   */
  getDFas() {
    return new DFas(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["339"],
      this.treatCondition["333"],
      this.treatCondition["331"],
      this.treatCondition["334"],
      this.treatCondition["338"],
      this.treatCondition["332"],
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["335"],
      // FNSI-add 装置設定画面表示の修正 徐 end
      this.treatCondition["373"],
      this.treatCondition["374"],
      this.treatCondition["377"],
      this.treatCondition["270"],
      this.treatCondition["376"],
      this.treatCondition["378"]
    );
  }

  /**
   * D-FASの項目名を取得する
   */
  getDFasTitle() {
    return [
      ORD_TREAT_CONDITION["339"].name,
      ORD_TREAT_CONDITION["333"].name,
      ORD_TREAT_CONDITION["331"].name,
      ORD_TREAT_CONDITION["334"].name,
      ORD_TREAT_CONDITION["338"].name,
      ORD_TREAT_CONDITION["332"].name,
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["335"].name,
      // FNSI-add 装置設定画面表示の修正 徐 end
      ORD_TREAT_CONDITION["373"].name,
      ORD_TREAT_CONDITION["374"].name,
      ORD_TREAT_CONDITION["377"].name,
      ORD_TREAT_CONDITION["270"].name,
      ORD_TREAT_CONDITION["376"].name,
      ORD_TREAT_CONDITION["378"].name
    ];
  }

  // FNSI-add 装置設定画面表示の修正 徐 start
  /**
   * ECUM設定の項目名を取得する
   */
  getEcumSettingTitle() {
    return [
      ORD_TREAT_CONDITION["16"].name,
      ORD_TREAT_CONDITION["17"].name,
      ORD_TREAT_CONDITION["18"].name,
      ORD_TREAT_CONDITION["19"].name
    ];
  }

  /**
   * ECUM設定のモデルを取得する
   */
  getEcumSetting() {
    return new EcumSetting(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["16"],
      this.treatCondition["17"] ? Number(this.treatCondition["17"]).toFixed(2) : "0.00",
      this.treatCondition["18"],
      this.treatCondition["19"]
    );
  }

  /**
   * 濃度プログラム自動設定警報のモデルを取得する
   */
  getConcentration() {
    return new Concentration(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["252"] ? Number(this.treatCondition["252"]).toFixed(1) : "0.0",
      this.treatCondition["253"] ? Number(this.treatCondition["253"]).toFixed(1) : "0.0",
      this.treatCondition["250"] ? Number(this.treatCondition["250"]).toFixed(1) : "0.0",
      this.treatCondition["251"] ? Number(this.treatCondition["251"]).toFixed(1) : "0.0"
    );
  }


  /**
   * 濃度プログラム自動設定警報の項目名を取得する
   */
  getConcentrationTitle() {
    return [
      ORD_TREAT_CONDITION["252"].name,
      ORD_TREAT_CONDITION["253"].name,
      ORD_TREAT_CONDITION["250"].name,
      ORD_TREAT_CONDITION["251"].name
    ];
  }

  /**
   * 除水プログラムのモデルを取得する
   */
  getDiversionProgram() {
    return new DiversionProgram(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["290"],
      this.treatCondition["311"],
      this.treatCondition["312"] ? Number(this.treatCondition["312"]).toFixed(1) : "0.0",
      this.treatCondition["313"],
      this.treatCondition["291"],
      this.treatCondition["301"],
      this.treatCondition["292"],
      this.treatCondition["302"],
      this.treatCondition["293"],
      this.treatCondition["303"],
      this.treatCondition["294"],
      this.treatCondition["304"],
      this.treatCondition["295"],
      this.treatCondition["305"],
      this.treatCondition["296"],
      this.treatCondition["306"],
      this.treatCondition["297"],
      this.treatCondition["307"],
      this.treatCondition["298"],
      this.treatCondition["308"],
      this.treatCondition["299"],
      this.treatCondition["309"],
      this.treatCondition["300"],
      this.treatCondition["310"],
      this.treatCondition["314"]
    );
  }


  /**
   * 除水プログラムの項目名を取得する
   */
  getDiversionProgramTitle() {
    return [
      ORD_TREAT_CONDITION["290"].name,
      ORD_TREAT_CONDITION["311"].name,
      ORD_TREAT_CONDITION["312"].name,
      ORD_TREAT_CONDITION["313"].name,
      ORD_TREAT_CONDITION["291"].name,
      ORD_TREAT_CONDITION["301"].name,
      ORD_TREAT_CONDITION["292"].name,
      ORD_TREAT_CONDITION["302"].name,
      ORD_TREAT_CONDITION["293"].name,
      ORD_TREAT_CONDITION["303"].name,
      ORD_TREAT_CONDITION["294"].name,
      ORD_TREAT_CONDITION["304"].name,
      ORD_TREAT_CONDITION["295"].name,
      ORD_TREAT_CONDITION["305"].name,
      ORD_TREAT_CONDITION["296"].name,
      ORD_TREAT_CONDITION["306"].name,
      ORD_TREAT_CONDITION["297"].name,
      ORD_TREAT_CONDITION["307"].name,
      ORD_TREAT_CONDITION["298"].name,
      ORD_TREAT_CONDITION["308"].name,
      ORD_TREAT_CONDITION["299"].name,
      ORD_TREAT_CONDITION["309"].name,
      ORD_TREAT_CONDITION["300"].name,
      ORD_TREAT_CONDITION["310"].name,
      ORD_TREAT_CONDITION["314"].name,
    ];
  }

  /**
   * Na注入プログラムのモデルを取得する
   */
  getNaInjectionProgram() {
    return new NaInjectionProgram(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["315"],
      this.treatCondition["326"],
      this.treatCondition["328"] ? Number(this.treatCondition["328"]).toFixed(1) : "0.0",
      this.treatCondition["327"],
      this.treatCondition["329"],
      this.treatCondition["316"],
      this.treatCondition["317"],
      this.treatCondition["318"],
      this.treatCondition["319"],
      this.treatCondition["320"],
      this.treatCondition["321"],
      this.treatCondition["322"],
      this.treatCondition["323"],
      this.treatCondition["324"],
      this.treatCondition["325"],
      this.treatCondition["330"],
      this.treatCondition["184"]
    );
  }

  /**
   * Na注入プログラムの項目名を取得する
   */
  getNaInjectionProgramTitle() {
    return [
      ORD_TREAT_CONDITION["315"].name,
      ORD_TREAT_CONDITION["326"].name,
      ORD_TREAT_CONDITION["328"].name,
      ORD_TREAT_CONDITION["327"].name,
      ORD_TREAT_CONDITION["329"].name,
      ORD_TREAT_CONDITION["316"].name,
      ORD_TREAT_CONDITION["317"].name,
      ORD_TREAT_CONDITION["318"].name,
      ORD_TREAT_CONDITION["319"].name,
      ORD_TREAT_CONDITION["320"].name,
      ORD_TREAT_CONDITION["321"].name,
      ORD_TREAT_CONDITION["322"].name,
      ORD_TREAT_CONDITION["323"].name,
      ORD_TREAT_CONDITION["324"].name,
      ORD_TREAT_CONDITION["325"].name,
      ORD_TREAT_CONDITION["330"].name,
      ORD_TREAT_CONDITION["184"].name
    ];
  }

  /**
   * 透析液濃度プログラムのモデルを取得する
   */
  getDialysisSolConcentrationProgram() {
    return new DialysisSolConcentrationProgram(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["340"],
      this.treatCondition["368"],
      this.treatCondition["364"] ? Number(this.treatCondition["364"]).toFixed(1) : "0.0",
      this.treatCondition["365"] ? Number(this.treatCondition["365"]).toFixed(2) : "0.00",
      this.treatCondition["351"] ? Number(this.treatCondition["351"]).toFixed(2) : "0.00",
      this.treatCondition["352"] ? Number(this.treatCondition["352"]).toFixed(2) : "0.00",
      this.treatCondition["353"] ? Number(this.treatCondition["353"]).toFixed(2) : "0.00",
      this.treatCondition["354"] ? Number(this.treatCondition["354"]).toFixed(2) : "0.00",
      this.treatCondition["355"] ? Number(this.treatCondition["355"]).toFixed(2) : "0.00",
      this.treatCondition["356"] ? Number(this.treatCondition["356"]).toFixed(2) : "0.00",
      this.treatCondition["357"] ? Number(this.treatCondition["357"]).toFixed(2) : "0.00",
      this.treatCondition["358"] ? Number(this.treatCondition["358"]).toFixed(2) : "0.00",
      this.treatCondition["359"] ? Number(this.treatCondition["359"]).toFixed(2) : "0.00",
      this.treatCondition["360"] ? Number(this.treatCondition["360"]).toFixed(2) : "0.00",
      this.treatCondition["366"] ? Number(this.treatCondition["366"]).toFixed(2) : "0.00",
      this.treatCondition["367"],
      this.treatCondition["361"] ? Number(this.treatCondition["361"]).toFixed(1) : "0.0",
      this.treatCondition["362"] ? Number(this.treatCondition["362"]).toFixed(1) : "0.0",
      this.treatCondition["341"] ? Number(this.treatCondition["341"]).toFixed(1) : "0.0",
      this.treatCondition["342"] ? Number(this.treatCondition["342"]).toFixed(1) : "0.0",
      this.treatCondition["343"] ? Number(this.treatCondition["343"]).toFixed(1) : "0.0",
      this.treatCondition["344"] ? Number(this.treatCondition["344"]).toFixed(1) : "0.0",
      this.treatCondition["345"] ? Number(this.treatCondition["345"]).toFixed(1) : "0.0",
      this.treatCondition["346"] ? Number(this.treatCondition["346"]).toFixed(1) : "0.0",
      this.treatCondition["347"] ? Number(this.treatCondition["347"]).toFixed(1) : "0.0",
      this.treatCondition["348"] ? Number(this.treatCondition["348"]).toFixed(1) : "0.0",
      this.treatCondition["349"] ? Number(this.treatCondition["349"]).toFixed(1) : "0.0",
      this.treatCondition["350"] ? Number(this.treatCondition["350"]).toFixed(1) : "0.0",
      this.treatCondition["363"] ? Number(this.treatCondition["363"]).toFixed(1) : "0.0"
    );
  }

  /**
   * 透析液濃度プログラムの項目名を取得する
   */
  getDialysisSolConcentrationProgramTitle() {
    return [
      ORD_TREAT_CONDITION["340"].name,
      ORD_TREAT_CONDITION["368"].name,
      ORD_TREAT_CONDITION["364"].name,
      ORD_TREAT_CONDITION["365"].name,
      ORD_TREAT_CONDITION["351"].name,
      ORD_TREAT_CONDITION["352"].name,
      ORD_TREAT_CONDITION["353"].name,
      ORD_TREAT_CONDITION["354"].name,
      ORD_TREAT_CONDITION["355"].name,
      ORD_TREAT_CONDITION["356"].name,
      ORD_TREAT_CONDITION["357"].name,
      ORD_TREAT_CONDITION["358"].name,
      ORD_TREAT_CONDITION["359"].name,
      ORD_TREAT_CONDITION["360"].name,
      ORD_TREAT_CONDITION["366"].name,
      ORD_TREAT_CONDITION["367"].name,
      ORD_TREAT_CONDITION["361"].name,
      ORD_TREAT_CONDITION["362"].name,
      ORD_TREAT_CONDITION["341"].name,
      ORD_TREAT_CONDITION["342"].name,
      ORD_TREAT_CONDITION["343"].name,
      ORD_TREAT_CONDITION["344"].name,
      ORD_TREAT_CONDITION["345"].name,
      ORD_TREAT_CONDITION["346"].name,
      ORD_TREAT_CONDITION["347"].name,
      ORD_TREAT_CONDITION["348"].name,
      ORD_TREAT_CONDITION["349"].name,
      ORD_TREAT_CONDITION["350"].name,
      ORD_TREAT_CONDITION["363"].name
    ];
  }
  // FNSI-add 装置設定画面表示の修正 徐 end

  /**
   * 装置プログラムのモデルを取得する
   */
  getSouchiProgram() {
    return new SouchiProgram(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["290"],
      this.treatCondition["311"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["312"],
      this.treatCondition["312"] ? Number(this.treatCondition["312"]).toFixed(1) : "0.0",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["291"],
      this.treatCondition["292"],
      this.treatCondition["293"],
      this.treatCondition["294"],
      this.treatCondition["295"],
      this.treatCondition["296"],
      this.treatCondition["297"],
      this.treatCondition["298"],
      this.treatCondition["299"],
      this.treatCondition["300"],
      this.treatCondition["301"],
      this.treatCondition["302"],
      this.treatCondition["303"],
      this.treatCondition["304"],
      this.treatCondition["305"],
      this.treatCondition["306"],
      this.treatCondition["307"],
      this.treatCondition["308"],
      this.treatCondition["309"],
      this.treatCondition["310"],
      this.treatCondition["313"],
      this.treatCondition["314"],
      this.treatCondition["315"],
      this.treatCondition["326"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["328"],
      this.treatCondition["328"] ? Number(this.treatCondition["328"]).toFixed(1) : "0.0",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["327"],
      this.treatCondition["316"],
      this.treatCondition["317"],
      this.treatCondition["318"],
      this.treatCondition["319"],
      this.treatCondition["320"],
      this.treatCondition["321"],
      this.treatCondition["322"],
      this.treatCondition["323"],
      this.treatCondition["324"],
      this.treatCondition["325"],
      this.treatCondition["329"],
      this.treatCondition["330"],
      this.treatCondition["340"],
      this.treatCondition["368"],
      this.treatCondition["367"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["361"],
      this.treatCondition["361"] ? Number(this.treatCondition["361"]).toFixed(1) : "0.0",
      // this.treatCondition["341"],
      this.treatCondition["341"] ? Number(this.treatCondition["341"]).toFixed(1) : "0.0",
      // this.treatCondition["342"],
      this.treatCondition["342"] ? Number(this.treatCondition["342"]).toFixed(1) : "0.0",
      // this.treatCondition["343"],
      this.treatCondition["343"] ? Number(this.treatCondition["343"]).toFixed(1) : "0.0",
      // this.treatCondition["344"],
      this.treatCondition["344"] ? Number(this.treatCondition["344"]).toFixed(1) : "0.0",
      // this.treatCondition["345"],
      this.treatCondition["345"] ? Number(this.treatCondition["345"]).toFixed(1) : "0.0",
      // this.treatCondition["346"],
      this.treatCondition["346"] ? Number(this.treatCondition["346"]).toFixed(1) : "0.0",
      // this.treatCondition["347"],
      this.treatCondition["347"] ? Number(this.treatCondition["347"]).toFixed(1) : "0.0",
      // this.treatCondition["348"],
      this.treatCondition["348"] ? Number(this.treatCondition["348"]).toFixed(1) : "0.0",
      // this.treatCondition["349"],
      this.treatCondition["349"] ? Number(this.treatCondition["349"]).toFixed(1) : "0.0",
      // this.treatCondition["350"],
      this.treatCondition["350"] ? Number(this.treatCondition["350"]).toFixed(1) : "0.0",
      // this.treatCondition["362"],
      this.treatCondition["362"] ? Number(this.treatCondition["362"]).toFixed(1) : "0.0",
      // this.treatCondition["363"],
      this.treatCondition["363"] ? Number(this.treatCondition["363"]).toFixed(1) : "0.0",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["184"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["364"],
      this.treatCondition["364"] ? Number(this.treatCondition["364"]).toFixed(1) : "0.0",
      // this.treatCondition["351"],
      this.treatCondition["351"] ? Number(this.treatCondition["351"]).toFixed(2) : "0.00",
      // this.treatCondition["352"],
      this.treatCondition["352"] ? Number(this.treatCondition["352"]).toFixed(2) : "0.00",
      // this.treatCondition["353"],
      this.treatCondition["353"] ? Number(this.treatCondition["353"]).toFixed(2) : "0.00",
      // this.treatCondition["354"],
      this.treatCondition["354"] ? Number(this.treatCondition["354"]).toFixed(2) : "0.00",
      // this.treatCondition["355"],
      this.treatCondition["355"] ? Number(this.treatCondition["355"]).toFixed(2) : "0.00",
      // this.treatCondition["356"],
      this.treatCondition["356"] ? Number(this.treatCondition["356"]).toFixed(2) : "0.00",
      // this.treatCondition["357"],
      this.treatCondition["357"] ? Number(this.treatCondition["357"]).toFixed(2) : "0.00",
      // this.treatCondition["358"],
      this.treatCondition["358"] ? Number(this.treatCondition["358"]).toFixed(2) : "0.00",
      // this.treatCondition["359"],
      this.treatCondition["359"] ? Number(this.treatCondition["359"]).toFixed(2) : "0.00",
      // this.treatCondition["360"],
      this.treatCondition["360"] ? Number(this.treatCondition["360"]).toFixed(2) : "0.00",
      // this.treatCondition["365"],
      this.treatCondition["365"] ? Number(this.treatCondition["365"]).toFixed(2) : "0.00",
      // this.treatCondition["366"],
      this.treatCondition["366"] ? Number(this.treatCondition["366"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["16"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["17"],
      this.treatCondition["17"] ? Number(this.treatCondition["17"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["18"],
      this.treatCondition["19"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["252"],
      this.treatCondition["252"] ? Number(this.treatCondition["252"]).toFixed(1) : "0.0",
      // this.treatCondition["253"],
      this.treatCondition["253"] ? Number(this.treatCondition["253"]).toFixed(1) : "0.0",
      // this.treatCondition["250"],
      this.treatCondition["250"] ? Number(this.treatCondition["250"]).toFixed(1) : "0.0",
      // this.treatCondition["251"]
      this.treatCondition["251"] ? Number(this.treatCondition["251"]).toFixed(1) : "0.0"
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
    );
  }


  /**
   * 装置プログラムの項目名を取得する
   */
  getSouchiProgramTitle() {
    return [
      ORD_TREAT_CONDITION["290"].name,
      ORD_TREAT_CONDITION["311"].name,
      ORD_TREAT_CONDITION["312"].name,
      ORD_TREAT_CONDITION["291"].name,
      ORD_TREAT_CONDITION["292"].name,
      ORD_TREAT_CONDITION["293"].name,
      ORD_TREAT_CONDITION["294"].name,
      ORD_TREAT_CONDITION["295"].name,
      ORD_TREAT_CONDITION["296"].name,
      ORD_TREAT_CONDITION["297"].name,
      ORD_TREAT_CONDITION["298"].name,
      ORD_TREAT_CONDITION["299"].name,
      ORD_TREAT_CONDITION["300"].name,
      ORD_TREAT_CONDITION["301"].name,
      ORD_TREAT_CONDITION["302"].name,
      ORD_TREAT_CONDITION["303"].name,
      ORD_TREAT_CONDITION["304"].name,
      ORD_TREAT_CONDITION["305"].name,
      ORD_TREAT_CONDITION["306"].name,
      ORD_TREAT_CONDITION["307"].name,
      ORD_TREAT_CONDITION["308"].name,
      ORD_TREAT_CONDITION["309"].name,
      ORD_TREAT_CONDITION["310"].name,
      ORD_TREAT_CONDITION["313"].name,
      ORD_TREAT_CONDITION["314"].name,
      ORD_TREAT_CONDITION["315"].name,
      ORD_TREAT_CONDITION["326"].name,
      ORD_TREAT_CONDITION["328"].name,
      ORD_TREAT_CONDITION["327"].name,
      ORD_TREAT_CONDITION["316"].name,
      ORD_TREAT_CONDITION["317"].name,
      ORD_TREAT_CONDITION["318"].name,
      ORD_TREAT_CONDITION["319"].name,
      ORD_TREAT_CONDITION["320"].name,
      ORD_TREAT_CONDITION["321"].name,
      ORD_TREAT_CONDITION["322"].name,
      ORD_TREAT_CONDITION["323"].name,
      ORD_TREAT_CONDITION["324"].name,
      ORD_TREAT_CONDITION["325"].name,
      ORD_TREAT_CONDITION["329"].name,
      ORD_TREAT_CONDITION["330"].name,
      ORD_TREAT_CONDITION["340"].name,
      ORD_TREAT_CONDITION["368"].name,
      ORD_TREAT_CONDITION["367"].name,
      ORD_TREAT_CONDITION["361"].name,
      ORD_TREAT_CONDITION["341"].name,
      ORD_TREAT_CONDITION["342"].name,
      ORD_TREAT_CONDITION["343"].name,
      ORD_TREAT_CONDITION["344"].name,
      ORD_TREAT_CONDITION["345"].name,
      ORD_TREAT_CONDITION["346"].name,
      ORD_TREAT_CONDITION["347"].name,
      ORD_TREAT_CONDITION["348"].name,
      ORD_TREAT_CONDITION["349"].name,
      ORD_TREAT_CONDITION["350"].name,
      ORD_TREAT_CONDITION["362"].name,
      ORD_TREAT_CONDITION["363"].name,
      ORD_TREAT_CONDITION["184"].name,
      ORD_TREAT_CONDITION["364"].name,
      ORD_TREAT_CONDITION["351"].name,
      ORD_TREAT_CONDITION["352"].name,
      ORD_TREAT_CONDITION["353"].name,
      ORD_TREAT_CONDITION["354"].name,
      ORD_TREAT_CONDITION["355"].name,
      ORD_TREAT_CONDITION["356"].name,
      ORD_TREAT_CONDITION["357"].name,
      ORD_TREAT_CONDITION["358"].name,
      ORD_TREAT_CONDITION["359"].name,
      ORD_TREAT_CONDITION["360"].name,
      ORD_TREAT_CONDITION["365"].name,
      ORD_TREAT_CONDITION["366"].name,
      ORD_TREAT_CONDITION["16"].name,
      ORD_TREAT_CONDITION["17"].name,
      ORD_TREAT_CONDITION["18"].name,
      ORD_TREAT_CONDITION["19"].name,
      ORD_TREAT_CONDITION["252"].name,
      ORD_TREAT_CONDITION["253"].name,
      ORD_TREAT_CONDITION["250"].name,
      ORD_TREAT_CONDITION["251"].name
    ];
  }

  /**
   * 血流量・透析液流量プログラムのモデルを取得する
   */
  getKetsuryuuRyouAndTousekiEkiRyuuRyouProgram() {
    return new KetsuryuuRyouAndTousekiEkiRyuuRyouProgram(
      this.receiveDate,
      this.treatClass,
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["431"],
      this.treatCondition["430"],
      this.treatCondition["429"],
      this.treatCondition["410"],
      this.treatCondition["411"],
      this.treatCondition["412"],
      this.treatCondition["413"],
      this.treatCondition["414"],
      this.treatCondition["415"],
      this.treatCondition["416"],
      this.treatCondition["417"],
      this.treatCondition["418"],
      this.treatCondition["419"],
      this.treatCondition["400"],
      this.treatCondition["401"],
      this.treatCondition["402"],
      this.treatCondition["403"],
      this.treatCondition["404"],
      this.treatCondition["405"],
      this.treatCondition["406"],
      this.treatCondition["407"],
      this.treatCondition["408"],
      this.treatCondition["409"],
      this.treatCondition["420"],
      this.treatCondition["421"],
      this.treatCondition["422"],
      this.treatCondition["423"],
      this.treatCondition["424"],
      this.treatCondition["425"],
      this.treatCondition["426"],
      this.treatCondition["427"],
      this.treatCondition["428"]
      // this.treatCondition["430"],
      // this.treatCondition["429"],
      // this.treatCondition["400"],
      // this.treatCondition["401"],
      // this.treatCondition["402"],
      // this.treatCondition["403"],
      // this.treatCondition["404"],
      // this.treatCondition["405"],
      // this.treatCondition["406"],
      // this.treatCondition["407"],
      // this.treatCondition["408"],
      // this.treatCondition["409"],
      // this.treatCondition["431"],
      // this.treatCondition["410"],
      // this.treatCondition["411"],
      // this.treatCondition["412"],
      // this.treatCondition["413"],
      // this.treatCondition["414"],
      // this.treatCondition["415"],
      // this.treatCondition["416"],
      // this.treatCondition["417"],
      // this.treatCondition["418"],
      // this.treatCondition["419"],
      // this.treatCondition["420"],
      // this.treatCondition["421"],
      // this.treatCondition["422"],
      // this.treatCondition["423"],
      // this.treatCondition["424"],
      // this.treatCondition["425"],
      // this.treatCondition["426"],
      // this.treatCondition["427"],
      // this.treatCondition["428"]
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * 血流量・透析液流量プログラムの項目名を取得する
   */
  getKetsuryuuRyouAndTousekiEkiRyuuRyouProgramTitle() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["431"].name,
      ORD_TREAT_CONDITION["430"].name,
      ORD_TREAT_CONDITION["429"].name,
      ORD_TREAT_CONDITION["410"].name,
      ORD_TREAT_CONDITION["411"].name,
      ORD_TREAT_CONDITION["412"].name,
      ORD_TREAT_CONDITION["413"].name,
      ORD_TREAT_CONDITION["414"].name,
      ORD_TREAT_CONDITION["415"].name,
      ORD_TREAT_CONDITION["416"].name,
      ORD_TREAT_CONDITION["417"].name,
      ORD_TREAT_CONDITION["418"].name,
      ORD_TREAT_CONDITION["419"].name,
      ORD_TREAT_CONDITION["400"].name,
      ORD_TREAT_CONDITION["401"].name,
      ORD_TREAT_CONDITION["402"].name,
      ORD_TREAT_CONDITION["403"].name,
      ORD_TREAT_CONDITION["404"].name,
      ORD_TREAT_CONDITION["405"].name,
      ORD_TREAT_CONDITION["406"].name,
      ORD_TREAT_CONDITION["407"].name,
      ORD_TREAT_CONDITION["408"].name,
      ORD_TREAT_CONDITION["409"].name,
      ORD_TREAT_CONDITION["420"].name,
      ORD_TREAT_CONDITION["421"].name,
      ORD_TREAT_CONDITION["422"].name,
      ORD_TREAT_CONDITION["423"].name,
      ORD_TREAT_CONDITION["424"].name,
      ORD_TREAT_CONDITION["425"].name,
      ORD_TREAT_CONDITION["426"].name,
      ORD_TREAT_CONDITION["427"].name,
      ORD_TREAT_CONDITION["428"].name
      // ORD_TREAT_CONDITION["430"].name,
      // ORD_TREAT_CONDITION["429"].name,
      // ORD_TREAT_CONDITION["400"].name,
      // ORD_TREAT_CONDITION["401"].name,
      // ORD_TREAT_CONDITION["402"].name,
      // ORD_TREAT_CONDITION["403"].name,
      // ORD_TREAT_CONDITION["404"].name,
      // ORD_TREAT_CONDITION["405"].name,
      // ORD_TREAT_CONDITION["406"].name,
      // ORD_TREAT_CONDITION["407"].name,
      // ORD_TREAT_CONDITION["408"].name,
      // ORD_TREAT_CONDITION["409"].name,
      // ORD_TREAT_CONDITION["431"].name,
      // ORD_TREAT_CONDITION["410"].name,
      // ORD_TREAT_CONDITION["411"].name,
      // ORD_TREAT_CONDITION["412"].name,
      // ORD_TREAT_CONDITION["413"].name,
      // ORD_TREAT_CONDITION["414"].name,
      // ORD_TREAT_CONDITION["415"].name,
      // ORD_TREAT_CONDITION["416"].name,
      // ORD_TREAT_CONDITION["417"].name,
      // ORD_TREAT_CONDITION["418"].name,
      // ORD_TREAT_CONDITION["419"].name,
      // ORD_TREAT_CONDITION["420"].name,
      // ORD_TREAT_CONDITION["421"].name,
      // ORD_TREAT_CONDITION["422"].name,
      // ORD_TREAT_CONDITION["423"].name,
      // ORD_TREAT_CONDITION["424"].name,
      // ORD_TREAT_CONDITION["425"].name,
      // ORD_TREAT_CONDITION["426"].name,
      // ORD_TREAT_CONDITION["427"].name,
      // ORD_TREAT_CONDITION["428"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }

  /**
   * 透析量プログラムのモデルを取得する
   */
  getTousekiRyouProgram() {
    return new TousekiRyouProgram(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["282"],
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["284"] ? Number(this.treatCondition["284"]).toFixed(2) : "0.00",
      this.treatCondition["283"] ? Number(this.treatCondition["283"]).toFixed(1) : "0.0",
      this.treatCondition["285"] ? Number(this.treatCondition["285"]).toFixed(1) : "0.0",
      this.treatCondition["286"],
      this.treatCondition["287"],
      // FNSI-add 装置設定画面表示の修正 徐 end
      this.treatCondition["288"]
    );
  }

  /**
   * 透析量プログラムの項目名を取得する
   */
  getTousekiRyouProgramTitle() {
    return [
      ORD_TREAT_CONDITION["282"].name,
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["284"].name,
      ORD_TREAT_CONDITION["283"].name,
      ORD_TREAT_CONDITION["285"].name,
      ORD_TREAT_CONDITION["286"].name,
      ORD_TREAT_CONDITION["287"].name,
      // FNSI-add 装置設定画面表示の修正 徐 end
      ORD_TREAT_CONDITION["288"].name
    ];
  }

  /**
   * BV-UFCのモデルを取得する
   */
  getBvUfc() {
    return new BvUfc(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["196"],
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["199"],
      this.treatCondition["206"] ? Number(this.treatCondition["206"]).toFixed(2) : "0.00",
      this.treatCondition["207"],
      this.treatCondition["208"] ? Number(this.treatCondition["208"]).toFixed(2) : "0.00",
      this.treatCondition["249"],
      this.treatCondition["197"] ? Number(this.treatCondition["197"]).toFixed(2) : "0.00",
      this.treatCondition["198"] ? Number(this.treatCondition["198"]).toFixed(2) : "0.00",
      this.treatCondition["209"],
      this.treatCondition["210"],
      this.treatCondition["248"] ? Number(this.treatCondition["248"]).toFixed(2) : "0.00",
      this.treatCondition["271"] ? Number(this.treatCondition["271"]).toFixed(2) : "0.00",
      this.treatCondition["272"],
      this.treatCondition["273"],
      this.treatCondition["274"],
      this.treatCondition["275"] ? Number(this.treatCondition["275"]).toFixed(2) : "0.00"
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["197"],
      // this.treatCondition["197"] ? Number(this.treatCondition["197"]).toFixed(2) : "0.00",
      // // this.treatCondition["198"],
      // this.treatCondition["198"] ? Number(this.treatCondition["198"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["199"],
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["206"],
      // this.treatCondition["206"] ? Number(this.treatCondition["206"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["207"],
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["208"],
      // this.treatCondition["208"] ? Number(this.treatCondition["208"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["209"],
      // this.treatCondition["210"],
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["248"],
      // this.treatCondition["248"] ? Number(this.treatCondition["248"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["249"],
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["271"],
      // this.treatCondition["271"] ? Number(this.treatCondition["271"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["272"],
      // this.treatCondition["273"],
      // this.treatCondition["274"],
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["275"],
      // this.treatCondition["275"] ? Number(this.treatCondition["275"]).toFixed(2) : "0.00"
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * BV-UFCの項目名を取得する
   */
  getBvUfcTitle() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["196"].name,
      ORD_TREAT_CONDITION["199"].name,
      ORD_TREAT_CONDITION["206"].name,
      ORD_TREAT_CONDITION["207"].name,
      ORD_TREAT_CONDITION["208"].name,
      ORD_TREAT_CONDITION["249"].name,
      ORD_TREAT_CONDITION["197"].name,
      ORD_TREAT_CONDITION["198"].name,
      ORD_TREAT_CONDITION["209"].name,
      ORD_TREAT_CONDITION["210"].name,
      ORD_TREAT_CONDITION["248"].name,
      ORD_TREAT_CONDITION["271"].name,
      ORD_TREAT_CONDITION["272"].name,
      ORD_TREAT_CONDITION["273"].name,
      ORD_TREAT_CONDITION["274"].name,
      ORD_TREAT_CONDITION["275"].name
      // ORD_TREAT_CONDITION["196"].name,
      // ORD_TREAT_CONDITION["197"].name,
      // ORD_TREAT_CONDITION["198"].name,
      // ORD_TREAT_CONDITION["199"].name,
      // ORD_TREAT_CONDITION["206"].name,
      // ORD_TREAT_CONDITION["207"].name,
      // ORD_TREAT_CONDITION["208"].name,
      // ORD_TREAT_CONDITION["209"].name,
      // ORD_TREAT_CONDITION["210"].name,
      // ORD_TREAT_CONDITION["248"].name,
      // ORD_TREAT_CONDITION["249"].name,
      // ORD_TREAT_CONDITION["271"].name,
      // ORD_TREAT_CONDITION["272"].name,
      // ORD_TREAT_CONDITION["273"].name,
      // ORD_TREAT_CONDITION["274"].name,
      // ORD_TREAT_CONDITION["275"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }

  /**
   * I-HDFのモデルを取得する
   */
  getIHdf() {
    return new IHdf(
      this.receiveDate,
      this.treatClass,
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["432"],
      this.treatCondition["200"],
      this.treatCondition["201"],
      this.treatCondition["205"] ? Number(this.treatCondition["205"]).toFixed(2) : "0.00",
      this.treatCondition["433"],
      this.treatCondition["203"],
      this.treatCondition["202"],
      this.treatCondition["204"],
      this.treatCondition["434"],
      this.treatCondition["435"],
      this.treatCondition["451"],
      this.treatCondition["436"],
      this.treatCondition["452"],
      this.treatCondition["437"],
      this.treatCondition["453"],
      this.treatCondition["438"],
      this.treatCondition["454"],
      this.treatCondition["439"],
      this.treatCondition["455"],
      this.treatCondition["440"],
      this.treatCondition["456"],
      this.treatCondition["441"],
      this.treatCondition["457"],
      this.treatCondition["442"],
      this.treatCondition["458"],
      this.treatCondition["443"],
      this.treatCondition["459"],
      this.treatCondition["444"],
      this.treatCondition["460"],
      this.treatCondition["445"],
      this.treatCondition["461"],
      this.treatCondition["446"],
      this.treatCondition["462"],
      this.treatCondition["447"],
      this.treatCondition["463"],
      this.treatCondition["448"],
      this.treatCondition["464"],
      this.treatCondition["449"],
      this.treatCondition["465"],
      this.treatCondition["450"],
      this.treatCondition["466"]
      // this.treatCondition["200"],
      // this.treatCondition["201"],
      // this.treatCondition["202"],
      // this.treatCondition["203"],
      // this.treatCondition["204"],
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["205"],
      // this.treatCondition["205"] ? Number(this.treatCondition["205"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["432"],
      // this.treatCondition["433"],
      // this.treatCondition["434"],
      // this.treatCondition["435"],
      // this.treatCondition["436"],
      // this.treatCondition["437"],
      // this.treatCondition["438"],
      // this.treatCondition["439"],
      // this.treatCondition["440"],
      // this.treatCondition["441"],
      // this.treatCondition["442"],
      // this.treatCondition["443"],
      // this.treatCondition["444"],
      // this.treatCondition["445"],
      // this.treatCondition["446"],
      // this.treatCondition["447"],
      // this.treatCondition["448"],
      // this.treatCondition["449"],
      // this.treatCondition["450"],
      // this.treatCondition["451"],
      // this.treatCondition["452"],
      // this.treatCondition["453"],
      // this.treatCondition["454"],
      // this.treatCondition["455"],
      // this.treatCondition["456"],
      // this.treatCondition["457"],
      // this.treatCondition["458"],
      // this.treatCondition["459"],
      // this.treatCondition["460"],
      // this.treatCondition["461"],
      // this.treatCondition["462"],
      // this.treatCondition["463"],
      // this.treatCondition["464"],
      // this.treatCondition["465"],
      // this.treatCondition["466"]
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * I-HDFの項目名を取得する
   */
  getIHdfTitle() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["432"].name,
      ORD_TREAT_CONDITION["200"].name,
      ORD_TREAT_CONDITION["201"].name,
      ORD_TREAT_CONDITION["205"].name,
      ORD_TREAT_CONDITION["433"].name,
      ORD_TREAT_CONDITION["203"].name,
      ORD_TREAT_CONDITION["202"].name,
      ORD_TREAT_CONDITION["204"].name,
      ORD_TREAT_CONDITION["434"].name,
      ORD_TREAT_CONDITION["435"].name,
      ORD_TREAT_CONDITION["451"].name,
      ORD_TREAT_CONDITION["436"].name,
      ORD_TREAT_CONDITION["452"].name,
      ORD_TREAT_CONDITION["437"].name,
      ORD_TREAT_CONDITION["453"].name,
      ORD_TREAT_CONDITION["438"].name,
      ORD_TREAT_CONDITION["454"].name,
      ORD_TREAT_CONDITION["439"].name,
      ORD_TREAT_CONDITION["455"].name,
      ORD_TREAT_CONDITION["440"].name,
      ORD_TREAT_CONDITION["456"].name,
      ORD_TREAT_CONDITION["441"].name,
      ORD_TREAT_CONDITION["457"].name,
      ORD_TREAT_CONDITION["442"].name,
      ORD_TREAT_CONDITION["458"].name,
      ORD_TREAT_CONDITION["443"].name,
      ORD_TREAT_CONDITION["459"].name,
      ORD_TREAT_CONDITION["444"].name,
      ORD_TREAT_CONDITION["460"].name,
      ORD_TREAT_CONDITION["445"].name,
      ORD_TREAT_CONDITION["461"].name,
      ORD_TREAT_CONDITION["446"].name,
      ORD_TREAT_CONDITION["462"].name,
      ORD_TREAT_CONDITION["447"].name,
      ORD_TREAT_CONDITION["463"].name,
      ORD_TREAT_CONDITION["448"].name,
      ORD_TREAT_CONDITION["464"].name,
      ORD_TREAT_CONDITION["449"].name,
      ORD_TREAT_CONDITION["465"].name,
      ORD_TREAT_CONDITION["450"].name,
      ORD_TREAT_CONDITION["466"].name
      // ORD_TREAT_CONDITION["200"].name,
      // ORD_TREAT_CONDITION["201"].name,
      // ORD_TREAT_CONDITION["202"].name,
      // ORD_TREAT_CONDITION["203"].name,
      // ORD_TREAT_CONDITION["204"].name,
      // ORD_TREAT_CONDITION["205"].name,
      // ORD_TREAT_CONDITION["432"].name,
      // ORD_TREAT_CONDITION["433"].name,
      // ORD_TREAT_CONDITION["434"].name,
      // ORD_TREAT_CONDITION["435"].name,
      // ORD_TREAT_CONDITION["436"].name,
      // ORD_TREAT_CONDITION["437"].name,
      // ORD_TREAT_CONDITION["438"].name,
      // ORD_TREAT_CONDITION["439"].name,
      // ORD_TREAT_CONDITION["440"].name,
      // ORD_TREAT_CONDITION["441"].name,
      // ORD_TREAT_CONDITION["442"].name,
      // ORD_TREAT_CONDITION["443"].name,
      // ORD_TREAT_CONDITION["444"].name,
      // ORD_TREAT_CONDITION["445"].name,
      // ORD_TREAT_CONDITION["446"].name,
      // ORD_TREAT_CONDITION["447"].name,
      // ORD_TREAT_CONDITION["448"].name,
      // ORD_TREAT_CONDITION["449"].name,
      // ORD_TREAT_CONDITION["450"].name,
      // ORD_TREAT_CONDITION["451"].name,
      // ORD_TREAT_CONDITION["452"].name,
      // ORD_TREAT_CONDITION["453"].name,
      // ORD_TREAT_CONDITION["454"].name,
      // ORD_TREAT_CONDITION["455"].name,
      // ORD_TREAT_CONDITION["456"].name,
      // ORD_TREAT_CONDITION["457"].name,
      // ORD_TREAT_CONDITION["458"].name,
      // ORD_TREAT_CONDITION["459"].name,
      // ORD_TREAT_CONDITION["460"].name,
      // ORD_TREAT_CONDITION["461"].name,
      // ORD_TREAT_CONDITION["462"].name,
      // ORD_TREAT_CONDITION["463"].name,
      // ORD_TREAT_CONDITION["464"].name,
      // ORD_TREAT_CONDITION["465"].name,
      // ORD_TREAT_CONDITION["466"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }

  /**
   * 静的静脈圧のモデルを取得する
   */
  getSeitekiJoumyakuAtsu() {
    return new SeitekiJoumyakuAtsu(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["468"],
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["469"],
      this.treatCondition["469"] ? Number(this.treatCondition["469"]).toFixed(2) : "0.00",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["470"],
      this.treatCondition["471"]
    );
  }

  /**
   * 静的静脈圧の項目名を取得する
   */
  getSeitekiJoumyakuAtsuTitle() {
    return [
      ORD_TREAT_CONDITION["468"].name,
      ORD_TREAT_CONDITION["469"].name,
      ORD_TREAT_CONDITION["470"].name,
      ORD_TREAT_CONDITION["471"].name
    ];
  }

  /**
   * 警報情報のモデルを取得する
   */
  getKeihouJouhou() {
    return new KeihouJouhou(
      this.receiveDate,
      this.treatClass,
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // this.treatCondition["180"],
      this.treatCondition["180"] ? Number(this.treatCondition["180"]).toFixed(1) : "0.0",
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      this.treatCondition["286"],
      this.treatCondition["335"]
    );
  }

  /**
   * 警報情報の項目名を取得する
   */
  getKeihouJouhouTitle() {
    return [
      ORD_TREAT_CONDITION["180"].name,
      ORD_TREAT_CONDITION["286"].name,
      ORD_TREAT_CONDITION["335"].name
    ];
  }

  /**
   * 指示情報のモデルを取得する
   */
  getShijiJouhou() {
    return new ShijiJouhou(
      this.receiveDate,
      this.treatClass,
      this.treatCondition["15"],
      this.treatCondition["14"],
      this.treatCondition["41"] ? Number(this.treatCondition["41"]).toFixed(2) : "0.00",
      this.treatCondition["43"] ? Number(this.treatCondition["43"]).toFixed(2) : "0.00",
      this.treatCondition["28"],
      this.treatCondition["23"],
      this.treatCondition["27"],
      this.treatCondition["26"] ? Number(this.treatCondition["26"]).toFixed(1) : "0.0",
      this.treatCondition["388"],
      this.treatCondition["382"] ? Number(this.treatCondition["382"]).toFixed(2) : "0.00",
      this.treatCondition["380"] ? Number(this.treatCondition["380"]).toFixed(2) : "0.00",
      this.treatCondition["381"] ? Number(this.treatCondition["381"]).toFixed(1) : "0.0",
      this.treatCondition["29"], // IP使用選択
      this.treatCondition["31"], // IPスタート
      this.treatCondition["32"], // IPワンショットスタート
      this.treatCondition["33"] ? Number(this.treatCondition["33"]).toFixed(1) : "0.0", // IPワンショット量
      this.treatCondition["30"] ? Number(this.treatCondition["30"]).toFixed(1) : "0.0", // IP速度
      this.treatCondition["180"] ? Number(this.treatCondition["180"]).toFixed(1) : "0.0", // IP速度最大値
      this.treatCondition["34"],
      this.treatCondition["35"],
      this.treatCondition["36"],
      this.treatCondition["37"],
    );
  }

  /**
   * 指示情報の項目名を取得する
   */
  getShijiJouhouTitle() {
    return [
      ORD_TREAT_CONDITION["15"].name,
      ORD_TREAT_CONDITION["14"].name,
      ORD_TREAT_CONDITION["41"].name,
      ORD_TREAT_CONDITION["43"].name,
      ORD_TREAT_CONDITION["28"].name,
      ORD_TREAT_CONDITION["23"].name,
      ORD_TREAT_CONDITION["27"].name,
      ORD_TREAT_CONDITION["26"].name,
      ORD_TREAT_CONDITION["388"].name,
      ORD_TREAT_CONDITION["382"].name,
      ORD_TREAT_CONDITION["380"].name,
      ORD_TREAT_CONDITION["381"].name,
      ORD_TREAT_CONDITION["29"].name,  // IP使用選択
      ORD_TREAT_CONDITION["31"].name,  // IPスタート
      ORD_TREAT_CONDITION["30"].name,  // IP速度
      ORD_TREAT_CONDITION["180"].name, // IP速度最大値
      ORD_TREAT_CONDITION["32"].name,  // IPワンショットスタート
      ORD_TREAT_CONDITION["33"].name,  // IPワンショット量
      ORD_TREAT_CONDITION["34"].name,
      ORD_TREAT_CONDITION["35"].name,
      ORD_TREAT_CONDITION["36"].name,
      ORD_TREAT_CONDITION["37"].name
    ];
  }

  /**
   * 除水補正情報のモデルを取得する
   */
  getJosuiHoseiJouhou() {
    return new JosuiHoseiJouhou(
      this.receiveDate,
      this.treatClass,
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["42"],
      this.treatCondition["45"],
      this.treatCondition["53"],
      this.treatCondition["54"],
      this.treatCondition["62"],
      this.treatCondition["63"],
      this.treatCondition["71"],
      this.treatCondition["72"],
      this.treatCondition["80"],
      this.treatCondition["81"],
      this.treatCondition["89"]
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["44"],
      // this.treatCondition["44"] ? Number(this.treatCondition["44"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["42"],
      // this.treatCondition["45"],
      // this.treatCondition["53"],
      // this.treatCondition["54"],
      // this.treatCondition["62"],
      // this.treatCondition["63"],
      // this.treatCondition["71"],
      // this.treatCondition["72"],
      // this.treatCondition["80"],
      // this.treatCondition["81"],
      // this.treatCondition["89"]
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * 除水補正情報の項目名を取得する
   */
  getJosuiHoseiJouhouTitle() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["42"].name,
      ORD_TREAT_CONDITION["45"].name,
      ORD_TREAT_CONDITION["53"].name,
      ORD_TREAT_CONDITION["54"].name,
      ORD_TREAT_CONDITION["62"].name,
      ORD_TREAT_CONDITION["63"].name,
      ORD_TREAT_CONDITION["71"].name,
      ORD_TREAT_CONDITION["72"].name,
      ORD_TREAT_CONDITION["80"].name,
      ORD_TREAT_CONDITION["81"].name,
      ORD_TREAT_CONDITION["89"].name
      // ORD_TREAT_CONDITION["44"].name,
      // ORD_TREAT_CONDITION["42"].name,
      // ORD_TREAT_CONDITION["45"].name,
      // ORD_TREAT_CONDITION["53"].name,
      // ORD_TREAT_CONDITION["54"].name,
      // ORD_TREAT_CONDITION["62"].name,
      // ORD_TREAT_CONDITION["63"].name,
      // ORD_TREAT_CONDITION["71"].name,
      // ORD_TREAT_CONDITION["72"].name,
      // ORD_TREAT_CONDITION["80"].name,
      // ORD_TREAT_CONDITION["81"].name,
      // ORD_TREAT_CONDITION["89"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }

  /**
   * 体重情報のモデルを取得する
   */
  getTaijuuJouhou() {
    return new TaijuuJouhou(
      this.receiveDate,
      this.treatClass,
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["40"] ? Number(this.treatCondition["40"]).toFixed(2) : "0.00",
      this.treatCondition["20"] ? Number(this.treatCondition["20"]).toFixed(2) : "0.00",
      this.treatCondition["44"] ? Number(this.treatCondition["44"]).toFixed(2) : "0.00"
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["20"],
      // this.treatCondition["20"] ? Number(this.treatCondition["20"]).toFixed(2) : "0.00",
      // // this.treatCondition["40"],
      // this.treatCondition["40"] ? Number(this.treatCondition["40"]).toFixed(2) : "0.00",
      // // this.treatCondition["285"],
      // this.treatCondition["285"] ? Number(this.treatCondition["285"]).toFixed(1) : "0.0",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // // this.treatCondition["283"],
      // this.treatCondition["283"] ? Number(this.treatCondition["283"]).toFixed(1) : "0.0",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["284"]
      // this.treatCondition["284"] ? Number(this.treatCondition["284"]).toFixed(2) : "0.00"
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * 体重情報の項目名を取得する
   */
  getTaijuuJouhouTitle() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["40"].name,
      ORD_TREAT_CONDITION["20"].name,
      ORD_TREAT_CONDITION["44"].name
      // ORD_TREAT_CONDITION["20"].name,
      // ORD_TREAT_CONDITION["40"].name,
      // ORD_TREAT_CONDITION["285"].name,
      // ORD_TREAT_CONDITION["283"].name,
      // ORD_TREAT_CONDITION["284"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }

  /**
   * マスタ情報のモデルを取得する
   */
  getMasterJouhou() {
    return new MasterJouhou(
      this.receiveDate,
      this.treatClass,
      // FNSI-add 装置設定画面表示の修正 徐 start
      this.treatCondition["164"] ? Number(this.treatCondition["164"]).toFixed(2) : "0.00",
      this.treatCondition["165"] ? Number(this.treatCondition["165"]).toFixed(2) : "0.00",
      this.treatCondition["166"],
      this.treatCondition["167"],
      this.treatCondition["170"],
      this.treatCondition["173"],
      this.treatCondition["176"],
      this.treatCondition["390"],
      this.treatCondition["393"],
      this.treatCondition["467"] ? Number(this.treatCondition["467"]).toFixed(1) : "0.0",
      this.treatCondition["188"],
      this.treatCondition["189"],
      this.treatCondition["187"]
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["467"],
      // this.treatCondition["467"] ? Number(this.treatCondition["467"]).toFixed(1) : "0.0",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["287"],
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // // this.treatCondition["164"],
      // this.treatCondition["164"] ? Number(this.treatCondition["164"]).toFixed(2) : "0.00",
      // // this.treatCondition["165"],
      // this.treatCondition["165"] ? Number(this.treatCondition["165"]).toFixed(2) : "0.00",
      // // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      // this.treatCondition["166"],
      // this.treatCondition["187"],
      // this.treatCondition["188"],
      // this.treatCondition["189"],
      // this.treatCondition["167"],
      // this.treatCondition["170"],
      // this.treatCondition["390"],
      // this.treatCondition["393"],
      // this.treatCondition["173"],
      // this.treatCondition["176"]
      // FNSI-add 装置設定画面表示の修正 徐 end
    );
  }

  /**
   * マスタ情報の項目名を取得する
   */
  getMasterJouhouTitle() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      ORD_TREAT_CONDITION["164"].name,
      ORD_TREAT_CONDITION["165"].name,
      ORD_TREAT_CONDITION["166"].name,
      ORD_TREAT_CONDITION["167"].name,
      ORD_TREAT_CONDITION["170"].name,
      ORD_TREAT_CONDITION["173"].name,
      ORD_TREAT_CONDITION["176"].name,
      ORD_TREAT_CONDITION["390"].name,
      ORD_TREAT_CONDITION["393"].name,
      ORD_TREAT_CONDITION["467"].name,
      ORD_TREAT_CONDITION["188"].name,
      ORD_TREAT_CONDITION["189"].name,
      ORD_TREAT_CONDITION["187"].name
      // ORD_TREAT_CONDITION["467"].name,
      // ORD_TREAT_CONDITION["287"].name,
      // ORD_TREAT_CONDITION["164"].name,
      // ORD_TREAT_CONDITION["165"].name,
      // ORD_TREAT_CONDITION["166"].name,
      // ORD_TREAT_CONDITION["187"].name,
      // ORD_TREAT_CONDITION["188"].name,
      // ORD_TREAT_CONDITION["189"].name,
      // ORD_TREAT_CONDITION["167"].name,
      // ORD_TREAT_CONDITION["170"].name,
      // ORD_TREAT_CONDITION["390"].name,
      // ORD_TREAT_CONDITION["393"].name,
      // ORD_TREAT_CONDITION["173"].name,
      // ORD_TREAT_CONDITION["176"].name
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }
}
export const CATEGORY = {
  SOUSA_HANI: "sousaHani",
  KEIHOU_TEN: "keihouTen",
  KETSUATSU_KEI: "ketsuatsuKei",
  BV: "bv",
  PRIMING_AND_HENKETSU: "primingAndHenketsu",
  DFAS: "dFas",
  SOUCHI_PROGRAM: "souchiProgram",
  KETSURYUU_RYOU_AND_TOUSEKIEKI_RYUURYOU_PROGRAM: "ketsuryuuRyouAndTousekiEkiRyuuRyouProgram",
  TOUSEKI_RYOU_PROGRAM: "tousekiRyouProgram",
  BV_UFC: "bvUfc",
  IHDF: "iHdf",
  SEITEKI_JOUMYAKU_ATSU: "seitekiJoumyakuAtsu",
  KEIHOU_JOUHOU: "keihouJouhou",
  SHIJI_JOUHOU: "shijiJouhou",
  JOSUI_HOSEI_JOUHOU: "josuiHoseiJouhou",
  TAIJUU_JOUHOU: "taijuuJouhou",
  MASTER_JOUHOU: "masterJouhou",
  // FNSI-add 装置設定画面表示の修正 徐 start
  ECUM_SETTING: "ecumSetting",
  CONCENTRATION_PROGRAM: "concentration",
  DIVERSION_PROGRAM: "diversionProgram",
  NA_INJECTIONPROGRAM: "naInjectionProgram",
  DIALYSIS_SOL_CONCENTRATION_PROGRAM: "dialysisSolConcentrationProgram"
  // FNSI-add 装置設定画面表示の修正 徐 end
}
