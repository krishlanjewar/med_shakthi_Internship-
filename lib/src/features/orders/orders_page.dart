import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String selectedStatus = "All";

  final List<String> statusList = [
    "All",
    "Pending",
    "Accepted",
    "Packed",
    "Dispatched",
    "Delivered",
    "Cancelled",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by Order ID or Pharmacy",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 🏷 Status Filters
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              itemBuilder: (context, index) {
                final status = statusList[index];
                final isSelected = selectedStatus == status;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedStatus = status;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📦 Orders List
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return _orderCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🧾 Order Card Widget
  Widget _orderCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order #ORD1023",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _statusBadge("Pending"),
              ],
            ),

            const SizedBox(height: 6),

            // Pharmacy Name
            const Text(
              "ABC Medicals",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 6),

            // Order Info
            const Text("₹4,560 • 12 items"),
            const Text(
              "Ordered on: 08 Jan 2026",
              style: TextStyle(color: Colors.grey),
            ),

            const Divider(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to Order Details
                  },
                  child: const Text("View Details"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Accept Order
                  },
                  child: const Text("Accept"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔴🟡🟢 Status Badge
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "Pending":
        color = Colors.orange;
        break;
      case "Delivered":
        color = Colors.green;
        break;
      case "Cancelled":
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
