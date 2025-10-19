import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../data/models/product_model.dart';
import '../../../../data/data_sources/local/search_data.dart';
import '../../../../data/data_sources/local/hive_service.dart';
import '../widgets/search_suggestion_item.dart';
import '../widgets/store_result_item.dart';
import '../widgets/trending_category_card.dart';
import '../widgets/smart_comparison_card.dart';
import '../../../../core/utils/number_formatter.dart';

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
  bool _showQuickTips = true;
  bool _hasSearched = false;
  
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
    _loadSearchHistory();
    _initSpeech();
    _initAnimations();
    
    if (widget.openWithVoice) {
      Future.delayed(const Duration(milliseconds: 400), () {
        _startListening();
      });
    } else {
      // Auto-focus and show keyboard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      });
    }
    
    _searchController.addListener(_onSearchChanged);
  }

  void _loadSearchHistory() {
    setState(() {
      _hasSearched = HiveService.hasSearched();
      _showQuickTips = !_hasSearched;
    });
  }

  Future<void> _markAsSearched() async {
    if (!_hasSearched) {
      await HiveService.markAsSearched();
      setState(() {
        _hasSearched = true;
        _showQuickTips = false;
      });
    }
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _micPulse = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _micAnimController,
        curve: Curves.easeInOut,
      ),
    );

    _micColor = ColorTween(
      begin: Colors.red[600],
      end: Colors.red[800],
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

  void _onSuggestionTap(ProductModel product) async {
    await _markAsSearched();
    await HiveService.saveSearchHistory(product.name, product.id);
    
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
            borderRadius: BorderRadius.circular(12),
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
            _buildHeroSearchBar(theme),
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
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              
              const SizedBox(width: 4),
              
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isListening 
                          ? Colors.red.withOpacity(0.6)
                          : theme.primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(
                          Icons.search,
                          color: theme.primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          autofocus: !widget.openWithVoice,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.tertiary,
                          ),
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
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: theme.colorScheme.tertiary.withOpacity(0.6),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).requestFocus(_searchFocusNode);
                          },
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
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
                          gradient: _isListening
                              ? LinearGradient(
                                  colors: [Colors.red[600]!, Colors.red[800]!],
                                )
                              : LinearGradient(
                                  colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                                ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? Colors.red : theme.primaryColor).withOpacity(0.4),
                              blurRadius: _isListening ? 15 : 10,
                              spreadRadius: _isListening ? 4 : 2,
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
          if (_showQuickTips) 
            _buildQuickTips(theme)
          else 
            _buildSmartComparisons(theme),
          
          _buildTrendingSearches(theme),
        ],
      ],
    );
  }

  Widget _buildQuickTips(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTipItem('🔍 Type product name to see instant suggestions', theme),
              _buildTipItem('🎤 Use voice search for hands-free searching', theme),
              _buildTipItem('💰 Compare prices across local & online stores', theme),
              _buildTipItem('📍 Find nearest stores with best deals', theme),
              _buildTipItem('⚡ Get real-time price alerts & updates', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.tertiary.withOpacity(0.85),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSmartComparisons(ThemeData theme) {
    final lastSearch = HiveService.getLastSearchedProduct();
    
    if (lastSearch == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    
    final stores = SearchData.getStoreResults(lastSearch.productId);
    
    // Sort by best choice
    stores.sort((a, b) {
      double scoreA = (a.rating ?? 0) * 100 - a.price / 100;
      double scoreB = (b.rating ?? 0) * 100 - b.price / 100;
      
      if (!a.isOnline && a.distance != null) {
        final distKm = double.tryParse(a.distance!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 999;
        scoreA += (10 / distKm) * 50;
      }
      
      if (!b.isOnline && b.distance != null) {
        final distKm = double.tryParse(b.distance!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 999;
        scoreB += (10 / distKm) * 50;
      }
      
      return scoreB.compareTo(scoreA);
    });
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Based on Your Last Search',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      // CLICKABLE PRODUCT NAME
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.text = lastSearch.productName;
                            _suggestions = SearchData.getFilteredSuggestions(lastSearch.productName);
                          });
                          FocusScope.of(context).requestFocus(_searchFocusNode);
                        },
                        child: Text(
                          lastSearch.productName,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(
            height: 440,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                String reason = '';
                
                if (index == 0) {
                  if (!store.isOnline) {
                    reason = 'Closest store with best reviews';
                  } else {
                    reason = 'Best price with fast delivery';
                  }
                } else if ((store.rating ?? 0) > 4.5) {
                  reason = 'Highly rated by customers';
                } else if (!store.isOnline) {
                  reason = 'Nearby store - Visit today';
                }
                
                return SmartComparisonCard(
                  store: store,
                  theme: theme,
                  isFirst: index == 0,
                  isBestChoice: index == 0,
                  reason: reason,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSearches(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: theme.primaryColor, size: 24),
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
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                TrendingCategoryCard(
                  title: 'Electronics Store\nNear You',
                  icon: Icons.store,
                  gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                  onTap: () => _onTrendingCategoryTap('electronics store'),
                ),
                TrendingCategoryCard(
                  title: 'Adidas Shoes\nCompare Price',
                  icon: Icons.shopping_bag,
                  gradient: [const Color(0xFFf093fb), const Color(0xFFF5576c)],
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
              ],
            ),
          ),
          
          const SizedBox(height: 20),
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
          _buildBestPriceBanner(theme),
          const SizedBox(height: 24),
          _buildSectionHeader('Local Offline Stores', _offlineResults.length, theme),
          const SizedBox(height: 12),
          ...List.generate(
            _offlineDisplayCount < _offlineResults.length 
                ? _offlineDisplayCount 
                : _offlineResults.length,
            (index) => StoreResultItem(store: _offlineResults[index], theme: theme),
          ),
          if (_offlineResults.length > _offlineDisplayCount)
            _buildShowMoreButton(theme),
          const SizedBox(height: 32),
          _buildSectionHeader('Local Online Stores', _onlineResults.length, theme),
          const SizedBox(height: 12),
          ...List.generate(
            _onlineResults.length,
            (index) => StoreResultItem(store: _onlineResults[index], theme: theme),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 32),
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormatter.formatIndianPrice(cheapest.price)} at ${cheapest.storeName}',
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
              fontSize: 13,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }
}
