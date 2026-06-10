using System;
using System.Text;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace LayoutDesignerTest
{
    /// <summary>
    /// RldExcelHelper の概要の説明
    /// </summary>
    [TestClass]
    public class RldExcelHelperTest
    {
        public RldExcelHelperTest()
        {
            //
            // TODO: コンストラクター ロジックをここに追加します
            //
        }

        private TestContext testContextInstance;

        /// <summary>
        ///現在のテストの実行についての情報および機能を
        ///提供するテスト コンテキストを取得または設定します。
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

        #region 追加のテスト属性
        //
        // テストを作成する際には、次の追加属性を使用できます:
        //
        // クラス内で最初のテストを実行する前に、ClassInitialize を使用してコードを実行してください
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // クラス内のテストをすべて実行したら、ClassCleanup を使用してコードを実行してください
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        // 各テストを実行する前に、TestInitialize を使用してコードを実行してください
        // [TestInitialize()]
        // public void MyTestInitialize() { }
        //
        // 各テストを実行した後に、TestCleanup を使用してコードを実行してください
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod]
        public void ToXmlElementTextTest()
        {

            var rules = new LayoutDesigner.Data.FormatConditionRules();
            for (int i = 0; i < 2; i++)
            {
                var item = new LayoutDesigner.Data.FormatConditionRule
                {
                    ComparisonOperator = "=",
                    Value = i.ToString()
                };
                item.Font = new System.Drawing.Font("Microsoft Sans Serif", i + 1, System.Drawing.FontStyle.Regular | System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic);
                rules.Add(item);
            }

            string elm = rules.ToXmlElementText();
            Assert.AreEqual(
                $"<rules><formatCondition comparisonOperator=\"{rules[0].ComparisonOperator}\" value=\"{rules[0].Value}\"><fontName>{rules[0].Font.Name}</fontName><fontSize>{rules[0].Font.Size.ToString()}</fontSize><fontStyle>{((int)rules[0].Font.Style).ToString()}</fontStyle></formatCondition><formatCondition comparisonOperator=\"{rules[1].ComparisonOperator}\" value=\"{rules[1].Value}\"><fontName>{rules[1].Font.Name}</fontName><fontSize>{rules[1].Font.Size.ToString()}</fontSize><fontStyle>{((int)rules[1].Font.Style).ToString()}</fontStyle></formatCondition></rules>",
                elm);

            var wXmlDoc = new System.Xml.XmlDocument();
            wXmlDoc.LoadXml(elm);
            LayoutDesigner.Data.FormatConditionRules result;
            LayoutDesigner.Data.FormatConditionRules.TryParse(wXmlDoc.DocumentElement, out result);
            for (int i = 0; i < result.Count; i++)
            {
                LayoutDesigner.Data.FormatConditionRule actual = result[i];
                LayoutDesigner.Data.FormatConditionRule exp = rules[i];
                Assert.AreEqual(exp.ComparisonOperator, actual.ComparisonOperator);
                Assert.AreEqual(exp.Value, actual.Value);
                Assert.AreEqual(exp.Font.Name, actual.Font.Name);
                Assert.AreEqual(exp.Font.Size, actual.Font.Size);
                Assert.AreEqual(exp.Font.Style, actual.Font.Style);
            }

            Assert.AreEqual("6.0", 6.ToString("0.0"));
            Assert.AreEqual("0.0", 0.ToString("0.0"));
            Assert.AreEqual("99.0", 99.ToString("0.0"));

        }
    }
}
