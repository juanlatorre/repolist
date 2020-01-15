import 'package:github/github.dart';
import 'dart:io';
import 'package:args/args.dart';
import 'package:colorize/colorize.dart';

GitHub github = GitHub();

void main(List<String> args) {
  try {
    var parser = ArgParser();
    parser.addOption('public', abbr: 'p');
    var results = parser.parse(args);

    print(github.auth.username);

    if (results['public'] != null) {
      if (isGithubUsernameValid(results['public'])) {
        getPublicRepos(results['public']);
      } else {
        var colorizedInvalidUsername = Colorize('This is not a GitHub username. Please try again.');
        colorizedInvalidUsername.red();
        stdout.writeln(colorizedInvalidUsername);
      }
    } else {
      if (!github.auth.isBasic) {
        // asks the user login/password
        var username, password;
        do {
          stdout.write('Please provide your GitHub username: ');
          username = stdin.readLineSync();
        } while (!isGithubUsernameValid(username));

        stdin.echoMode = false; // hide stdin text for password input

        do {
          stdout.writeln('Please provide your GitHub password (Does not show up): ');
          password = stdin.readLineSync();
        } while (password == '' || password == null);
        
        var colorizedLoading = Colorize('Now attempting to login...');
        colorizedLoading.lightCyan();
        stdout.writeln(colorizedLoading);

        loginWithUserAndPassword(username, password).then((res) {
          if (res[1]) {
            var colorizedSuccessfulLoginMessage = Colorize('Login successful :D');
            colorizedSuccessfulLoginMessage.green();
            stdout.writeln(colorizedSuccessfulLoginMessage);
            getPrivateRepos(res[0]);
          } else {
            var colorizedErrorMessageOnLogin = Colorize('There was an error on Login, please try again...');
            colorizedErrorMessageOnLogin.red();
            stdout.writeln(colorizedErrorMessageOnLogin);
            exit(0);
          }
        });
      } else {
        // search and shows the repo list
        stdout.writeln('show repo list');
      }
    }
  } on FormatException {
    var colorizedFormatException = Colorize('Please provide a username.');
    colorizedFormatException.red();
    stdout.writeln(colorizedFormatException);
  }
}

bool isGithubUsernameValid(String user) {
  var githubUserRegExp = RegExp(r'^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){0,38}$');
  if (!githubUserRegExp.hasMatch(user)) {
    return false;
  }

  return true;
}

Future<List<dynamic>> loginWithUserAndPassword(String user, String password) async {
  // login
  var githubWithAuth = GitHub(auth: Authentication.basic(user, password));

  // check if login was successful by sending some write request
  final isSuccessful = await githubWithAuth.users.getCurrentUser().then((_) {
    return [githubWithAuth, true];
  }).catchError((e) {
    return [githubWithAuth, false];
  });

  return isSuccessful;
}

Future<void> getPublicRepos(String user) async {
  await github.repositories.listUserRepositories(user).toList().then((repos) {
    repos.forEach((repo) {
      var repoName = repo.toString().split('Repository: ')[1];

      var colorizedRepoName = Colorize(repoName);
      colorizedRepoName.lightYellow();

      var colorizedUrl = Colorize('https://github.com/' + repoName);
      colorizedUrl.lightMagenta();

      stdout.writeln('Repository: ${colorizedRepoName} | URI: ${colorizedUrl}');
    });
  });

  exit(0);
}

Future<void> getPrivateRepos(GitHub ghAuth) async {
  await ghAuth.repositories.listRepositories().toList().then((repos) {
    repos.forEach((repo) {
      var repoName = repo.toString().split('Repository: ')[1];

      var colorizedRepoName = Colorize(repoName);
      colorizedRepoName.lightYellow();

      var colorizedUrl = Colorize('https://github.com/' + repoName);
      colorizedUrl.lightMagenta();

      stdout.writeln('Repository: ${colorizedRepoName} | URI: ${colorizedUrl}');
    });
  });

  exit(0);
}

// Future<bool> isUserLoggedInGithub() async {
  
// }