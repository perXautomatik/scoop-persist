using System;
using System.Collections.Generic;
using System.IO;
//using System.Data.Entity;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
//using Microsoft.EntityFrameworkCore;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
//using System.Windows.Shapes;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore.Sqlite;

using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Data.Sqlite;

namespace WpfApp
{
    public partial class MainWindow : Window
    {
        // Create a connection to the SQLite database
        private SqliteConnection connection = new SqliteConnection("Data Source=files.db");

        public MainWindow()
        {
            InitializeComponent();

        }
    }
}