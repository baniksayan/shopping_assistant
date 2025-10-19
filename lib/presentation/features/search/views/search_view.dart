import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../data/models/product_model.dart';
import '../../../../data/data_sources/local/search_data.dart';
import '../widgets/search_suggestion_item.dart';
import '../widgets/store_result_item.dart';
import '../widgets/trending_category_card.dart';

class SearchView extends StatefulWidget {
  final bool openWithVoice;
  
  const SearchView({super.key, this.openWithVoice = false});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _speechEnabled = false;
  bool _showResults = false;
  
  List<ProductModel> _suggestions = [];
  List<StoreProductModel> _offlineResults = [];
  List<StoreProductModel> _onlineResults = [];
  int _offlineDisplayCount = 4;
  
  late AnimationController _micAnimController;
  late Animation<double> _micPulse;
  late Animation<Color?> _micColor;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initAnimations();
    
    if (widget.openWithVoice) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _startListening();
      });
    } else {
      // Auto-focus search field when opening normally
      Future.delayed(const Duration(milliseconds: 300), () {
        _searchFocusNode.requestFocus();
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

  void _initAnimations() {
    _micAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _micPulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _micAnimController,
        curve: Curves.easeInOut,
      ),
    );

    _micColor = ColorTween(
      begin: Colors.red,
      end: Colors.red[700],
    ).animate(_micAnimController);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showResults = false;
      });
    } else {
      setState(() {
        _suggestions = SearchData.getFilteredSuggestions(query);
        _showResults = false;
      });
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      _showSnackBar('Speech recognition not available', isError: true);
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
      _showResults = true;
      
      final allResults = SearchData.getStoreResults(product.id);
      _offlineResults = allResults.where((r) => !r.isOnline).toList();
      _onlineResults = allResults.where((r) => r.isOnline).toList();
      _offlineDisplayCount = 4;
    });
    
    _searchFocusNode.unfocus();
  }

  void _onTrendingCategoryTap(String query) {
    _searchController.text = query;
    _onSearchChanged();
  }

  void _showMoreOfflineStores() {
    setState(() {
      _offlineDisplayCount = _offlineResults.length;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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
      body: SafeArea(
        child: Column(
          children: [
            // Animated Search Bar (Hero)
            _buildHeroSearchBar(theme),
            
            // Content
            Expanded(
              child: _showResults 
                  ? _buildSearchResults(theme)
                  : _buildSearchSuggestions(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSearchBar(ThemeData theme) {
    return Hero(
      tag: 'searchBar',
      child: Material(
        color: Colors.white,
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back Button
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              
              const SizedBox(width: 12),
              
              // Search Field
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isListening 
                          ? Colors.red.withOpacity(0.5)
                          : theme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: !widget.openWithVoice,
                    decoration: InputDecoration(
                      hintText: _isListening 
                          ? 'Listening...' 
                          : 'Search products, stores...',
                      hintStyle: TextStyle(
                        color: _isListening 
                            ? Colors.red 
                            : theme.colorScheme.tertiary.withOpacity(0.5),
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.primaryColor,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: theme.colorScheme.tertiary.withOpacity(0.6),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchFocusNode.requestFocus();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isListening 
                              ? _micColor.value 
                              : theme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening 
                                  ? Colors.red 
                                  : theme.primaryColor).withOpacity(0.3),
                              blurRadius: _isListening ? 12 : 8,
                              spreadRadius: _isListening ? 3 : 2,
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
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // Suggestions List
        if (_suggestions.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return SearchSuggestionItem(
                    product: _suggestions[index],
                    onTap: () => _onSuggestionTap(_suggestions[index]),
                    theme: theme,
                  );
                },
                childCount: _suggestions.length,
              ),
            ),
          )
        else ...[
          // Trending Searches Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trending Searches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Trending Categories
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildListDelegate([
                TrendingCategoryCard(
                  title: 'Electronics Store\nNear You',
                  icon: Icons.store,
                  gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                  onTap: () => _onTrendingCategoryTap('electronics store'),
                ),
                TrendingCategoryCard(
                  title: 'Adidas Shoes\nCompare Price',
                  icon: Icons.shopping_bag,
                  gradient: [const Color(0xFFf093fb), const Color(0xFff5576c)],
                  onTap: () => _onTrendingCategoryTap('adidas shoes'),
                ),
                TrendingCategoryCard(
                  title: 'iPhone 15\nBest Deals',
                  icon: Icons.smartphone,
                  gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
                  onTap: () => _onTrendingCategoryTap('iPhone 15'),
                ),
                TrendingCategoryCard(
                  title: 'Samsung TV\nNearest Shop',
                  icon: Icons.tv,
                  gradient: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
                  onTap: () => _onTrendingCategoryTap('Samsung TV'),
                ),
                TrendingCategoryCard(
                  title: 'Grocery Stores\nAround Me',
                  icon: Icons.local_grocery_store,
                  gradient: [const Color(0xFFfa709a), const Color(0xFFfee140)],
                  onTap: () => _onTrendingCategoryTap('grocery store'),
                ),
                TrendingCategoryCard(
                  title: 'Fashion Outlet\nSale Items',
                  icon: Icons.checkroom,
                  gradient: [const Color(0xFF30cfd0), const Color(0xFF330867)],
                  onTap: () => _onTrendingCategoryTap('fashion outlet'),
                ),
              ]),
            ),
          ),
          
          // Quick Tips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem(
                      '🔍 Type product name to see suggestions',
                      theme,
                    ),
                    _buildTipItem(
                      '🎤 Use voice search for hands-free searching',
                      theme,
                    ),
                    _buildTipItem(
                      '💰 Compare prices across local stores',
                      theme,
                    ),
                    _buildTipItem(
                      '📍 Find nearest stores with best deals',
                      theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTipItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.tertiary.withOpacity(0.8),
          height: 1.4,
        ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
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
              borderRadius: BorderRadius.circular(12),
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
                    color: Colors.white.withOpacity(0.95),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.15),
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
          style: TextButton.styleFrom(
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
