// ignore_for_file: non_constant_identifier_names

import 'package:graphql/client.dart';

final USERS = gql(r"""
  query usersPermissionsUsers() {
    usersPermissionsUsers() {
      data{
        id
        attributes {
          username
        }
      }
    }
  }
""");

final LOGIN = gql(r"""
  mutation login($input: UsersPermissionsLoginInput!){
    login (input: $input){
      jwt
      user {
        id
        username
      }
    }
  }
""");

final USER = gql(r"""
  query user($id: ID){
    usersPermissionsUser(id: $id){
      data {
        id
        attributes {
          username
          expire {
            id
            days
            begin
          }
          devices {
            id
            total
            listDevices
          }
        }
      }
    }
  }
""");

final UPDATE_USER = gql(r"""
  mutation updateUser($id: ID!, $data: UsersPermissionsUserInput!){
    updateUsersPermissionsUser(id: $id, data: $data){
      data {
        id
        attributes {
          username
          devices {
            id
            total
            listDevices
          }
        }
      }
    }
  }
""");
