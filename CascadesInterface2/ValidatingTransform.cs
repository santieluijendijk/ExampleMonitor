using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Schema;
using System.Xml.Xsl;
using System.Xml;
using System.IO;
using System.Configuration;

namespace DataAbstraction.Cascades.Runtime
{
    [Serializable]
    public class CascadesException : Exception
    {
        /// <summary>
        /// Intantiates an empty CascadesException
        /// </summary>
        public CascadesException()
        {
        }

        /// <summary>
        /// Intantiates an CascadesException with a message
        /// </summary>
        /// <param name="message">string representing the message associated with exception</param>
        public CascadesException(String message)
            : base(message)
        {
        }

        /// <summary>
        /// Intantiates an CascadesException with a message and an inner exception object
        /// </summary>
        /// <param name="message">string representing the message associated with exception</param>
        /// <param name="innerException">The innerexception associated with this exception</param>
        public CascadesException(String message, Exception innerException)
            : base(message, innerException)
        {
        }

        /// <summary>
        /// Constructor to support serialization not intended to be called from user code
        /// </summary>
        /// <param name="info"></param>
        /// <param name="context"></param>
        public CascadesException(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)
            : base(info, context)
        {
        }
    }

    [Serializable]
    public class CascadesConfigurationException : CascadesException
    {
        public String ConfigurationFile { get; protected set; }

        /// <summary>
        /// Intantiates an empty CascadesConfigurationException
        /// </summary>
        public CascadesConfigurationException()
        {
        }

        /// <summary>
        /// Intantiates an CascadesConfigurationException with a message
        /// </summary>
        /// <param name="message">string representing the message associated with exception</param>
        public CascadesConfigurationException(String message, String configurationFile)
            : base(message)
        {
            ConfigurationFile = configurationFile;
        }

        /// <summary>
        /// Intantiates an CascadesConfigurationException with a message and an inner exception object
        /// </summary>
        /// <param name="message">string representing the message associated with exception</param>
        /// <param name="innerException">The innerexception associated with this exception</param>
        public CascadesConfigurationException(String message, String configurationFile, Exception innerException)
            : base(message, innerException)
        {
            ConfigurationFile = configurationFile;
        }

        /// <summary>
        /// Constructor to support serialization not intended to be called from user code
        /// </summary>
        /// <param name="info"></param>
        /// <param name="context"></param>
        public CascadesConfigurationException(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)
            : base(info, context)
        {
        }

    }
    public class ValidationSettings
    {
        public ValidationSettings()
        {

            ReaderSettings = new XmlReaderSettings();
            ReaderSettings.ConformanceLevel = ConformanceLevel.Document;
            ReaderSettings.ValidationEventHandler += OnXmlValidationEvent;

            WriterSettings = new XmlWriterSettings();
            WriterSettings.ConformanceLevel = ConformanceLevel.Document;
            WriterSettings.CheckCharacters = true;
            WriterSettings.Indent = true;
        }

        private void OnXmlValidationEvent(Object sender, ValidationEventArgs eventArgs)
        {
            if (eventArgs.Exception != null) throw new CascadesException("Schema validation exception", eventArgs.Exception);
        }

        public XmlReaderSettings ReaderSettings { get; private set; }
        public XmlWriterSettings WriterSettings { get; private set; }
    }

    public class TransformConfigurationCollection : ConfigurationElementCollection
    {
        public TransformConfigurationCollection()
        {
        }

        public override ConfigurationElementCollectionType CollectionType
        {
            get
            {
                return ConfigurationElementCollectionType.AddRemoveClearMap;
            }
        }

        protected override ConfigurationElement CreateNewElement()
        {
            return new TransformConfigurationElement();
        }

        protected override ConfigurationElement CreateNewElement(String elementScheme)
        {
            return new TransformConfigurationElement(elementScheme);
        }

        protected override Object GetElementKey(ConfigurationElement element)
        {
            return ((TransformConfigurationElement)element).Name;
        }

        public new int Count
        {
            get { return base.Count; }
        }

        public TransformConfigurationElement this[int index]
        {
            get
            {
                return (TransformConfigurationElement)BaseGet(index);
            }
            set
            {
                if (BaseGet(index) != null)
                {
                    BaseRemoveAt(index);
                }
                BaseAdd(index, value);
            }
        }

        public new TransformConfigurationElement this[String name]
        {
            get
            {
                return (TransformConfigurationElement)BaseGet(name);
            }
        }

        public int IndexOf(TransformConfigurationElement element)
        {
            if (element == null) throw new ArgumentNullException("element");

            return BaseIndexOf(element);
        }

        public void Add(TransformConfigurationElement element)
        {
            if (element == null) throw new ArgumentNullException("element");

            BaseAdd(element);
            // Add custom code here.
        }

        protected override void BaseAdd(ConfigurationElement element)
        {
            if (element == null) throw new ArgumentNullException("element");
            BaseAdd(element, false);
            // Add custom code here.
        }

        public void Remove(TransformConfigurationElement element)
        {
            if (element == null) throw new ArgumentNullException("element");

            if (BaseIndexOf(element) >= 0)
                BaseRemove(element.Name);
        }

        public void RemoveAt(int index)
        {
            BaseRemoveAt(index);
        }

        public void Remove(String name)
        {
            BaseRemove(name);
        }

