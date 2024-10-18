import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';

class BagPage extends StatefulWidget {
  final ProfileManager profileManager;

  const BagPage({
    super.key,
    required this.profileManager,
  });

  @override
  BagPageState createState() => BagPageState();
}

class BagPageState extends State<BagPage> {
  final TextEditingController bagController = TextEditingController();
  final TextEditingController platinController = TextEditingController();
  final TextEditingController goldController = TextEditingController();
  final TextEditingController electrumController = TextEditingController();
  final TextEditingController silverController = TextEditingController();
  final TextEditingController copperController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
  }

  Future<void> _loadCharacterData() async {
    List<Map<String, dynamic>> result =
        await widget.profileManager.getBagItems();

    if (result.isNotEmpty) {
      Map<String, dynamic> characterData = result.first;
      setState(() {
        bagController.text = characterData[Defines.bagBag] ?? '';
        platinController.text =
            (characterData[Defines.bagPlatin] ?? 0).toString();
        goldController.text = (characterData[Defines.bagGold] ?? 0).toString();
        electrumController.text =
            (characterData[Defines.bagElectrum] ?? 0).toString();
        silverController.text =
            (characterData[Defines.bagSilver] ?? 0).toString();
        copperController.text =
            (characterData[Defines.bagCopper] ?? 0).toString();
      });
    }
  }

  void _onFieldChanged(String field, String value) {
    if (field == Defines.bagPlatin ||
        field == Defines.bagGold ||
        field == Defines.bagElectrum ||
        field == Defines.bagSilver ||
        field == Defines.bagCopper) {
      final int? intValue = int.tryParse(value);
      if (intValue != null) {
        widget.profileManager.updateBag(field: field, value: intValue);
      }
    } else {
      widget.profileManager.updateBag(field: field, value: value);
    }
  }

  @override
  void dispose() {
    bagController.dispose();
    platinController.dispose();
    goldController.dispose();
    electrumController.dispose();
    silverController.dispose();
    copperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gegenstände/Ausrüstung'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildIntegerTextField(
                        'PM', platinController, Defines.bagPlatin)),
                const SizedBox(width: 4),
                Expanded(
                    child: _buildIntegerTextField(
                        'GM', goldController, Defines.bagGold)),
                const SizedBox(width: 4),
                Expanded(
                    child: _buildIntegerTextField(
                        'EM', electrumController, Defines.bagElectrum)),
                const SizedBox(width: 4),
                Expanded(
                    child: _buildIntegerTextField(
                        'SM', silverController, Defines.bagSilver)),
                const SizedBox(width: 4),
                Expanded(
                    child: _buildIntegerTextField(
                        'KM', copperController, Defines.bagCopper)),
              ],
            ),
            const SizedBox(height: 16),
            _buildLargeTextField('Tasche', bagController, Defines.bagBag, 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegerTextField(
    String label,
    TextEditingController controller,
    String field,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth * 0.18;

        return TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.center,
          onChanged: (value) => _onFieldChanged(field, value),
        );
      },
    );
  }

  Widget _buildLargeTextField(String label, TextEditingController controller,
      String field, int maxLines) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) => _onFieldChanged(field, value),
    );
  }
}
