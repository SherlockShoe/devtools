// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// This class is merely a duplicate of the InspectorSerializationDelegate inside the `assets/scripts/inspector_polyfill_script.dart`.
/// This delegate is used for testing Widget Diagnostics Node so that we don't have to create manual JSON each time we want to create new test cases.
/// TODO(adalberht): Ask Jacob on what's the better solution on code reuse between the Layout Explorer polyfillscripts and the code inside test package?
class LayoutExplorerSerializationDelegate
    extends InspectorSerializationDelegate {
  LayoutExplorerSerializationDelegate({
    String groupName = '',
    int subtreeDepth = 1,
    @required WidgetInspectorService service,
  }) : super(
          groupName: groupName,
          subtreeDepth: subtreeDepth,
          service: service,
          summaryTree: true,
          addAdditionalPropertiesCallback: (node, delegate) {
            final Map<String, Object> additionalJson = <String, Object>{};
            final Object value = node.value;
            if (value is Element) {
              final renderObject = value.renderObject;
              additionalJson['renderObject'] =
                  renderObject.toDiagnosticsNode()?.toJsonMap(
                        delegate.copyWith(
                          subtreeDepth: 0,
                          includeProperties: true,
                        ),
                      );
              // ignore: invalid_use_of_protected_member
              final Constraints constraints = renderObject.constraints;
              if (constraints != null) {
                final Map<String, Object> constraintsProperty =
                    <String, Object>{
                  'type': constraints.runtimeType.toString(),
                  'description': constraints.toString(),
                };
                if (constraints is BoxConstraints) {
                  constraintsProperty.addAll(<String, Object>{
                    'minWidth': constraints.minWidth.toString(),
                    'minHeight': constraints.minHeight.toString(),
                    'maxWidth': constraints.maxWidth.toString(),
                    'maxHeight': constraints.maxHeight.toString(),
                  });
                }
                additionalJson['constraints'] = constraintsProperty;
              }
              if (renderObject is RenderBox) {
                additionalJson['size'] = <String, Object>{
                  'width': renderObject.size.width.toString(),
                  'height': renderObject.size.height.toString(),
                };

                final ParentData parentData = renderObject.parentData;
                if (parentData is FlexParentData) {
                  additionalJson['flexFactor'] = parentData.flex;
                  additionalJson['flexFit'] =
                      describeEnum(parentData.fit ?? FlexFit.tight);
                }
              }
            }
            return additionalJson;
          },
        );
}
