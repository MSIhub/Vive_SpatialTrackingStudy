using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Threading;
using System.Diagnostics;
using System.Runtime.InteropServices;


namespace ClientAPI_VC
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Process b2 = Process.Start("F:\\ViveDynTrackTest\\cppWorkspace\\ClientParallel\\bin\\Win32\\Release\\ClientParallel.exe");
            Thread.Sleep(500);
            toolStripStatusLabel1.Text = "Client server of Vive and Comau was run succesfully in parallel and data is stored in \n (CURRENT_DIRECTORY_OF_API)\\dataLogV1\\";
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            string folderName = System.IO.Directory.GetCurrentDirectory();
            string pathString = System.IO.Path.Combine(folderName, "dataLogV1");

            string pathString1 = System.IO.Path.Combine(pathString, "comau");
            string pathString2 = System.IO.Path.Combine(pathString, "hmd");
            string pathString3 = System.IO.Path.Combine(pathString, "controller");
            string pathString4 = System.IO.Path.Combine(pathString, "tracker");

            if (!System.IO.Directory.Exists(pathString))
            {
                System.IO.Directory.CreateDirectory(pathString);
                Console.WriteLine("{0} :dir created", pathString);
            }
            if (!System.IO.Directory.Exists(pathString1))
            {
                System.IO.Directory.CreateDirectory(pathString1);
                Console.WriteLine("{0} :dir created", pathString1);
            }
            if (!System.IO.Directory.Exists(pathString2))
            {
                System.IO.Directory.CreateDirectory(pathString2);
                Console.WriteLine("{0} :dir created", pathString2);
            }
            if (!System.IO.Directory.Exists(pathString3))
            {
                System.IO.Directory.CreateDirectory(pathString3);
                Console.WriteLine("{0} :dir created", pathString3);
            }
            if (!System.IO.Directory.Exists(pathString4))
            {
                System.IO.Directory.CreateDirectory(pathString4);
                Console.WriteLine("{0} :dir created", pathString4);
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Process b2 = Process.Start("F:\\ViveDynTrackTest\\cppWorkspace\\ClientVive\\bin\\Win32\\Release\\ClientVive.exe");
            Thread.Sleep(500);
            toolStripStatusLabel1.Text = "Client server of Vive was run succesfully and data is stored in \n (CURRENT_DIRECTORY_OF_API)\\dataLogV1\\hmd(/controller/tracker)";
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Process b3 = Process.Start("F:\\ViveDynTrackTest\\cppWorkspace\\ClientComau\\bin\\Win32\\Release\\ClientComau.exe");
            Thread.Sleep(500);
            toolStripStatusLabel1.Text = "Client server of COMAU was run succesfully and data is stored in \n (CURRENT_DIRECTORY_OF_API)\\dataLogV1\\comau";
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click_1(object sender, EventArgs e)
        {
            Application.Exit();
        }
    }
}
