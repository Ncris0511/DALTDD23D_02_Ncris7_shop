import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Cần import để logout
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/admin_service.dart';
import '../auth/login_screen.dart'; // Import màn hình đăng nhập
import 'admin_order_detail_screen.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';

  // Biến thống kê
  double _totalRevenue = 0;
  int _pendingCount = 0;
  int _shippingCount = 0;

  final List<Map<String, String>> _filters = [
    {'key': 'all', 'label': 'Tất cả'},
    {'key': 'pending', 'label': 'Chờ xử lý'},
    {'key': 'shipping', 'label': 'Đang giao'},
    {'key': 'delivered', 'label': 'Hoàn thành'},
    {'key': 'cancelled', 'label': 'Đã hủy'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() async {
    setState(() => _isLoading = true);

    // 1. Lấy danh sách theo bộ lọc hiện tại
    final data = await _adminService.getAllOrders(
      status: _selectedStatus == 'all' ? null : _selectedStatus,
    );

    // 2. Tính toán thống kê (Tính trên toàn bộ dữ liệu nếu cần, ở đây tính tạm trên list tải về)
    // Lưu ý: Để thống kê chính xác tuyệt đối, nên có API riêng.
    // Ở đây mình tính sơ bộ dựa trên dữ liệu tải về để hiển thị cho đẹp.
    double tempRevenue = 0;
    int tempPending = 0;
    int tempShipping = 0;

    // Gọi thêm 1 lần lấy tất cả để tính thống kê tổng quan (nếu đang ở tab lọc)
    List<dynamic> allOrdersForStats = data;
    if (_selectedStatus != 'all') {
      allOrdersForStats = await _adminService.getAllOrders(status: null);
    }

    for (var order in allOrdersForStats) {
      if (order['status'] == 'delivered' || order['payment_status'] == 'paid') {
        tempRevenue += (order['final_amount'] ?? 0);
      }
      if (order['status'] == 'pending') tempPending++;
      if (order['status'] == 'shipping') tempShipping++;
    }

    if (mounted) {
      setState(() {
        _orders = data;
        _totalRevenue = tempRevenue;
        _pendingCount = tempPending;
        _shippingCount = tempShipping;
        _isLoading = false;
      });
    }
  }

  //CHỨC NĂNG ĐĂNG XUẤT
  void _handleLogout() async {
    // Hiện dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc muốn thoát tài khoản Admin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Xóa dữ liệu và về trang Login
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onFilterChanged(String status) {
    if (_selectedStatus == status) return;
    setState(() {
      _selectedStatus = status;
    });
    _fetchOrders();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      // APP BAR VỚI NÚT LOGOUT
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin Dashboard", style: AppStyles.h2.copyWith(fontSize: 18)),
            Text(
              "Quản lý cửa hàng",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: "Đăng xuất",
          ),
        ],
      ),
      body: Column(
        children: [
          //PHẦN DASHBOARD THỐNG KÊ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Thẻ doanh thu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tổng doanh thu (Hoàn thành)",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currency.format(_totalRevenue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 2 Thẻ nhỏ thống kê đơn
                Row(
                  children: [
                    _buildStatCard(
                      "Chờ xử lý",
                      "$_pendingCount",
                      Colors.orange,
                      Icons.hourglass_empty,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      "Đang giao",
                      "$_shippingCount",
                      Colors.blue,
                      Icons.local_shipping,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- BỘ LỌC ---
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                bool isSelected = _selectedStatus == filter['key'];
                return InkWell(
                  onTap: () => _onFilterChanged(filter['key']!),
                  child: Chip(
                    label: Text(filter['label']!),
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textBody,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: isSelected
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.border),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          //DANH SÁCH ĐƠN HÀNG
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Chưa có đơn hàng nào", style: AppStyles.body),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _fetchOrders(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final user = order['user'] ?? {};

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminOrderDetailScreen(
                                      orderId: order['order_id'],
                                    ),
                                  ),
                                );
                                _fetchOrders();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Đơn #${order['order_id']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              order['status'],
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            _getStatusText(order['status']),
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                order['status'],
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      height: 24,
                                      color: AppColors.backgroundLight,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_circle,
                                          size: 36,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user['full_name'] ?? "Khách lẻ",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                DateFormat(
                                                  'HH:mm - dd/MM/yyyy',
                                                ).format(
                                                  DateTime.parse(
                                                    order['order_date'],
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          currency.format(
                                            order['final_amount'],
                                          ),
                                          style: AppStyles.price.copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget con để vẽ thẻ thống kê
  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 4),
                ],
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
