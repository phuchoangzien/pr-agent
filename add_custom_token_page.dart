import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:timeless_aa/app/common/ui/color/color.dart';
import 'package:timeless_aa/app/common/ui/font/font.dart';
import 'package:timeless_aa/app/common/ui/size/size_extension.dart';
import 'package:timeless_aa/app/layers/ui/component/sheet/chain/chain_picker_button.dart';
import 'package:timeless_aa/core/arch/ui/controller/controller_provider.dart';
import 'package:timeless_aa/app/layers/ui/component/page/add_custom_token/add_custom_token_controller.dart';
import 'package:timeless_aa/app/layers/ui/component/widget/custom_buton/cta_button.dart';
import 'package:timeless_aa/app/layers/ui/component/widget/custom_text_field/custom_text_field.dart';
import 'package:timeless_aa/app/layers/ui/component/widget/header/header_view.dart';

class AddCustomTokenPage extends StatelessWidget
    with ControllerProvider<AddCustomTokenController>, ChainControllerProvider {
  const AddCustomTokenPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _description.marginOnly(
                      bottom: 24.hMin,
                    ),
                    _networkPicker.marginOnly(
                      bottom: 24.hMin,
                      left: 19.wMin,
                    ),
                    _tokenAddressField
                        .marginSymmetric(
                          horizontal: 19.wMin,
                        )
                        .marginOnly(
                          bottom: 27.hMin,
                        ),
                    _tokenSymbolField
                        .marginSymmetric(
                          horizontal: 19.wMin,
                        )
                        .marginOnly(
                          bottom: 27.hMin,
                        ),
                    _tokenDecimalField
                        .marginSymmetric(
                          horizontal: 19.wMin,
                        )
                        .marginOnly(
                          bottom: 27.hMin,
                        ),
                    _tokenIdField.marginSymmetric(
                      horizontal: 19.wMin,
                    ),
                    _addTokenButton
                        .marginOnly(
                          top: 53.hMin,
                        )
                        .marginSymmetric(
                          horizontal: 33.wMin,
                        ),
                  ],
                ).marginOnly(bottom: 10.hMin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _header => const HeaderView(
        title: 'Add Custom Token',
      );

  Widget get _networkPicker {
    return Observer(
      builder: (context) {
        final ctrl = controller(context);
        return ChainPickerButton(
          iconSize: 22,
          fontSize: 14.spMin,
          initialChain: ctrl.selectedChain.value,
          showAllChains: false,
          customChains: chainController.allActiveChains.value,
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.hMin),
          onChainChanged: (chain) {
            if (chain == null) return;
            ctrl.selectedChain.value = chain;
            ctrl.reset();
          },
        );
      },
    );
  }

  Widget get _description => Builder(
        builder: (context) {
          return Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: context.color.containerBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12.rMin,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 19.wMin,
                  child: Text(
                    '􀁞',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.color.warningTextColor,
                      fontSize: 15.spMin,
                      fontFamily: Font.sfProText,
                    ),
                  ),
                ),
                SizedBox(width: 9.wMin),
                SizedBox(
                  width: 260.wMin,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontFamily: Font.sfProText,
                        color: context.color.subTextColor,
                      ),
                      children: <TextSpan>[
                        const TextSpan(text: 'Always '),
                        TextSpan(
                          text: 'DYOR. ',
                          style: TextStyle(
                            fontFamily: Font.sfProText,
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.bold,
                            color: context.color.warningTextColor,
                          ),
                        ),
                        const TextSpan(
                          text:
                              'Make sure you know what you’re doing. Anyone can create a token on a whim, including ',
                        ),
                        TextSpan(
                          text: 'fake ',
                          style: TextStyle(
                            fontFamily: Font.sfProText,
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.bold,
                            color: context.color.warningTextColor,
                          ),
                        ),
                        const TextSpan(text: 'versions of existing tokens'),
                      ],
                    ),
                  ),
                ),
              ],
            ).paddingAll(
              18.rMin,
            ),
          ).marginSymmetric(
            horizontal: 16.wMin,
          );
        },
      );

  Widget get _tokenAddressField => Builder(
        builder: (context) {
          final ctrl = controller(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Token Address',
                style: TextStyle(
                  fontSize: 15.spMin,
                  color: context.color.textColor.withOpacity(0.75),
                ),
              ).marginOnly(bottom: 10.hMin),
              CustomTextField(
                controller: ctrl.tokenAddressTextController,
                backgroundColor: context.color.sheetColor,
                hintText: '0x...',
              ),
              Observer(
                builder: (_) {
                  return !ctrl.isInvalid.value
                      ? const SizedBox()
                      : Text(
                          'Invalid Address',
                          style: TextStyle(
                            color:
                                context.color.errorTextColor.withOpacity(0.6),
                            fontSize: 12.spMin,
                            fontFamily: Font.sfProText,
                          ),
                        ).marginOnly(
                          top: 4.hMin,
                          left: 10.wMin,
                        );
                },
              ),
            ],
          );
        },
      );

  Widget get _tokenSymbolField => Builder(
        builder: (context) {
          final ctrl = controller(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Token Symbol',
                style: TextStyle(
                  fontSize: 15.spMin,
                  color: context.color.textColor.withOpacity(0.75),
                ),
              ).marginOnly(bottom: 10.hMin),
              CustomTextField(
                controller: ctrl.tokenSymbolTextController,
                backgroundColor: context.color.sheetColor,
                hintText: 'ENS',
              ),
            ],
          );
        },
      );

  Widget get _tokenDecimalField => Builder(
        builder: (context) {
          final ctrl = controller(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Token Decimal',
                style: TextStyle(
                  fontSize: 15.spMin,
                  color: context.color.textColor.withOpacity(0.75),
                ),
              ).marginOnly(bottom: 10.hMin),
              CustomTextField(
                controller: ctrl.tokenDecimalTextController,
                backgroundColor: context.color.sheetColor,
                inputType: TextInputType.number,
                hintText: '18',
              ),
            ],
          );
        },
      );

  Widget get _tokenIdField => Builder(
        builder: (context) {
          final ctrl = controller(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CoinGecko ID (Optional)',
                style: TextStyle(
                  fontSize: 15.spMin,
                  color: context.color.textColor.withOpacity(0.75),
                ),
              ).marginOnly(
                bottom: 10.hMin,
              ),
              CustomTextField(
                controller: ctrl.coinGeckoIdTextController,
                backgroundColor: context.color.sheetColor,
                hintText: 'ethereum-name-service',
              ).marginOnly(
                bottom: 4.hMin,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: context.color.textColor.withOpacity(0.6),
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'CoinGecko is used to fetch token quotes. This is an optional field needed to fetch token prices. ID is the last part of the token URL: https://www.coingecko.com/en/coins/',
                    ),
                    TextSpan(
                      text: 'ethereum-name-service',
                      style: TextStyle(
                        color: context.color.warningTextColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ).marginOnly(
                left: 10.wMin,
              ),
            ],
          );
        },
      );

  Widget get _addTokenButton => Builder(
        builder: (context) {
          final ctrl = controller(context);
          return Observer(
            builder: (context) {
              return Opacity(
                opacity:
                    ctrl.enableAddButton.value && !ctrl.loading.value ? 1 : 0.3,
                child: CtaButton(
                  padding: EdgeInsets.zero,
                  style: CtaButtonStyle.flat,
                  onPressed: ctrl.enableAddButton.value && !ctrl.loading.value
                      ? ctrl.addCustomToken
                      : null,
                  child: Builder(
                    builder: (context) {
                      return Container(
                        width: MediaQuery.of(context).size.width - 66.wMin,
                        height: 48.hMin,
                        decoration: BoxDecoration(
                          color: context.color.containerBackground,
                          borderRadius: BorderRadius.circular(21.rMin),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (ctrl.loading.value)
                              const CupertinoActivityIndicator().marginOnly(
                                right: 6.wMin,
                              ),
                            Icon(
                              CupertinoIcons.add,
                              color: context.color.commonGradientColors.last,
                              size: 17.rMin,
                            ),
                            Text(
                              'Add Token',
                              style: TextStyle(
                                fontSize: 17.spMin,
                                color: context.color.commonGradientColors.last,
                                fontFamily: Font.sfProText,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      );
}
