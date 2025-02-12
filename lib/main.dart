import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'friend.dart';
import 'friend_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FriendAdapter());
  await Hive.openBox<Friend>('friendsBox');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Friends with Wishes',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: FriendsPage(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class FriendsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  FriendsPage({required this.toggleTheme, required this.isDarkMode});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late Box<Friend> friendsBox;

  @override
  void initState() {
    super.initState();
    friendsBox = Hive.box<Friend>('friendsBox');
  }

  void addFriend(String name, String image, String wish) {
    final newFriend = Friend(name: name, image: image, wish: wish);
    friendsBox.add(newFriend);
    setState(() {});
  }

  void editFriend(int index, String name, String image, String wish) {
    final updatedFriend = Friend(name: name, image: image, wish: wish);
    friendsBox.putAt(index, updatedFriend);
    setState(() {});
  }

  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Friend'),
          content: const Text('Are you sure you want to delete this friend?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                friendsBox.deleteAt(index);
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Friend deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index, Friend friend) {
    TextEditingController nameController =
        TextEditingController(text: friend.name);
    TextEditingController wishController =
        TextEditingController(text: friend.wish);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Friend"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Friend's Name"),
              ),
              TextField(
                controller: wishController,
                decoration: const InputDecoration(labelText: "Wish"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                editFriend(index, nameController.text, friend.image,
                    wishController.text);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends with Wishes'),
        backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.teal[600],
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
              color: widget.isDarkMode ? Colors.yellow : Colors.white,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.grey[850] : Colors.teal[600]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/e.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bez@wit',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            const ListTile(title: Text('Friends'), onTap: null),
            const ListTile(title: Text('Settings'), onTap: null),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: friendsBox.listenable(),
        builder: (context, Box<Friend> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No friends added yet."));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final friend = box.getAt(index) as Friend;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: widget.isDarkMode ? Colors.grey[850] : Colors.teal[100],
                elevation: 5,
                shadowColor: Colors.tealAccent,
                child: ListTile(
                  leading: ClipOval(
                    child: Image.asset(
                      friend.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 60),
                    ),
                  ),
                  title: Text(
                    friend.name,
                    style: TextStyle(
                        fontSize: 18,
                        color: widget.isDarkMode ? Colors.white : Colors.teal[800]),
                  ),
                  subtitle: Text(
                    friend.wish,
                    style: TextStyle(
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'Delete') {
                        _showDeleteDialog(context, index);
                      } else if (value == 'Edit') {
                        _showEditDialog(context, index, friend);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController nameController = TextEditingController();
          TextEditingController wishController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add New Friend"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Friend's Name"),
                    ),
                    TextField(
                      controller: wishController,
                      decoration: const InputDecoration(labelText: "Wish"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      addFriend(nameController.text, "assets/a.jpg", wishController.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.teal[600],
        child: const Icon(Icons.add),
      ),
    );
  }
}
