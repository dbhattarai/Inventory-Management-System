using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IMSModel
{
  public class Received
    {
        public DateTime Date { get; set; }
        public int itemId { get; set; }
        public string unit { get; set; }
        public int quantity { get; set; }
        public decimal Rate { get; set; }
        public decimal amount { get; set; }
        public int vendorId { get; set; }
        public int GNR { get; set; }
        public string remarks { get; set; }
        public string receivedby { get; set; }
        public string Id { get; set; }

        public string vendorName { get; set; }
        public string itemName { get; set; }
    }
}
