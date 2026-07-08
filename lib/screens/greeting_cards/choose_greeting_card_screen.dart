import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/core/constants/message_template_catalog.dart';
import 'package:remind_me/models/contact_model.dart';
import 'package:remind_me/models/greeting_card_editor_args.dart';
import 'package:remind_me/models/greeting_card_model.dart';
import 'package:remind_me/screens/greeting_cards/greeting_card_editor_screen.dart';
import 'package:remind_me/services/greeting_card_service.dart';
import 'package:remind_me/widgets/app_card.dart';

class ChooseGreetingCardScreen extends StatefulWidget {
  const ChooseGreetingCardScreen({
    super.key,
    required this.contact,
    required this.style,
    required this.templateText,
  });

  final ContactModel contact;
  final MessageTemplateOption style;
  final String templateText;

  @override
  State<ChooseGreetingCardScreen> createState() => _ChooseGreetingCardScreenState();
}

class _ChooseGreetingCardScreenState extends State<ChooseGreetingCardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = GreetingCardService.instance;

  late Future<List<GreetingCardModel>> _birthdayCardsFuture;
  late Future<List<GreetingCardModel>> _anniversaryCardsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _birthdayCardsFuture = _service.getCards(MessageTemplateSection.birthday);
    _anniversaryCardsFuture =
        _service.getCards(MessageTemplateSection.anniversary);
    if (widget.style.section == MessageTemplateSection.anniversary) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openEditor(GreetingCardModel card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GreetingCardEditorScreen(
          args: GreetingCardEditorArgs(
            contact: widget.contact,
            card: card,
            style: widget.style,
            templateText: widget.templateText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choose Greeting Card'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Birthday Cards'),
            Tab(text: 'Anniversary Cards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CardsGrid(
            cardsFuture: _birthdayCardsFuture,
            emptyLabel:
                'No birthday cards found in assets/cards/birthday/. Add templates to continue.',
            onTap: _openEditor,
          ),
          _CardsGrid(
            cardsFuture: _anniversaryCardsFuture,
            emptyLabel:
                'No anniversary cards found in assets/cards/anniversary/. Add templates to continue.',
            onTap: _openEditor,
          ),
        ],
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  const _CardsGrid({
    required this.cardsFuture,
    required this.emptyLabel,
    required this.onTap,
  });

  final Future<List<GreetingCardModel>> cardsFuture;
  final String emptyLabel;
  final ValueChanged<GreetingCardModel> onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GreetingCardModel>>(
      future: cardsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final cards = snapshot.data!;
        if (cards.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 44,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      emptyLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1100
                ? 4
                : constraints.maxWidth > 700
                    ? 3
                    : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.72,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () => onTap(card),
                  child: Hero(
                    tag: card.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      child: Image.asset(card.assetPath, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
