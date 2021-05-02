import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../../../utils/node_utils.dart';
import '../../../models/issue.dart';
import '../../../models/severity.dart';
import '../models/obsolete_rule.dart';
import '../rule_utils.dart';

class NoObjectDeclarationRule extends ObsoleteRule {
  static const String ruleId = 'no-object-declaration';

  static const _warningMessage =
      'Avoid Object type declaration in class member';

  NoObjectDeclarationRule({Map<String, Object> config = const {}})
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.style),
          excludes: readExcludes(config),
        );

  @override
  Iterable<Issue> check(ResolvedUnitResult source) {
    final _visitor = _Visitor();

    source.unit?.visitChildren(_visitor);

    return _visitor.members
        .map(
          (member) => createIssue(
            rule: this,
            location: nodeLocation(
              node: member,
              source: source,
              withCommentOrMetadata: true,
            ),
            message: _warningMessage,
          ),
        )
        .toList(growable: false);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final _members = <ClassMember>[];

  Iterable<ClassMember> get members => _members;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    super.visitFieldDeclaration(node);

    if (_hasObjectType(node.fields.type)) {
      _members.add(node);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    if (_hasObjectType(node.returnType)) {
      _members.add(node);
    }
  }

  bool _hasObjectType(TypeAnnotation? type) =>
      type?.type?.isDartCoreObject ??
      (type is TypeName && type.name.name == 'Object');
}