

namespace ConvertCommon.dto
{

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false, ElementName = "rootNode")]
    public partial class ConfigInfoDto
    {

        private rootNodeTableInfo[] tableInfoField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("tableInfo")]
        public rootNodeTableInfo[] tableInfo
        {
            get
            {
                return this.tableInfoField;
            }
            set
            {
                this.tableInfoField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class rootNodeTableInfo
    {

        private string nameField;

        private string xmlConfigNameField;

        private string fnwTableNameField;

        private string ntssTableNameField;

        private string hiddenField;

        private string fnwPkField;

        private string mstSelectorCodeField;

        private string mstSelectorNameField;

        private string sqlForToolField;

        private string sqlForSyncField;

        private string sqlForDiffField;

        private string sqlForSyncTableAliasField;

        private string sqlForSpecifyPeriodField;

        private string sqlForExclusiveOutputtedField;

        private string convertKindField;

        private rootNodeTableInfoChild[] childField;

        /// <remarks/>
        public string name
        {
            get
            {
                return this.nameField;
            }
            set
            {
                this.nameField = value;
            }
        }

        /// <remarks/>
        public string xmlConfigName
        {
            get
            {
                return this.xmlConfigNameField;
            }
            set
            {
                this.xmlConfigNameField = value;
            }
        }

        /// <remarks/>
        public string fnwTableName
        {
            get
            {
                return this.fnwTableNameField;
            }
            set
            {
                this.fnwTableNameField = value;
            }
        }

        /// <remarks/>
        public string ntssTableName
        {
            get
            {
                return this.ntssTableNameField;
            }
            set
            {
                this.ntssTableNameField = value;
            }
        }

        /// <remarks/>
        public string hidden
        {
            get
            {
                return this.hiddenField;
            }
            set
            {
                this.hiddenField = value;
            }
        }

        /// <remarks/>
        public string fnwPk
        {
            get
            {
                return this.fnwPkField;
            }
            set
            {
                this.fnwPkField = value;
            }
        }

        /// <remarks/>
        public string mstSelectorCode
        {
            get
            {
                return this.mstSelectorCodeField;
            }
            set
            {
                this.mstSelectorCodeField = value;
            }
        }

        /// <remarks/>
        public string mstSelectorName
        {
            get
            {
                return this.mstSelectorNameField;
            }
            set
            {
                this.mstSelectorNameField = value;
            }
        }

        /// <remarks/>
        public string sqlForTool
        {
            get
            {
                return this.sqlForToolField;
            }
            set
            {
                this.sqlForToolField = value;
            }
        }

        /// <remarks/>
        public string sqlForSync
        {
            get
            {
                return this.sqlForSyncField;
            }
            set
            {
                this.sqlForSyncField = value;
            }
        }

        /// <remarks/>
        public string sqlForDiff
        {
            get
            {
                return this.sqlForDiffField;
            }
            set
            {
                this.sqlForDiffField = value;
            }
        }

        /// <remarks/>
        public string sqlForSyncTableAlias
        {
            get
            {
                return this.sqlForSyncTableAliasField;
            }
            set
            {
                this.sqlForSyncTableAliasField = value;
            }
        }

        public string sqlForSpecifyPeriod
        {
            get
            {
                return this.sqlForSpecifyPeriodField;
            }

            set
            {
                this.sqlForSpecifyPeriodField = value;
            }
        }

        public string sqlForExclusiveOutputted
        {
            get
            {
                return this.sqlForExclusiveOutputtedField;
            }

            set
            {
                this.sqlForExclusiveOutputtedField = value;
            }
        }

        public string convertKind
        {
            get
            {
                return this.convertKindField;
            }
            set
            {
                this.convertKindField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("child")]
        public rootNodeTableInfoChild[] child
        {
            get
            {
                return this.childField;
            }
            set
            {
                this.childField = value;
            }
        }

        
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class rootNodeTableInfoChild
    {

        private string xmlConfigNameField;

        private string fnwTableNameField;

        private string parentPkField;

        private string childPkField;

        private string jsonNameField;

        private string sqlForToolField;

        private string sqlForSyncField;

        private string sqlForSpecifyPeriodField;

        private string sqlForExclusiveOutputtedField;

        /// <remarks/>
        public string xmlConfigName
        {
            get
            {
                return this.xmlConfigNameField;
            }
            set
            {
                this.xmlConfigNameField = value;
            }
        }

        /// <remarks/>
        public string fnwTableName
        {
            get
            {
                return this.fnwTableNameField;
            }
            set
            {
                this.fnwTableNameField = value;
            }
        }

        /// <remarks/>
        public string parentPk
        {
            get
            {
                return this.parentPkField;
            }
            set
            {
                this.parentPkField = value;
            }
        }

        /// <remarks/>
        public string childPk
        {
            get
            {
                return this.childPkField;
            }
            set
            {
                this.childPkField = value;
            }
        }

        /// <remarks/>
        public string jsonName
        {
            get
            {
                return this.jsonNameField;
            }
            set
            {
                this.jsonNameField = value;
            }
        }

        /// <remarks/>
        public string sqlForTool
        {
            get
            {
                return this.sqlForToolField;
            }
            set
            {
                this.sqlForToolField = value;
            }
        }

        /// <remarks/>
        public string sqlForSync
        {
            get
            {
                return this.sqlForSyncField;
            }
            set
            {
                this.sqlForSyncField = value;
            }
        }

        public string sqlForSpecifyPeriod
        {
            get
            {
                return this.sqlForSpecifyPeriodField;
            }

            set
            {
                this.sqlForSpecifyPeriodField = value;
            }
        }

        public string sqlForExclusiveOutputted
        {
            get
            {
                return this.sqlForExclusiveOutputtedField;
            }

            set
            {
                this.sqlForExclusiveOutputtedField = value;
            }
        }
    }

}