import 'dart:async';
import 'package:ether_dart/ether_dart.dart';
import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:timeless_aa/core/arch/ui/controller/base_controller.dart';
import 'package:timeless_aa/core/arch/ui/controller/controller_provider.dart';
import 'package:timeless_aa/core/arch/repository/repository_provider.dart';
import 'package:timeless_aa/core/di/injector.dart';
import 'package:timeless_aa/app/layers/data/local/model/custom_token_info.dart';
import 'package:timeless_aa/app/layers/repository/custom_token_manage/custom_token_manage_repository.dart';
import 'package:timeless_aa/core/arch/data/network/api_service_provider.dart';
import 'package:timeless_aa/core/reactive_v2/dynamic_to_obs_data.dart';
import 'package:timeless_aa_api/core/service/model/response/chain.dart';

/// Controller class for adding a custom token.
class AddCustomTokenController extends BaseController
    with
        RepositoryProvider,
        ChainControllerProvider,
        CustomTokenManageControllerProvider,
        ApiServiceProvider,
        ExchangeControllerProvider,
        ChainControllerProvider {
  AddCustomTokenController() {
    _initialize();
  }

  // --- Member Variables ---

  final tokenAddressTextController = TextEditingController();
  final tokenSymbolTextController = TextEditingController();
  final tokenDecimalTextController = TextEditingController();
  final coinGeckoIdTextController = TextEditingController();

  String _icon = '';

  final StreamController<String> _tokenAddressStream = StreamController();
  late StreamSubscription<String> _tokenAddressSubscription;

  // --- Computed Variables ---

  // --- State Variables ---

  final tokenAddress = listenable('');

  final tokenSymbol = listenable('');

  final tokenDecimal = listenable('');

  final coinGeckoId = listenable('');

  final isInvalid = listenable(false);

  final loading = listenable(false);

  late final selectedChain =
      listenable<EvmChain?>(chainController.currentChain.value());

  // --- State Computed ---

  late final enableAddButton = listenableComputed(
    () =>
        tokenAddress.value.isNotEmpty &&
        tokenSymbol.value.isNotEmpty &&
        tokenDecimal.value.isNotEmpty &&
        isInvalid.value == false,
  );

  // --- Repositories ---

  late final _repository = repository<CustomTokenManageRepository>();

  // --- Methods ---

  Future<void> addCustomToken() async {
    loading.value = true;
    final customTokensMap = customTokenManageController.customTokens.value;
    final chainId = selectedChain.value?.chainId;
    if (chainId == null) {
      nav.showSnackBar(message: 'Please select a chain');
      loading.value = false;
      return;
    }
    if ((selectedChain.value?.tokens ?? []).any(
      (element) =>
          element.address?.toLowerCase() ==
          tokenAddressTextController.text.toLowerCase(),
    )) {
      nav.showSnackBar(message: 'Token already exists');
      loading.value = false;
      return;
    }
    final customTokens = CustomTokenInfo(
      id: '$chainId:${tokenSymbolTextController.text.toUpperCase()}',
      symbol: tokenSymbolTextController.text.toUpperCase(),
      name: tokenSymbolTextController.text.toUpperCase(),
      decimalPlace: tokenDecimalTextController.text.isEmpty
          ? 0
          : int.parse(tokenDecimalTextController.text),
      address:
          EthereumAddress.fromHex(tokenAddressTextController.text).hexEip55,
      icon: _icon,
      coinGeckoId: coinGeckoIdTextController.text,
    );
    final customTokensList = customTokensMap?[chainId];
    if (customTokensList == null) {
      customTokensMap?[chainId] = [customTokens];
    } else {
      customTokensList.add(customTokens);
      customTokensMap?[chainId] = customTokensList;
    }
    await _repository.addCustomToken(customTokensMap ?? {});
    await chainController.sync();
    await exchangeController.sync();
    chainController.updateActiveTokensCached(
      tokenId: customTokens.id,
      value: true,
    );
    nav.showSnackBar(message: 'Custom Token Added Successfully');
    await nav.back<void>();
  }

  @override
  FutureOr onDispose() {
    tokenAddressTextController.dispose();
    tokenSymbolTextController.dispose();
    tokenDecimalTextController.dispose();
    coinGeckoIdTextController.dispose();
    _tokenAddressSubscription.cancel();
  }

  Future<void> _initialize() async {
    _tokenAddressSubscription = _tokenAddressStream.stream
        .debounce(const Duration(milliseconds: 500))
        .distinct()
        .listen(_getTokenInfo);
    tokenAddressTextController.addListener(() {
      tokenAddress.value = tokenAddressTextController.text;
      _tokenAddressStream.sink.add(tokenAddressTextController.text);
    });
    tokenSymbolTextController.addListener(() {
      tokenSymbol.value = tokenSymbolTextController.text;
    });
    tokenDecimalTextController.addListener(() {
      tokenDecimal.value = tokenDecimalTextController.text;
    });
    coinGeckoIdTextController.addListener(() {
      coinGeckoId.value = coinGeckoIdTextController.text;
    });
  }

  Future<void> _getTokenInfo(String address) async {
    if (address.isEmpty) {
      isInvalid.value = false;
      return;
    }
    final coingeckoPlatformId = selectedChain.value?.coingeckoPlatformId;
    if (coingeckoPlatformId == null) {
      return;
    }
    try {
      final eAddress = EthereumAddress.fromHex(address).hexEip55;
      final data = await _repository.getTokenInfo(
        network: coingeckoPlatformId.toLowerCase(),
        address: eAddress,
      );
      if (data != null) {
        int? decimal;
        tokenSymbolTextController.text = data.symbol ?? '';
        final detailPlatform =
            data.detailPlatforms?[selectedChain.value?.name.toLowerCase()]
                as Map<String, dynamic>;
        if (detailPlatform['decimal_place'] != null) {
          decimal = detailPlatform['decimal_place'] as int;
        } else {
          decimal = data.detailPlatforms?.values
              .toList()
              .firstOrNull['decimal_place'] as int?;
        }

        tokenDecimalTextController.text =
            decimal != null ? decimal.toString() : '';
        coinGeckoIdTextController.text = data.id ?? '';
        _icon = data.image?.large ?? '';
        isInvalid.value = false;
      } else {
        isInvalid.value = true;
      }
    } catch (e) {
      isInvalid.value = true;
    }
  }

  void reset() {
    tokenAddressTextController.clear();
    tokenSymbolTextController.clear();
    tokenDecimalTextController.clear();
    coinGeckoIdTextController.clear();
    _icon = '';
    tokenAddress.value = '';
    tokenSymbol.value = '';
    tokenDecimal.value = '';
    coinGeckoId.value = '';
    isInvalid.value = false;
    loading.value = false;
  }
}
