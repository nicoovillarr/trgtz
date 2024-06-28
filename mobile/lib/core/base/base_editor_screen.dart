import 'package:flutter/material.dart';
import 'package:trgtz/core/base/index.dart';

abstract class BaseEditorScreen<TWidget extends StatefulWidget, TEntity>
    extends BaseScreen<TWidget> {
  TEntity? entity;
}
