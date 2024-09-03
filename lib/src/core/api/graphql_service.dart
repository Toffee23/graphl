import 'dart:convert';
import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod/riverpod.dart';
import 'package:vmodel/src/core/models/login_model.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/enum/auth_enum.dart';

import 'graphql_confiq.dart';

final graphqlClientProvider = Provider((ref) => GraphQlConfig.instance.client());

@Deprecated("Scheduled for removal")
final authProvider = StateNotifierProvider((ref) => AuthNotifier(ref.watch(graphqlClientProvider)));

@Deprecated("Scheduled for removal. Don't not update this class")
class AuthNotifier extends StateNotifier<AuthResponseModel> {
  AuthNotifier(this._client) : super(AuthResponseModel());

  final GraphQLClient _client;

  Future register(String email, String password1, String username, String password2, String firstName, String lastName) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
          mutation Register(\$email: String!, \$password1: String!, \$password2: String!, \$username: String!, \$lastName: String!, \$firstName: String!) {
            register(email: \$email, password1: \$password1, password2: \$password2, username: \$username, lastName: \$lastName, firstName: \$firstName ) {
              success,
              token,
              errors,
            }
          }
        '''),
        variables: {'email': email, 'password1': password1, 'password2': password2, 'username': username, 'firstName': firstName, 'lastName': lastName},
      ));
      final success = result.data!['register']['success'];
      if (success == true) {
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
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
      final username = result.data!['tokenAuth']['user']['username'];
      final pk = result.data!['tokenAuth']['user']['pk'];

      VConstants.logggedInUser?.token = token;
      state = state.copyWith(status: AuthStatus.authenticated, token: token, pk: pk, username: username);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
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
      final usename = result.data!['tokenAuth']['user']['username'];
      final pk = result.data!['tokenAuth']['user']['pk'];
      state = state.copyWith(status: AuthStatus.authenticated, token: token, pk: pk, username: usename);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
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
      final picture = result.data!['updateUser']['result']['profilePicture']['filename'];
      state = state.copyWith(profilePicture: picture);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
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
      final picture = result.data!['deleteProfilePic']['user']['profilePicture']['filename'];
      state = state.copyWith(profilePicture: picture);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future userUpdate(
      int id, String bio, String height, String username, String firstName, String lastName, String weight, String hair, String eyes, String chest) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql('''
          mutation updateUser(\$id: ID!, \$bio: String, \$username:String, \$height: String, \$weight: String, \$firstName: String, \$lastName: String, \$hair: String, \$eyes:String, \$chest: String) {
  updateUser(input:{
    username: \$username,
    bio: \$bio,
    height: \$height,
    weight: \$weight,
    firstName: \$firstName,
    lastName: \$lastName,
    hair: \$hair,
    eyes: \$eyes,
    chest: \$chest
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
    userType
    isVerified
    weight
    height
    postcode
    gender
    firstName
    lastName
    chest
    hair
    eyes
    }
  }
}
        '''),
        variables: {
          'username': username,
          'id': id,
          'height': height,
          'bio': bio,
          'weight': weight,
          'firstName': firstName,
          'lastName': lastName,
          'hair': hair,
          'eyes': eyes,
          'chest': chest
        },
      ));
      if (result.hasException) {}
      final usename = result.data!['updateUser']['result']['username'];
      final heght = result.data!['updateUser']['result']['height'];
      final bio1 = result.data!['updateUser']['result']['bio'];
      final weght = result.data!['updateUser']['result']['weight'];
      final firstname = result.data!['updateUser']['result']['firstName'];
      final lastname = result.data!['updateUser']['result']['lastName'];
      final hairr = result.data!['updateUser']['result']['hair'];
      final eyess = result.data!['updateUser']['result']['eyes'];
      final chests = result.data!['updateUser']['result']['chest'];
      state = state.copyWith(
          username: usename, bio: bio1, height: heght, firstName: firstname, lastName: lastname, weight: weght, hair: hairr, chest: chests, eyes: eyess);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Stream<dynamic> getUserStream(String username) async* {
    try {
      final result = await _client.query(QueryOptions(
        document: gql('''
            query(\$username: Int!){
  getUser(username:\$username){
    username
    id
    email
    bio
    gender
    userType
    isVerified
    weight
    height
    postcode
    gender
    firstName
    lastName
    chest
    hair
    
    reviewStats{
      noOfReviews
      rating
    }
    eyes
    profilePicture
    location{
      id
      latitude
      longitude
    }
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
        lastName: profile['lastName'],
        firstName: profile['firstName'],
        height: profile['height'],
        bio: profile['bio'],
        profilePicture: profile['profilePicture']['filename'],
      );
      yield result.data!;
    } catch (e) {}
  }

  Future uploadPost(String id, String album, String content, String filename, String caption, String locationInfo) async {
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
        variables: {'content': content, 'id': id, 'filename': filename, 'locationInfo': locationInfo, 'caption': caption, 'album': album},
      ));
      if (result.hasException) {}
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Stream<dynamic> getPosts(String username) async* {
    try {
      final result = await _client.query(QueryOptions(
        document: gql('''
        query getposts{
  posts(where:{user:{username:{exact:"$username"}}}){
    data{
      photos{
        data{
          itemLink
          description
          postSet{
            data{
              postType
            }
          }
        }
      },
      album{
        name
      },
      postType
      id
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
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
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

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
    } else {
      final Map<String, dynamic>? responseData = result.data?['createPost'];
      if (responseData != null && responseData['status'] == 'success') {
      } else {}
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Send mutation to server to logout
      state = state.copyWith(status: AuthStatus.unauthenticated, token: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated, error: e.toString());
    }
  }

  Future resetPassword({
    required String token,
    required String newPassword1,
    required String newPassword2,
  }) async {
    try {
      QueryResult result = await _client.mutate(MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql('''
             mutation{
  passwordReset(token:"$token",newPassword1:"$newPassword1",newPassword2:"$newPassword2"){
    success
    errors
  }
}
              '''), variables: {'token': token, 'newPassword1': newPassword1, 'newPassword2': newPassword2}));
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

  Future updateFcmToken({
    required String fcmToken,
  }) async {
    try {
      QueryResult result = await _client.mutate(MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql('''
             mutation{
             updateFcmToken(fcmToken:"$fcmToken"){
                success
               }
              }
              '''), variables: {
        'fcmToken': fcmToken,
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
      final token = result.data!['sendPasswordResetEmail']['errors']['token'] as String;
      final otp = result.data!['sendPasswordResetEmail']['errors']['otp'];
      state = state.copyWith(status: AuthStatus.authenticated, token: token, otp: otp);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }
}
