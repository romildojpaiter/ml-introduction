import 'package:flutter/material.dart';
import 'package:recoface/models/user.dart';
import 'package:recoface/utils/local_db.dart';
import 'package:recoface/utils/utils.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User>? users;

  @override
  void initState() {
    super.initState();
    users = LocalDb.getUsers();
    setState(() {
      users = LocalDb.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    printIfDebug("Quantidade de usuarios cadastrados: ${LocalDb.getUsers().length}");

    printIfDebug("Usuarios cadastrados: ${users!.length}");

    // setState(() {
    //   users = LocalDb.getUsers();
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuários"),
      ),
      body: users!.isNotEmpty
          ? ListView.builder(
              itemCount: users!.length,
              itemBuilder: (context, index) {
                var user = LocalDb.getUsers()[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xff764abc),
                    child: Text("$index"),
                  ),
                  title: Text('${user.name}'),
                  subtitle: Text('${user.array!.first}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      LocalDb.deleteUser(index);
                      printIfDebug(LocalDb.getUsers().length);
                      setState(() {
                        users = LocalDb.getUsers();
                      });
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text("Nenhum usuario encontrado"),
            ),
    );
  }
}
