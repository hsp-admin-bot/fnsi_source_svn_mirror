namespace LayoutDesigner
{

    /// <summary>
    /// mst_report 追加情報
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class AdditionalInfo
    {

        /// <summary>
        /// ラベルの列数
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "col_count")]
        public int ColCount { get; set; } = 0;

        /// <summary>
        /// ラベルの行数
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "row_count")]
        public int RowCount { get; set; } = 0;

        /// <summary>
        /// 印刷方向(N型:0, Z型:1)
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "print_direct")]
        public int PrintDirection { get; set; } = 0;

        /// <summary>
        /// 現在のインスタンスのコピーである新しいオブジェクトを作成する
        /// </summary>
        /// <returns>このインスタンスのコピーである新しいオブジェクト</returns>
        public AdditionalInfo Clone()
        {
            return new AdditionalInfo
            {
                ColCount = this.ColCount,
                RowCount = this.RowCount,
                PrintDirection = this.PrintDirection
            };
        }

    }

}