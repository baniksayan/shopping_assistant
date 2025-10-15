import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../data/models/product_model.dart';
import '../../../../data/data_sources/local/search_data.dart';
import '../widgets/search_suggestion_item.dart';
import '../widgets/store_result_item.dart';

class SearchView extends StatefulWidget {
  final bool openWithVoice;
  
  const SearchView({super.key, this.openWithVoice = false});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _speechEnabled = false;
  bool _showSuggestions = true;
  bool _showResults = false;
  
  List<ProductModel> _suggestions = [];
  List<StoreProductModel> _offlineResults = [];
  List<StoreProductModel> _onlineResults = [];
  int _offlineDisplayCount = 4;
  
  late AnimationController _micAnimController;
  late Animation<double> _micPulse;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initMicAnimation();
    
    if (widget.openWithVoice) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _startListening();
      });
    }
    
    _searchController.addListener(_onSearchChanged);
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
          _micAnimController.stop();
          _micAnimController.reset();
        }
      },
    );
    setState(() {});
  }

  void _initMicAnimation() {
    _micAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _micPulse = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _micAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = true;
        _showResults = false;
      });
    } else {
      setState(() {
        _suggestions = SearchData.getFilteredSuggestions(query);
        _showSuggestions = true;
        _showResults = false;
      });
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
    });
    
    _micAnimController.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    _micAnimController.stop();
    _micAnimController.reset();
  }

  void _onSuggestionTap(ProductModel product) {
    setState(() {
      _searchController.text = product.name;
      _showSuggestions = false;
      _showResults = true;
      
      final allResults = SearchData.getStoreResults(product.id);
      _offlineResults = allResults.where((r) => !r.isOnline).toList();
      _onlineResults = allResults.where((r) => r.isOnline).toList();
      _offlineDisplayCount = 4;
    });
    
    _searchFocusNode.unfocus();
  }

  void _showMoreOfflineStores() {
    setState(() {
      _offlineDisplayCount = _offlineResults.length;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _micAnimController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),
          
          // Content
          Expanded(
            child: _showResults 
                ? _buildSearchResults(theme)
                : _buildSuggestions(theme),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text('Search Products'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: _isListening 
                      ? 'Listening...' 
                      : 'Search for products...',
                  hintStyle: TextStyle(
                    color: _isListening 
                        ? theme.primaryColor 
                        : theme.colorScheme.tertiary.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.primaryColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Mic Button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedBuilder(
              animation: _micAnimController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _micPulse.value : 1.0,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isListening 
                          ? Colors.red 
                          : theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : theme.primaryColor)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(theme);
    }

    if (_suggestions.isEmpty) {
      return _buildNoResults(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        return SearchSuggestionItem(
          product: _suggestions[index],
          onTap: () => _onSuggestionTap(_suggestions[index]),
          theme: theme,
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.tertiary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Start typing to search',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.tertiary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Or tap the mic button to speak',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.tertiary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.tertiary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.tertiary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.tertiary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best Price Banner
          _buildBestPriceBanner(theme),
          
          const SizedBox(height: 24),
          
          // Offline Stores Section
          _buildSectionHeader(
            'Local Offline Stores',
            _offlineResults.length,
            theme,
          ),
          
          const SizedBox(height: 12),
          
          ...List.generate(
            _offlineDisplayCount < _offlineResults.length 
                ? _offlineDisplayCount 
                : _offlineResults.length,
            (index) => StoreResultItem(
              store: _offlineResults[index],
              theme: theme,
            ),
          ),
          
          if (_offlineResults.length > _offlineDisplayCount)
            _buildShowMoreButton(theme),
          
          const SizedBox(height: 32),
          
          // Online Stores Section
          _buildSectionHeader(
            'Local Online Stores',
            _onlineResults.length,
            theme,
          ),
          
          const SizedBox(height: 12),
          
          ...List.generate(
            _onlineResults.length,
            (index) => StoreResultItem(
              store: _onlineResults[index],
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestPriceBanner(ThemeData theme) {
    final allResults = [..._offlineResults, ..._onlineResults];
    if (allResults.isEmpty) return const SizedBox.shrink();
    
    allResults.sort((a, b) => a.price.compareTo(b.price));
    final cheapest = allResults.first;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Best Price Found!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cheapest.price.toStringAsFixed(0)} at ${cheapest.storeName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShowMoreButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: TextButton.icon(
          onPressed: _showMoreOfflineStores,
          icon: Icon(Icons.expand_more, color: theme.primaryColor),
          label: Text(
            'Show More (${_offlineResults.length - _offlineDisplayCount} more)',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
