using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Messaging;
using System.IO;
using System.Xml;
using System.Threading;
using System.Configuration;
using System.Diagnostics;
using System.Xml.Xsl;
using System.Xml.XPath;
using DataAbstraction.Cascades.Runtime;

namespace DataAbstraction.Cascades
{
    class CascadesInterfaceConfigurationSection : ConfigurationSection
    {
        public CascadesInterfaceConfigurationSection()
        {
        }

        [ConfigurationProperty("refreshTime", IsRequired = false, DefaultValue = "0:0:2")]
        public TimeSpan RefreshTime
        {
            get { return (TimeSpan)this["refreshTime"]; }
            set { this["refreshTime"] = value; }
        }

        [ConfigurationProperty("allowFallbackBrand", IsRequired = false, DefaultValue = "true", IsKey = false)]
        public Boolean AllowFallbackBrand
        {
            get { return (Boolean)this["allowFallbackBrand"]; }
            set { this["allowFallbackBrand"] = value; }
        }
        [ConfigurationProperty("fileName", IsRequired = true)]
        public String FileName
        {
            get { return (String)this["fileName"]; }
            set { this["fileName"] = value; }
        }
        [ConfigurationProperty("transforms", IsRequired = false)]
        public TransformConfigurationCollection Transforms
        {
            get { return (TransformConfigurationCollection)this["transforms"]; }
            set { this["transforms"] = value; }
        }
    }
    public class StatusReader
    {
        Boolean AllowFallbackBrand;
        ValidatingTransform FallbackBrand;
        public ValidatingTransformCollection Transforms { get; private set; }
        private String FileName;


        private const String DateTimeFormat = "yyyy/MM/dd hh:mm:ss.fff";
        internal const String DateTimeParameterName = "DateTime";

        public TimeSpan RefreshTime { get; private set; }
        private int TotalRetries;
        //TODO: Add code to write all exceptions to Notify 

        public Message Receive()
        {
            Message Result = null;
            try
            {
                Byte[] Buffer = File.ReadAllBytes(FileName);
                MemoryStream Stream = new MemoryStream(Buffer);
                Result = new Message();
                Result.BodyStream = Stream;
            }
            catch (Exception e)
            {
                 Debug.WriteLine(String.Format("Exception", e.ToString()));
            }
            return Result;
        }

        private Stream TransformMessage(Message message, String formName, Dictionary<String, String> parameters)
        {
            Stream FormResult = null;
            ValidatingTransform FormTransform = Transforms[formName];
            if (FormTransform != null && message != null)
            {
                XsltArgumentList Arguments = new XsltArgumentList();
                if (parameters != null)
                {
                    foreach (String Key in parameters.Keys)
                    {
                        String Value = parameters[Key];
                        Arguments.AddParam(Key, "", Value);
                    }
                }
                String DateString = DateTime.Now.ToString("O");
                Arguments.AddParam(DateTimeParameterName, "", DateString);
                XmlReader Reader = message.CreateReader();
                FormResult = FormTransform.Apply(Reader, Arguments);
                Reader.Close();
            }
            return FormResult;
        }

        public String TransformBodyContent(Message message, String formName, Dictionary<String, String> parameters)
        {
            String Content = String.Empty;
            Stream FormResult = TransformMessage(message, formName, parameters);
            if (FormResult != null)
            {
                ValidatingTransform Brand = null;
                XsltArgumentList BrandArguments = new XsltArgumentList();
                if (parameters.ContainsKey("Brand"))
                    Brand = Transforms[parameters["Brand"]];
                else
                {
                    if (AllowFallbackBrand) Brand = FallbackBrand;
                    else throw new CascadesException("Brand transform not specified and fallback not allowed");
                }
                Stream Output = Brand.Apply(FormResult, BrandArguments);
                XmlReader OutputReader = XmlReader.Create(Output);
                OutputReader.MoveToContent();
                Content = OutputReader.ReadOuterXml();
            }
            return Content;
        }

        public void Disconnect()
        {
        }

        public void Connect()
        {
        }

        public StatusReader(Configuration configuration)
        {
            CascadesInterfaceConfigurationSection Section = configuration.GetSection("CascadesInterface2") as CascadesInterfaceConfigurationSection;
            RefreshTime = Section.RefreshTime;
            FileName = Section.FileName;
            AllowFallbackBrand = Section.AllowFallbackBrand;
            TransformConfigurationCollection TransformConfigCollection = Section.Transforms;
            Transforms = new ValidatingTransformCollection(Section.Transforms);
            if (Transforms.ContainsKey("Brand"))
                FallbackBrand = Transforms["Brand"];
         }

        public void Start()
        {

        }
    }
}