import 'package:github/github.dart';

Future<void> main() async {
    var github = GitHub();
    // check login



    //var repo = await github.repositories.getRepository(RepositorySlug('juanlatorre', 'repolist'));
    //print(repo);
}

// check login
  // if logged in, go to func
  // if not, ask for login

// func
  // $ repolist / --my-repolist
  // $ repolist -p <username> / --public-repolist 