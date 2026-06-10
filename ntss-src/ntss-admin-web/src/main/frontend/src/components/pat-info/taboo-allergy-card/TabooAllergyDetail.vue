<template>
  <div>
    <div v-if="className !== ''" class="taboo-allergy-class">
      {{ className }}
    </div>
    <div class="taboo-allergy-detail">
      【薬剤】<br />
      <label v-if="isTabooAllergyEmpty(medicine)">なし</label>
      <ul>
        <li v-for="(name, index) in medicine" :key="index">{{ name }}</li>
      </ul>
    </div>
    <div class="taboo-allergy-detail" v-if="!isTabooAllergyEmpty(medicineMix)">
      【調製薬剤】<br />
      <ul>
        <li v-for="(name, index) in medicineMix" :key="index">{{ name }}</li>
      </ul>
    </div>
    <!-- modify by maxueqiang bug:5430 -->
    <!-- <div class="taboo-allergy-detail">
      【調製薬剤】 <br />
      <label v-if="isTabooAllergyEmpty(medicineMix)">なし</label>
      <ul>
        <li v-for="(name, index) in medicineMix" :key="index">{{ name }}</li>
      </ul>
    </div> -->
    <!-- modify by maxueqiang bug:5430 -->
    <div class="taboo-allergy-detail">
      【医療材料】 <br />
      <label v-if="isTabooAllergyEmpty(equip)">なし</label>
      <ul>
        <li v-for="(name, index) in equip" :key="index">{{ name }}</li>
      </ul>
    </div>
    <div class="taboo-allergy-detail">
      【ダイアライザ】 <br />
      <label v-if="isTabooAllergyEmpty(dialyzer)">なし</label>
      <ul>
        <li v-for="(name, index) in dialyzer" :key="index">{{ name }}</li>
      </ul>
    </div>
    <div class="taboo-allergy-detail">
      【一般名処方】 <br />
      <label v-if="isTabooAllergyEmpty(genericMedicine)">なし</label>
      <ul>
        <li v-for="(name, index) in genericMedicine" :key="index">{{ name }}</li>
      </ul>
    </div>
    <div class="taboo-allergy-detail">
      【フリーワード】 <br />
      <label v-if="isTabooAllergyEmpty(freeWord)">なし</label>
      <ul>
        <li v-for="(name, index) in freeWord" :key="index">{{ name }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
import _ from "underscore";

export default {
  props: {
    className: {
      type: String,
      default: ""
    },

    // add 9987 by kangjie 20231215 start
    medicineMix: {
      required: true
    },
    // add 9987 by kangjie 20231215 end

    medicine: {
      required: true
    },

    // del #9981 5430 余計なコーディングの削除 limf start
    // medicineMix: {
    //   required: true
    // },
    // del #9981 5430 余計なコーディングの削除 limf end

    equip: {
      required: true
    },

    dialyzer: {
      required: true
    },

    genericMedicine: {
      required: true
    },

    freeWord: {
      required: true
    }
  },

  methods: {
    // 各区分の名称が空かチェック
    isTabooAllergyEmpty(tabooAllergyDetailName) {
      return _.isEmpty(tabooAllergyDetailName);
    }
  }
};
</script>

<style scoped>
.taboo-allergy-class {
  font-weight: bold;
}

.taboo-allergy-detail ul {
  margin: 0 0 15px 0;
}
</style>
