// ignore_for_file: non_constant_identifier_names

import 'package:graphql/client.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';

final DEV_MODE = gql(r"""
  query dev(){
    dev(){
      data {
        id
        attributes {
          AndroidMode
          IOSMode
        }
      }
    }
  }
""");
