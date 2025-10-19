import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../core/constants/countries.dart';

class CountryDropdown extends StatelessWidget {
  final String selectedCountry;
  final ValueChanged<String> onCountryChanged;
  final bool showLabel;
  final String? labelText;

  const CountryDropdown({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
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
            labelText ?? 'Select Country',
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
          value: selectedCountry,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: Countries.all.map((Country country) {
            return DropdownMenuItem<String>(
              value: country.name,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      country.flagAsset,
                      width: 28,
                      height: 20,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 28,
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.flag,
                            size: 12,
                            color: theme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      country.name,
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
              onCountryChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCupertinoDropdown(BuildContext context, ThemeData theme) {
    final selectedCountryObj = Countries.getByName(selectedCountry);
    
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
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                selectedCountryObj.flagAsset,
                width: 28,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.flag,
                      size: 12,
                      color: theme.primaryColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCountryObj.name,
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
    int selectedIndex = Countries.all.indexWhere(
      (country) => country.name == selectedCountry,
    );
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
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
                      'Select Country',
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
                    onCountryChanged(Countries.all[index].name);
                  },
                  children: Countries.all.map((Country country) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              country.flagAsset,
                              width: 32,
                              height: 22,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 32,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.flag,
                                    size: 14,
                                    color: theme.primaryColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            country.name,
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
}
