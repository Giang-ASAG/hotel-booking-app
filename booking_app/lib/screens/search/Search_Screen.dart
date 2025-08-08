import 'package:booking_app/data/apiService/GoongService.dart';
import 'package:booking_app/screens/home/Hotels_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _addressController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _peopleCount = 1;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectCheckInDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: _checkInDate!.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  Widget _buildAddressField() {
    return FutureBuilder<List<String>>(
      future: GoongService.loadLocations(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final locations = snapshot.data!;
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
            return locations.where((option) =>
                option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          fieldViewBuilder: (context, controller, focusNode, _) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            );
          },
          onSelected: (selection) {
            _addressController.text = selection;
          },
        );
      },
    );
  }




  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectCheckInDate,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: _checkInDate != null
                      ? _formatDate(_checkInDate)
                      : 'Nhận phòng',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _checkInDate != null ? _selectCheckOutDate : null,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: _checkOutDate != null
                      ? _formatDate(_checkOutDate)
                      : 'Trả phòng',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Số người',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _peopleCount,
          isExpanded: true,
          items: List.generate(5, (index) => index + 1).map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text('$value người'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _peopleCount = value!;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm khách sạn'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildAddressField(),
            const SizedBox(height: 16),
            _buildDatePickers(),
            const SizedBox(height: 16),
            _buildPeopleDropdown(),
            const SizedBox(height: 24),
            CustomButton(
                text: "Tìm kiếm",
                onPressed: () {
                  GoongService.loadLocations();
                  btnSearch(context);
                })
          ],
        ),
      ),
    );
  }

  Future<void> btnSearch(BuildContext context) async {
    final address = _addressController.text.trim();
    if (address.isEmpty || _checkInDate == null || _checkOutDate == null) {
      showPopup(
        context: context,
        title: "Thông báo",
        content: "Vui lòng nhập điền thông tin còn thiếu",
        type: AlertType.warning,
        onOkPressed: () {
          print("OK được nhấn");
        },
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HotelScreen(
                  address: address,
                  checkinDate: _checkInDate!,
                  checkoutDate: _checkOutDate!,
                  peoplecount: _peopleCount
              )
          )
      );
    }
  }
}
