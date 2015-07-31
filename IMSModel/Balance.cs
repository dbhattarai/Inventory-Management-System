using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IMSModel
{
    public class Balance
    {
        public int itemId { get; set; }
        public decimal quantity { get; set; }
        public decimal Rate { get; set; }
        public decimal amount { get; set; }
        public int Id { get; set; }
        public DateTime date { get; set; }
        public int grn { get; set; }
        public int isn { get; set; }
        public string transactionId { get; set; }
    }
}
