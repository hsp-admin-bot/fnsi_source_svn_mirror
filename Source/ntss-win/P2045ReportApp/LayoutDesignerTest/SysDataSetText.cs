using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace LayoutDesignerTest
{
    [TestClass]
    public class SysDataSetText
    {
        [TestMethod]
        public void JsonSerializeTest()
        {

            System.Collections.Generic.List<LayoutDesigner.Data.SysDataSetData> sysDataSets = new System.Collections.Generic.List<LayoutDesigner.Data.SysDataSetData>();

            for (int i = 0; i < 3; i++)
            {
                sysDataSets.Add(new LayoutDesigner.Data.SysDataSetData());
                //sysDataSets[i].DetailInfo = new System.Collections.Generic.List<LayoutDesigner.Data.SysDataSetDetailData>();
                //for (int j = 0; j < 3; j++)
                //{
                //    sysDataSets[i].DetailInfo.Add(new LayoutDesigner.Data.SysDataSetDetailData());
                //}
                sysDataSets[i].DetailInfo = new LayoutDesigner.Data.SysDataSetDetailInfoData();
                for (int j = 0; j < 3; j++)
                {
                    sysDataSets[i].DetailInfo.Details.Add(new LayoutDesigner.Data.SysDataSetDetailData());
                }

            }

            using (System.IO.MemoryStream stream = new System.IO.MemoryStream())
            {
                System.Runtime.Serialization.Json.DataContractJsonSerializer serializer = new System.Runtime.Serialization.Json.DataContractJsonSerializer(sysDataSets.GetType());
                serializer.WriteObject(stream, sysDataSets);
                string result = System.Text.Encoding.UTF8.GetString(stream.ToArray());
                System.Diagnostics.Debug.Print(result);
            }

        }

        [TestMethod]
        public void FunctionTest()
        {
            var a = "##=SUM(M1:O1,R1:X1)";
            var pos = a.IndexOf("(");
            Assert.AreEqual(6, pos);
            Assert.AreEqual("SUM", a.Substring(3, pos - 3).ToUpper());
            Assert.AreEqual("M1:O1,R1:X1", a.Substring(pos + 1, a.Length - pos - 2));

        }

    }
}