        public void Clear()
        {
            BaseClear();
            // Add custom code here.
        }
    }
    public class TransformConfigurationElement : ConfigurationElement
    {
        public TransformConfigurationElement(String name)
        {
            Name = name;
        }

        public TransformConfigurationElement()
            : this(String.Empty)
        {
        }

        [ConfigurationProperty("name", IsRequired = true, IsKey = true)]
        public String Name
        {
            get
            {
                return (String)this["name"];
            }
            set
            {
                this["name"] = value;
            }
        }
        [ConfigurationProperty("transform", IsRequired = false)]
        public Uri Transform
        {
            get
            {
                return (Uri)this["transform"];
            }
            set
            {
                this["transform"] = value;
            }
        }

        [ConfigurationProperty("enableDebugging", IsRequired = false, DefaultValue = false)]
        public Boolean EnableDebugging
        {
            get
            {
                return (Boolean)this["enableDebugging"];
            }
            set
            {
                this["enableDebugging"] = value;
            }
        }
    }
    public class ValidatingTransform
    {
        public String Name { get; private set; }

        public ValidatingTransform(TransformConfigurationElement transformConfiguration)
        {
            Name = transformConfiguration.Name;
            String TransformPath = transformConfiguration.Transform.ToString();

            Transform = new XslCompiledTransform();
            try
            {
                Transform.Load(TransformPath);
            }
            catch (System.Net.WebException we)
            {
                throw new CascadesException(String.Format("Transform {0} could not be loaded ({1}).", Name, we.Message), we);
            }
            catch (System.IO.FileNotFoundException fnfe)
            {
                throw new CascadesException(String.Format("Transform {0} could not be found ({1}).", Name, fnfe.Message), fnfe);
            }
            catch (UriFormatException ufe)
            {
                throw new CascadesException(String.Format("Transform URI {0} is invalid ({1}).", Name, ufe.Message), ufe);
            }
            catch (DirectoryNotFoundException dnfe)
            {
                throw new CascadesException(String.Format("Transform {0} could not be found (invalid path).", Name), dnfe);
            }
            catch (XsltException xse)
            {
                throw new CascadesException(String.Format("Content of transform {0} is invalid ({1}).", Name, xse.Message), xse);
            }
            catch (XmlException xe)
            {
                throw new CascadesException(String.Format("Content of transform {0} is not valid XML ({1}).", Name, xe.Message), xe);
            }

        }


        public ValidationSettings SourceSettings { get; private set; }
        public ValidationSettings TargetSettings { get; private set; }

        public XslCompiledTransform Transform { get; private set; }

        public Stream Apply(XmlReader reader, XsltArgumentList arguments)
        {
            MemoryStream Result = new MemoryStream();
            XmlWriter Writer;

            if (Transform != null)
            {
                Writer = XmlWriter.Create(Result, Transform.OutputSettings);
                Transform.Transform(reader, arguments, Writer);
            }
            else
            {
                if (TargetSettings != null)
                {
                    Writer = XmlWriter.Create(Result, TargetSettings.WriterSettings);
                }
                else
                {
                    Writer = XmlWriter.Create(Result);
                }
                reader.MoveToContent();
                Writer.WriteNode(reader.ReadSubtree(), true);
            }

            Writer.Flush();
            Writer.Close();

            Result.Seek(0, SeekOrigin.Begin);

            return Result;
        }

        public Stream Apply(Stream input, XsltArgumentList arguments)
        {
            input.Seek(0, SeekOrigin.Begin);

            XmlReader Reader;
            if (SourceSettings != null)
            {
                Reader = XmlReader.Create(input, SourceSettings.ReaderSettings);
            }
            else
            {
                Reader = XmlReader.Create(input);
            }
            return Apply(Reader, arguments);
        }
    }

    public class ValidatingTransformCollection : IEnumerable<ValidatingTransform>
    {

        public ValidatingTransformCollection(TransformConfigurationCollection ValidatingTransformsConfiguration)
        {
            if (ValidatingTransformsConfiguration != null)
            {
                foreach (TransformConfigurationElement ValidatingTransformConfiguration in ValidatingTransformsConfiguration)
                {
                    ValidatingTransform ValidatingTransform = new ValidatingTransform(ValidatingTransformConfiguration);
                    Add(ValidatingTransform);
                }
            }
        }


        private Dictionary<String, ValidatingTransform> NameToValidatingTransform = new Dictionary<String, ValidatingTransform>();

        private String CompositeKey(String source, String target)
        {
            String Key = String.Empty;

            if (!String.IsNullOrEmpty(source)) Key = Key + source;
            Key = Key + ',';
            if (!String.IsNullOrEmpty(target)) Key = Key + target;

            return Key;
        }

        private String CompositeKey(Uri source, Uri target)
        {
            String Source = (source == null) ? null : source.OriginalString;
            String Target = (target == null) ? null : target.OriginalString;

            return CompositeKey(Source, Target);
        }


        public ValidatingTransform this[String name]
        {
            get
            {
                return NameToValidatingTransform[name];
            }
        }


        public void Add(ValidatingTransform validatingTransform)
        {
            if (validatingTransform == null) throw new ArgumentNullException("validatingTransform");
             NameToValidatingTransform.Add(validatingTransform.Name, validatingTransform);
        }


        public Boolean ContainsKey(String name)
        {
            return NameToValidatingTransform.ContainsKey(name);
        }

        public IEnumerator<ValidatingTransform> GetEnumerator()
        {
            return NameToValidatingTransform.Values.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
}