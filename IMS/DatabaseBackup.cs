using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using IMSBusinessService;
using System.IO;
using System.IO.Compression;

namespace IMS
{
    public partial class DatabaseBackup : Form
    {
        private readonly BSDBService _dbServices = new BSDBService();
        public DatabaseBackup()
        {
            InitializeComponent();
        }
      
        
        private static void Compress(FileInfo fi)
        {
            // Get the stream of the source file.
            using (FileStream inFile = fi.OpenRead())
            {
                // Prevent compressing hidden and already compressed files.
                if ((File.GetAttributes(fi.FullName) & FileAttributes.Hidden)
                        != FileAttributes.Hidden & fi.Extension != ".gz")
                {
                    // Create the compressed file.
                    using (FileStream outFile = File.Create(fi.FullName + ".gz"))
                    {
                        using (GZipStream Compress = new GZipStream(outFile,
                                CompressionMode.Compress))
                        {
                            // Copy the source file into the compression stream.
                            byte[] buffer = new byte[4096];
                            int numRead;
                            while ((numRead = inFile.Read(buffer, 0, buffer.Length)) != 0)
                            {
                                Compress.Write(buffer, 0, numRead);
                            }
                            Console.WriteLine("Compressed {0} from {1} to {2} bytes.",
                                fi.Name, fi.Length.ToString(), outFile.Length.ToString());
                        }
                    }
                }
            }
        }

        private void DatabaseBackup_Load(object sender, EventArgs e)
        {
            string DbName = _dbServices.GetCurrentDatabaseName();
            if (saveDb == null) return;
            saveDb.InitialDirectory = Environment.CurrentDirectory;
            saveDb.Filter = "bak files (*.bak)|*.bak";
            saveDb.FilterIndex = 2;

            saveDb.FileName = "IMSDATABKP_" + DbName + "_" + string.Format("{0:dd_MM_yyyy}", DateTime.Today);
            saveDb.ShowDialog();
        }

        private void saveDb_FileOk(object sender, CancelEventArgs e)
        {
            string dbname = _dbServices.GetCurrentDatabaseName();
            string fullpath = Path.GetFullPath(saveDb.FileName);

            if (_dbServices.CreateDBBackUp(fullpath, dbname) != 0)
            {
                MessageBox.Show("Database Backup is created successfully", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);

            }
            else
            {
                MessageBox.Show("Error while creating backup", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            this.BeginInvoke(new MethodInvoker(Close));
        }
    }
}
