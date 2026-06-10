using System.Collections.Generic;

namespace NKKAccessCardLib
{
    public class CardConfiguration
    {
        public int BlockUnitSize { get; set; } = 16;
        public List<CardItemMeta> Metadata { get; set; } = new List<CardItemMeta>();
    }
    
    public class CardItemMeta
    {
        public string Name { get; set; } = string.Empty;
        public string Label { get; set; } = string.Empty;
        public int Size { get; set; } = 0;
        public int Block { get; set; } = 0;
        public int Offset { get; set; } = 0;
        public CardItemSpec Spec { get; set; } = new CardItemSpec();
    }

    public class CardItemSpec
    {
        public string Type { get; set; }
        public object[] Range { get; set; }
        public object[] Option { get; set; }
        public int Decimals { get; set; } = 0;
    }

    public class CardResponse
    {
        public CardWriteValue CardWriteValue { get; set; } = new CardWriteValue();
    }
    
    public class CardWriteValue
    {
        public string Firstname { get; set; }
        public string Lastname { get; set; }
        public string Birthdate { get; set; }
        public string CardCd { get; set; }
        public string Type { get; set; }
        public string Info { get; set; }
        public Dictionary<string, string> InfoDic { get; set; }
    }
}