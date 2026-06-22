

namespace ConvertCommon.dto
{
    /// <remarks/> AuthoritySettings.xmlをデシリアライズ後、格納用のクラス
    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false, ElementName = "authority_settings")]
    public partial class AuthoritySettingsDto
    {

        private authority_settingsJob_authority_list[] job_authority_listField;

        private authority_settingsJob_authority_list_default job_authority_list_defaultField;

        private authority_settingsAdmin_user_authority_list admin_user_authority_listField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("job_authority_list")]
        public authority_settingsJob_authority_list[] job_authority_list
        {
            get
            {
                return this.job_authority_listField;
            }
            set
            {
                this.job_authority_listField = value;
            }
        }

        /// <remarks/>
        public authority_settingsJob_authority_list_default job_authority_list_default
        {
            get
            {
                return this.job_authority_list_defaultField;
            }
            set
            {
                this.job_authority_list_defaultField = value;
            }
        }

        /// <remarks/>
        public authority_settingsAdmin_user_authority_list admin_user_authority_list
        {
            get
            {
                return this.admin_user_authority_listField;
            }
            set
            {
                this.admin_user_authority_listField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class authority_settingsJob_authority_list
    {

        private string fnw_job_class_cdField;

        private string user_settingsField;

        private byte user_typeField;

        private byte administratorField;

        private object default_menu_settingsField;

        /// <remarks/>
        public string fnw_job_class_cd
        {
            get
            {
                return this.fnw_job_class_cdField;
            }
            set
            {
                this.fnw_job_class_cdField = value;
            }
        }

        /// <remarks/>
        public string user_settings
        {
            get
            {
                return this.user_settingsField;
            }
            set
            {
                this.user_settingsField = value;
            }
        }

        /// <remarks/>
        public byte user_type
        {
            get
            {
                return this.user_typeField;
            }
            set
            {
                this.user_typeField = value;
            }
        }

        /// <remarks/>
        public byte administrator
        {
            get
            {
                return this.administratorField;
            }
            set
            {
                this.administratorField = value;
            }
        }

        /// <remarks/>
        public object default_menu_settings
        {
            get
            {
                return this.default_menu_settingsField;
            }
            set
            {
                this.default_menu_settingsField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class authority_settingsJob_authority_list_default
    {

        private string fnw_job_class_cdField;

        private string user_settingsField;

        private byte user_typeField;

        private byte administratorField;

        private object default_menu_settingsField;

        /// <remarks/>
        public string fnw_job_class_cd
        {
            get
            {
                return this.fnw_job_class_cdField;
            }
            set
            {
                this.fnw_job_class_cdField = value;
            }
        }

        /// <remarks/>
        public string user_settings
        {
            get
            {
                return this.user_settingsField;
            }
            set
            {
                this.user_settingsField = value;
            }
        }

        /// <remarks/>
        public byte user_type
        {
            get
            {
                return this.user_typeField;
            }
            set
            {
                this.user_typeField = value;
            }
        }

        /// <remarks/>
        public byte administrator
        {
            get
            {
                return this.administratorField;
            }
            set
            {
                this.administratorField = value;
            }
        }

        /// <remarks/>
        public object default_menu_settings
        {
            get
            {
                return this.default_menu_settingsField;
            }
            set
            {
                this.default_menu_settingsField = value;
            }
        }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class authority_settingsAdmin_user_authority_list
    {

        private string[] fnw_staff_cdField;

        private string user_settingsField;

        private byte user_typeField;

        private byte administratorField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("fnw_staff_cd")]
        public string[] fnw_staff_cd
        {
            get
            {
                return this.fnw_staff_cdField;
            }
            set
            {
                this.fnw_staff_cdField = value;
            }
        }

        /// <remarks/>
        public string user_settings
        {
            get
            {
                return this.user_settingsField;
            }
            set
            {
                this.user_settingsField = value;
            }
        }

        /// <remarks/>
        public byte user_type
        {
            get
            {
                return this.user_typeField;
            }
            set
            {
                this.user_typeField = value;
            }
        }

        /// <remarks/>
        public byte administrator
        {
            get
            {
                return this.administratorField;
            }
            set
            {
                this.administratorField = value;
            }
        }
    }
}
