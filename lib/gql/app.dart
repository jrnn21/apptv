// ignore_for_file: non_constant_identifier_names

import 'package:graphql/client.dart';

final APP_VERSION = gql(r"""
  query app {
    app{
      data {
        id
        attributes{
          version
          appUrl
        }
      }
    }
  }
""");
