import 'package:flutter/material.dart';
import 'package:mobile/core/base/index.dart';

abstract class BaseEditorScreen<TWidget extends StatefulWidget, TEntity>
    extends BaseScreen<TWidget> {
  TEntity? get entity;
}
