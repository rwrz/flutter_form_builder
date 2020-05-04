import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

enum ColorPickerType { ColorPicker, MaterialPicker, BlockPicker }

class FormBuilderColorPickerField extends FormBuilderField<Color> {
  FormBuilderColorPickerField({
    Key key,
    @required String attribute,
    Color initialValue,
    List<FormFieldValidator> validators = const [],
    bool enabled = true,
    bool autovalidate = false,
    ValueTransformer valueTransformer,
    ValueChanged onChanged,
    FormFieldSetter<Color> onSaved,
    //
    this.controller,
    this.focusNode,
    this.readOnly = false,
    this.colorPickerType = ColorPickerType.ColorPicker,
    InputDecoration decoration = const InputDecoration(),
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextAlign textAlign = TextAlign.start,
    TextInputType keyboardType,
    TextInputAction textInputAction,
    TextStyle style,
    StrutStyle strutStyle,
    TextDirection textDirection,
    bool autofocus = false,
    bool obscureText = false,
    bool autocorrect = true,
    bool maxLengthEnforced = true,
    int maxLines = 1,
    bool expands = false,
    bool showCursor,
    int minLines,
    int maxLength,
    VoidCallback onEditingComplete,
    ValueChanged<String> onFieldSubmitted,
    // FormFieldValidator<String> validator,
    List<TextInputFormatter> inputFormatters,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder buildCounter,
  }) : super(
          key: key,
          initialValue: initialValue,
          attribute: attribute,
          validators: validators,
          enabled: enabled,
          autovalidate: autovalidate,
          valueTransformer: valueTransformer,
          onChanged: onChanged,
          readOnly: readOnly,
          onSaved: onSaved,
          builder: (field) {
            final _FormBuilderColorPickerFieldState state = field;
            return TextField(
              style: style,
              decoration: decoration.copyWith(
                errorText: state.errorText,
                suffixIcon: LayoutBuilder(builder: (context, constraints) {
                  // print("Layout Builder ${state.value}");
                  return Container(
                    height: constraints.minHeight,
                    width: constraints.minHeight,
                    decoration: BoxDecoration(
                      color: state.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
              ),
              enabled: enabled,
              readOnly: state.readOnly,
              controller: state.effectiveController,
              focusNode: state.effectiveFocusNode,
              textAlign: textAlign,
              autofocus: autofocus,
              expands: expands,
              scrollPadding: scrollPadding,
              autocorrect: autocorrect,
              textCapitalization: textCapitalization,
              keyboardType: keyboardType,
              obscureText: obscureText,
              buildCounter: buildCounter,
              cursorColor: cursorColor,
              cursorRadius: cursorRadius,
              cursorWidth: cursorWidth,
              enableInteractiveSelection: enableInteractiveSelection,
              inputFormatters: inputFormatters,
              keyboardAppearance: keyboardAppearance,
              maxLength: maxLength,
              maxLengthEnforced: maxLengthEnforced,
              maxLines: maxLines,
              minLines: minLines,
              onEditingComplete: onEditingComplete,
              // onFieldSubmitted: onFieldSubmitted,
              showCursor: showCursor,
              strutStyle: strutStyle,
              textDirection: textDirection,
              textInputAction: textInputAction,
            );
          },
        );
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool readOnly;
  final ColorPickerType colorPickerType;

  @override
  _FormBuilderColorPickerFieldState createState() =>
      _FormBuilderColorPickerFieldState();
}

class _FormBuilderColorPickerFieldState extends FormBuilderFieldState<Color> {
  FormBuilderColorPickerField get widget => super.widget;

  FocusNode _effectiveFocusNode;
  TextEditingController _effectiveController;

  TextEditingController get effectiveController =>
      _effectiveController;

  FocusNode get effectiveFocusNode => _effectiveFocusNode;

  String get valueString => value?.toString();

  Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveController =
        widget.controller ?? TextEditingController();
    _effectiveController.text = valueString;
    _effectiveFocusNode.addListener(_handleFocus);
  }

  _handleFocus() async {
    if (effectiveFocusNode.hasFocus && !readOnly) {
      Future.microtask(() => FocusScope.of(context).requestFocus(FocusNode()));
      bool selected = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: null, //const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: _buildColorPicker(),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (selected != null && selected == true) {
        didChange(_selectedColor);
      }
    }
  }

  _buildColorPicker() {
    switch (widget.colorPickerType) {
      case ColorPickerType.ColorPicker:
        return ColorPicker(
          pickerColor: value ?? Colors.transparent,
          onColorChanged: _colorChanged,
          // enableLabel: true,
          colorPickerWidth: 300,
          displayThumbColor: true,
          enableAlpha: true,
          paletteType: PaletteType.hsl,
          pickerAreaHeightPercent: 1.0,
        );
      case ColorPickerType.MaterialPicker:
        return MaterialPicker(
          pickerColor: value ?? Colors.transparent,
          onColorChanged: _colorChanged,
          enableLabel: true, // only on portrait mode
        );
      case ColorPickerType.BlockPicker:
        return BlockPicker(
          pickerColor: value ?? Colors.transparent,
          onColorChanged: _colorChanged,
          /*availableColors: [],
          itemBuilder: ,
          layoutBuilder: ,*/
        );
      default:
        throw "Unknown ColorPickerType";
    }
  }

  _colorChanged(Color color) {
    print("Color Changing...");
    setState(() {
      _selectedColor = color;
    });
  }

  _setTextFieldString(){
    setState(() {
      _effectiveController.text = valueString ?? '';
    });
  }

  @override
  void didChange(Color value) {
    super.didChange(value);
    _setTextFieldString();
  }

  @override
  void reset() {
    super.reset();
    _setTextFieldString();
  }
}