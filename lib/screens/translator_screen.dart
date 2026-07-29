import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/language_provider.dart';
import '../models/app_models.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/translation_widgets.dart';
import '../services/history_service.dart';