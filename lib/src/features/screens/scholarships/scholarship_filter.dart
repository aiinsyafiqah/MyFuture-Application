import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class FilterModal extends StatefulWidget {
  final String currentSpmResult; 
  final String currentType; 
  final Function(String, String) onApply; // Return (SpmResult, Type)

  const FilterModal({
    super.key,
    required this.currentSpmResult,
    required this.currentType,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String _tempSpmResult;
  late String _tempType;

  // --- 1. DATA OPTIONS (MESTI SAMA DENGAN ADMIN PAGE) ---
  
  // Kalau dalam database tulis "Full Scholarship", sini pun kena sama.
  final List<String> _types = [
    "All Types", // Default
    "Full Scholarship",
    "Partial Scholarship",
    "Convertible Loan", // PBU
    "Education Loan",
    "Bursary",
  ];

  // Kalau dalam database tulis "Minimum 9A", sini pun kena sama.
  final List<String> _spmOptions = [
    "All Results", // Default
    "Straight A+ (Semua A+)",
    "Minimum 9A",
    "Minimum 7A",
    "Minimum 5A",
    "Credit in all subjects",
    "Pass all subjects (Lulus Semua)",
    "No Specific Requirement"
  ];

  @override
  void initState() {
    super.initState();
    // Pastikan value yang dihantar wujud dalam list, kalau tak, set default
    _tempSpmResult = _spmOptions.contains(widget.currentSpmResult) 
        ? widget.currentSpmResult 
        : "All Results";
        
    _tempType = _types.contains(widget.currentType) 
        ? widget.currentType 
        : "All Types";
  }

  void _resetFilters() {
    setState(() {
      _tempSpmResult = "All Results";
      _tempType = "All Types";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(width: 50, child: Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 14))),
                ), 
                const Expanded(
                  child: Text("Filter Scholarships", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                GestureDetector(
                  onTap: _resetFilters,
                  child: SizedBox(width: 50, child: Text("Reset", textAlign: TextAlign.end, style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w600))),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- LIST CONTENT ---
          Expanded(
            child: ListView(
              children: [
                // SECTION A: SCHOLARSHIP TYPE
                _buildExpansionSection(
                  title: "Scholarship Type",
                  options: _types,
                  selectedOption: _tempType,
                  onChanged: (val) => setState(() => _tempType = val),
                  isExpanded: true, 
                ),

                const Divider(height: 1),

                // SECTION B: SPM RESULTS
                _buildExpansionSection(
                  title: "SPM Requirement",
                  options: _spmOptions,
                  selectedOption: _tempSpmResult,
                  onChanged: (val) => setState(() => _tempSpmResult = val),
                  isExpanded: true, 
                ),
                const Divider(height: 1),
              ],
            ),
          ),

          // --- BOTTOM BUTTON ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, 
              border: Border(top: BorderSide(color: Colors.grey.shade200))
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Hantar data balik ke page sebelum ini
                    widget.onApply(_tempSpmResult, _tempType);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  child: const Text("Show Results", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required List<String> options,
    required String selectedOption,
    required Function(String) onChanged,
    bool isExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        initiallyExpanded: isExpanded,
        children: options.map((option) {
          final isSelected = selectedOption == option;
          return RadioListTile<String>(
            title: Text(
              option, 
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[700], 
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
              )
            ),
            value: option,
            groupValue: selectedOption,
            activeColor: primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          );
        }).toList(),
      ),
    );
  }
}