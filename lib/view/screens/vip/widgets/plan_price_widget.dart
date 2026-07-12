import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/view/screens/vip/widgets/plan_price_row.dart';

class PlanPriceWidget extends StatelessWidget {
  const PlanPriceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PlanPriceRow(
            planDuration: 'Monthly',
            price: 4.99,
            badgeName: 'Most Popular',
          ),
        ),
        Gap(AppResponsive.space(15)),
        Expanded(
          child: PlanPriceRow(
            planDuration: 'Yearly',
            price: 29.99,
            discount: 'Save 50%',
          ),
        ),
      ],
    );
  }
}
