/**
 * This file is deprecated please do not update content
 * of this file.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/models/login_model.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/enum/auth_enum.dart';
import 'package:vmodel/src/features/authentication/register/views/sign_up.dart';

import '../cache/credentials.dart';
import '../cache/local_storage.dart';
import '../utils/enum/ethnicity_enum.dart';
import '../utils/enum/gender_enum.dart';
import '../utils/enum/size_enum.dart';
import 'graphql_confiq.dart';

final graphqlClientProvider =
    Provider((ref) => GraphQlConfig.instance.client());

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthResponseModel>((ref) {
  return AuthNotifier(ref.read(graphqlClientProvider));
});

@Deprecated("Scheduled for removal")
class AuthNotifier extends StateNotifier<AuthResponseModel> {
  AuthNotifier(this._client) : super(AuthResponseModel());

  final GraphQLClient _client;

  Future register(String email, String password1, String username,
      String password2, String firstName, String lastName) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
          mutation Register(\$email: String!, \$password1: String!, \$password2: String!, \$username: String!, \$lastName: String!, \$firstName: String!) {
            register(email: \$email, password1: \$password1, password2: \$password2, username: \$username, lastName: \$lastName, firstName: \$firstName ) {
              success,
              token,
              restToken,
              errors,
            }
          }
        '''),
        variables: {
          'email': email,
          'password1': password1,
          'password2': password2,
          'username': username,
          'firstName': firstName,
          'lastName': lastName
        },
      ));

      final success = result.data!['register']['success'];
      final token = result.data!['register']['token'];
      final restToken = result.data!['register']['restToken'];

      //update and store user token
      GraphQlConfig.instance.updateToken(token);
      final storeToken =
          VModelSharedPrefStorage().putString(VSecureKeys.userTokenKey, token);
      await VCredentials.inst.storeUserCredentials(token);
      //upadate and store restToken
      GraphQlConfig.instance.updateRestToken(restToken);
      globalUsername = username;
      //store username
      final storeUsername =
          VModelSharedPrefStorage().putString(VSecureKeys.username, username);

      Future.wait([storeToken, storeUsername]);
      // We'll need to know more about you

      errorList = result.data!['register']['errors'];
      errorList?.forEach(
        (key, value) {
          if (key != null && value != null) {
            for (Map errorSingle in value) {
              errorSingle.forEach((key, value2) {
                if (key == "message" && value2 != null) {
                  signUpErrorMessage = value2;
                }
              });
            }
          }
        },
      );
      signUpErrorMessage ??= "User name or email already exists";

      if (success == true) {
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
          mutation TokenAuth(\$email: String!, \$password: String!) {
            tokenAuth(email: \$email, password: \$password) {
              success
              token
              errors
              user{
                username
                lastName
                firstName
                isActive
                bio
                id
                pk
               }
            }
          }
        '''),
        variables: {
          'email': email,
          'password': password,
        },
      ));

      final token = result.data!['tokenAuth']['token'] as String;
      // final success = result.data!['tokenAuth']['success'];
      // final error = result.data!['tokenAuth']['errors'];
      final firstName = result.data!['tokenAuth']['user']['firstName'];
      final lastName = result.data!['tokenAuth']['user']['lastName'];
      final username = result.data!['tokenAuth']['user']['username'];
      final pk = result.data!['tokenAuth']['user']['pk'];

      // User userModel = User.fromJson(result.data!);

      globalUsername = username;
      userIDPk = pk;
      VConstants.logggedInUser?.token = token;
      // if(success == )
      state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          firstName: firstName,
          lastName: lastName,
          pk: pk,
          username: username);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> loginUsername(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
          mutation TokenAuth(\$username: String!, \$password: String!) {
            tokenAuth(username: \$username, password: \$password) {
              success
              token
              errors
              user{
                username
                lastName
                firstName
                isActive
                bio
                id
                pk
               }
            }
          }
        '''),
        variables: {
          'username': username,
          'password': password,
        },
      ));
      final token = result.data!['tokenAuth']['token'] as String;
      // final success = result.data!['tokenAuth']['success'];
      // final error = result.data!['tokenAuth']['errors'];
      // final firstName = result.data!['tokenAuth']['user']['firstName'];
      // final lastName = result.data!['tokenAuth']['user']['lastName'];
      final usename = result.data!['tokenAuth']['user']['username'];
      final pk = result.data!['tokenAuth']['user']['pk'];
      // if(success == )
      state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          pk: pk,
          username: usename);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future pictureUpdate(
    int id,
    String content,
    String filename,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
        mutation updateuser(\$id: ID!, \$content: Binary, \$filename: String,){
  updateUser(input:{
    profilePicture:{
      content: \$content,
      filename:\$filename
    }
  },where:{
    id:{
      exact:\$id
    }
  }){
    ok
    errors{
      messages
      field
    }
    result{
    id
    profilePicture{filename, url}
    firstName
    lastName
    username
    }
  }
}
        '''),
        variables: {
          'content': content,
          'id': id,
          'filename': filename,
        },
      ));
      if (result.hasException) {}
      final picture =
          result.data!['updateUser']['result']['profilePicture']['filename'];
      state = state.copyWith(profilePicture: picture);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future heightUpdate(String height) async {
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
       mutation updateHeight(\$id: ID!, \$height: String){
  updateHeight(
    input:{
      value:\$height
    }
    where:{
    user:{
      id:{
        exact:\$id
      }
    }
  }){
    ok
    errors{
      field
      messages
    }
    result{
      id
      value
      unit
    }
  }
} 
        '''),
        variables: {
          'id': state.pk,
          'height': height,
        },
      ));
      if (result.hasException) {}
      String newHeight = result.data!['updateHeight']['result']['value'];
      state = state.copyWith(height: newHeight);
    } catch (e) {
      // state = state.copyWith(
      //     status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future locationNameUpdate(String locationName) async {
    // state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
       mutation updateUserLocation(\$id: ID!, \$locationName: String!){
  updateUserLocation(
    input:{
      locationName:\$locationName
    }
    where:{
    user:{
      id:{
        exact:\$id
      }
    }
  }){
    ok
    errors{
      field
      messages
    }
    result{
      id
      latitude
      longitude
      locationName
    }
  }
} 
        '''),
        variables: {
          'id': state.pk,
          'locationName': locationName,
        },
      ));
      if (result.hasException) {}
      final newLocationName =
          result.data!['updateUserLocation']['result']['locationName'];
      state = state.copyWith(locationName: newLocationName);
    } catch (e) {
      // state = state.copyWith(
      //     status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future deletePicture(
    int id,
    // String content, String filename,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
        mutation deleteProfilePic(\$id: Int!){
  deleteProfilePic(pk:\$id){
    user{
      id
      profilePicture{
        url
        filename
      }
    }
    message
  }
}
        '''),
        variables: {
          'id': id,
        },
      ));
      if (result.hasException) {}
      final picture = result.data!['deleteProfilePic']['user']['profilePicture']
          ['filename'];
      state = state.copyWith(profilePicture: picture);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future userUpdate({
    int? id,
    String? bio,
    String? height,
    String? username,
    String? firstName,
    String? lastName,
    String? hair,
    String? eyes,
    String? phone,
    Gender? gender,
    Ethnicity? ethnicity,
    String? locationName,
    ModelSize? modelSize,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    if (locationName != null && locationName.isNotEmpty) {
      await locationNameUpdate(locationName);
    }
    if (height != null && height.isNotEmpty) {
      await heightUpdate(height);
    }
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
          mutation updateUser(\$id: ID!,
           \$bio: String,
            \$username:String,
               \$firstName: String,
                \$lastName: String,
                 \$hair: String,
                  \$eyes:String,
                    \$gender:UserGenderEnum,
                    \$ethnicity:UserEthnicityEnum,
                    \$modelSize:UserSizeEnum,
                     \$phone: String,
                   ) {
  updateUser(input:{
    username: \$username,
    bio: \$bio,
    firstName: \$firstName,
    lastName: \$lastName,
    hair: \$hair,
    eyes: \$eyes,
    phoneNumber: \$phone,
    gender: \$gender,
    ethnicity: \$ethnicity,
    size: \$modelSize,
  },where:{
    id:{
      exact: \$id
    }
  }){
    ok
    errors{
      messages
      field
    }
    result{
      id
     username
    email
    bio
    gender
    ethnicity
    size
    userType
    isVerified
    height {
      value
    }
    postcode
    firstName
    lastName
    chest {
      value
    }
    location {
      locationName
    }
    hair
    eyes
    phoneNumber
    }
  }
}
        '''),
        // ethnicity
        // locationName
        variables: {
          'username': username ?? state.username,
          'id': id ?? state.pk,
          'bio': bio ?? state.bio,
          'firstName': firstName ?? state.firstName,
          'lastName': lastName ?? state.lastName,
          'hair': hair ?? state.hair,
          'eyes': eyes ?? state.eyes,
          'phone': phone ?? state.phone,
          'gender': gender?.apiValue ?? state.gender?.apiValue,
          'ethnicity': ethnicity?.apiValue ?? state.ethnicity?.apiValue,
          'modelSize': modelSize?.apiValue ?? state.modelSize?.apiValue,
        },
      ));
      if (result.hasException) {}
      final updatedUsername = result.data!['updateUser']['result']['username'];
      final updatedBio1 = result.data!['updateUser']['result']['bio'];
      final updatedFirstname =
          result.data!['updateUser']['result']['firstName'];
      final updatedLastname = result.data!['updateUser']['result']['lastName'];
      final updatedHair = result.data!['updateUser']['result']['hair'];
      final updatedEyes = result.data!['updateUser']['result']['eyes'];
      final updatedPhoneNumber =
          result.data!['updateUser']['result']['phoneNumber'];
      final updatedGender = result.data!['updateUser']['result']['gender'];
      final updatedEthnicity =
          result.data!['updateUser']['result']['ethnicity'];
      final updatedUserSize = result.data!['updateUser']['result']['size'];
      state = state.copyWith(
        username: updatedUsername,
        bio: updatedBio1,
        firstName: updatedFirstname,
        lastName: updatedLastname,
        hair: updatedHair,
        eyes: updatedEyes,
        phone: updatedPhoneNumber,
        gender: Gender.genderByApiValue(updatedGender),
        ethnicity: Ethnicity.ethnicityByApiValue(updatedEthnicity),
        modelSize: ModelSize.modelSizeByApiValue(updatedUserSize),
      );
    } catch (e) {
      // state = state.copyWith(
      //     status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Stream<dynamic> getUser(String username) async* {
    try {
      final result = await _client.query(QueryOptions(
        document: gql('''
            query(\$username: String!){
  getUser(username:\$username){
    username
    id
    email
    bio
    gender
    userType
    isVerified
    height {
      value
      unit
    }
    location{
      locationName
    }
    website
    price
    postcode
    gender
    ethnicity
    size
    firstName
    lastName
    hair
    eyes
    phoneNumber
    profilePicture{filename, url}
    isBusinessAccount
    userType
  }
}
        '''),
        variables: {'username': username},
      ));
      if (result.hasException) {
        throw result.exception!;
      }
      final profile = result.data!['getUser'];
      state = state.copyWith(
        status: AuthStatus.authenticated,
        username: profile['username'],
        email: profile['email'],
        lastName: profile['lastName'],
        firstName: profile['firstName'],
        height: profile['height'] != null ? profile['height']['value'] : "",
        price: profile['price'],
        bio: profile['bio'],
        hair: profile['hair'],
        eyes: profile['eyes'],
        phone: profile['phoneNumber'],
        gender: Gender.genderByApiValue(profile['gender'] ?? ''),
        ethnicity: Ethnicity.ethnicityByApiValue(profile['ethnicity'] ?? ''),
        modelSize: ModelSize.modelSizeByApiValue(profile['size'] ?? ''),
        locationName: profile['location'] != null
            ? profile['location']['locationName']
            : '',
        pk: int.parse(profile['id']),
        isVerified: profile['isVerified'],
        profilePicture: profile['profilePicture'] != null
            ? profile['profilePicture']['filename']
            : '',
        isBusinessAccount: profile['isBusinessAccount'],
        accountType: profile['userType'],
      );
      yield result.data!;
    } catch (e) {}
  }

  Future uploadPost(String id, String album, String content, String filename,
      String caption, String locationInfo) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
        mutation CreatePost(\$id: String, \$album: String!, \$content: Binary, \$filename: String, \$caption: String, \$locationInfo: String, ){
  createPost(input:{
  album:{
      create:{
        name: \$album
        userID:{
          connect:{
            username:{
              exact: \$id
            }
          }
        }
      }
    }
    postType:PICTURE
    photos:{
      create:{
        file:{
          content: \$content,
          filename:\$filename,
        }
      }
    },
    user:{
      connect:{
        username:{
          exact:\$id
        }
      }
    },
    caption:\$caption
    locationInfo: \$locationInfo
  }){
    ok,
    errors{
      messages
      field
    }
    result{
      id
      album {name}
      photos{count, data{file{url, filename, size}}}
      
    }
  }
}
        '''),
        variables: {
          'content': content,
          'id': id,
          'filename': filename,
          'locationInfo': locationInfo,
          'caption': caption,
          'album': album
        },
      ));
      if (result.hasException) {}
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Stream<dynamic> getPosts(String username) async* {
    try {
      final result = await _client.query(QueryOptions(
        document: gql('''
        query getposts{
  userPosts {
    id
    user {
      id
    }
    album {
      id
      name
    }
    photos {
      id
      itemLink
      description
      postSet {
        id
        postType
      }
    }
    
  }
}
        '''),
        variables: {'username': username},
      ));
      if (result.hasException) {
        throw result.exception!;
      }
      // final List profile = result.data!['posts']['data'];
      yield result.data!;
    } catch (e) {}
  }

  Stream getAlbum(String username) async* {
    try {
      final result = await _client.query(QueryOptions(
        document: gql('''
        query chek{
  albums(where:{
    userID:{
      username:{
        exact:"$username"
      }
    }
  }){
    data{
      id
      name
      userID{
        id
      }
    }
  }
}
        '''),
        variables: {'username': username},
      ));
      if (result.hasException) {
        throw result.exception!;
      }
      yield result.data!;
    } catch (e) {}
  }

  Future createAlbum(String name, int id) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
          mutation creatal{
  createAlbum(name:"$name",user: $id){
    message
    album{
      name
      userID{
        id
        username
      }
    }
  }
}
        '''),
        variables: {
          'name': name,
          'user': id,
        },
      ));
      return result.data!;
      // if(success == )
      // state = state.copyWith(status: AuthStatus.authenticated, token: token, pk: pk, username: usename);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> createPost({
    required int album,
    required int user,
    required List<File> files,
    required String caption,
    required int tagged,
    required String locationInfo,
  }) async {
    final List imageFiles = files.map(
      (file) {
        final base = base64Encode(file.readAsBytesSync());
        return base.split('/').last;
      },
    ).toList();

    final MutationOptions options = MutationOptions(
      document: gql('''
      mutation CreatePost(\$album: Int!, \$user: Int!, \$files: Binary!, \$caption: String!, \$tagged: Int!, \$locationInfo: String!) {
        createPost(album: \$album, user: \$user, file: \$files, caption: \$caption, tagged: \$tagged, locationInfo: \$locationInfo) {
          status
          message
          error
        }
      }
    '''),
      variables: <String, dynamic>{
        'album': album,
        'user': user,
        'files': imageFiles,
        'caption': caption,
        'tagged': tagged,
        'locationInfo': locationInfo,
      },
    );

    await _client.mutate(options);
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Send mutation to server to logout
      state = state.copyWith(status: AuthStatus.unauthenticated, token: null);
    } catch (e) {
      state =
          state.copyWith(status: AuthStatus.authenticated, error: e.toString());
    }
  }

  Future resetPassword({
    required String token,
    required String newPassword1,
    required String newPassword2,
  }) async {
    try {
      QueryResult result = await _client.mutate(MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
             mutation{
  passwordReset(token:"$token",newPassword1:"$newPassword1",newPassword2:"$newPassword2"){
    success
    errors
  }
}
              '''),
          variables: {
            'token': token,
            'newPassword1': newPassword1,
            'newPassword2': newPassword2
          }));
      if (result.hasException) {
        result.exception?.graphqlErrors[0];
        throw Exception(result.exception);
      } else {
        return true;
      }
    } catch (error) {
      return false;
    }
  }

  Future<void> resetLink(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(document: gql('''
          mutation SendPasswordResetEmail(\$email: String!) {
            sendPasswordResetEmail(email: \$email) {
              errors
              success
            }
         }
        '''), variables: {'email': email}));
      final token =
          result.data!['sendPasswordResetEmail']['errors']['token'] as String;
      final otp = result.data!['sendPasswordResetEmail']['errors']['otp'];
      state = state.copyWith(
          status: AuthStatus.authenticated, token: token, otp: otp);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future passwordChange({
    required String token,
    required String oldPassword,
    required String newPassword1,
    required String newPassword2,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _client.mutate(MutationOptions(document: gql('''
            mutation passwordChange(\$oldPassword:String!,\$newPassword1:String!,\$newPassword2:String!) {
            passwordChange(oldPassword:\$oldPassword,newPassword1:\$newPassword1,newPassword2:\$newPassword2) {
              success,
              errors,
              token,
            }
          }
          '''), variables: {
        'oldPassword': oldPassword,
        'newPassword1': newPassword1,
        'newPassword2': newPassword2
      }));
      if (result.hasException) {
        // final error = result.exception?.graphqlErrors[0];
        throw Exception(result.exception);
      } else {
        if (result.data!['passwordChange']['success'] == true) {
          state = state.copyWith(status: AuthStatus.authenticated);
        } else {
          state = state.copyWith(
              status: AuthStatus.unauthenticated,
              error: 'Invalid old password');
        }
      }
    } catch (error) {
      // return false;
    }
  }

  Stream<dynamic> getAllPost() async* {
    final result = await vBaseServiceInstance.getQuery(queryDocument: '''

  posts{
    data{
      id
      description
      postType
      audios{
        count
        data{
          id
        }
      }
      videos{
        count
        data{
          id
        }
      }
      photos{
        count
        data{
          id
        }
      }
    }
  }

''', payload: {});

    yield result;
  }
}

class ErrorObject {
  String message;
  ErrorObject(this.message);
}
