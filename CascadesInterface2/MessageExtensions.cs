using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Messaging;
using System.Xml;
using System.Xml.Linq;
using System.IO;

namespace DataAbstraction.Cascades.Runtime
{
    public static class MessageExtensions
    {
        public static XmlReader CreateReader(this Message message, XmlReaderSettings settings = null)
        {
            message.BodyStream.Seek(0, System.IO.SeekOrigin.Begin);
            XmlReader Reader = XmlReader.Create(message.BodyStream, settings);
            return Reader;
        }

        public static XmlWriter CreateWriter(this Message message, XmlWriterSettings settings = null)
        {
            message.BodyStream = new MemoryStream();
            XmlWriter Writer = XmlWriter.Create(message.BodyStream, settings);
            return Writer;
        }

        public static XmlDocument CreateXmlDocument(this Message message)
        {
            XmlDocument Document = new XmlDocument();
            Document.AppendChild(Document.CreateXmlDeclaration("1.0", "utf-8", null));
            XmlReader Reader = message.CreateReader();
            Reader.MoveToContent();

            Document.AppendChild(Document.ReadNode(Reader));
            Reader.Close();

            message.BodyStream.Seek(0, SeekOrigin.Begin);

            return Document;
        }

        public static XDocument CreateXDocument(this Message message)
        {
            XDocument Document = new XDocument();
            XmlWriter Writer = Document.CreateWriter();

            XmlReader Reader = message.CreateReader();
            Writer.WriteStartDocument();
            Reader.MoveToContent();
            Writer.WriteNode(Reader, true);
            Writer.WriteEndDocument();
            Writer.Flush();
            Writer.Close();
            Reader.Close();

            message.BodyStream.Seek(0, SeekOrigin.Begin);

            return Document;
        }
    }
}
