import 'package:github/github.dart';
import 'dart:io';
import 'package:args/args.dart';

RegExp githubUserRegExp = RegExp(r'^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){0,38}$');

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption('public', abbr: 'p');
  var results = parser.parse(args);

  if (githubUserRegExp.hasMatch(results['public'])) {
    getPublicRepos(results['public']);
  } else {
    stdout.writeln('This is not a GitHub username. Please try again.');
  }
}

Future<void> getPublicRepos(String user) async {
  var github = GitHub();

  await github.repositories.listUserRepositories(user).toList().then((repos) {
    repos.forEach((repo) {
      var repoUrl = repo.toString().split('Repository: ')[1];
      stdout.writeln(repo.toString() + ' | URI: https://github.com/'+repoUrl);
    });
  });
}