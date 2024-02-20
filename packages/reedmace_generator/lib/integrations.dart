import 'package:build/build.dart';
import 'package:reedmace_generator/src/builders/client_builder.dart';
import 'package:reedmace_generator/src/builders/definition_builder.dart';
import 'package:reedmace_generator/src/builders/reactor_builder.dart';

Builder definitionsSubject(BuilderOptions options) => DefinitionBuilder().subjectBuilder;
Builder definitionsDescriptor(BuilderOptions options) => DefinitionBuilder().descriptorBuilder;
Builder reactorBuilder(BuilderOptions options) => ReedmaceReactorBuilder();
PostProcessBuilder clientPostProcessBuilder(BuilderOptions options) => ClientPostProcessBuilder();