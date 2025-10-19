import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class GenderDropdown extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final bool showLabel;
  final String? labelText;

  static const List<String> genders = ['Male', 'Female', 'Other'];

  const GenderDropdown({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    this.showLabel = true,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            labelText ?? 'Gender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Platform-specific dropdown
        Platform.isIOS 
            ? _buildCupertinoDropdown(context, theme)
            : _buildMaterialDropdown(context, theme),
      ],
    );
  }

  Widget _buildMaterialDropdown(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: genders.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Row(
                children: [
                  Icon(
                    _getGenderIcon(gender),
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      gender,
                      style: TextStyle(
                        color: theme.colorScheme.tertiary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onGenderChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCupertinoDropdown(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showCupertinoPicker(context, theme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _getGenderIcon(selectedGender),
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedGender,
                style: TextStyle(
                  color: theme.colorScheme.tertiary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              color: theme.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoPicker(BuildContext context, ThemeData theme) {
    int selectedIndex = genders.indexOf(selectedGender);
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Select Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 50,
                  onSelectedItemChanged: (int index) {
                    onGenderChanged(genders[index]);
                  },
                  children: genders.map((String gender) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getGenderIcon(gender),
                            color: theme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            gender,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'Male':
        return Icons.male;
      case 'Female':
        return Icons.female;
      case 'Other':
        return Icons.transgender;
      default:
        return Icons.person;
    }
  }
}
